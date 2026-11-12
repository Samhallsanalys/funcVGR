# Kräver internet
if (requireNamespace("curl", quietly = TRUE) && curl::has_internet()) {
  # Nästa publicering för BAS (arbetsmarknadsstatistik)
  func_scb_publiceringskalender("bas")

  # Senaste referensperiod för befolkningsstatistiken, som text
  print(func_scb_publiceringskalender("bef", enbart_text = FALSE))

  # Hela kalendern som data frame
  kalender <- func_scb_publiceringskalender(returnera_df = TRUE)
  print(head(kalender))

  # Samma sak med det äldre namnet, som finns kvar för gamla skript
  func_scb_publicering("bas")
}
