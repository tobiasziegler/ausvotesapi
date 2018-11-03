# ausvotesapi

## Overview

A web API, implemented in R using the [`plumber`](https://www.rplumber.io/) package, that provides Australian federal election information and results in JSON format.

The API retrieves and processes data that has been extracted from the Australian Electoral Commission's FTP media feeds and stored in a database using the [`aecfeedr`](https://github.com/tobiasziegler/aecfeedr) package.

Both `ausvotesapi` and `aecfeedr` are in early development and their interfaces and functionality are expected to change until stable releases are published.

## Installation

1. You'll need to set up an R script that uses [`aecfeedr`](https://github.com/tobiasziegler/aecfeedr) to retrieve data from an AEC media feed and store it in a PostgreSQL database.

2. To get started with the API, fork and/or clone this repository, or download the project files.

3. Copy `config-example.yml` to `config.yml` and edit the configuration file to provide the location and credentials of the database containing the results.

4. For local development and/or use, you can open the directory as an RStudio project. To start the API server locally, open `plumber.R` and select "Run API" on the toolbar, or open `entrypoint.R` and run the file's contents. You can then load API endpoints through `http://localhost:8000/`

5. For deployment options, check out [the plumber documentation](https://www.rplumber.io/docs/).

## Usage

Versions 0.1.0 of `ausvotesapi` and `aecfeedr` were developed and tested together with live results from the Wentworth by-election on 20 October 2018. The initial version of the API only provides a few basic endpoints:

- `/tables` provides a list of the database tables as a basic check for successful database connectivity.

- `/house/divisions` provides summary data (including the ID code) about each electorate that has results in the database.

- `/house/divisions/<id>` provides the total first preference votes (current and historic) for each candidate, the corresponding percentage amounts, and the percentage swing compared to the total historic vote (i.e., not matched to the polling places that have returned current results).
