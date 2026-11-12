# Slumpade punkter i Västra Götaland (vg_kommuner), tätare kring Göteborg
set.seed(1)
spridda <- sf::st_sample(sf::st_union(vg_kommuner), 200)
gbg <- sf::st_buffer(sf::st_sfc(sf::st_point(c(322000, 6403000)), crs = 3006), 20000)
tatt <- sf::st_sample(sf::st_intersection(sf::st_union(vg_kommuner), gbg), 150)
punkter <- sf::st_sf(antal = rpois(350, 10), geometry = c(spridda, tatt))

func_graf_heatmap_coordinats(df = punkter, df_varde = "antal", basemap = vg_kommuner)

# Med rubrik, källa och förklaring
func_graf_heatmap_coordinats(df = punkter, df_varde = "antal", basemap = vg_kommuner,
                             title = "Täthet", annotation_text = "Källa: påhittade data",
                             show_legend = TRUE)
