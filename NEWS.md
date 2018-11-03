# ausvotesapi 0.1.0

- Initial version used for live testing during the Wentworth by-election on 20 October 2018.

- API endpoints provide the following data:

  - `/tables` provides a list of the database tables as a basic check for successful database connectivity.

  - `/house/divisions` provides summary data (including the ID code) about each electorate that has results in the database.

  - `/house/divisions/<id>` provides the total first preference votes (current and historic) for each candidate, the corresponding percentage amounts, and the percentage swing compared to the total historic vote (i.e., not matched to the polling places that have returned current results).
