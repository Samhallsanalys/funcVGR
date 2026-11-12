df <- data.frame(Region = c("Västra Götaland", "Skåne", "Riket"),
                 Invånare = c(1744859, 1414659, 10551707),
                 Andel = c(16.5, 13.4, 100))

# Som flextable-objekt, t.ex. till func_skapa_pptx()
ft <- func_graf_tabell(df, return_object = TRUE, title = "Befolkning 2024",
                       highlight_row = "Västra Götaland", decimal_digits = 1,
                       footer_text = "Källa: SCB")
ft

# Som PNG-bild i en temporär katalog. Kräver webshot2 och Chrome eller Edge, och körs
# bara interaktivt eftersom funktionen annars kan försöka installera PhantomJS
if (interactive() && requireNamespace("webshot2", quietly = TRUE)) {
  func_graf_tabell(df, filename = "befolkning.png", file_path = tempdir(),
                   title = "Befolkning 2024", highlight_row = "Västra Götaland")
}
