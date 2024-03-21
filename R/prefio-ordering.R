#' Calculate the first preference
#' @export
pref_fp <- function (x) {
  fp <- vapply(vctrs::vec_data(x), `[`, integer(1L), 1L)
  vctrs::new_factor(fp, levels(x))
}

#' Calculate the two candidate preferences
#' 
#' I'm not sure exactly what process should be used, better check this first!
#' 
#' @export
pref_tcp <- function (x) {
  ## Get top two preferences
  tcp <- order(table(pref_fp(x)), decreasing = TRUE)[1:2]
  
  ## Probably need to recursively do this -- someone else can do that!
  
  # Find preference for each element
  out <- vapply(vctrs::vec_data(x), function(x) {
    # Remove non-tcp preferences
    p <- intersect(x, tcp)
    # If no tcp preferences, return NA
    if(!length(p)) return(NA_integer_)
    # Return top tcp preference
    p[1L]
  }, integer(1L))
  
  vctrs::new_factor(out, levels(x))
}