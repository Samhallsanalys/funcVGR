# Updated func_dim_sni07 function with comprehensive lookup
#' Uppslag och förkortning av SNI 2007-kategorier
#'
#' Lägger till kolumner med kortnamn, SNI-bokstavskod, sektor och huvudkategori
#' till en data frame, baserat på en kolumn med SNI 2007-texter enligt SCB.
#' Kortnamnen hittas först genom exakt matchning mot uppslagstabellen, sedan
#' genom mönstermatchning mot SCB:s alternativa benämningar. Omatchade värden
#' behålls oförändrade.
#'
#' De nya kolumnerna får namn efter `sni_column_name` med suffixen `_short`,
#' `_kod`, `_sektor` och `_huvudkategori`.
#'
#' @param df Data frame med SNI-data.
#' @param sni_column_name Namn på kolumnen med SNI-kategorier.
#' @param add_short Lägg till kolumn med förkortade namn.
#' @param add_key Lägg till kolumn med SNI-bokstavskod (A, B, C, ...).
#'   Omatchade får `"Unknown"`.
#' @param add_sektor Lägg till kolumn med sektor
#'   (Primär/Sekundär/Tertiär/Offentlig/...). Omatchade får `"Okänd"`.
#' @param add_huvudkategori Lägg till kolumn med huvudkategori (A–H).
#'   Omatchade får `"Okänd"`.
#' @param return_lookup_only `TRUE` returnerar bara uppslagstabellen.
#'
#' @return `df` med de valda kolumnerna tillagda, eller uppslagstabellen om
#'   `return_lookup_only = TRUE`.
#' @export
#'
#' @example inst/examples/func_hamta_dim_sni07.R
func_hamta_dim_sni07 <- function(df = NULL,  # Input dataframe containing SNI data
                           sni_column_name = "näringsgren SNI 2007",  # Name of the column containing SNI categories (default: "näringsgren SNI 2007")
                           add_short = TRUE,  # If TRUE, creates a column with shortened, readable SNI names (default: TRUE)
                           add_key = FALSE,  # If TRUE, adds official SNI letter codes (A, B, C, etc.) (default: FALSE)
                           add_sektor = FALSE,  # If TRUE, categorizes industries into economic sectors (Primär/Sekundär/Tertiär/Offentlig) (default: FALSE)
                           add_huvudkategori = FALSE,  # If TRUE, groups industries into main logical categories (A-H) (default: FALSE)
                           return_lookup_only = FALSE) {  # If TRUE, returns only the lookup table without processing data (default: FALSE) 
  
# Complete SNI 2007 lookup table based on official SCB data
sni_lookup <- data.frame(
  sni_kod = c(
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
    # Combined categories from your original data
    "A+U+US", "B+C", "D+E", "M+N", "R+S+T+U", "US"
  ),
  sni_text = c(
    "Jordbruk, skogsbruk och fiske",
    "Utvinning av mineral", 
    "Tillverkning",
    "Försörjning av el, gas, värme och kyla",
    "Vattenförsörjning; avloppsrening, avfallshantering och sanering",
    "Byggverksamhet",
    "Handel; reparation av motorfordon och motorcyklar",
    "Transport och magasinering",
    "Hotell- och restaurangverksamhet",
    "Informations- och kommunikationsverksamhet",
    "Finans- och försäkringsverksamhet",
    "Fastighetsverksamhet",
    "Verksamhet inom juridik, ekonomi, vetenskap och teknik",
    "Uthyrning, fastighetsservice, resetjänster och andra stödtjänster",
    "Offentlig förvaltning och försvar; obligatorisk socialförsäkring",
    "Utbildning",
    "Vård och omsorg; sociala tjänster",
    "Kultur, nöje och fritid",
    "Annan serviceverksamhet",
    "Förvärvsarbete i hushåll; hushållens produktion av diverse varor och tjänster för eget bruk",
    "Verksamhet vid internationella organisationer, utländska ambassader o.d.",
    # Combined categories
    "Total",
    "Utvinning av mineral; Tillverkning",
    "Försörjning av el, gas, värme och kyla; Vattenförsörjning; avloppsrening, avfallshantering och sanering",
    "Verksamhet inom juridik, ekonomi, vetenskap och teknik; Uthyrning, fastighetsservice, resetjänster och andra stödtjänster",
    "Kultur, nöje och fritid; Annan serviceverksamhet; Förvärvsarbete i hushåll; Verksamhet vid internationella organisationer",
    "uppgift saknas"
  ),
  sni_text_short = c(
    "Jordbruk, skogsbruk och fiske",
    "Utvinning av mineral",
    "Tillverkning", 
    "El, gas, värme och kyla",
    "Vatten och avfall",
    "Byggverksamhet",
    "Handel och reparation",
    "Transport och magasinering",
    "Hotell och restaurang",
    "Information och kommunikation",
    "Finans och försäkring",
    "Fastighetsverksamhet",
    "Juridik, ekonomi och teknik",
    "Uthyrning och stödtjänster",
    "Offentlig förvaltning",
    "Utbildning",
    "Vård och omsorg",
    "Kultur och fritid",
    "Annan service",
    "Hushållsarbete",
    "Internationella organisationer",
    # Combined categories short
    "Total",
    "Tillverkning och gruvor",
    "Energi och miljö",
    "Konsult och stödtjänster",
    "Kultur och övrig service",
    "uppgift saknas"
  ),

  huvudgrupp_kod = c(
    "01-03", "05-09", "10-33", "35", "36-39", "41-43", "45-47", "49-53", "55-56", 
    "58-63", "64-66", "68", "69-75", "77-82", "84", "85", "86-88", "90-93", 
    "94-96", "97-98", "99",
    # Combined categories
    "01-03,97-99", "05-33", "35-39", "69-82", "90-99", "US"
  ),
  sektor = c(
    "Primär", "Sekundär", "Sekundär", "Sekundär", "Sekundär", "Sekundär", 
    "Tertiär", "Tertiär", "Tertiär", "Tertiär", "Tertiär", "Tertiär", 
    "Tertiär", "Tertiär", "Offentlig", "Offentlig", "Offentlig", 
    "Tertiär", "Tertiär", "Hushåll", "Övrigt",
    # Combined categories
    "Total", "Sekundär", "Sekundär", "Tertiär", "Tertiär", "Okänd"
  ),
  sni_huvudkategori = c(
    "A. Primärnäringar", "B. Industri och utvinning", "B. Industri och utvinning", 
    "B. Industri och utvinning", "B. Industri och utvinning", "B. Industri och utvinning",
    "C. Handel och transport", "C. Handel och transport", "C. Handel och transport",
    "D. Information och finans", "D. Information och finans", "D. Information och finans",
    "E. Företagstjänster", "E. Företagstjänster", "F. Offentliga tjänster", 
    "F. Offentliga tjänster", "F. Offentliga tjänster", "G. Personliga tjänster", 
    "G. Personliga tjänster", "H. Hushåll och övrigt", "H. Hushåll och övrigt",
    # Combined categories
    "Total", "B. Industri och utvinning", "B. Industri och utvinning", 
    "E. Företagstjänster", "G. Personliga tjänster", "Okänd"
  ),
  stringsAsFactors = FALSE
)

  # If user only wants the lookup table
  if (return_lookup_only) {
    return(sni_lookup)
  }
  
  # Error handling
  if (is.null(df)) {
    stop("Error: Please provide a dataframe or set return_lookup_only = TRUE to get the lookup table.")
  }
  
  if (!sni_column_name %in% names(df)) {
    stop(paste("Error: Column", sni_column_name, "not found in the dataframe."))
  }
  
  # Start with the original dataframe
  result_df <- df

  # Match on the column as character: for a factor column, lookup[x] indexed by the factor's
  # integer codes and returned the wrong categories, and TRUE ~ x failed on the type mismatch
  sni_chr <- as.character(df[[sni_column_name]])
  
  # Create lookup vectors for easier matching
  lookup_short <- setNames(sni_lookup$sni_text_short, sni_lookup$sni_text)
  lookup_key <- setNames(sni_lookup$sni_kod, sni_lookup$sni_text)
  lookup_sektor <- setNames(sni_lookup$sektor, sni_lookup$sni_text)
  lookup_huvudkategori <- setNames(sni_lookup$sni_huvudkategori, sni_lookup$sni_text)
  
  # Add short names if requested
  if (add_short) {
    result_df <- result_df %>%
      mutate(
        !!paste0(sni_column_name, "_short") := case_when(
          # Direct matches from lookup table
          sni_chr %in% names(lookup_short) ~ lookup_short[sni_chr],
          # Pattern matching for variations
          sni_chr == "Total" ~ "Total",
          str_detect(tolower(sni_chr), "företag inom jordbruk.*skogsbruk.*fiske") ~ "Jordbruk, skogsbruk och fiske",
          str_detect(tolower(sni_chr), "tillverkningsindustri.*gruvor.*mineral") ~ "Industri och utvinning",
          str_detect(tolower(sni_chr), "företag inom energi.*miljö") ~ "Energi och miljö",
          str_detect(tolower(sni_chr), "byggindustri") ~ "Byggverksamhet",
          str_detect(tolower(sni_chr), "handel.*service.*motor") ~ "Handel och reparation",
          str_detect(tolower(sni_chr), "transport.*magasin") ~ "Transport och magasinering",
          str_detect(tolower(sni_chr), "hotell.*restaurang") ~ "Hotell och restaurang",
          str_detect(tolower(sni_chr), "informations.*kommunikation") ~ "Information och kommunikation",
          str_detect(tolower(sni_chr), "kreditinstitut.*försäkring") ~ "Finans och försäkring",
          str_detect(tolower(sni_chr), "fastighetsbolag.*fastighetsförvaltare") ~ "Fastighetsverksamhet",
          str_detect(tolower(sni_chr), "företag inom juridik.*ekonomi.*vetenskap.*teknik.*uthyrning") ~ "Konsult och stödtjänster",
          str_detect(tolower(sni_chr), "civila myndigheter.*försvar") ~ "Offentlig förvaltning",
          str_detect(tolower(sni_chr), "utbildningsväsendet") ~ "Utbildning",
          str_detect(tolower(sni_chr), "enheter för vård.*omsorg.*socialtjänst") ~ "Vård och omsorg",
          str_detect(tolower(sni_chr), "enheter för kultur.*nöje.*fritid.*service") ~ "Kultur och övrig service",
          str_detect(tolower(sni_chr), "uppgift saknas") ~ "uppgift saknas",
          TRUE ~ sni_chr  # Keep original if no match
        )
      )
  }
  
  # Add key codes if requested
  if (add_key) {
    result_df <- result_df %>%
      mutate(
        !!paste0(sni_column_name, "_kod") := case_when(
          sni_chr %in% names(lookup_key) ~ lookup_key[sni_chr],
          TRUE ~ "Unknown"
        )
      )
  }
  
  # Add sektor if requested
  if (add_sektor) {
    result_df <- result_df %>%
      mutate(
        !!paste0(sni_column_name, "_sektor") := case_when(
          sni_chr %in% names(lookup_sektor) ~ lookup_sektor[sni_chr],
          TRUE ~ "Okänd"
        )
      )
  }
  
  # Add huvudkategori if requested
  if (add_huvudkategori) {
    result_df <- result_df %>%
      mutate(
        !!paste0(sni_column_name, "_huvudkategori") := case_when(
          sni_chr %in% names(lookup_huvudkategori) ~ lookup_huvudkategori[sni_chr],
          TRUE ~ "Okänd"
        )
      )
  }
  
  return(result_df)
  }
