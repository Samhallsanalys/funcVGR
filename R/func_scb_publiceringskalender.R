# Funktioner för att hämta publiceringsdatum från SCB.
#
# func_scb_hamta_tabell_id() / func_scb_hamta_uppdaterad() använder SCB:s officiella PxWebApi 2.0
# (api.scb.se), som ger ett strukturerat "updated"-fält (senast uppdaterad/publicerad) för valfri
# SSD-tabell givet dess tabell-id eller en sökterm — ingen web-scraping krävs för det.
#
# func_scb_publiceringskalender() (tidigare func_scb_publicering, kvar som bakåtkompatibelt alias)
# skrapar fortfarande SCB:s publiceringskalender-sida, eftersom PxWebApi inte exponerar kommande
# publiceringsdatum — bara "senast uppdaterad". Den funktionen används alltså numera bara för
# "nästa publicering"-delen.

# Slå upp SCB:s kanoniska tabell-id (t.ex. "TAB638") för en sökterm eller ett äldre alias
# (t.ex. "BefolkningNy"). Om `query` redan ser ut som ett kanoniskt id (TAB följt av siffror)
# används det direkt utan någon sökning.
#' Slå upp SCB:s tabell-id
#'
#' Söker i SCB:s PxWebApi 2.0 efter en tabell och returnerar det kanoniska
#' id:t (t.ex. `"TAB638"`) för den mest relevanta träffen. Ser `query` redan ut
#' som ett tabell-id returneras det direkt.
#'
#' @param query Sökterm eller äldre SSD-alias, t.ex. `"BefolkningNy"`, eller
#'   ett tabell-id. Obligatorisk.
#' @param lang Språk: `"sv"` eller `"en"`.
#'
#' @return Tabell-id som teckensträng.
#' @seealso [func_scb_hamta_uppdaterad()]
#' @export
#'
#' @example inst/examples/func_scb_hamta_tabell_id.R
func_scb_hamta_tabell_id <- function(
    query,        # Character: sökterm eller äldre SSD-alias, t.ex. "BefolkningNy" | Om redan ett TAB-id, returneras det oförändrat
    lang = "sv"    # Character: språk för sökningen/svaret | Options: "sv", "en"
) {

  if (grepl("^TAB\\d+$", query)) return(query)  # Redan ett kanoniskt PxWebApi 2.0-id — inget att slå upp

  resp <- httr::GET(
    "https://api.scb.se/OV0104/v2beta/api/v2/tables",
    query = list(query = query, lang = lang)
  )
  httr::stop_for_status(resp, task = paste("söka efter SCB-tabell:", query))
  result <- jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"))

  # With no hits the API returns an empty list, for which nrow() is NULL; NROW() gives 0
  if (NROW(result$tables) == 0) {
    stop("Ingen SCB-tabell hittades för sökningen: '", query, "'")
  }

  result$tables$id[1]  # Ta den mest relevanta träffen (API:et sorterar redan efter relevans)
}

# Hämta senaste uppdaterings-/publiceringsdatum för en given SCB-tabell via PxWebApi 2.0.
# Detta ersätter det gamla, skrapningsbaserade sättet att få fram "senaste referensdatum" och
# fungerar för VILKEN SSD-tabell som helst (inte bara de två hårdkodade ämnesområdena i
# func_scb_publiceringskalender()) — ge bara tabellens id eller en sökterm/alias.
#' Senaste uppdateringsdatum för en SCB-tabell
#'
#' Hämtar när en tabell i SCB:s statistikdatabas senast uppdaterades, via
#' PxWebApi 2.0. Fungerar för alla tabeller. Ange tabell-id eller en
#' sökterm, som löses upp med [func_scb_hamta_tabell_id()].
#'
#' @param table_id Tabell-id (t.ex. `"TAB638"`), sökterm eller äldre alias.
#'   Obligatorisk.
#' @param lang Språk: `"sv"` eller `"en"`.
#'
#' @return En lista med `table_id`, `label` (tabellens namn) och `updated`
#'   (POSIXct, UTC).
#' @seealso [func_scb_publiceringskalender()] för kommande publiceringar.
#' @export
#'
#' @example inst/examples/func_scb_hamta_uppdaterad.R
func_scb_hamta_uppdaterad <- function(
    table_id,      # Character: SCB tabell-id (t.ex. "TAB638") ELLER en sökterm/äldre alias (t.ex. "BefolkningNy") | Löses upp automatiskt via func_scb_hamta_tabell_id()
    lang = "sv"    # Character: språk för svaret | Options: "sv", "en"
) {

  resolved_id <- func_scb_hamta_tabell_id(table_id, lang = lang)

  resp <- httr::GET(
    paste0("https://api.scb.se/OV0104/v2beta/api/v2/tables/", resolved_id),
    query = list(lang = lang)
  )
  httr::stop_for_status(resp, task = paste("hämta metadata för SCB-tabell:", resolved_id))
  info <- jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"))

  if (is.null(info$updated)) {
    stop("Svaret för tabell '", resolved_id, "' innehöll inget 'updated'-fält.")
  }

  list(
    table_id = resolved_id,
    label = info$label,
    updated = lubridate::ymd_hms(info$updated, tz = "UTC")
  )
}

