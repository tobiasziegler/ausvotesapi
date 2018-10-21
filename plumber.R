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

#* List the House contests
#* @get /house/divisions
function() {
  feeds_tbl <- tbl(pool, "feeds")
  contests_tbl <- tbl(pool, "contests")

  preload_feed_id <-
    feeds_tbl %>%
    filter(results_verbosity == "Preload") %>%
    select(feed_id) %>%
    pull()

  contests <-
    contests_tbl %>%
    filter(
      feed_id == preload_feed_id
    ) %>%
    collect()

  contests
}

#* Provide summary results and data for a specified House of Reps division
#* @serializer unboxedJSON
#* @get /house/divisions/<id:int>
function(id) {
  feeds_tbl <- tbl(pool, "feeds")
  contests_tbl <- tbl(pool, "contests")
  candidates_tbl <- tbl(pool, "candidates")
  results_fp_by_type_tbl <- tbl(pool, "results_fp_by_type")
  results_fp_by_type_historic_tbl <- tbl(pool, "results_fp_by_type_historic")

  preload_feed_id <-
    feeds_tbl %>%
    filter(results_verbosity == "Preload") %>%
    select(feed_id) %>%
    pull()

  results_feed_id <-
    feeds_tbl %>%
    filter(
      results_verbosity == "Light",
      feed_created == max(feed_created, na.rm = TRUE)
    ) %>%
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
    select(-feed_id, -contest_id)

  results_fp <-
    results_fp_by_type_tbl %>%
    filter(
      feed_id == results_feed_id,
      contest_id == id
    ) %>%
    group_by(candidate_type, candidate_id) %>%
    summarise(
      votes = sum(votes, na.rm = TRUE)
    )

  results_fp_historic <-
    results_fp_by_type_historic_tbl %>%
    filter(
      feed_id == preload_feed_id,
      contest_id == id
    ) %>%
    group_by(candidate_type, candidate_id) %>%
    summarise(
      votes_historic = sum(votes_historic, na.rm = TRUE)
    )

  candidates <-
    candidates %>%
    left_join(
      results_fp,
      by = c("candidate_type", "candidate_id")
    ) %>%
    left_join(
      results_fp_historic,
      by = c("candidate_type", "candidate_id")
    )

  candidates <-
    candidates %>%
    mutate(
      pct = votes / sum(votes, na.rm = TRUE),
      pct_historic = votes_historic / sum(votes_historic, na.rm = TRUE),
      swing = pct - pct_historic
    ) %>%
    collect()

  list(
    feed_ids = list(preload = preload_feed_id, results = results_feed_id),
    contest = contest,
    candidates = candidates
  )
}
