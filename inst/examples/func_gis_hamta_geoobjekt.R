# Kräver VGR:s nätverk: exemplet körs bara om geodata.vgregion.se går att nå
nar_servern <- tryCatch({
  s <- suppressWarnings(socketConnection("geodata.vgregion.se", 5432, open = "r+", timeout = 3))
  close(s)
  TRUE
}, error = function(e) FALSE)

if (nar_servern) {
  # Lista tillgängliga tabeller
  tabeller <- func_gis_hamta_geoobjekt()
  print(head(tabeller))

  # Hämta VGR:s kommunytor och rita dem
  kommuner <- func_gis_hamta_geoobjekt(table_name = "Kommunytor VG", print_map = TRUE)

  # Karta över kommunernas yta i km2
  kommuner$yta_km2 <- as.numeric(sf::st_area(kommuner)) / 1e6
  func_graf_karta(df = kommuner, df_value = "yta_km2", basemap = kommuner,
                  geom_col = "geom", data_label_show = FALSE,
                  legend_position = "right", legend_title = "Yta (km2)")
}
