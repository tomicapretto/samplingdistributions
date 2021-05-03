source("ui_utils.R")
source("number-input.R")
source("range-input.R")
source("selector-input.R")

sidebar = function() {
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
    tags$div(
      id = "distributions_div"
    ),
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

body = function() {
  tags$div(
    style = "margin-left: 260px;",
    tags$div(
      class = "ui container",
      tags$h1(class = "ui header", "Sampling distributions playground"),
      ui_row(
        style = "margin-bottom:25px;",
        ui_col(
          width = 4,
          tags$p("Sample size", class = "card-header"),
          tags$div(
            numberInput("size", value = 20, min = 2, max = 1000)
          )
        ),
        ui_col(
          width = 4,
          tags$p("Repetitions", class = "card-header"),
          numberInput("repetitions", value = 200, min = 10, max = 1000, step = 10)
        ),
        ui_col(
          width = 4,
          tags$p("Statistic", class = "card-header"),
          selectorInput("statistic", c("Mean", "Median", "Minimum", "Maximum", "Percentile"))
        ),
        ui_col(
          width = 4,
          conditionalPanel(
            "input.statistic == 'Percentile'",
            tags$div(
              tags$p("Percentile", class = "card-header"),
              numberInput("percentile", value = 25, min = 1, max = 99, step = 1)
            )
          )
        )
      ),
      tags$div(
        echarts4r::echarts4rOutput("plot_rvs", height = "340px", width = "85%"),
        echarts4r::echarts4rOutput("plot_pdf", height = "340px", width = "85%"),
        align = "center"
      )
    )
  )
}

ui = shiny.semantic::semanticPage(
    tags$head(shiny::includeCSS(file.path("www", "style.css"))),
    shinyjs::useShinyjs(),
    sidebar(),
    body()
)
