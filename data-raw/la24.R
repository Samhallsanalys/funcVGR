# Bygger kolumnerna la24_region och la24_region_kod i func_hamta_dim_region() från SCB:s
# "Lokala arbetsmarknader 2024 BAS" (fliken 2024), i samma radordning som tabellen.
# Kör från paketets rotkatalog med sökvägen till SCB:s Excelfil
# (lokala-arbetsmarknader-20202024-bas.xlsx) som argument:
#   Rscript data-raw/la24.R <sökväg till xlsx>
# Skriptet skriver två färdiga c(...)-block till en temporär fil, som klistras in efter
# fa_region_kod i R/func_hamta_dim_region.R. Ett nytt år (LA 2025 osv.) byggs på samma sätt:
# byt fil, flik och kolumnnamn.
xlsx <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(xlsx) || !file.exists(xlsx)) stop("Ange sökvägen till SCB:s Excelfil med lokala arbetsmarknader")
flik <- "2024"
prefix <- "la24"

pkgload::load_all(".", quiet = TRUE)
d <- openxlsx::read.xlsx(xlsx, sheet = flik, colNames = FALSE, startRow = 6)
d <- d[grepl("^LA", d$X1), 1:4]
names(d) <- c("la_kod", "la_namn", "kommun_kod", "kommun_namn")
d[] <- lapply(d, trimws)  # SCB:s celler kan ha avslutande mellanslag ("LA2401 ")
d$kommun_kod <- sprintf("%04d", as.integer(d$kommun_kod))

# Samma kommuner som i tabellen, och en kod per LA-namn
ref <- suppressMessages(func_hamta_dim_region(gruppering = c("region_namn", "kategori")))
kommuner <- ref$region_kod[ref$kategori == "kommun"]
stopifnot(!anyDuplicated(d$kommun_kod), setequal(kommuner, d$kommun_kod),
          all(tapply(d$la_namn, d$la_kod, function(x) length(unique(x))) == 1))

# Län och riket får NA
idx <- match(ref$region_kod, d$kommun_kod)
format_vektor <- function(namn, x) {
  delar <- ifelse(is.na(x), "NA", paste0("\"", x, "\""))
  rader <- vapply(split(delar, ceiling(seq_along(delar) / 20)), paste, "", collapse = ", ")
  paste0("    ", namn, " = c(\n", paste0("      ", rader, collapse = ",\n"), "\n    )")
}
ut <- tempfile(paste0(prefix, "_"), fileext = ".txt")
writeLines(enc2utf8(c(paste0(format_vektor(paste0(prefix, "_region"), d$la_namn[idx]), ","),
                      format_vektor(paste0(prefix, "_region_kod"), d$la_kod[idx]))), ut, useBytes = TRUE)
message("Klistra in efter fa_region_kod: ", ut)
