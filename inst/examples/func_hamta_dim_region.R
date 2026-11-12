# Alla kolumner för VGR:s kommuner och länet, plus riket
vg <- func_hamta_dim_region(hamta_enbart_VGR = TRUE, hamta_riket = TRUE)
head(vg)

# Skåne och Västra Götaland (län och kommuner)
head(func_hamta_dim_region(gruppering = "region_namn", region_kod_prefix = c("12", "14")))

# Prefix som tal: 6 blir "06" (Jönköpings län)
func_hamta_dim_region(gruppering = "region_namn", region_kod_prefix = c(14, 6),
                      hamta_lan = TRUE)

# Bara namn och SKR-kommungrupp för kommuner, och antal kommuner per grupp
kommuner <- func_hamta_dim_region(gruppering = c("region_namn", "skr_kommungrupp"),
                                  hamta_kommuner = TRUE)
table(kommuner$skr_kommungrupp)

# Koppla tabellen till egna data med regionkoden
mina_data <- data.frame(region_kod = c("1480", "1490", "1496"),
                        invanare = c(604000, 115000, 57000))
merge(mina_data, func_hamta_dim_region(gruppering = c("region_namn", "fa_region")))
