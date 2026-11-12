#' Skapa en datumstämplad utskriftsmapp
#'
#' Skapar en mapp med dagens datum (`ÅÅÅÅ-MM-DD`) under `filvag`, som
#' standard i en undermapp för innevarande år. Finns mappen redan händer
#' inget.
#'
#' @param filvag Katalog där mappen ska skapas. `NULL` (standard) skapar ingen
#'   mapp: funktionen skriver ut projektkatalogen (via [here::here()]) och
#'   returnerar `NULL`.
#' @param yearmap `TRUE` = `filvag/ÅÅÅÅ/ÅÅÅÅ-MM-DD`, `FALSE` =
#'   `filvag/ÅÅÅÅ-MM-DD`.
#' @param quiet `FALSE` skriver ut om mappen skapades eller redan fanns.
#'
#' @return Sökvägen till mappen, eller `NULL` om `filvag` saknas.
#' @export
#'
#' @example inst/examples/func_utskriftsmapp.R
func_utskriftsmapp <- function(filvag = NULL, yearmap = TRUE, quiet = TRUE) {
  
  # Check if filvag is provided
  if (is.null(filvag)) {
    WD <- here()
    writeLines(paste("Du måste välja en filväg där du vill att mappen ska skapas. Du arbetar från:", WD))
    return(NULL)  # Exit function if no path is provided
  }
  
  # Get today's date and current year
  current_date <- format(Sys.Date(), "%Y-%m-%d")
  current_year <- format(Sys.Date(), "%Y")
  
  if(yearmap){
    # Construct output folder path
    output_folder <- file.path(filvag, current_year, current_date)
  } else {
    # Construct output folder path
    output_folder <- file.path(filvag, current_date)
  }
  
  # Create directory without asking
  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
    if(!quiet) {
      writeLines(paste("Mappen skapades:", output_folder))
    }
  } else {
    if(!quiet) {
      writeLines(paste("Mappen finns redan:", output_folder))
    }
  }
  
  return(output_folder)  # Return the created folder path
}
