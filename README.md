# govdown

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/ukgovdatascience/govdown.svg?branch=master)](https://travis-ci.org/ukgovdatascience/govdown)
[![CRAN status](https://www.r-pkg.org/badges/version/govdown)](https://CRAN.R-project.org/package=govdown)
<!-- badges: end -->

Make websites with R Markdown styled with the GOV.UK Design System.  See the
[website](https://ukgovdatascience.github.io/govdown).

## Installation

``` r
remotes::install_github("ukgovdatascience/govdown")
```

## Shiny

If you are developing a Shiny application, then look at
https://github.com/moj-analytical-services/shinyGovstyle.

## Development

Use `install-govuk-frontend.sh` to download, modify and compile the GOV.UK Design System to get the css files for the templates.

### Prerequisites

The `sassc` command-line tool.  If you can't get that to work, try the `sass`
package by RStudio, which wraps it.