# Hämta "nästa publicering"-datum från SCB:s publiceringskalender (finns inte i PxWebApi, så det
# här skrapas fortfarande). `tabell` matchar nu mot BÅDE det korta filternamnet ("bas"/"bef") OCH
# den långa visningstexten ("Befolkningsstatistik" m.fl.), så båda formerna fungerar som indata.
#' Nästa publicering enligt SCB:s publiceringskalender
#'
#' Hämtar SCB:s publiceringskalender från scb.se, eftersom PxWebApi inte har
#' kommande publiceringsdatum. Tidsfönstret är tre månader bakåt och två
#' månader framåt. Kalendern hämtas från samma adress som kalendersidan på
#' scb.se använder för sin tabell, så funktionen kan sluta fungera om SCB
#' ändrar sidan igen. Resultatet filtreras på databaspubliceringar för
#' ämnesområdena "Befolkningens arbetsmarknadsstatus" (`"bas"`) och
#' "Befolkningsstatistik" (`"bef"`).
#'
#' `func_scb_publicering()` är ett bakåtkompatibelt alias.
#'
#' @param tabell `"bas"`, `"bef"` eller hela ämnestexten. `NULL` = alla
#'   ämnesområden.
#' @param enbart_text `TRUE` skriver ut senaste referensperiod och nästa
#'   publicering. `FALSE` returnerar senaste publicerade referensperiod
#'   (`"ÅÅÅÅ-MM"`).
#' @param returnera_df `TRUE` returnerar hela den rensade kalendern som data
#'   frame. Går före `enbart_text`.
#' @param ... Argument som skickas vidare till
#'   `func_scb_publiceringskalender()`.
#'
#' @return Beroende på argumenten: `NULL` (osynligt, meddelanden skrivs ut),
#'   en teckensträng eller en data frame.
#' @seealso [func_scb_hamta_uppdaterad()]
#' @export
#'
#' @example inst/examples/func_scb_publiceringskalender.R
func_scb_publiceringskalender <- function(
    tabell = NULL,          # Character: "bas", "bef", eller den fulla svenska ämnestexten | NULL = alla ämnesområden
    enbart_text = TRUE,     # Logical: TRUE = skriv ut meddelande(n), FALSE = returnera senaste referensperiod som text
    returnera_df = FALSE    # Logical: TRUE = returnera hela den rensade datan som data frame (ignorerar enbart_text)
) {

  filter_list <- data.frame(
    tabell_long = c("Befolkningens arbetsmarknadsstatus", "Befolkningsstatistik"),
    filternamn = c("bas", "bef")
  )

  if (is.null(tabell)) {
    filtered_data <- filter_list
  } else {
    filtered_data <- filter_list |>
      filter(tolower(filternamn) == tolower(tabell) | tolower(tabell_long) == tolower(tabell))
    if (nrow(filtered_data) == 0) {
      stop("Okänt värde för 'tabell': '", tabell, "'. Giltiga värden: ",
           paste(c(filter_list$filternamn, filter_list$tabell_long), collapse = ", "))
    }
  }

  # %m+%/%m-% roll back to the last day of the month; plain + months() gave NA when the target
  # day does not exist (e.g. 31 december + 2 months), which broke the calendar URL
  pubdate_to <- today() %m+% months(2)
  pubdate_from <- today() %m-% months(3)

  # Sedan hösten 2026 laddar scb.se kalendertabellen i efterhand från UpdateKalenderResults
  # (samma anrop som sidans JavaScript gör); själva sidan innehåller ingen tabell längre.
  # Med period = "Custom" och tomt subjectAreas kommer hela kalendern för tidsfönstret i
  # ett svar, så ingen sidbläddring behövs. Ämnesområdena filtreras nedan på undersökningens namn.
  svar <- httr::GET(
    "https://www.scb.se/PubliceringsKalender/UpdateKalenderResults",
    query = list(prodkod = "", dateFrom = as.character(pubdate_from), dateTo = as.character(pubdate_to),
                 subjectAreas = "", period = "Custom", form = "", statistikansvarig = "", paging = "",
                 sortOrder = "", sortField = "", contentLang = "sv"),
    httr::add_headers(`X-Requested-With` = "XMLHttpRequest")
  )
  httr::stop_for_status(svar, task = "hämta SCB:s publiceringskalender")
  tabell_nod <- html_node(read_html(httr::content(svar, as = "text", encoding = "UTF-8")), "table")
  if (inherits(tabell_nod, "xml_missing")) {
    stop("Kunde inte hämta någon data från SCB:s publiceringskalender.")
  }

  combined_data <- html_table(tabell_nod) |>
    mutate(across(everything(), ~ str_squish(as.character(.)))) |>
    # Ett ändrat datum står som "2026-07-28 Ändrat från:2026-07-31 Orsak: ..."; det första är det gällande
    mutate(Publiceringsdatum = str_extract(Publiceringsdatum, "\\d{4}-\\d{2}-\\d{2}")) |>
    # Kolumnen hette "Statistik, kontakter m.m." i den gamla tabellen; namnet behålls i resultatet
    rename(statistik_kontakter_m_m = "Undersökning")

  # "01 augusti 2025" -> "2025-08" (NA if it is not a Swedish month name + year)
  sv_manad_till_ym <- function(x) {
    manader <- c(januari = 1, februari = 2, mars = 3, april = 4, maj = 5, juni = 6, juli = 7,
                 augusti = 8, september = 9, oktober = 10, november = 11, december = 12)
    delar <- str_match(tolower(x), "^01 ([a-z]+) (\\d{4})$")
    manad <- manader[delar[, 2]]
    ifelse(is.na(manad), NA_character_, sprintf("%s-%02d", delar[, 3], manad))
  }

  clean_df <- combined_data |>
    janitor::clean_names() |>
    mutate(
      across(everything(), ~ ifelse(. == "", NA, .)),
      referenstid = trimws(referenstid),
      referenstid = ifelse(str_detect(referenstid, "^[a-zA-Z]+ \\d{4}$"),
                           paste("01", referenstid), NA),
      # Swedish month names are mapped explicitly: dmy() parses month names in the session's
      # locale, so "maj"/"oktober" etc. became NA on a machine with English locale
      referenstid = sv_manad_till_ym(referenstid),
      publiceringsdatum = ymd(publiceringsdatum),
      framtida_publicering = case_when(
        publiceringsdatum <= lubridate::today() ~ FALSE,  # Samma dag räknas som redan publicerad (SCB publicerar vid fast klockslag)
        publiceringsdatum > lubridate::today() ~ TRUE
      )
    ) |>
    filter(str_detect(publiceringsform, regex("databas", ignore_case = TRUE))) |>
    filter(statistik_kontakter_m_m %in% filtered_data$tabell_long) |>
    filter(!str_detect(referenstid, "kvartal")) |>
    filter(nchar(referenstid) != 4)

  max_referenstid <- clean_df |>
    filter(framtida_publicering == FALSE) |>
    pull(referenstid) |>
    max(na.rm = TRUE)

  list_pub <- clean_df |>
    group_by(statistik_kontakter_m_m) |>
    summarize(
      last_referenstid = max(referenstid[framtida_publicering == FALSE], na.rm = TRUE),
      next_publiceringsdatum = min(publiceringsdatum[framtida_publicering == TRUE], na.rm = TRUE),
      days_until_next = as.numeric(min(publiceringsdatum[framtida_publicering == TRUE], na.rm = TRUE) - today()),
      .groups = "drop"
    ) |>
    mutate(
      message = paste(
        "Tabell:", statistik_kontakter_m_m,
        ", sista referensdatum ", last_referenstid,
        "\nNästa publicering om ", days_until_next, " dagar, ", next_publiceringsdatum
      )
    )

  if (returnera_df == TRUE) {
    return(clean_df)
  } else if (enbart_text == FALSE) {
    return(max_referenstid)
  } else {
    return(for (message in list_pub$message) cat(message, "\n"))
  }
}

# Bakåtkompatibelt alias — filnamnet och funktionsnamnet var tidigare olika (func_scb_publicering).
#' @rdname func_scb_publiceringskalender
#' @export
func_scb_publicering <- function(...) func_scb_publiceringskalender(...)
