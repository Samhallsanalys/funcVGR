# Anslutning till VGR:s geodatabas (PostGIS) som innehåller alla ytor för att rita kartor.
#
# Värd, port och databas är fasta och går inte att ändra, så att lösenordet aldrig kan skickas
# till en annan server. Användarnamn och lösenord står inte i koden: de läses ur Windows
# Autentiseringshanteraren (Credential Manager) med keyring, under tjänsten
# "geodata.vgregion.se". Finns inga uppgifter sparade frågar paketet efter dem i en interaktiv
# session och sparar dem där. Alla anslutningar (DBI och GDAL) hämtar uppgifterna från
# gis_inloggning(), så att de aldrig kan hamna i otakt med varandra.
gis_server <- list(
  host   = "geodata.vgregion.se",
  port   = 5432L,
  dbname = "geodata"
)

# Tjänstens namn i Windows Autentiseringshanteraren
gis_keyring_tjanst <- "geodata.vgregion.se"

# Sparade användarnamn för geodatabasen (tom vektor om inga finns)
gis_sparade_anvandare <- function() {
  poster <- tryCatch(keyring::key_list(gis_keyring_tjanst), error = function(e) NULL)
  if (is.null(poster) || nrow(poster) == 0) return(character())
  # key_list() kan matcha tjänster som bara börjar med samma namn
  unique(poster$username[poster$service == gis_keyring_tjanst])
}

# Värd, port, databas, användarnamn och lösenord. Saknas sparade uppgifter frågar funktionen
# efter dem (bara i en interaktiv session) och sparar dem i Windows Autentiseringshanteraren.
gis_inloggning <- function() {
  anvandare <- gis_sparade_anvandare()

  if (length(anvandare) == 0) {
    if (!interactive()) {
      stop("Det finns inga inloggningsuppgifter till geodatabasen (", gis_server$host,
           ") i Windows Autentiseringshanteraren.\n",
           "Spara dem en gång i en interaktiv R-session med func_gis_satt_inloggning().",
           call. = FALSE)
    }
    message("Det finns inga inloggningsuppgifter till geodatabasen (", gis_server$host,
            ") sparade. Ange dem nu, så sparas de i Windows Autentiseringshanteraren.")
    func_gis_satt_inloggning(testa = FALSE)
    anvandare <- gis_sparade_anvandare()
    if (length(anvandare) == 0) {
      stop("Inloggningsuppgifterna kunde inte sparas.", call. = FALSE)
    }
  }

  c(gis_server, list(
    user     = anvandare[1],
    password = keyring::key_get(gis_keyring_tjanst, anvandare[1])
  ))
}

# Frågar efter en text: dialogruta i RStudio, annars i konsolen
gis_fraga_text <- function(fraga) {
  svar <- if (rstudioapi::isAvailable()) {
    rstudioapi::showPrompt("Geodatabasen", fraga)
  } else {
    readline(paste0(fraga, " "))
  }
  if (is.null(svar)) "" else trimws(svar)
}

# Läser en tabell eller fråga med sf::st_read() via GDAL:s PostgreSQL-drivrutin. Lösenordet
# lämnas via PGPASSWORD i stället för i anslutningssträngen, så att det inte kan synas i
# felmeddelanden från GDAL.
gis_st_read <- function(query) {
  inloggning <- gis_inloggning()
  withr::with_envvar(
    c(PGPASSWORD = inloggning$password),
    sf::st_read(gis_pgstring(inloggning, med_losenord = FALSE), query = query, quiet = TRUE)
  )
}

gis_pgstring <- function(inloggning, med_losenord) {
  paste0(
    "PG:host=", inloggning$host,
    " port=", inloggning$port,
    " dbname=", inloggning$dbname,
    " user=", inloggning$user,
    if (med_losenord) paste0(" password=", inloggning$password)
  )
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
#' Användarnamn och lösenord läses ur Windows Autentiseringshanteraren
#' (Credential Manager), där de sparas under tjänsten `geodata.vgregion.se`.
#' Första gången, när inga uppgifter finns sparade, frågar funktionen efter
#' användarnamn och lösenord och sparar dem där. Det går bara i en interaktiv
#' R-session; i ett skript som körs med `Rscript` stoppar funktionen i stället.
#' Uppgifterna kan bytas med [func_gis_satt_inloggning()].
#'
#' Servern nås bara inifrån VGR:s nätverk. Värd, port och databas går inte att
#' ändra, så att lösenordet bara skickas till `geodata.vgregion.se`.
#'
#' @param med_losenord `TRUE` (standard) tar med lösenordet i strängen, så att
#'   den kan användas direkt i [sf::st_read()]. `FALSE` utelämnar det. Skriv inte
#'   ut en sträng med lösenordet, och spara den inte i en fil.
#'
#' @return `func_gis_hamta_con()`: ett DBI-anslutningsobjekt. Stäng det med
#'   [DBI::dbDisconnect()] när du är klar. `func_gis_hamta_pgstring()`: en
#'   teckensträng.
#' @seealso [func_gis_hamta_geoobjekt()], [func_gis_satt_inloggning()]
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
      fel <- conditionMessage(e)
      rad <- if (grepl("password authentication failed|authentication failed", fel, ignore.case = TRUE)) {
        paste0("\nAnvändarnamnet (", inloggning$user, ") eller lösenordet godtogs inte. ",
               "Spara nya uppgifter med func_gis_satt_inloggning().")
      } else {
        "\nKontrollera att du är ansluten till VGR:s nätverk."
      }
      stop("Kunde inte ansluta till geodatabasen (", inloggning$host, "): ", fel, rad,
           call. = FALSE)
    }
  )
}

