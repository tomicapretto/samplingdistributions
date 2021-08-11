# Custom select input that has an animation when changin between options.
# See `www/selector-input/binding.js`
selectorInput <- function(inputId, label, choices) {
  form <- tags$div(
    class = "top-input",
    tags$p(label, class = "card-header"),
    tags$div(
      class = "selector-input",
      id = inputId,
      tags$div(
        class = "data",
        selectorOptions(choices)
      ),
      tags$div(
        class = "select-input-controls",
        tags$div(
          class = "selection",
          choices[1]
        ),
        tags$div(
          class = "input-arrows",
          tags$div(
            id = "step-up",
            list(shiny::icon("angle-up"), "")
          ),
          tags$div(
            id = "step-down",
            list(shiny::icon("angle-down"), "")
          )
        )
      )
    )
  )

  deps <- htmltools::htmlDependency(
    name = "selectorInput",
    version = "1.0.0",
    src = c(file = file.path("www", "selector-input")),
    script = "binding.js",
    stylesheet = "styles.css"
  )

  htmltools::attachDependencies(form, deps)
}

# Utility function to properly add choices to the input.
selectorOptions <- function(choices) {
  first = paste0(
    '<option class = "animate-bottom" value = "', choices[1], '" selected>', 
    choices[1], '</option>'
  )
  html = vapply(choices[-1], function(x) {
    paste0(
      '<option class = "animate-bottom" value = "', x, '">', x, '</option>'
    )},
    character(1)
  )
  shiny::HTML(paste(c(first, html), collapse = "\n"))
}
