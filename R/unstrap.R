#' Remove bootstrap css from crosstalk components
#'
#' If your page renders weirdly, it might be because a crosstalk component like
#' [`crosstalk::filter_select()`] is injecting unexpected css into
#' your page, which happens because they try to use the Bootstrap css library by
#' default.  The `unstrap()` function prevents that from happening.
#'
#' @param x a crosstalk component, such as [`crosstalk::filter_select()`]
#'
#' @return
#'
#' The component `x` but with any `"boostrap"` dependency removed from its
#' `html_dependencies` attribute.
#'
#' @examples
#' # The fs object will inject css into your page.
#' if (requireNamespace("crosstalk", quietly = TRUE)) {
#'   df <- crosstalk::SharedData$new(mtcars)
#'
#'   fs <- crosstalk::filter_select(
#'       id = "myselector",
#'       label = "select something",
#'       sharedData = df,
#'       group = ~cyl
#'     )
#'
#'   # The fs_nobootstrap object won't inject css into your page.
#'   fs_nobootstrap <- unstrap(fs)
#' }
#' @export
unstrap <- function(x) {
  attr(x, "html_dependencies") <-
    Filter(
      function(dependency) {dependency$name != "bootstrap"},
      attr(x, "html_dependencies")
    )
  x
}
