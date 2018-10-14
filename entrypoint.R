library(plumber)

router <- plumber::plumb("plumber.R")
router$run(port = 8000)
