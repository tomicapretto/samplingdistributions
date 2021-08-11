# Custom numeric input. See `www/number-input/binding.js` for source.
numberInput = function(inputId, label, value = 0, min = NULL, max = NULL, step = 1) {
  form <- tags$div(
    class = "top-input",
    tags$p(label, class = "card-header"),
    tags$div(
      class = "number-input",
      id = inputId,
      tags$div(
        class = "number-input-controls",
        tags$input(
          type = "number", 
          min = min, 
          max = max, 
          value = value, 
          step = step
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
    name = "numberInput",
    version = "1.0.0",
    src = c(file = file.path("www", "number-input")),
    script = "binding.js",
    stylesheet = "styles.css"
  )

  htmltools::attachDependencies(form, deps)
}
