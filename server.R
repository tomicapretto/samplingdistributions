library(markdown)

source("utils.R")
source("server_utils.R")
source("mixtures.R")
source("plots.R")

server = function(input, output, session) {
  
  mixture = Mixture$new()
  
  # Rvs and pdfs are stored here so we automatically updated plots when they
  # change
  store = reactiveValues()
  
  # Prevent from recomputing too often based on changes on the inputs.
  reactive_inputs = shiny::debounce(
    shiny::reactive(
      list(input$size, input$repetitions, input$statistic, input$percentile)
    ),
    millis = 250
  )
  
  # Add new distribution to the mixture.
  observeEvent(input$add, {
    id = mixture$add(input$distribution)
    add_distribution(input$distribution, id)
    
    # The parameters of the components are also debounced.
    reactive_params = shiny::debounce(
      shiny::reactive({
        ids = c(paste0("weight_", id), paste0("dist_", id, c("_param_1", "_param_2")))
        lapply(ids, function(x) input[[x]])
      }),
      millis = 250
    )
    
    # Create observer on the parameters and the inputs.
    observer = observeEvent(
      c(reactive_params(),
        reactive_inputs()), {
      appHandler({
        wts = appHandler(mixture$get_weights(input))
        if (sum(wts) != 1) {
          shiny::showNotification(
            "Weights must add up to 1.",
            duration = NULL,
            type = "error",
            id = "weight_noti"
          )
          req(FALSE)
        } else {
          shiny::removeNotification("weight_noti")
        }
        store$rvs_list = mixture$mixture_rvs(input, wts, input$size, input$repetitions)
        store$pdf = mixture$mixture_pdf(input, wts)
      })
    }, ignoreInit = TRUE)

    observeEvent(input[[paste0("remove_", id)]], {
      removeUI(paste0("#", paste0("div_", id)))
      mixture$remove(id)
      observer$destroy() # observed is destroyed when the component is removed
    }, ignoreInit = TRUE)
  })
  
  # Plot histogram with the sampling distribution of the statistic selected.
  output$plot_rvs = echarts4r::renderEcharts4r({
    req(store$rvs_list)
    fun = switch(
      shiny::isolate(input$statistic),
      "Mean" = mean,
      "Median" = stats::median,
      "Minimum" = min,
      "Maximum" = max,
      "Percentile" = function(x) {
        stats::quantile(x, probs = shiny::isolate(input$percentile) / 100)
      }
    )
    histogram(vapply(store$rvs_list, fun, numeric(1)))
  })
  
  # Plot density of the mixture
  output$plot_pdf = echarts4r::renderEcharts4r({
    req(store$pdf)
    density_plot(store$pdf$x, store$pdf$pdf)
  })
  
  # Show how to use the app.
  observeEvent(input$how_to, {
    shiny.semantic::create_modal(shiny.semantic::modal(
      id = "simple-modal",
      header = h2("How to use this app"),
      includeMarkdown("howto.md")
    ))
  })
  
}
