#' GOV.UK style HTML template
#'
#' A template for rendering R Markdown documents as HTML using the GOV.UK Design
#' System.  Can be used for single documents or for websites.
#'
#' @param phase one of `"none"` (default), `"alpha"` or `"beta"` to put an alpha
#' or beta banner indicating the maturity of the service (if it is a service).
#' @param feedback_url URL for feedback, given in the phase banner when `phase`
#' is `"alpha"` or `"beta"`.
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
#' the default images.
#'
#' @param font one of `"new-transport"` (default) or `"sans-serif"`.  New
#' Transport must be when the document or website is published on the GOV.UK
#' domain, otherwise it must not be used.
#' @param service_name for websites, the words to appear in the navbar after the
#' logo and the name of the organisation.  For single documents, use `title:` in
#' the yaml header instead.
#' @param keep_md logical, whether to keep the intermediate `.md` file after
#' rendering.
#'
#' @details
#'
#' To configure a standalone document, use the yaml at the top of the `.Rmd`
#' file.
#'
#' ```
#' ---
#' title: "GOV.UK-style R Markdown Document"
#' organisation: "govdown"
#' logo: "./images/govdown-logo-white-on-transparent.svg"
#' output:
#'   govdown::govdown_document:
#'     font: "sans-serif"
#' ---
#' ```
#'
#' To configure a website, use a `_site.yml` file instead.
#'
#' ```
#' output_dir: docs # to host on GitHub pages
#' navbar:
#'   logo: "images/govdown-logo-white-on-transparent.svg"
#'   title: "govdown"
#'   homepage: "https://ukgovdatascience.github.io/govdown"
#'   service_name: "Reproducible Analytical Pipelines"
#'   links:
#'     - text: "Home"
#'       href: index.html
#'     - text: "Tech docs"
#'       href: tech-docs.html
#' output:
#'   govdown::govdown_document:
#'     font: "sans-serif"
#'     phase: alpha
#'     feedback_url: "https://github.com/ukgovdatascience/govdown/issues"
#'     favicon: "custom"
#' ```
#'
#' @export
govdown_document <- function(phase = c("none", "alpha", "beta"),
                           feedback_url = "404.html",
                           favicon = c("govuk", "custom"),
                           font = c("new-transport", "sans-serif"),
                           service_name = NULL,
                           keep_md = FALSE) {
  rmarkdown::pandoc_available("2", error = TRUE)

  phase <- match.arg(phase)
  font <- match.arg(font)
  favicon <- match.arg(favicon)

  pandoc_args <- NULL

  lua <- pkg_file("rmarkdown/resources/govuk.lua")
  path_sep <- ifelse(.Platform$OS.type == "windows", ";", ":")
  resources <- paste0(".", path_sep, pkg_file("rmarkdown/resources"))
  template <- pkg_file("rmarkdown/resources/govuk.html")

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

  if (favicon == "govuk") {
    favicon_html <- pkg_file("rmarkdown/resources/favicon.html")
  } else {
    favicon_html <- pkg_file("rmarkdown/resources/favicon-custom.html")
  }
  pandoc_args <-
    c(pandoc_args,
      rmarkdown::includes_to_pandoc_args(list(in_header = favicon_html)))

  pre_processor <- function(metadata, input_file, runtime, knit_meta,
                            files_dir, output_dir) {
    # Set/get config depending whether this is a website or a single document
    config <- rmarkdown::site_config()
    if (is.null(config)) { # single document
      yaml <- rmarkdown::yaml_front_matter(input_file)
      config <- list(navbar = list(service_name = yaml$title,
                                   title = yaml$organisation,
                                   logo = yaml$logo))
      phase <- "none"
    }

    # Navbar
    # In the pre_processor because it needs to know the input_file to determine
    # which item to highlight.
    # Unlike rmarkdown::html_document we only support it as defined in _site.yml,
    # not as a given _navbar.html.
    navbar_arg <- navbar_html(config$navbar, input_file)

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

  base_format <- rmarkdown::output_format(
    knitr = NULL,
    pandoc = rmarkdown::pandoc_options(
      to = "html",
      from = rmarkdown::from_rmarkdown(implicit_figures = FALSE,
                            extensions = "+smart")
      ),
    keep_md = keep_md,
    pre_processor = pre_processor,
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
navbar_html <- function(navbar, input_file) {

  # title and type
  homepage <- navbar$homepage
  title <- navbar$title
  service_name <- navbar$service_name

  if (is.null(homepage)) homepage <- ""
  if (is.null(title)) title <- ""
  if (is.null(service_name)) service_name <- ""

  # build the navigation bar and return it as a temp file
  logo <- ""
  if (is.null(navbar$logo)) { # default to GOV.UK crown
    logo <- file_string(pkg_file("rmarkdown/resources/logo-svg.html"))
  } else if (is.logical(navbar$logo) && !navbar$logo) { # false --> no logo
    logo <- ""
  } else {
    logo <- file_string(navbar$logo) # read from file
  }

  service_name <- ""
  if (!is.null(navbar$service_name)) {
    service_name  <- file_string(pkg_file("rmarkdown/resources/navbar-service-name.html"))
    service_name  <- sprintf(service_name, navbar$service_name)
  }

  # Build up links html one by one
  links_html <- ""
  if (!is.null(navbar$links)) {
    all_links <- ""

    active_html <- file_string(pkg_file("rmarkdown/resources/navbar-item-active.html"))
    other_html <- file_string(pkg_file("rmarkdown/resources/navbar-item-other.html"))

    for (link in navbar$links) {
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
  if (!is.null(navbar$service_name) || !is.null(navbar$links)) {
    content <- file_string(pkg_file("rmarkdown/resources/header-content.html"))
    content <- sprintf(content, service_name, links_html)
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

filename <- function(x) tools::file_path_sans_ext(basename(x))
