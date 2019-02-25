#' GOV.UK style HTML template
#'
#' Loads additional style and template file
#'
#' @inheritParams rmarkdown::html_document
#' @export
govuk_document <- function(toc = FALSE,
                           toc_depth = 3,
                           toc_float = FALSE,
                           fig_width = 7,
                           fig_height = 5,
                           fig_retina = 2,
                           dev = "png",
                           phase = c("none", "alpha", "beta"),
                           service_name = NULL,
                           smart = TRUE,
                           self_contained = TRUE,
                           mathjax = "default",
                           extra_dependencies = NULL,
                           css = NULL,
                           includes = NULL,
                           keep_md = FALSE,
                           lib_dir = NULL,
                           md_extensions = NULL,
                           pandoc_args = NULL) {

  # locations of resource files in the package
  pkg_resource <- function(...) {
    system.file(..., package = "govdown")
  }

  template <- pkg_resource("rmarkdown/resources/govuk.html")
  css <- c(css, pkg_resource("rmarkdown/resources/govuk.css"))
  lua <- pkg_resource("rmarkdown/resources/govuk.lua")
  resources <- paste0(".:", pkg_resource("rmarkdown/resources"))

  # Use highlights.js from the rmarkdown package
  extra_dependencies <-
    append(extra_dependencies,
           list(rmarkdown::html_dependency_highlightjs("default")))

  phase <- match.arg(phase)
  if (phase != "none") {
    banner_file <-
      pkg_resource(paste0("rmarkdown/resources/govuk-", phase, "-banner.html"))
    banner_html <- readChar(banner_file, file.info(banner_file)$size)
    pandoc_args <-
      c(pandoc_args, pandoc_variable_arg("phase_banner", banner_html))
  }

  if (!is.null(service_name)) {
    pandoc_args <-
      c(pandoc_args, pandoc_variable_arg("service_name", service_name))
  }

  # call the base html_document function with the default template so that it
  # sets up mathjax without a warning despite `self_contained = TRUE`.
  base_format <-
    rmarkdown::html_document(toc = toc,
                             toc_depth = toc_depth,
                             toc_float = toc_float,
                             fig_width = fig_width,
                             fig_height = fig_height,
                             fig_retina = fig_retina,
                             dev = dev,
                             df_print = "default",
                             code_folding = "none",
                             smart = smart,
                             self_contained = self_contained,
                             mathjax = mathjax,
                             keep_md = keep_md,
                             number_sections = FALSE,
                             section_divs = FALSE,
                             fig_caption = FALSE,
                             code_download = FALSE,
                             theme = NULL,
                             highlight = NULL,
                             css = css,
                             lib_dir = lib_dir,
                             pandoc_args = c(pandoc_args,
                                             "--lua-filter", lua,
                                             "--resource-path", resources,
                                             "--highlight-style=pygments"
                                             ),
                             extra_dependencies = extra_dependencies)

  # Drop the --no-highlight pandoc argument
  no_highlight_arg <- which(base_format$pandoc$args == "--no-highlight")
  base_format$pandoc$args <- base_format$pandoc$args[-no_highlight_arg]

#   # Override the default template
#   template_arg <- which(base_format$pandoc$args == "--template") + 1L
#   base_format$pandoc$args[template_arg] <- template

  base_format
}
