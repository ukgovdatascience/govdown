#' GOV.UK style HTML template
#'
#' A template for rendering R Markdown documents as HTML using the GOV.UK Design
#' System.  Can be used for single documents or for websites.
#'     font: "sans-serif"
#'     favicon: "custom"
#'     logo: "images/govdown-logo-white-on-transparent.svg"
#'     logo_url: "index.html"
#'     logo_text: "govdown"
#'     page_title: "page_title"
#'     title: "title"
#'     phase: alpha
#'     feedback_url: "https://github.com/ukgovdatascience/govdown/issues"
#'
#' @param font one of `"sans-serif"` (default) or `"new-transport"`.  New
#' Transport must be when the document or website is published on the GOV.UK
#' domain, otherwise it must not be used.
#' @param favicon one of `"govuk"` (default) or `"custom"`.  For websites only,
#' not standalone documents. If `"custom"` then image files in the directory
#' `"favicon/"` will be used. The filenames are:
#'
#' * `apple-touch-icon-152x152.png`
#' * `apple-touch-icon-167x167.png`
#' * `apple-touch-icon-180x180.png`
#' * `apple-touch-icon.png`
#' * `favicon.ico`
#' * `mask-icon.svg`
#'
#' See `system.file("rmarkdown/resources/favicon-custom.html", package =
#' "govdown")` for how the icons are used.  See
#' `system.file("rmarkdown/resources/assets/images", package = "govdown")` for
#' the default images.  All the files are required.
#' @param logo `FALSE` (default) or a path to an image file.
#' @param logo_url URL to follow when the logo is clicked.
#' @param logo_text Text to place beside the logo.
#' @param page_title Text to go inside the `<title>` tags, used in browser
#' toolbars, when making bookmarks and in search engine results.
#' @param title Text to appear in the main part of the bar at the top of every
#' page.
#' @param phase one of `"none"` (default), `"alpha"` or `"beta"` to put an alpha
#' or beta banner indicating the maturity of the service (if it is a service).
#' @param feedback_url URL for feedback, given in the phase banner when `phase`
#' is `"alpha"` or `"beta"`.
#' @param google_analytics Google Analytics ID for monitoring traffic to the
#' website.
#' @param keep_md logical, whether to keep the intermediate `.md` file after
#' rendering.
#' @param ... passed on to [rmarkdown::html_document_base()], used by Shiny and
#' [rmarkdown::run()].
#'
#' @details
#'
#' To configure a standalone document, use the yaml at the top of the `.Rmd`
#' file.
#'
#' ```
#' ---
#' output:
#'   govdown::govdown_document:
#'     font: "sans-serif"
#'     favicon: "custom"
#'     logo: "images/logo.svg"
#'     logo_url: "https://ukgovdatascience.github.io/govdown"
#'     logo_text: "logo_text"
#'     page_title: "page_title"
#'     title: "title"
#'     phase: alpha
#'     feedback_url: "https://github.com/ukgovdatascience/govdown/issues"
#'     google_analytics: "UA-12345678-90"
#' ---
#' ```
#'
#' To configure a website, use a `_site.yml` file instead.
#'
#' ```
#' output_dir: docs # to host on GitHub pages
#' navbar:
#'   - text: "Home"
#'     href: index.html
#'   - text: "Tech docs"
#'     href: tech-docs.html
#'   - text: "News"
#'     href: NEWS.html
#' output:
#'   govdown::govdown_document:
#'     font: "sans-serif"
#'     favicon: "custom"
#'     logo: "images/govdown-logo-white-on-transparent.svg"
#'     logo_url: "index.html"
#'     logo_text: "govdown"
#'     page_title: "page_title"
#'     title: "title"
#'     phase: alpha
#'     feedback_url: "https://github.com/ukgovdatascience/govdown/issues"
#'     google_analytics: "UA-45097885-11"
#' ```
#'
#' @return R Markdown output format to pass to [rmarkdown::render()]
#'
#' @examples
#' \dontrun{
#'   # Requires pandoc version 2+
#'   input_rmd <- system.file("extdata/input.Rmd", package = "govdown")
#'   x <- rmarkdown::render(input_rmd, govdown_document())
#'   y <- rmarkdown::render(input_rmd, govdown_document(phase = "alpha"))
#'   utils::browseURL(x)
#'   utils::browseURL(y)
#' }
#' @export
govdown_document <- function(keep_md = FALSE,
                             font = c("sans-serif", "new-transport"),
                             favicon = c("none", "custom", "govuk"),
                             logo = FALSE,
                             logo_url = "",
                             logo_text = "Logo text",
                             page_title = "Page title",
                             title = "Title",
                             phase = c("none", "alpha", "beta"),
                             feedback_url = "404.html",
                             google_analytics = NULL,
                             ...) {

  rmarkdown::pandoc_available("2", error = TRUE)

  phase <- match.arg(phase)
  font <- match.arg(font)
  favicon <- match.arg(favicon)

  pandoc_args <- NULL

  govuk_lua <- pkg_file("rmarkdown/resources/govuk.lua")
  highlight_lua <- pkg_file("rmarkdown/resources/highlight.lua")
  path_sep <- ifelse(.Platform$OS.type == "windows", ";", ":")
  resources <- paste0(".", path_sep, pkg_file("rmarkdown/resources"))
  template_html <- file_string(pkg_file("rmarkdown/resources/govuk.html"))

  if (font == "new-transport") {
    css <- pkg_file("rmarkdown/resources/govuk.css")
    pandoc_args <-
      c(pandoc_args,
        rmarkdown::includes_to_pandoc_args(list(css = "govuk.css")))
  } else {
    css <- pkg_file("rmarkdown/resources/govukish.css")
    pandoc_args <-
      c(pandoc_args,
        rmarkdown::includes_to_pandoc_args(list(css = "govukish.css")))
  }

  if (favicon != "none") {
    if (favicon == "govuk") {
      favicon_html <- pkg_file("rmarkdown/resources/favicon.html")
    } else if (favicon == "custom") {
      favicon_html <- pkg_file("rmarkdown/resources/favicon-custom.html")
    }
    pandoc_args <-
      c(pandoc_args,
        rmarkdown::includes_to_pandoc_args(list(in_header = favicon_html)))
  }

  analytics <- ""
  if (is.null(google_analytics)) {
    template_html <- sprintf(template_html, "", page_title)
  } else {
    analytics_html <- file_string(pkg_file("rmarkdown/resources/google-analytics.html"))
    analytics_html <- sprintf(analytics_html, google_analytics, google_analytics)
    template_html <- sprintf(template_html, analytics_html, page_title)
  }

  template <- as_tmpfile(template_html)

  pre_processor <- function(metadata, input_file, runtime, knit_meta,
                            files_dir, output_dir) {
    config <- list(title = title,
                   logo_text = logo_text,
                   logo_url = logo_url,
                   logo = logo)
    site_config <- rmarkdown::site_config()
    if (!is.null(site_config)) { # website
      config$links <- site_config$navbar
    }

    # Navbar
    # In the pre_processor because it needs to know the input_file to determine
    # which item to highlight.
    # Unlike rmarkdown::html_document we only support it as defined in _site.yml,
    # not as a given _navbar.html.
    navbar_arg <- navbar_html(config, input_file)

    # Phase (none, alpha, beta)
    phase_arg <- NULL
    if (phase != "none") {
      banner_file <-
        pkg_file(paste0("rmarkdown/resources/", phase, "-banner.html"))
      banner_filestring <- file_string(banner_file)
      banner_filestring <- sprintf(banner_filestring , feedback_url)
      tmpfile <- as_tmpfile(banner_filestring)
      phase_arg <- list(before_body = tmpfile)
    }

    pre_processor_pandoc_args <-
      rmarkdown::includes_to_pandoc_args(list(before_body = c(navbar_arg,
                                                              phase_arg)))
  }

  # Use highlights.js from the rmarkdown package
  extra_dependencies <- list(rmarkdown::html_dependency_highlightjs("default"))

  dots <- list(...)
  html_document_base_args <-
    c(
      list(
        mathjax = NULL,
        pandoc_args = c(pandoc_args,
                        "--css", rmarkdown::pandoc_path_arg(css),
                        "--standalone",
                        "--self-contained",
                        "--template", template,
                        "--lua-filter", govuk_lua,
                        "--lua-filter", highlight_lua,
                        "--resource-path", resources,
                        "--no-highlight",
                        "--mathjax"
                        ),
        extra_dependencies = extra_dependencies
      ),
      dots)

  # override arguments provided by rmarkdown::render_site()
  html_document_base_args$self_contained <- NULL

  base_format <- rmarkdown::output_format(
    knitr = NULL,
    pandoc = rmarkdown::pandoc_options(
      to = "html",
      from = rmarkdown::from_rmarkdown(implicit_figures = FALSE,
                            extensions = "+smart")
      ),
    keep_md = keep_md,
    pre_processor = pre_processor,
    base_format = do.call(rmarkdown::html_document_base,
                          html_document_base_args)
  )

  base_format
}

