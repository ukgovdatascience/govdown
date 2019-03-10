#' GOV.UK style HTML template
#'
#' Loads additional style and template file
#'
#' @inheritParams rmarkdown::html_document
#' @export
govuk_document <- function(...,
                           phase = c("none", "alpha", "beta"),
                           service_name = NULL,
                           css = NULL,
                           extra_dependencies = NULL,
                           pandoc_args = NULL,
                           keep_md = FALSE) {

  template <- pkg_file("rmarkdown/resources/govuk.html")
  css <- c(css, pkg_file("rmarkdown/resources/govuk.css"))
  lua <- pkg_file("rmarkdown/resources/govuk.lua")
  resources <- paste0(".:", pkg_file("rmarkdown/resources"))

  # Navbar
  # Unlike rmarkdown::html_document we only support it as defined in _site.yml,
  # not as a given _navbar.html.
  config <- rmarkdown::site_config()
  navbar <- navbar_html(config$navbar)

  # include the navbar html
  includes <- list(before_body = navbar)
  pandoc_args <- c(pandoc_args, rmarkdown::includes_to_pandoc_args(includes))

  # TODO: create navbar html inside a pre_processor() function that receives the
  # name of the input file so that it can highlight the selected page.

  # Use highlights.js from the rmarkdown package
  extra_dependencies <-
    append(extra_dependencies,
           list(rmarkdown::html_dependency_highlightjs("default")))

  phase <- match.arg(phase)
  if (phase != "none") {
    banner_file <-
      pkg_file(paste0("rmarkdown/resources/govuk-", phase, "-banner.html"))
    includes <- list(before_body = banner_file)
    pandoc_args <- c(pandoc_args, rmarkdown::includes_to_pandoc_args(includes))
  }

  base_format <- rmarkdown::output_format(
    knitr = NULL,
    pandoc = rmarkdown::pandoc_options(
      to = "html",
      from = rmarkdown::from_rmarkdown(implicit_figures = FALSE,
                            extensions = "+smart")
      ),
    keep_md = keep_md,
    base_format =
      rmarkdown::html_document_base(
        mathjax = NULL,
        pandoc_args = c(pandoc_args,
                        "--css", rmarkdown::pandoc_path_arg(css),
                        "--standalone",
                        "--self-contained",
                        "--template", template,
                        "--lua-filter", lua,
                        "--resource-path", resources,
                        "--highlight-style=pygments",
                        "--mathjax"
                        ),
        extra_dependencies = extra_dependencies
      )
  )

  base_format
}

# Can't use rmarkdown::navbar_html because its template is hardcoded.
# This builds up a navbar in stages.
navbar_html <- function(navbar) {

  # title and type
  homepage <- navbar$homepage
  title <- navbar$title
  service_name <- navbar$service_name

  if (is.null(homepage)) title <- ""
  if (is.null(title)) title <- ""
  if (is.null(service_name)) service_name <- ""

  # build the navigation bar and return it as a temp file
  logo <- ""
  if (is.null(navbar$logo) || navbar$logo == "true") { # default: TRUE
    logo <-
      file_string(pkg_file("rmarkdown/resources/govuk-logo-svg.html"))
  } else {
    logo <- file_string(navbar$logo) # read from file
  }

  service_name <- ""
  if (!is.null(navbar$service_name)) {
    service_name  <- file_string(pkg_file("rmarkdown/resources/govuk-service-name.html"))
    service_name  <- sprintf(service_name, navbar$service_name)
  }

  # Build up links html one by one
  links <- ""
  if (!is.null(navbar$links)) {
    link <- navbar$links[[1]]

    links <- file_string(pkg_file("rmarkdown/resources/govuk-nav.html"))

    all_links <- ""

    # href is relative to index.Rmd and index.html
    active_link <- file_string(pkg_file("rmarkdown/resources/govuk-nav-item-active.html"))
    active_link <- sprintf(active_link, link$href, link$text)

    all_links <- paste0(all_links, active_link)

    if (length(navbar$links) > 1L) {
      for (link in navbar$links[-1L]) {
        other_link <- file_string(pkg_file("rmarkdown/resources/govuk-nav-item-other.html"))
        other_link <- sprintf(other_link, link$href, link$text)

        all_links <- paste0(all_links, other_link)
      }
    }

    links <- sprintf(links, all_links)
  }

  nav <- ""
  if (!is.null(navbar$service_name) || !is.null(navbar$links)) {
    nav <- file_string(pkg_file("rmarkdown/resources/govuk-nav.html"))
    nav <- sprintf(nav, links)
  }

  content <- ""
  if (!is.null(navbar$service_name) || !is.null(navbar$links)) {
    content <- file_string(pkg_file("rmarkdown/resources/govuk-header-content.html"))
    content <- sprintf(content, service_name, nav)
  }

  navbar <- file_string(pkg_file("rmarkdown/resources/navbar.html"))
  navbar <- sprintf(navbar, homepage, logo, title, content)

  as_tmpfile(navbar)
}

# utils from rmarkdown

read_utf8 <- function(file, encoding = 'UTF-8') {
  if (inherits(file, 'connection')) con <- file else {
    con <- base::file(file, encoding = encoding); on.exit(close(con), add = TRUE)
  }
  enc2utf8(readLines(con, warn = FALSE))
}

file_string <- function(path, encoding = 'UTF-8') {
  one_string(read_utf8(path, encoding))
}

one_string <- function(x) paste(x, collapse = '\n')

# has to be this, otherwise rmarkdown::render won't be able to find the files to
# delete them
tmpfile_pattern <- "rmarkdown-str"

# return a string as a tempfile
as_tmpfile <- function(str) {
  if (length(str) == 0) return()
  f <- tempfile(tmpfile_pattern, fileext = ".html")
  write_utf8(str, f)
  f
}

write_utf8 <- function (text, con, ...) {
  opts <- options(encoding = "native.enc"); on.exit(options(opts), add = TRUE)
  writeLines(enc2utf8(text), con, ..., useBytes = TRUE)
}

# locations of resource files in the package
pkg_file <- function(...) {
  system.file(..., package = "govdown", mustWork = TRUE)
}
