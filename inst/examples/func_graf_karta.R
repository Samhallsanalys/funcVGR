# Västra Götalands kommuner (vg_kommuner) med påhittade värden.
# Aktuella kommungränser hämtas med func_gis_hamta_geoobjekt().
set.seed(1)
kommuner <- vg_kommuner
kommuner$arbetsloshet <- round(runif(nrow(kommuner), 3, 9), 1)

func_graf_karta(df = kommuner, df_value = "arbetsloshet",
                basemap = vg_kommuner, geom_col = "geometry",
                data_label_show = FALSE,
                title = "Arbetslöshet per kommun", legend_title = "Procent",
                legend_position = "right", breaks_num_group = 4,
                breaks_decimals = 1)

# Etikett med kommunnamn och värde för några utvalda kommuner
func_graf_karta(df = kommuner, df_value = "arbetsloshet",
                basemap = vg_kommuner, geom_col = "geometry",
                data_label_column = "kommun", data_label_show_value = TRUE,
                data_label_filter = c("Göteborg", "Borås", "Skövde", "Trollhättan"),
                data_label_decimals = 1, legend_position = "right")

# Kategorikarta: en färg per grupp i stället för en färgskala
kommuner$lage <- ifelse(kommuner$arbetsloshet > 6, "Över 6 procent", "Högst 6 procent")
func_graf_karta(df = kommuner, group = "lage",
                basemap = vg_kommuner, geom_col = "geometry",
                data_label_show = FALSE, legend_title = "Arbetslöshet",
                colors = c("Över 6 procent" = "#D0573A",
                           "Högst 6 procent" = "#1a9fb3"))
