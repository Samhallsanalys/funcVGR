df <- data.frame(ar = rep(2021:2023, 2),
                 kon = rep(c("Kvinnor", "Män"), each = 3),
                 antal = c(120, 135, 150, 110, 128, 141))

func_graf_barchart(df, x_value = "ar", y_value = "antal", group = "kon",
                   title = "Antal per år", data_labels = TRUE,
                   data_label_decimals = 0, legend_position = "bottom")

# Staplade och 100 %-staplar
func_graf_barchart(df, x_value = "ar", y_value = "antal", group = "kon",
                   bar_type = "stacked", data_labels = TRUE,
                   data_label_position = "middle", data_label_decimals = 0)
func_graf_barchart(df, x_value = "ar", y_value = "antal", group = "kon",
                   bar_type = "filled")

# Liggande staplar sorterade med största överst
kommuner <- data.frame(kommun = c("Borås", "Göteborg", "Skövde", "Trollhättan"),
                       invanare = c(115000, 600000, 57000, 60000))
func_graf_barchart(kommuner, x_value = "kommun", y_value = "invanare",
                   horizontal = TRUE, sort_by = "value_desc",
                   data_labels = TRUE, data_label_decimals = 0)

# Egna färger per grupp, stödlinjer vid värdena, axellinjer och större
# text för export
func_graf_barchart(df, x_value = "ar", y_value = "antal", group = "kon",
                   colors = c("Kvinnor" = "#1a9fb3", "Män" = "#ffc107"),
                   show_major_grid = "y", x_axis_line = TRUE, y_axis_line = TRUE,
                   text_scale = 1.3, legend_position = "bottom")

# Förändring med negativa värden: etiketterna hamnar under staplarna,
# och utan kantlinje
forandring <- data.frame(kommun = c("Borås", "Göteborg", "Skövde", "Trollhättan"),
                         procent = c(1.2, -0.8, 2.5, -1.6))
func_graf_barchart(forandring, x_value = "kommun", y_value = "procent",
                   data_labels = TRUE, bar_line_color = NULL)
