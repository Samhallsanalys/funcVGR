#Används för att sätt ditt working directory

#' Sätt arbetskatalogen till det aktiva skriptets katalog
#'
#' Använder \pkg{rstudioapi} för att hitta sökvägen till skriptet som är
#' öppet i RStudio och sätter arbetskatalogen till dess katalog. Fungerar bara
#' i RStudio och för sparade skript.
#'
#' @return Den nya arbetskatalogen, eller ett felmeddelande som text om
#'   skriptet inte är sparat.
#' @export
#'
#' @example inst/examples/func_setwd.R
func_setwd <- function() {
  # Ensure the pacman package is available
  
  # Use tryCatch to handle potential errors
  tryCatch({
    # Get the path to the currently active R script
    script_path <- rstudioapi::getActiveDocumentContext()$path

    # An unsaved script has an empty path, so stop before dirname()/setwd() silently no-op on "."
    if (!nzchar(script_path)) stop("Skriptet är inte sparat")

    # Get the path to the directory containing the R script
    script_dir <- dirname(script_path)

    # Set the working directory
    setwd(script_dir)
    
    # Get the path to the current working directory
    working_directory <- getwd()
    
    return(working_directory)
  }, error = function(e) {
    # Return an error message if something goes wrong
    return(paste("Du måste spara ner ditt skript innan du kan sätta din arbetsyta:", e$message))
  })
}
