#
# This is a Plumber API. In RStudio 1.2 or newer you can run the API by
# clicking the 'Run API' button above.
#
# In RStudio 1.1 or older, see the Plumber documentation for details
# on running the API.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)

#* @apiTitle AusVotes API

#* List the database tables
#* @get /tables
function() {
  DBI::dbListTables(pool)
}

#* Provide summary data for a specified House of Reps division
#* @serializer unboxedJSON
#* @get /house/divisions/<id:int>
function(id) {
  feeds_tbl <- tbl(pool, "feeds")
  contests_tbl <- tbl(pool, "contests")
  candidates_tbl <- tbl(pool, "candidates")

  preload_feed_id <-
    feeds_tbl %>%
    filter(results_verbosity == "Preload") %>%
    select(feed_id) %>%
    pull()

  contest <-
    contests_tbl %>%
    filter(
      feed_id == preload_feed_id,
      contest_id == id
    ) %>%
    select(-feed_id) %>%
    collect()

  candidates <-
    candidates_tbl %>%
    filter(
      feed_id == preload_feed_id,
      contest_id == id
    ) %>%
    select(-feed_id, -contest_id) %>%
    collect()

  list(
    feed_ids = list(preload = preload_feed_id),
    contest = contest,
    candidates = candidates
  )
}
