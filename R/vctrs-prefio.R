# list of preferences
#' Create a new vector of preferences
#' 
#' @param x The list of integers, containing the indexed preferences in order
#' @param levels The labels of the preferences
#' 
#' @export
new_prefio <- function(x, levels) {
  x <- vctrs::as_list_of(x, .ptype = integer())
  vctrs::new_vctr(
    x, levels = levels, class = "prefio"
  )
}

#' @export
levels.prefio <- function(x) {
  attr(x, "levels")
}

#' @export
`levels<-.prefio` <- function(x, value) {
  attr(x, "levels") <- value
  x
}

#' @export
format.prefio <- function(x, ...) {
  levels <- levels(x)
  fmt_order <- function(p) paste(levels[p], collapse = "<")
  vapply(vctrs::vec_data(x), fmt_order, character(1L))
}