# Påhittade arbetsställen i Västra Götaland (vg_kommuner): spridda över
# länet, plus ett tätt kluster kring Göteborg
set.seed(1)
punkter <- sf::st_sample(sf::st_union(vg_kommuner), 300)
gbg <- sf::st_buffer(sf::st_sfc(sf::st_point(c(322000, 6403000)), crs = 3006), 20000)
tatt <- sf::st_sample(sf::st_intersection(sf::st_union(vg_kommuner), gbg), 200)
arbetsstallen <- sf::st_sf(antal = rpois(500, 10),
                           bransch = sample(c("Handel", "Industri"), 500, TRUE),
                           geometry = c(punkter, tatt))

func_graf_karta_heatmap(df = arbetsstallen, df_value = "antal", basemap = vg_kommuner,
                        title = "Arbetsställen", legend_position = "right",
                        legend_title = "Täthet")

# Punkterna färgade efter bransch, med egna färger per bransch
func_graf_karta_heatmap(df = arbetsstallen, df_value = "antal", basemap = vg_kommuner,
                        group = "bransch", legend_position = "bottom",
                        colors = c("Handel" = "#1a9fb3", "Industri" = "#ffc107"),
                        legend_key_shape = "circle", point_size = 1)

# Samma karta med det äldre namnet, som finns kvar för gamla skript
graf_karta_heatmap(df = arbetsstallen, df_value = "antal", basemap = vg_kommuner)
