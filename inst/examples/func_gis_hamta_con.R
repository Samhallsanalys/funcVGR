# Kräver VGR:s nätverk: exemplet körs bara om geodata.vgregion.se går att nå
nar_servern <- tryCatch({
  s <- suppressWarnings(socketConnection("geodata.vgregion.se", 5432, open = "r+", timeout = 3))
  close(s)
  TRUE
}, error = function(e) FALSE)

if (nar_servern) {
  # Anslutningen används med DBI, och stängs när man är klar
  con <- func_gis_hamta_con()
  print(DBI::dbGetQuery(con, "SELECT count(*) FROM geometry_columns"))
  DBI::dbDisconnect(con)

  # GDAL-strängen läses direkt med sf
  kommuner <- sf::st_read(func_gis_hamta_pgstring(),
                          query = 'SELECT * FROM public."Kommunytor VG"', quiet = TRUE)
  print(nrow(kommuner))
}
