# Påhittade data: utbildningsnivå och sysselsättning i 18 kommuner
set.seed(1)
kommuner <- data.frame(
  kommun  = c("Göteborg", "Borås", "Trollhättan", "Skövde", "Uddevalla", "Alingsås",
              "Lidköping", "Kungsbacka", "Mölndal", "Kungälv", "Lerum", "Partille",
              "Vänersborg", "Falköping", "Mariestad", "Ulricehamn", "Stenungsund", "Tjörn"),
  region  = rep(c("Göteborgsregionen", "Sjuhärad", "Fyrbodal", "Skaraborg"), length.out = 18),
  invanare = round(c(600000, 115000, 60000, 58000, 57000, 42000, 40000, 85000, 70000,
                     47000, 44000, 40000, 40000, 33000, 30000, 25000, 27000, 16000))
)
kommuner$hogutb    <- round(runif(18, 22, 50), 1)                                    # andel med eftergymnasial utbildning, %
kommuner$sysselsatt <- round(70 + 0.25 * kommuner$hogutb + rnorm(18, 0, 2), 1)       # sysselsättningsgrad, %

# Enklaste anropet: bara de obligatoriska parametrarna
func_graf_spridningsdiagram(kommuner, x_value = "hogutb", y_value = "sysselsatt")

# Färg per region, kommunnamn vid punkterna, trendlinje med konfidensband och
# referenslinjer vid medelvärdena
func_graf_spridningsdiagram(kommuner, x_value = "hogutb", y_value = "sysselsatt", group = "region",
                            data_labels = TRUE, data_label_column = "kommun",
                            trend_line = TRUE, trend_line_se = TRUE,
                            x_break_line = "mean", y_break_line = "mean",
                            x_axis_title = "Eftergymnasial utbildning (%)",
                            y_axis_title = "Sysselsättningsgrad (%)",
                            title = "Utbildning och sysselsättning")

# Bubbeldiagram: punktens storlek efter antal invånare, vit kantlinje och
# etiketter bara för två kommuner
func_graf_spridningsdiagram(kommuner, x_value = "hogutb", y_value = "sysselsatt",
                            point_size_column = "invanare", point_size_title = "Invånare",
                            point_border_color = "white", point_alpha = 0.7,
                            data_labels = TRUE, data_label_column = "kommun",
                            data_label_filter = c("Borås", "Skövde"))

# Samma diagram under det engelska namnet, en panel och trendlinje per region
func_graf_scatterplot(kommuner, x_value = "hogutb", y_value = "sysselsatt", group = "region",
                      facet_var = "region", trend_line = "group", legend_position = "none")
