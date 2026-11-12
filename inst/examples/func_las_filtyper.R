# Skapa en mapp med två csv-filer att läsa
mapp <- file.path(tempdir(), "exempeldata")
dir.create(mapp, showWarnings = FALSE)
write.csv(data.frame(kommun = "Borås", antal = 10), file.path(mapp, "boras.csv"),
          row.names = FALSE)
write.csv(data.frame(kommun = "Skövde", antal = 7), file.path(mapp, "skovde.csv"),
          row.names = FALSE)

func_las_filtyper(mapp, "csv")                      # lista med sökvägar
func_las_filtyper(mapp, "csv", retur = "df")        # alla filer i en data frame
