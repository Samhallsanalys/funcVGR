#' Lista eller läs in alla filer av en viss typ i en katalog
#'
#' Hittar alla filer med angiven filändelse i en katalog. Skiftläget spelar
#' ingen roll. Returnerar sökvägarna, eller läser in filerna och slår ihop dem
#' till en data frame med kolumnen `file_source` (filnamnet).
#'
#' @param mappnamn Sökväg till katalogen. Obligatorisk.
#' @param filtyp Filändelse utan punkt, t.ex. `"xlsx"`, `"csv"` eller `"rds"`.
#'   Obligatorisk.
#' @param retur `"list"` returnerar en lista med sökvägar. `"df"` läser in och
#'   slår ihop filerna (stöds för xlsx, rds och csv). Har en kolumn olika typ i
#'   olika filer läses alla kolumner som text, med en varning.
#'
#' @return En lista med sökvägar, eller en data frame.
#' @export
#'
#' @example inst/examples/func_las_filtyper.R
func_las_filtyper <- function(mappnamn, filtyp, retur = c("list", "df")) {
  
  # Validate the retur argument
  retur <- match.arg(retur)
  
  # Check if the directory exists
  if (!dir.exists(mappnamn)) {
    stop("Directory does not exist.")
  }
  
  # Normalize filtyp to lowercase so the case-insensitive list.files() match
  # and the case-sensitive switch() below always agree
  # and accept both "csv" and ".csv" (a leading dot previously matched no files)
  filtyp <- sub("^\\.", "", tolower(filtyp))

  # Construct the file pattern with case-insensitive matching
  filtyp <- paste0("\\.", filtyp, "$")
  filer_list <- list.files(mappnamn, pattern = filtyp, full.names = TRUE, ignore.case = TRUE)
  
  # If no files are found, return an appropriate message
  if (length(filer_list) == 0) {
    stop("No files of the specified type found.")
  }
  
  # If retur is "list", simply return the file paths
  if (retur == "list") {
    return(as.list(filer_list))
  }
  
  # If retur is "dataframe", read and combine the files
  if (retur == "df") {
    read_file <- switch(filtyp,
                        "\\.xlsx$" = function(file) read.xlsx(file),
                        "\\.rds$"  = function(file) readRDS(file),
                        "\\.csv$"  = function(file) read.csv(file, stringsAsFactors = FALSE),
                        stop("Unsupported file type for dataframe conversion"))
    
    # Read each file and combine into a single data frame
    all_data <- lapply(filer_list, read_file)
    
    # Optionally, add a column with the file name for traceability
    all_data <- mapply(function(data, file) {
      data$file_source <- basename(file)
      return(data)
    }, all_data, filer_list, SIMPLIFY = FALSE)
    
    # Combine all data frames into one. If a column has different types in different
    # files (e.g. numbers in one, text in another) bind_rows() fails; then read
    # everything as text, with a warning, instead of stopping with dplyr's error
    final_data <- tryCatch(bind_rows(all_data), error = function(e) {
      warning("Kolumner har olika typ i olika filer och l\u00e4ses d\u00e4rf\u00f6r som text.", call. = FALSE)
      bind_rows(lapply(all_data, function(d) mutate(d, across(everything(), as.character))))
    })
    
    return(final_data)
  }
}
