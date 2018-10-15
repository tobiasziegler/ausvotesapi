library(plumber)

config <- config::get()

router <- plumber::plumb("plumber.R")
router$run(port = 8000)
