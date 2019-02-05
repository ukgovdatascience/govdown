#' GOV.UK style HTML template
#'
#' Loads additional style and template file
#'
#' @inheritParams rmarkdown::html_document
#' @param ... additional arguments provided to `rmarkdown::html_document`
#' @export
govuk_document <- function(...) {

  # locations of resource files in the package
  pkg_resource <- function(...) {
    system.file(..., package = "govdown")
  }

  template <- pkg_resource("rmarkdown/resources/govuk.html")
  css <- pkg_resource("rmarkdown/resources/govuk.css")
  lua <- pkg_resource("rmarkdown/resources/govuk.lua")
  resources <- paste0(".:", pkg_resource("rmarkdown/resources"))

  # Use highlights.js from the rmarkdown package
  extra_dependencies <- NULL
  extra_dependencies <-
    append(extra_dependencies,
           list(rmarkdown::html_dependency_highlightjs("default")))

  # call the base html_document function with the default template so that it
  # sets up mathjax without a warning despite `self_contained = TRUE`.
  base_format <-
    rmarkdown::html_document(
                             section_divs = FALSE,
                             fig_caption = FALSE,
                             smart = TRUE,
                             self_contained = TRUE,
                             theme = NULL,
                             highlight = NULL,
                             lib_dir =  "libs",
                             css = css,
                             pandoc_args = c("--lua-filter", lua,
                                             "--resource-path", resources,
                                             "--highlight-style=pygments"
                                             ),
                             extra_dependencies = extra_dependencies,
                             ...)

  # Drop the --no-highlight pandoc argument
  no_highlight_arg <- which(base_format$pandoc$args == "--no-highlight")
  base_format$pandoc$args <- base_format$pandoc$args[-no_highlight_arg]

  # Override the default template
  template_arg <- which(base_format$pandoc$args == "--template") + 1L
  base_format$pandoc$args[template_arg] <- template

  base_format
}
