# Skapa en mapp för dagens utskrifter, <katalog>/<år>/<datum>. Här i en temporär
# katalog; i ett projekt t.ex. func_utskriftsmapp(here::here("utskrifter"))
ut <- func_utskriftsmapp(tempdir(), quiet = FALSE)
ut
dir.exists(ut)

# Utan årsmapp: <katalog>/<datum>
func_utskriftsmapp(tempdir(), yearmap = FALSE)

# Filer sparas sedan i mappen
write.csv(data.frame(kommun = "Borås", antal = 10), file.path(ut, "antal.csv"),
          row.names = FALSE)
list.files(ut)
