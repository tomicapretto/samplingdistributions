# Custom stop function used within the app.
stop2 = function(message, call = NULL, ...) {
  err = structure(
    list(
      message = message,
      call = call,
      ...
    ),
    class = c("samp.error", "error", "condition")
  )
  stop(err)
}

# Catches errors generated in the app and show notification instead of 
# breaking the app.
appHandler = function(expr) {
  tryCatch({
    expr
  },
  shiny.silent.error = function(cnd) NULL,
  samp.error = function(cnd) {
    shiny::showNotification(cnd$message, type = "error")
  },
  error = function(cnd) {
    shiny::showNotification("Unexpected error ocurred.", type = "error")
  })
}
