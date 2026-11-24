# Regressionstest för func_hamta_dim_region() (funcVGR 0.5.0).
# Användning: Rscript tests/regression/test_dim_region.R [paketkatalog]
# Ska misslyckas på 0.4.0 och gå igenom från 0.5.0. Skriver ingenting till disk.
# Testar rättningarna (fa_region_kod med fyra siffror, län_kod "00" för riket),
# region_kod_prefix med text och tresiffriga koder, och LA24-kolumnerna.
args <- commandArgs(trailingOnly = TRUE)
pkg <- normalizePath(if (length(args)) args[1] else ".", winslash = "/")

# keyring krävs av paketet men inte av funktionen. Saknas det läses R/-filerna in direkt.
if (requireNamespace("keyring", quietly = TRUE)) {
  suppressMessages(pkgload::load_all(pkg, quiet = TRUE))
  dim_region <- func_hamta_dim_region
} else {
  env <- suppressMessages(suppressWarnings(roxygen2::load_source(pkg)))
  dim_region <- env$func_hamta_dim_region
}

fel <- 0
kontroll <- function(namn, villkor) {
  ok <- isTRUE(tryCatch(villkor, error = function(e) FALSE))
  cat(if (ok) "OK  " else "FEL ", namn, "\n", sep = "")
  if (!ok) fel <<- fel + 1
}
d <- suppressMessages(dim_region())

# fa_region_kod har alltid fyra siffror (Östhammar, Vingåker och Katrineholm hade tre)
fa <- setNames(d$fa_region_kod, d$region_kod)
kontroll("fa_region_kod Östhammar = 0382",   identical(unname(fa["0382"]), "0382"))
kontroll("fa_region_kod Vingåker = 0483",    identical(unname(fa["0428"]), "0483"))
kontroll("fa_region_kod Katrineholm = 0483", identical(unname(fa["0483"]), "0483"))
# Koderna har två eller fyra siffror (så ser tabellen ut); en tresiffrig kod har tappat sin nolla
kontroll("ingen fa_region_kod har tre siffror",
         !any(nchar(d$fa_region_kod[d$kategori == "kommun"]) == 3))

# Riket har län_kod "00", samma som region_kod
kontroll("riket har län_kod 00", identical(d$län_kod[d$region_kod == "00"], "00"))

# region_kod_prefix: text och tal ger samma rader, tre siffror får en inledande nolla
p6_txt <- suppressMessages(dim_region(region_kod_prefix = "6"))
p6_tal <- suppressMessages(dim_region(region_kod_prefix = 6))
kontroll("prefix \"6\" ger rader", nrow(p6_txt) > 0)
kontroll("prefix \"6\" och 6 ger samma rader", identical(p6_txt$region_kod, p6_tal$region_kod))
kontroll("prefix \"6\" ger bara koder som börjar på 06", all(startsWith(p6_txt$region_kod, "06")))
kontroll("prefix 114 ger Upplands Väsby (0114)",
         identical(suppressMessages(dim_region(region_kod_prefix = 114))$region_kod, "0114"))
kontroll("prefix \"114\" ger Upplands Väsby (0114)",
         identical(suppressMessages(dim_region(region_kod_prefix = "114"))$region_kod, "0114"))

# Ett prefix som redan matchar behåller sin betydelse (som i 0.4.0)
antal <- function(p) nrow(suppressMessages(dim_region(region_kod_prefix = p)))
kontroll("prefix \"148\" ger kommunerna 1480-1489 (9 st)", antal("148") == 9)
kontroll("prefix 148 ger kommunerna 1480-1489 (9 st)", antal(148) == 9)
kontroll("prefix \"1\" ger alla koder som börjar med 1 (138 st)", antal("1") == 138)
kontroll("prefix \"2\" ger alla koder som börjar med 2 (75 st)", antal("2") == 75)
kontroll("prefix 1 (tal) ger Stockholms län, 01 (27 st)", antal(1) == 27)
kontroll("prefix c(14, 6) ger Västra Götaland och Jönköping (64 st)", antal(c(14, 6)) == 64)
kontroll("prefix \"99\" ger inga rader", antal("99") == 0)
# Två siffror är en hel länskod och får ingen nolla ("11" får inte bli "011", 0114-0117)
kontroll("prefix 11 (tal) ger inga rader", antal(11) == 0)
kontroll("prefix \"11\" ger inga rader", antal("11") == 0)
kontroll("prefix \"16\" ger inga rader", antal("16") == 0)
kontroll("prefix \"38\" ger inga rader", antal("38") == 0)
# En tom vektor ger inga rader (som i 0.4.0), inte ett fel
kontroll("prefix character(0) ger inga rader", antal(character(0)) == 0)
kontroll("prefix numeric(0) ger inga rader", antal(numeric(0)) == 0)
# NA matchar ingenting: det ignoreras i stället för att ge rader med NA, och bara NA är ett fel
na_rader <- suppressMessages(dim_region(region_kod_prefix = c("14", NA)))
kontroll("prefix c(\"14\", NA) ger Västra Götaland utan NA-rader",
         nrow(na_rader) == 50 && !anyNA(na_rader$region_kod))
kontroll("prefix c(NA, 6) (tal) ger Jönköpings län, 06 (14 st)", antal(c(NA, 6)) == 14)
kontroll("prefix c(NA, NA, 14, 6) (tal) ger 64 rader", antal(c(NA, NA, 14, 6)) == 64)
kontroll("prefix NA ger ett fel", inherits(tryCatch(dim_region(region_kod_prefix = NA), error = function(e) e), "error"))

# LA24-kolumnerna
har_la24 <- all(c("la24_region", "la24_region_kod") %in% names(d))
kontroll("kolumnerna la24_region och la24_region_kod finns", har_la24)
if (!har_la24) d$la24_region <- d$la24_region_kod <- NA_character_  # så att kontrollerna nedan misslyckas
kom <- d$kategori == "kommun"
kontroll("290 kommuner", sum(kom) == 290)
kontroll("la24_region_kod har formen LA24nn för alla kommuner", all(grepl("^LA24[0-9]{2}$", d$la24_region_kod[kom])))
kontroll("la24_region finns för alla kommuner", !anyNA(d$la24_region[kom]) && all(nzchar(d$la24_region[kom])))
kontroll("la24 är NA för län och riket", all(is.na(d$la24_region[!kom])) && all(is.na(d$la24_region_kod[!kom])))
kontroll("en LA-kod har bara ett namn",
         all(tapply(d$la24_region[kom], d$la24_region_kod[kom], function(x) length(unique(x))) == 1))
kontroll("Göteborg ligger i LA2420 Göteborg",
         identical(d$la24_region_kod[d$region_kod == "1480"], "LA2420") &&
           identical(d$la24_region[d$region_kod == "1480"], "Göteborg"))

cat(if (fel == 0) "\nAlla kontroller gick igenom\n" else sprintf("\n%d kontroller misslyckades\n", fel))
quit(status = if (fel == 0) 0 else 1)
