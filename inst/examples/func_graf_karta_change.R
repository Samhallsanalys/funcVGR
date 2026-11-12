# Västra Götalands kommuner (vg_kommuner) med påhittad befolkning två år,
# en rad per kommun och år
set.seed(1)
bef_2015 <- round(runif(nrow(vg_kommuner), 5000, 120000), -2)
bef_2024 <- round(bef_2015 * runif(nrow(vg_kommuner), 0.95, 1.12), -2)
befolkning <- rbind(
  cbind(vg_kommuner, ar = 2015, befolkning = bef_2015),
  cbind(vg_kommuner, ar = 2024, befolkning = bef_2024))

func_graf_karta_change(df = befolkning, df_value = "befolkning",
                       basemap = vg_kommuner, geom_col = "geometry", year_column = "ar",
                       percentage_growth = TRUE, breaks_num_group = 4,
                       data_label_show = FALSE,
                       title = "Befolkningsförändring", subtitle = "Procent",
                       legend_position = "right")
