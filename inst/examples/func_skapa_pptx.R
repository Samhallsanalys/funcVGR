df <- data.frame(ar = rep(2020:2024, 2),
                 region = rep(c("Västra Götaland", "Riket"), each = 5),
                 andel = c(8.3, 7.9, 6.8, 7.0, 7.4, 8.5, 8.8, 7.5, 7.7, 8.4))

linje  <- func_graf_linjediagram(df, x_value = "ar", y_value = "andel", group = "region",
                                 legend_position = "bottom")
stapel <- func_graf_barchart(df, x_value = "ar", y_value = "andel", group = "region",
                             legend_position = "bottom")
tabell <- func_graf_tabell(df, return_object = TRUE)

fil <- func_skapa_pptx(
  list("Arbetslöshet över tid" = linje,
       "Arbetslöshet per år" = stapel,
       "Tabell" = tabell),
  output_path = file.path(tempdir(), "rapport.pptx"),
  presentation_title = "Läget i regionen")
file.exists(fil)
