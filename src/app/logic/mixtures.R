# This R6 class encapsulates the data and behavior of the distribution mixture
# that is created on the fly in the app.
# It keeps track of the distributions added, and knows how to generate both
# random values and the pdf for the mixture it contains.
# The mixture is made of components. Each component has info about the
# distribution, the parameter values for the distribution, and the weight that
# distribution is assigned in the mixture.

# 'param_list' is going to be the "input" of our Shiny app
# but it could be any list-like object that can be subsetable by
# object[["name"]]

Mixture <- R6::R6Class(
  "Mixture",
  class = FALSE, # disable S3 dispatch
  cloneable = FALSE, # save some memory
  public = list(
    # A component is a list with a unique id and a list with info about the 
    # distribution it represents.
    components = list(),
    
    # Do nothing at initialization.
    initialize = function() {},
    
    # Add component to the mixture, making sure the id assigned is unique.
    add = function(dist) {
      id <- as.character(self$new_id())
      self$components[[id]] = list(id = id, dist = dist)
      return(id)
    },
    
    # Remove component by ID.
    remove = function(id) {
      self$components[[id]] = NULL
    },
    
    # Generate new unique ID. 
    # They are consecutive numbers from 1 to len(self$components)
    # If the deletion of any component leaves a gap in the sequence, this 
    # function fills that gap.
    new_id = function() {
      ids <- as.numeric(names(self$components))
      ids_seq <- seq(length(self$components))
      if (length(setdiff(ids_seq, ids)) > 0) {
        id <- setdiff(ids_seq, ids)[1]
      } else {
        id <- length(self$components) + 1
      }
      return(id)
    },
    
    # A wrapper to return the number of components in the mixture.
    count = function() {
      length(self$components)
    },
  
    # Return current parameter values for each component 
    get_params = function(param_list) {
     lapply(self$components, function(x) {
        param_names <- paste0("dist_", x$id, "_param_", 1:2)
        lapply(param_names, function(x) param_list[[x]])
      })
    },
    
    # Return a vector with the names of the distributions
    get_dists = function() {
      vapply(self$components, function(x) x$dist, character(1))
    },
    
    # Return a vector with the weights of the distributions
    get_weights = function(param_list) {
      vapply(
        self$components,
        function(x) param_list[[paste0("weight_", x$id)]],
        numeric(1)
      )
    },
    
    # Obtain random values from the mixture
    mixture_rvs = function(param_list, wts, size, reps) {
      .l <- list(self$get_dists(), self$get_params(param_list), round(wts * size))
      .f <- function(x) {
        unlist(purrr::pmap(.l, self$component_rvs), use.names = FALSE)
      }
      replicate(reps, .f(), simplify = FALSE)
    },
    
    # Obtain random values for a single component. Used within `mixture_rvs()`
    component_rvs = function(distribution, params, size) {
      .f <- paste0("r", distribution)
      .args <- c(list(size), params)
      do.call(.f, .args)
    },
    
    # Obtain the pdf for the mixture.
    mixture_pdf = function(param_list, wts) {
      dists <- self$get_dists()
      params <- self$get_params(param_list)

      grid <- self$mixture_grid(dists, params)

      .l <- list(dists, params)
      pdf <- unlist(purrr::pmap(.l, self$component_pdf, grid = grid))
      pdf <- as.vector(matrix(pdf, ncol = length(wts)) %*% wts)

      # In some edge cases pdf is `Inf`
      pdf[is.infinite(pdf)] = NA

      return(list("x" = grid, "pdf" = pdf))
    },
    
    # Obtain the pdf for a component in the mixture.
    component_pdf = function(distribution, params, grid) {
      .f <- paste0("d", distribution)
      .args <- c(list(grid), params)
      do.call(.f, .args)
    },
    
    # Compute a grid over the support of the mixture.
    mixture_grid = function(distributions, params) {
      .l <- list(distributions, params)
      out <- unlist(purrr::pmap(.l, self$pdf_bounds))
      seq(min(out), max(out), length.out = 250)
    },
    
    # Obtain domain bounds for a given pdf and parameter values.
    pdf_bounds = function(distribution, params) {
      .f <- pdf_bounds_list[[distribution]]
      .f(params)
    },
    
    # Return input values (weights and parameter values)
    get_inputs = function() {
      unlist(lapply(self$components, function(x) {
        c(paste0("weight_", x$id), paste0("dist_", x$id, c("_param_1", "_param_2")))
      }), use.names = FALSE)
    }
  )
)

# Some continuous distributions have all the reals are domain, but in the place
# we live we can't plot from -infty to +infty.
# Also, use machine precision to avoid boundary issues 
# (i.e. evaluating at 0 when x must be positive)
pdf_bounds_list <- list(
  "norm" = function(params) {
    width <- 3 * params[[2]]
    c(params[[1]] - width, params[[1]] + width)
  },
  "t" = function(params) {
    qt(c(0.005, 0.995), params[[1]], params[[2]])
  },
  "gamma" = function(params) {
    c(.Machine$double.eps, qgamma(0.995, params[[1]], params[[2]]))
  },
  "beta" = function(params) {
    c(.Machine$double.eps, 1 - .Machine$double.eps)
  },
  "lnorm" = function(params) {
    c(.Machine$double.eps, qlnorm(0.995, params[[1]], params[[2]]))
  },
  "weibull" = function(params) {
    c(.Machine$double.eps, qweibull(0.995, params[[1]], params[[2]]))
  },
  "unif" = function(params) {
    c(params[[1]], params[[2]])
  }
)