# Can't use rmarkdown::navbar_html because its template is hardcoded.
# This builds up a navbar in stages.
navbar_html <- function(config, input_file) {

  # title and type
  logo_url <- config$logo_url
  logo_text <- config$logo_text

  if (is.null(config$logo_url)) {
    browser()
    logo_url <- ""
  }
  if (is.null(logo_text)) logo_text <- ""

  # build the navigation bar and return it as a temp file
  logo <- ""
  if (is.null(config$logo)) { # default to no logo
    logo <- ""
  } else if (is.logical(config$logo) && !config$logo) { # false --> no logo
    logo <- ""
  } else if (config$logo == "crown") { # GOV.UK crown
    logo <- file_string(pkg_file("rmarkdown/resources/logo-svg.html"))
  } else {
    logo <- file_string(config$logo) # read from file
  }

  title <- ""
  if (!is.null(config$title)) {
    title  <- file_string(pkg_file("rmarkdown/resources/navbar-service-name.html"))
    title  <- sprintf(title, config$title)
  }

  # Build up links html one by one
  links_html <- ""
  if (!is.null(config$links)) {
    all_links <- ""

    active_html <- file_string(pkg_file("rmarkdown/resources/navbar-item-active.html"))
    other_html <- file_string(pkg_file("rmarkdown/resources/navbar-item-other.html"))

    for (link in config$links) {
      # input_file has two suffixes e.g. index.utf8.md so strip twice
      is_active <- filename(link$href) == filename(filename(input_file))
      link_html <- if (is_active) active_html else other_html
      link_html <- sprintf(link_html, link$href, link$text)
      all_links <- paste0(all_links, link_html)
    }

    links_html <- file_string(pkg_file("rmarkdown/resources/navbar-links.html"))
    links_html <- sprintf(links_html, all_links)
  }

  content <- ""
  if (!is.null(config$title) || !is.null(config$links)) {
    content <- file_string(pkg_file("rmarkdown/resources/header-content.html"))
    content <- sprintf(content, title, links_html)
  }

  navbar <- file_string(pkg_file("rmarkdown/resources/navbar.html"))
  navbar <- sprintf(navbar, logo_url, logo, logo_text, content)

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

filename <- function(x) tools::file_path_sans_ext(basename(x))
