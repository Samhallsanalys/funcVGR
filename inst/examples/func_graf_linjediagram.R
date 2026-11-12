df <- data.frame(
  ar     = rep(2015:2024, 2),
  region = rep(c("Västra Götaland", "Riket"), each = 10),
  andel  = c(7.1, 6.9, 6.5, 6.2, 6.4, 8.3, 7.9, 6.8, 7.0, 7.4,
             7.4, 7.0, 6.7, 6.3, 6.8, 8.5, 8.8, 7.5, 7.7, 8.4))

func_graf_linjediagram(df, x_value = "ar", y_value = "andel",
                       group = "region", legend_position = "bottom",
                       title = "Arbetslöshet", y_axis_title = "Procent",
                       data_labels = TRUE, data_label_first_last = TRUE,
                       data_label_decimals = 1)

# Lyft fram en grupp och lägg till en referenslinje
func_graf_linjediagram(df, x_value = "ar", y_value = "andel", group = "region",
                       highlight_groups = "Västra Götaland", legend_position = "bottom",
                       x_break_line = 2020, y_axis_min = 0)

# Tona ned övriga grupper och skriv gruppnamnet i slutet av den framhävda
# linjen, som ren text utan ruta (kräver gghighlight)
if (requireNamespace("gghighlight", quietly = TRUE)) {
  func_graf_linjediagram(df, x_value = "ar", y_value = "andel", group = "region",
                         group_highlight = "Västra Götaland")
}

# Egna färger per grupp, vågräta stödlinjer, ingen y-axellinje och större
# text för export
func_graf_linjediagram(df, x_value = "ar", y_value = "andel", group = "region",
                       colors = c("Västra Götaland" = "#1a9fb3", "Riket" = "#37474F"),
                       show_major_grid = "y", y_axis_line = FALSE,
                       legend_position = "bottom", text_scale = 1.3)

# Datum på x-axeln
manad <- data.frame(datum = seq(as.Date("2023-01-01"), by = "month", length.out = 24),
                    antal = round(100 + 10 * sin(1:24 / 2)))
func_graf_linjediagram(manad, x_value = "datum", y_value = "antal",
                       x_date_labels = "%b %Y")
