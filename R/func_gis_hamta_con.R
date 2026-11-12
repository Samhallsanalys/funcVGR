# Anslutning till VGR:s geodatabas (PostGIS) som innehåller alla ytor för att rita kartor.
#
# Inloggningsuppgifterna är hårdkodade (beslut 2026-10-06): servern nås bara inifrån VGR:s
# nätverk, så säkerheten anses hög nog. Undantaget gäller bara geodata.vgregion.se. Därför är
# även värd, port och databas fasta och går inte att ändra med miljövariabler, så att
# lösenordet aldrig kan skickas till en annan server. Alla anslutningar (DBI och GDAL) hämtar
# uppgifterna från gis_inloggning(), så att de aldrig kan hamna i otakt med varandra.
gis_anslutning <- list(
  host     = "geodata.vgregion.se",
  port     = 5432L,
  dbname   = "geodata",
  user     = "***",
  password = "***"
)

gis_inloggning <- function() gis_anslutning

# Läser en tabell eller fråga med sf::st_read() via GDAL:s PostgreSQL-drivrutin
gis_st_read <- function(query) {
  sf::st_read(func_gis_hamta_pgstring(med_losenord = TRUE), query = query, quiet = TRUE)
}

#' Anslutning till VGR:s geodatabas (PostGIS)
#'
#' `func_gis_hamta_con()` skapar en DBI-anslutning till PostgreSQL-databasen
#' `geodata` på `geodata.vgregion.se`, som innehåller alla ytor som behövs för
#' att rita kartor.
#'
#' `func_gis_hamta_pgstring()` bygger motsvarande GDAL-anslutningssträng
#' (`"PG:..."`) för [sf::st_read()]. Den ger snabbare hämtning av geometrier och
#' trunkerar inte kolumnnamn. Enklast är att hämta tabeller med
#' [func_gis_hamta_geoobjekt()].
#'
#' @section Inloggning:
#' Användarnamn och lösenord är inbyggda i paketet, så ingen inloggning behöver
#' sparas. Servern nås bara inifrån VGR:s nätverk. Uppgifterna används bara mot
#' `geodata.vgregion.se`; värd, port och databas går inte att ändra.
#'
#' @param med_losenord `TRUE` (standard) tar med lösenordet i strängen, så att
#'   den kan användas direkt i [sf::st_read()]. `FALSE` utelämnar det.
#'
#' @return `func_gis_hamta_con()`: ett DBI-anslutningsobjekt. Stäng det med
#'   [DBI::dbDisconnect()] när du är klar. `func_gis_hamta_pgstring()`: en
#'   teckensträng.
#' @seealso [func_gis_hamta_geoobjekt()]
#' @export
#'
#' @example inst/examples/func_gis_hamta_con.R
func_gis_hamta_con <- function() {

  inloggning <- gis_inloggning()

  tryCatch(
    DBI::dbConnect(RPostgres::Postgres(),
                   host = inloggning$host,
                   port = inloggning$port,
                   dbname = inloggning$dbname,
                   user = inloggning$user,
                   password = inloggning$password),
    error = function(e) {
      stop("Kunde inte ansluta till geodatabasen (", inloggning$host, "): ",
           conditionMessage(e),
           "\nKontrollera att du är ansluten till VGR:s nätverk.", call. = FALSE)
    }
  )
}

#' @rdname func_gis_hamta_con
#' @export
func_gis_hamta_pgstring <- function(med_losenord = TRUE) {

  inloggning <- gis_inloggning()
  paste0(
    "PG:host=", inloggning$host,
    " port=", inloggning$port,
    " dbname=", inloggning$dbname,
    " user=", inloggning$user,
    if (med_losenord) paste0(" password=", inloggning$password)
  )
}

#' Spara inloggningsuppgifter till geodatabasen (behövs inte längre)
#'
#' Sedan version 0.1.6 är inloggningen till geodatabasen inbyggd i paketet (se
#' [func_gis_hamta_con()]), så funktionen sparar ingenting. Den finns kvar så
#' att äldre skript som anropar den fortsätter att fungera, och skriver bara
#' ut ett meddelande. Uppgifter som sparats tidigare (`GEODATA_USER` och
#' `GEODATA_PASSWORD` i `.Renviron`, eller i Windows Autentiseringshanteraren)
#' används inte längre och kan tas bort.
#'
#' @param anvandare Används inte längre.
#' @param metod Används inte längre.
#' @param testa Används inte längre.
#'
#' @return `NULL`, osynligt.
#' @seealso [func_gis_hamta_con()]
#' @export
#'
#' @example inst/examples/func_gis_satt_inloggning.R
func_gis_satt_inloggning <- function(anvandare = NULL, metod = c("renviron", "keyring"), testa = TRUE) {
  message("Inloggningen till geodatabasen är inbyggd i funcVGR sedan version 0.1.6, så ",
          "func_gis_satt_inloggning() behövs inte längre och sparar ingenting. Tidigare sparade ",
          "GEODATA_USER och GEODATA_PASSWORD används inte och kan tas bort ur .Renviron.")
  invisible(NULL)
}
