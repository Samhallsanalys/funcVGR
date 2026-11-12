#' Kör (source) alla R-skript i en katalog
#'
#' Kör alla filer med ändelsen `.R` eller `.r` i katalogen med [source()].
#'
#' @param mappnamn Sökväg till katalogen. Obligatorisk.
#'
#' @return En teckenvektor med sökvägarna till de skript som körts.
#' @export
#'
#' @example inst/examples/func_las_rskript.R
func_las_rskript <- function(mappnamn) {
  script_filer <- list.files(mappnamn, pattern = "\\.[Rr]$", full.names = TRUE)
  
  # Use invisible() to suppress the return value
  invisible(
    lapply(script_filer, function(file) {
      # Use source with echo=FALSE
      source(file, echo = FALSE)
    })
  )
  
  # Return only the file paths if needed
  return(script_filer)
}
