# govdown

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/ukgovdatascience/govdown.svg?branch=master)](https://travis-ci.org/ukgovdatascience/govdown)
<!-- badges: end -->

Make websites with R Markdown styled with the GOV.UK Design System.  See the
[website](https://ukgovdatascience.github.io/govdown).

## Installation

``` r
remotes::install_github("ukgovdatascience/govdown")
```

## Development

Use `install-govuk-frontend.sh` to download, modify and compile the GOV.UK Design System to get the css files for the templates.

### Prerequisites

The `sassc` command-line tool.  If you can't get that to work, try the `sass`
package by RStudio, which wraps it.
