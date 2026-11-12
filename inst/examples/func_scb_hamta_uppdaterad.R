# När uppdaterades SCB:s tabell TAB638? Kräver internet
if (requireNamespace("curl", quietly = TRUE) && curl::has_internet()) {
  info <- func_scb_hamta_uppdaterad("TAB638")
  print(info$label)
  print(info$updated)
}
