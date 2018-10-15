library(plumber)
library(pool)
library(RPostgres)

config <- config::get()

pool <- pool::dbPool(
  drv = RPostgres::Postgres(),
  dbname = config$dbname,
  host = config$host,
  port = config$port,
  user = config$user,
  password = config$password
)

router <- plumber::plumb("plumber.R")

router$registerHook("exit", function() {
  pool::poolClose(pool)
})

router$run(port = 8000)