#' @rdname func_gis_hamta_con
#' @export
func_gis_hamta_pgstring <- function(med_losenord = TRUE) {
  gis_pgstring(gis_inloggning(), med_losenord = med_losenord)
}

#' Spara inloggningsuppgifter till geodatabasen
#'
#' Frågar efter användarnamn och lösenord till VGR:s geodatabas
#' (`geodata.vgregion.se`) och sparar dem i Windows Autentiseringshanteraren
#' (Credential Manager) under tjänsten `geodata.vgregion.se`. Där läser
#' [func_gis_hamta_con()], [func_gis_hamta_pgstring()] och
#' [func_gis_hamta_geoobjekt()] dem sedan, så att de bara behöver anges en gång
#' per dator.
#'
#' Funktionen behöver bara anropas för att byta uppgifter, t.ex. efter ett nytt
#' lösenord: saknas uppgifter frågar anslutningsfunktionerna själva efter dem.
#' Tidigare sparade uppgifter för tjänsten tas bort, så att bara en användare
#' finns sparad. Lösenordet anges i en dialogruta och syns aldrig i konsolen.
#' Funktionen kräver en interaktiv R-session.
#'
#' @param anvandare Användarnamn som text. `NULL` (standard) frågar efter det.
#' @param metod Används inte längre. Uppgifterna sparas alltid i Windows
#'   Autentiseringshanteraren. Finns kvar så att äldre skript fungerar.
#' @param testa `TRUE` (standard) provar att ansluta med de nya uppgifterna och
#'   säger om det gick.
#'
#' @return Användarnamnet, osynligt.
#' @seealso [func_gis_hamta_con()]
#' @export
#'
#' @example inst/examples/func_gis_satt_inloggning.R
func_gis_satt_inloggning <- function(anvandare = NULL, metod = NULL, testa = TRUE) {

  if (!interactive()) {
    stop("func_gis_satt_inloggning() frågar efter lösenordet och kräver därför en ",
         "interaktiv R-session.", call. = FALSE)
  }
  if (!is.null(metod)) {
    message("`metod` används inte längre: uppgifterna sparas alltid i Windows ",
            "Autentiseringshanteraren.")
  }

  if (is.null(anvandare)) {
    anvandare <- gis_fraga_text("Användarnamn till geodatabasen (geodata.vgregion.se):")
  }
  if (!is.character(anvandare) || length(anvandare) != 1 || !nzchar(trimws(anvandare))) {
    stop("Inget användarnamn angavs, så ingenting sparades.", call. = FALSE)
  }
  anvandare <- trimws(anvandare)

  # keyring::key_set() frågar efter lösenordet utan att visa det
  keyring::key_set(gis_keyring_tjanst, anvandare,
                   prompt = paste0("Lösenord för ", anvandare, " till geodatabasen: "))

  # Ta bort andra användare för tjänsten, så att det inte är oklart vilken som används
  for (gammal in setdiff(gis_sparade_anvandare(), anvandare)) {
    keyring::key_delete(gis_keyring_tjanst, gammal)
  }
  message("Inloggningsuppgifterna för ", anvandare,
          " är sparade i Windows Autentiseringshanteraren.")

  if (testa) {
    con <- tryCatch(func_gis_hamta_con(), error = function(e) e)
    if (inherits(con, "error")) {
      warning("Uppgifterna är sparade, men anslutningen misslyckades: ",
              conditionMessage(con), call. = FALSE)
    } else {
      DBI::dbDisconnect(con)
      message("Anslutningen till geodatabasen fungerar.")
    }
  }

  invisible(anvandare)
}
