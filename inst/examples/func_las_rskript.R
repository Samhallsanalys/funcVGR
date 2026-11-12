# Skapa en mapp med ett skript som definierar en funktion
mapp <- file.path(tempdir(), "skript")
dir.create(mapp, showWarnings = FALSE)
writeLines("dubbla <- function(x) 2 * x", file.path(mapp, "hjalpfunktioner.R"))

func_las_rskript(mapp)
dubbla(21)
