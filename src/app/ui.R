source(here("src", "app", "utils", "ui.R"))
source(here("src", "app", "inputs" ,"number-input.R"))
source(here("src", "app", "inputs" ,"range-input.R"))
source(here("src", "app", "inputs" ,"selector-input.R"))

sidebar <- function() {
  tags$div(
    class = "ui sidebar inverted vertical visible menu",
    style = "display:flex; flex-direction:column; margin:0;",
    id = "sidebar",
    tags$div(
      class = "item",
      tags$p(
        class = "sidebar_header",
        HTML("Add distributions and <br> make your own mix!")
      )
    ),
    tags$div(
      class = "item",
      ui_row(
        ui_col(
          width = 14,
          shiny.semantic::selectInput(
            inputId = "distribution",
            label = "Select a distribution",
            choices = c(
              "Normal" = "norm",
              "T" = "t",
              "Gamma" = "gamma",
              "Beta" = "beta",
              "Log-normal" = "lnorm",
              "Uniform" = "unif"
            )
          )
        ),
        ui_col(
          width = 2,
          style = "top:50%",
          link_add("add")
        )
      )
    ),
    tags$div(id = "distributions_div"),
    tags$div(
      class = "item",
      style = "margin-top:auto",
      tags$div(
        class = "ui grid",
        style = "margin: 0; padding:bottom: 1em",
        tags$div(
          class = "row",
          ui_col(
            width = 16,
            style = paste(
              "font-weight: bold",
              "text-align: center",
              sep = ";"
            ),
            actionLink(
              "how_to",
              "How to use this app?",
              style = "font-size:16px;",
              class = "footer-link"
            )
          )
        )
      )
    )
  )
}

body <- function() {
  tags$div(
    style = "margin-left: 260px;",
    tags$div(
      class = "ui container",
      tags$h1(class = "ui header", "Sampling distributions playground"),
      tags$div(
        class = "input-container",
        numberInput(
          "size", "Sample size", 
          value = 20, min = 2, max = 1000
        ),
        numberInput(
          "repetitions", "Repetitions", 
          value = 200, min = 10, max = 1000, step = 10
        ),
        selectorInput(
          "statistic", "Statistic", 
          c("Mean", "Median", "Minimum", "Maximum", "Percentile")
        ),
        tags$div(
          style = "flex: 1;",
          conditionalPanel(
            "input.statistic == 'Percentile'",
            numberInput(
              "percentile", "Percentile", 
              value = 25, min = 1, max = 99, step = 1
            )
          )
        )
      ),
      tags$div(
        style = "margin-top: 20px",
        echarts4r::echarts4rOutput("plot_rvs", height = "340px", width = "90%"),
        echarts4r::echarts4rOutput("plot_pdf", height = "340px", width = "90%"),
        align = "center"
      )
    )
  )
}

ui <- shiny.semantic::semanticPage(
    tags$head(shiny::includeCSS(file.path("www", "style.css"))),
    shinyjs::useShinyjs(),
    sidebar(),
    body()
)
