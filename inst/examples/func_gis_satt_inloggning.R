# Frågar efter användarnamn och lösenord och sparar dem i Windows
# Autentiseringshanteraren. Funktionen kräver en interaktiv session, så exemplet
# körs inte i R CMD check. Den behövs bara för att byta uppgifter: första gången
# frågar func_gis_hamta_con() själv efter dem.
if (interactive()) {
  func_gis_satt_inloggning()
}
