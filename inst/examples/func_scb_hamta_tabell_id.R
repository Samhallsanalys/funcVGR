# Ett tabell-id returneras som det är, utan sökning
func_scb_hamta_tabell_id("TAB638")

# Sök fram id för ett äldre tabellnamn. Kräver internet
if (requireNamespace("curl", quietly = TRUE) && curl::has_internet()) {
  func_scb_hamta_tabell_id("BefolkningNy")
}
