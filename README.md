# funcVGR

Hjälpfunktioner för Samhällsanalys i Västra Götalandsregionen: diagram och kartor
i VGR:s grafiska profil, tabeller som bild, PowerPoint-export, uppslagstabeller
för regioner och SNI 2007, geodata från VGR:s PostGIS-databas och
publiceringsdatum från SCB.

Paketet ersätter de fristående skripten i `func_vgr`, som tidigare lästes in med
`source()`. Funktionerna har samma namn och argument som i skripten.

## Installation

Kräver R 4.1 eller senare. Paketet installeras från GitHub med **remotes**, och
beroenden från CRAN installeras automatiskt:

```r
install.packages("remotes")
remotes::install_github("Samhallsanalys/funcVGR", dependencies = TRUE, build_vignettes = TRUE)
```

`build_vignettes = TRUE` gör att vignetten (en genomgång av paketet) följer med
installationen. Det kräver pandoc, som ingår i RStudio.

### Åtkomst till GitHub

Repot är privat. Du behöver ett GitHub-konto med åtkomst till organisationen
Samhallsanalys, och R behöver en personlig åtkomsttoken (PAT) för att hämta
paketet. Det görs en gång per dator:

```r
install.packages(c("usethis", "gitcreds"))
usethis::create_github_token()   # öppnar GitHub: skapa en token med behörigheten "repo"
gitcreds::gitcreds_set()         # klistra in token när R frågar
```

Token sparas i Windows Autentiseringshanteraren via Git, så Git for Windows måste
vara installerat. Har du redan klonat eller pushat repot med Git på datorn finns
oftast en inloggning sparad, och då behövs inte de här stegen. Felet
`HTTP error 404. Not Found` betyder att token saknas eller att kontot inte har
åtkomst till repot.

### Från en lokal kopia

Har du källkoden på datorn, t.ex. en klon av repot, installerar du från mappen:

```r
remotes::install_local("sökväg/till/funcVGR", dependencies = TRUE, build_vignettes = TRUE)
```

### Valfria paket

Några funktioner använder paket som inte installeras automatiskt:

| Paket         | Behövs för                                                                          |
|---------------|-------------------------------------------------------------------------------------|
| `ggfx`        | `data_label_glow = TRUE` (glöd runt etiketter) i diagram och kartor                 |
| `gghighlight` | `group_highlight` i `func_graf_linjediagram()`                                      |
| `ragg`        | Rekommenderad grafikenhet med datorns typsnitt, se [Grafikinställning i RStudio](#grafikinställning-i-rstudio) |
| `webshot2`    | PNG-export i `func_graf_tabell()` (kräver Chrome eller Edge)                        |

```r
install.packages(c("ggfx", "gghighlight", "ragg", "webshot2"))
```

### Grafikinställning i RStudio

Diagrammen använder typsnitt som finns installerade på datorn (standard Verdana)
och hittar dem med paketet **systemfonts**. Rekommendationen är att låta RStudio
rita med grafikenheten AGG från paketet ragg, som använder systemfonts direkt:

1. Installera ragg: `install.packages("ragg")`
2. I RStudio: **Tools → Global Options → General → Graphics**
3. Sätt **Backend** till **AGG** och klicka **OK**

Med AGG blir diagrammen i RStudios Plots-panel likadana som när de sparas med
`ggsave()`, som använder ragg automatiskt för PNG när ragg är installerat. Texten
blir också skarpare och å, ä och ö ritas korrekt.

Diagrammen fungerar även med standardinställningen (backend "Default") och i
Rgui. Paketet registrerar då typsnittet hos Windows egen grafikenhet, så att
Verdana används där också.

### Inloggning till geodatabasen

Användarnamn och lösenord till VGR:s geodatabas (`geodata.vgregion.se`) sparas
i Windows Autentiseringshanteraren (Credential Manager) med paketet keyring, under
tjänsten `geodata.vgregion.se`. Första gången du hämtar något från geodatabasen
frågar paketet efter dem och sparar dem där, så de behöver bara anges en gång per
dator. Lösenordet anges i en dialogruta och syns aldrig i konsolen eller i koden.

Det kräver en interaktiv R-session, t.ex. RStudio. Ska skript köras med `Rscript`
eller schemalagt, spara uppgifterna först i RStudio:

```r
func_gis_satt_inloggning()
```

Samma funktion byter uppgifterna, t.ex. efter ett nytt lösenord. Datorn måste
också vara ansluten till VGR:s nätverk, eftersom servern bara nås inifrån.

Raderna `GEODATA_USER` och `GEODATA_PASSWORD` i `.Renviron` används inte och kan
tas bort (öppna filen med `usethis::edit_r_environ()`).

### Uppdatera

Kör `remotes::install_github()` igen med samma argument. Den installerar bara
om det finns en ny commit på GitHub; `force = TRUE` installerar om ändå. Starta
om R först om paketet redan är laddat.

## Kom igång

```r
library(funcVGR)
?funcVGR                  # översikt över alla funktioner
?func_graf_linjediagram   # hjälp för en enskild funktion
```

Vignetten "Kom igång med funcVGR" går igenom ett typiskt arbetsflöde, från
diagram och kartor till en färdig PowerPoint-presentation. Öppna den med
`vignette("funcVGR", package = "funcVGR")`. Den finns bara om paketet
installerades med `build_vignettes = TRUE`.

Varje funktion har körbara exempel i sin hjälpsida, t.ex. `example(func_graf_karta)`.
I hjälpsidorna slutar beskrivningen av de parametrar som måste anges med
"Obligatorisk.". Övriga parametrar har standardvärden. Se även
[Obligatoriska parametrar](#obligatoriska-parametrar).

Ändringar mellan versionerna finns i `NEWS.md`, eller med
`news(package = "funcVGR")`.

## Exempel

Varje exempel nedan kan köras för sig efter `library(funcVGR)`. Data skapas i
exemplet. Undantag är geodatabasen, som kräver VGR:s nätverk, och SCB, som
kräver internetanslutning.

### Linjediagram

```r
arbetsloshet <- data.frame(
  ar     = rep(2015:2024, 2),
  region = rep(c("Västra Götaland", "Riket"), each = 10),
  andel  = c(7.1, 6.9, 6.5, 6.2, 6.4, 8.3, 7.9, 6.8, 7.0, 7.4,
             7.4, 7.0, 6.7, 6.3, 6.8, 8.5, 8.8, 7.5, 7.7, 8.4)
)

func_graf_linjediagram(
  arbetsloshet, x_value = "ar", y_value = "andel", group = "region",
  title = "Arbetslöshet 2015–2024", y_axis_title = "Procent",
  legend_position = "bottom",
  data_labels = TRUE, data_label_first_last = TRUE, data_label_decimals = 1
)

# Lyft fram en grupp och lägg till en referenslinje
func_graf_linjediagram(
  arbetsloshet, x_value = "ar", y_value = "andel", group = "region",
  highlight_groups = "Västra Götaland", x_break_line = 2020,
  y_axis_min = 0, legend_position = "bottom"
)
```

### Stapeldiagram

```r
sysselsatta <- data.frame(ar    = rep(2021:2023, 2),
                          kon   = rep(c("Kvinnor", "Män"), each = 3),
                          antal = c(120, 135, 150, 110, 128, 141))

func_graf_barchart(sysselsatta, x_value = "ar", y_value = "antal", group = "kon",
                   title = "Antal per år", legend_position = "bottom",
                   data_labels = TRUE, data_label_decimals = 0)

# Staplade staplar med etiketter mitt i varje del
func_graf_barchart(sysselsatta, x_value = "ar", y_value = "antal", group = "kon",
                   bar_type = "stacked", data_labels = TRUE,
                   data_label_position = "middle", data_label_decimals = 0)

# Liggande staplar sorterade med största överst
invanare <- data.frame(kommun   = c("Borås", "Göteborg", "Skövde", "Trollhättan"),
                       invanare = c(115000, 600000, 57000, 60000))
func_graf_barchart(invanare, x_value = "kommun", y_value = "invanare",
                   horizontal = TRUE, sort_by = "value_desc",
                   data_labels = TRUE, data_label_decimals = 0)
```

### Dumbbell-diagram (före och efter)

```r
fore_efter <- data.frame(
  kommun = rep(c("Borås", "Göteborg", "Skövde", "Trollhättan"), 2),
  ar     = rep(c("2014", "2024"), each = 4),
  andel  = c(8.1, 7.4, 5.2, 10.3, 6.9, 6.8, 4.1, 9.2)
)

func_graf_dumbbell(fore_efter, x_value = "kommun", y_value = "andel", group = "ar",
                   highlight_x_values = "Göteborg",
                   title = "Arbetslöshet 2014 och 2024")
```

### Spridningsdiagram

```r
kommuner <- data.frame(
  kommun     = c("Göteborg", "Borås", "Trollhättan", "Skövde", "Uddevalla", "Alingsås"),
  hogutb     = c(48, 33, 30, 36, 29, 41),
  sysselsatt = c(78, 80, 76, 82, 77, 83),
  invanare   = c(600000, 115000, 60000, 58000, 57000, 42000)
)

# Kommunnamn vid punkterna, trendlinje och referenslinjer vid medelvärdena
func_graf_spridningsdiagram(kommuner, x_value = "hogutb", y_value = "sysselsatt",
                            data_labels = TRUE, data_label_column = "kommun",
                            trend_line = TRUE, x_break_line = "mean", y_break_line = "mean")

# Bubbeldiagram: punktens storlek efter antal invånare
func_graf_spridningsdiagram(kommuner, x_value = "hogutb", y_value = "sysselsatt",
                            point_size_column = "invanare", point_size_title = "Invånare")
```

### Histogram

```r
personer <- data.frame(alder = round(runif(1000, 18, 80)),
                       kon   = sample(c("Kvinnor", "Män"), 1000, replace = TRUE))

# Femårsklasser staplade per kön, med medianen som referenslinje
func_graf_histogram(personer, x_value = "alder", group = "kon", bin_width = 5,
                    x_break_line = "median")

# Fördelningarnas form: andel inom varje kön, ritade över varandra
func_graf_histogram(personer, x_value = "alder", group = "kon", bin_width = 5,
                    bar_type = "overlay", histogram_y = "percent")
```

### Lådagram

```r
inkomst <- data.frame(region  = rep(c("Göteborgsregionen", "Sjuhärad", "Fyrbodal"), each = 200),
                      kon     = sample(c("Kvinnor", "Män"), 600, replace = TRUE),
                      inkomst = round(rlnorm(600, log(300), 0.3)))

# En låda per delregion, sorterade efter medianen, med medelvärde och medianetikett
func_graf_ladagram(inkomst, x_value = "region", y_value = "inkomst",
                   sort_by = "value_desc", box_mean = TRUE, data_labels = TRUE)

# Kvinnor och män bredvid varandra, liggande lådor
func_graf_ladagram(inkomst, x_value = "region", y_value = "inkomst", group = "kon",
                   horizontal = TRUE)
```

### Färger och tema

```r
func_fargtema("vgr")          # VGR:s palett (6 färger)
func_fargtema("ru", n = 10)   # 10 färger interpolerade från RU-paletten
func_fargtema("ru_kontrast")  # 7 tydligt olika färger, för diagram med många grupper

library(ggplot2)
arbetsloshet <- data.frame(ar     = rep(2020:2024, 2),
                           region = rep(c("Västra Götaland", "Riket"), each = 5),
                           andel  = c(8.3, 7.9, 6.8, 7.0, 7.4, 8.5, 8.8, 7.5, 7.7, 8.4))

ggplot(arbetsloshet, aes(ar, andel, color = region)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(values = func_fargtema("vgr")) +
  labs(title = "Arbetslöshet", x = NULL, y = "Procent", color = NULL) +
  func_tema_vgr()
```

Diagram- och kartfunktionerna har måttliga textstorlekar som standard (rubrik
16 punkter, axeltext 11 punkter). `text_scale` multiplicerar alla
textstorlekar på en gång, t.ex. `text_scale = 1.3` för en stor export.
Gruppfärger kan anges med namn, t.ex.
`colors = c("Kvinnor" = "#1a9fb3", "Män" = "#ffc107")`, så att samma grupp
alltid får samma färg.

Typsnitt hämtas från datorns installerade typsnitt via **systemfonts**.
Standard är Verdana. Saknas typsnittet används `"sans"`. Verdana används på
skärmen (bäst med AGG-backenden, se
[Grafikinställning i RStudio](#grafikinställning-i-rstudio)) och vid export till
PNG, SVG och PowerPoint. R:s vanliga `pdf()`-enhet kan inte läsa datorns
typsnitt och använder då Helvetica. För Verdana i PDF sparar du med
`ggsave("diagram.pdf", device = cairo_pdf)`.

### Kartor

Kartfunktionerna tar `sf`-objekt. Paketet innehåller `vg_kommuner`, gränserna för
Västra Götalands 49 kommuner i SWEREF 99 TM, så att exemplen går att köra utan
nätverk. Värdena nedan är påhittade:

```r
set.seed(1)
kommuner <- vg_kommuner
kommuner$arbetsloshet <- round(runif(nrow(kommuner), 3, 9), 1)

# Koropletkarta med värden i klasser, etiketter för några kommuner
func_graf_karta(df = kommuner, df_value = "arbetsloshet",
                basemap = vg_kommuner, geom_col = "geometry",
                breaks_num_group = 4, breaks_decimals = 1,
                data_label_column = "kommun", data_label_show_value = TRUE,
                data_label_filter = c("Göteborg", "Borås", "Skövde", "Trollhättan"),
                data_label_decimals = 1, legend_position = "right",
                legend_title = "Procent", title = "Arbetslöshet per kommun")

# Kategorikarta: en färg per grupp i stället för en färgskala
kommuner$lage <- ifelse(kommuner$arbetsloshet > 6, "Över 6 procent", "Högst 6 procent")
func_graf_karta(df = kommuner, group = "lage",
                basemap = vg_kommuner, geom_col = "geometry",
                data_label_show = FALSE, legend_title = "Arbetslöshet")

# Förändring mellan första och sista året: en rad per område och år
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

# Heatmap över punkter, här 300 slumpade arbetsställen
arbetsstallen <- sf::st_sf(antal    = rpois(300, 10),
                           geometry = sf::st_sample(sf::st_union(vg_kommuner), 300))
func_graf_karta_heatmap(df = arbetsstallen, df_value = "antal", basemap = vg_kommuner,
                        title = "Arbetsställen", legend_position = "right",
                        legend_title = "Punkter per km²")
```

Heatmapens förklaring visar tätheten som antal punkter per km², oavsett vilket
koordinatsystem kartan har. Kartan ritas i bakgrundskartans koordinatsystem.

Riktiga kommun- och länsgränser hämtas från VGR:s geodatabas. Det kräver VGR:s
nätverk (se [Inloggning till geodatabasen](#inloggning-till-geodatabasen)):

```r
tabeller <- func_gis_hamta_geoobjekt()                              # lista tillgängliga tabeller
kommuner <- func_gis_hamta_geoobjekt(table_name = "Kommunytor VG")  # VGR:s 49 kommuner

kommuner$yta_km2 <- as.numeric(sf::st_area(kommuner)) / 1e6
func_graf_karta(df = kommuner, df_value = "yta_km2", basemap = kommuner,
                geom_col = "geom", data_label_show = FALSE,
                legend_position = "right", legend_title = "Yta (km2)")
```

### Tabell som bild

```r
befolkning <- data.frame(Region   = c("Västra Götaland", "Skåne", "Riket"),
                         Invånare = c(1744859, 1414659, 10551707),
                         Andel    = c(16.5, 13.4, 100))

# Som flextable-objekt, t.ex. till PowerPoint
ft <- func_graf_tabell(befolkning, return_object = TRUE, title = "Befolkning 2024",
                       highlight_row = "Västra Götaland", footer_text = "Källa: SCB")
ft

# Som PNG-bild (kräver webshot2 och Chrome/Edge)
func_graf_tabell(befolkning, filename = "befolkning.png", file_path = tempdir(),
                 title = "Befolkning 2024", highlight_row = "Västra Götaland")
```

### PowerPoint

Presentationen byggs på VGR:s mall, som följer med paketet. Namnen i listan
blir rubriker på bilderna.

```r
arbetsloshet <- data.frame(ar     = rep(2020:2024, 2),
                           region = rep(c("Västra Götaland", "Riket"), each = 5),
                           andel  = c(8.3, 7.9, 6.8, 7.0, 7.4, 8.5, 8.8, 7.5, 7.7, 8.4))

linje  <- func_graf_linjediagram(arbetsloshet, "ar", "andel", group = "region",
                                 legend_position = "bottom")
stapel <- func_graf_barchart(arbetsloshet, "ar", "andel", group = "region",
                             legend_position = "bottom")
tabell <- func_graf_tabell(arbetsloshet, return_object = TRUE)

func_skapa_pptx(
  plot_list = list("Arbetslöshet över tid" = linje,
                   "Arbetslöshet per år"   = stapel,
                   "Tabell"                = tabell),
  output_path = file.path(tempdir(), "rapport.pptx"),
  presentation_title = "Läget i regionen"
)
```

### Uppslagstabeller

```r
# Kommuner i Västra Götaland med SKR:s kommungrupp, plus riket
func_hamta_dim_region(gruppering = c("region_namn", "skr_kommungrupp"),
                      hamta_enbart_VGR = TRUE, hamta_riket = TRUE)

# Flera län på en gång: Skåne och Västra Götaland (län och kommuner)
func_hamta_dim_region(gruppering = c("region_namn", "län_namn"),
                      region_kod_prefix = c("12", "14"))

# Bara kommunerna i Halland och Västra Götaland
func_hamta_dim_region(gruppering = "region_namn",
                      region_kod_prefix = c("13", "14"), hamta_kommuner = TRUE)

# SCB:s lokala arbetsmarknader 2024 för VG-kommunerna
func_hamta_dim_region(gruppering = c("region_namn", "la24_region", "la24_region_kod"),
                      hamta_enbart_VGR = TRUE, hamta_kommuner = TRUE)

# Kortnamn och bokstavskod för SNI 2007
bransch <- data.frame(sni = c("Tillverkning", "Vård och omsorg; sociala tjänster"))
func_hamta_dim_sni07(bransch, sni_column_name = "sni", add_key = TRUE)
```

Koderna kan anges som text eller som tal. Länskoder har två siffror och kommunkoder
fyra, och en inledande nolla läggs till där den fattas: `region_kod_prefix = c(14, 6)`
ger Västra Götaland och Jönköpings län (`"06"`), och `114` ger Upplands Väsby (`"0114"`).
Ett prefix som matchar behåller sin betydelse, så `"148"` ger kommunerna 1480–1489.

### SCB

Kräver internetanslutning.

```r
func_scb_hamta_uppdaterad("TAB638")            # senast uppdaterad, via PxWebApi
func_scb_publiceringskalender("bas")           # nästa publicering enligt SCB:s kalender
```

### Brus för röjandeskydd

```r
svar <- data.frame(id = 1:100, q1 = sample(1:4, 100, replace = TRUE))
func_censur_brus(svar, cols = q1, seed = 42)
```

### Filer och mappar

Exemplen använder R:s temporära mapp. Byt `tempdir()` mot din egen sökväg,
t.ex. `"G:/utdata"`.

```r
# Datumstämplad mapp för utdata: <mapp>/ÅÅÅÅ/ÅÅÅÅ-MM-DD
ut <- func_utskriftsmapp(tempdir(), quiet = FALSE)

# Läs och slå ihop alla csv-filer i en mapp
mapp <- file.path(tempdir(), "exempeldata")
dir.create(mapp, showWarnings = FALSE)
write.csv(data.frame(kommun = "Borås",  antal = 10), file.path(mapp, "boras.csv"),  row.names = FALSE)
write.csv(data.frame(kommun = "Skövde", antal = 7),  file.path(mapp, "skovde.csv"), row.names = FALSE)
func_las_filtyper(mapp, "csv", retur = "df")

# Kör alla R-skript i en mapp
skript <- file.path(tempdir(), "skript")
dir.create(skript, showWarnings = FALSE)
writeLines("dubbla <- function(x) 2 * x", file.path(skript, "hjalpfunktioner.R"))
func_las_rskript(skript)
dubbla(21)

# Arbetskatalog = det öppna skriptets mapp (bara i RStudio, med ett sparat skript)
if (rstudioapi::isAvailable()) func_setwd()
```

## Funktioner

Parametrar som inte står under "Obligatoriska parametrar" har standardvärden.

| Funktion | Vad den gör | Obligatoriska parametrar |
|---|---|---|
| **Diagram** | | |
| `func_graf_linjediagram()` | Linjediagram | `df`, `x_value`, `y_value` |
| `func_graf_barchart()` | Stapeldiagram | `df`, `x_value`, `y_value` |
| `func_graf_dumbbell()` | Dumbbell-diagram (före/efter) | `df`, `x_value`, `y_value`, `group` |
| `func_graf_tabell()` | Formaterad tabell som bild eller flextable | `df` |
| **Färger och tema** | | |
| `func_fargtema()` | Färgpaletter i VGR:s grafiska profil | – |
| `func_tema_vgr()` | ggplot2-tema i VGR:s stil | – |
| **Kartor** | | |
| `func_graf_karta()` | Koropletkarta med klassindelade värden | `df`, `basemap`, `geom_col`, samt `df_value` eller `group` |
| `func_graf_karta_change()` | Karta över förändring mellan första och sista året | `df`, `df_value`, `basemap`, `geom_col` |
| `func_graf_karta_heatmap()` | Heatmap (täthetskarta) över punktdata | `df`, `df_value`, `basemap` |
| `func_graf_heatmap_coordinats()` | Enkel heatmap över punktkoordinater (äldre variant) | `df`, `df_varde`, `basemap` |
| **Geodata** | | |
| `func_gis_satt_inloggning()` | Spara inloggningsuppgifter till geodatabasen i Windows Autentiseringshanteraren | – |
| `func_gis_hamta_geoobjekt()` | Hämta geografiska objekt från VGR:s PostGIS-databas | – |
| `func_gis_hamta_con()`, `func_gis_hamta_pgstring()` | Anslutning till VGR:s geodatabas (PostGIS) | – |
| **Uppslag** | | |
| `func_hamta_dim_region()` | Uppslagstabell över Sveriges kommuner och län | – |
| `func_hamta_dim_sni07()` | Uppslag och förkortning av SNI 2007-kategorier | `df`, utom med `return_lookup_only = TRUE` |
| **SCB** | | |
| `func_scb_hamta_tabell_id()` | Slå upp SCB:s tabell-id | `query` |
| `func_scb_hamta_uppdaterad()` | Senaste uppdateringsdatum för en SCB-tabell | `table_id` |
| `func_scb_publiceringskalender()` | Nästa publicering enligt SCB:s publiceringskalender | – |
| **Data, filer och export** | | |
| `func_censur_brus()` | Lägg till diskret brus i valda kolumner (röjandeskydd) | `.data`, `cols` |
| `func_skapa_pptx()` | Skapa en PowerPoint-presentation från en lista med diagram | `plot_list`, `output_path` |
| `func_las_filtyper()` | Lista eller läs in alla filer av en viss typ i en katalog | `mappnamn`, `filtyp` |
| `func_las_rskript()` | Kör (source) alla R-skript i en katalog | `mappnamn` |
| `func_setwd()` | Sätt arbetskatalogen till det aktiva skriptets katalog | – |
| `func_utskriftsmapp()` | Skapa en datumstämplad utskriftsmapp (utan `filvag` skapas ingen mapp) | – |

Datasetet `vg_kommuner` innehåller Västra Götalands 49 kommuner som `sf`-objekt.
Äldre namn finns kvar som alias: `graf_karta_heatmap()` och
`func_scb_publicering()`.

## Byta från skripten

Ta bort `source()`-anropen till `func_vgr` (t.ex. `func_all.R`) och lägg till
`library(funcVGR)`. Funktionerna fungerar som förut, med dessa skillnader:

- Paketen laddas inte längre med `pacman::p_load()`. Använder ditt eget skript
  t.ex. dplyr eller ggplot2 direkt behöver du ladda dem själv med `library()`.
- Typsnitt hanteras med systemfonts i stället för showtext.
- Inloggningsuppgifterna till geodatabasen står inte i koden, som i skripten,
  utan sparas i Windows Autentiseringshanteraren. Paketet frågar efter dem
  första gången (se [Inloggning till geodatabasen](#inloggning-till-geodatabasen)).
  Värd, port och databas går inte att ändra.
- SKR-kolumnerna i `func_hamta_dim_region()` är rättade och följer SKR:s
  kommungruppsindelning 2023.
- `region_kod_prefix` i `func_hamta_dim_region()` tar nu även flera prefix,
  t.ex. `c("12", "14")`, och tal, t.ex. `c(14, 6)` (6 blir `"06"`).

## Versionshistorik

Samma historik finns i NEWS.md och visas i R med `news(package = "funcVGR")`.

### 0.5.0 (2026-11-17)

#### Nytt

* `func_graf_ladagram()` (även under namnet `func_graf_boxplot()`): nytt lådagram,
  fördelningen av ett numeriskt värde per kategori. Lådan går från första till tredje
  kvartilen med medianen som ett streck, och morrhåren når de mest extrema värdena inom
  `box_whisker_range` kvartilavstånd (1,5 som standard); värden utanför ritas som punkter.
  * `group` ritar en låda per grupp bredvid varandra. Varje grupp har en fast plats i
    varje kategori, och en saknad grupp blir en egen grå "NA"-grupp.
  * `horizontal = TRUE` ger liggande lådor, och `sort_by` sorterar kategorierna efter
    medianen eller namnet.
  * `box_mean` visar medelvärdet som en romb, `point_show` ritar alla värden som punkter
    spridda i sidled, och `data_labels` skriver medianen bredvid lådan.
  * `y_break_line` kan vara ett eller flera tal, eller `"mean"` och `"median"`.
  * Statistiken räknas fram i funktionen med samma metod som ggplot2:s `geom_boxplot()`,
    så att `func_d3_ladagram()` i funcVGRD3 får exakt samma lådor.
* `func_hamta_dim_region()`: två nya kolumner med SCB:s lokala arbetsmarknader 2024,
  `la24_region` (t.ex. `"Göteborg"`) och `la24_region_kod` (t.ex. `"LA2420"`). De finns
  för alla 290 kommuner; för län och riket är de `NA`. Kolumnerna följer med när alla
  kolumner hämtas (`gruppering = "alla"`, standard), så tabellen har nu 17 kolumner i
  stället för 15.

#### Ändrat

* `func_hamta_dim_region()`: `region_kod_prefix` lägger till den inledande nollan även för
  text och för tresiffriga koder, när prefixet annars inte matchar någon kod. Länskoder har
  två siffror och kommunkoder fyra, så `"6"` och `6` blir `"06"` och `114` eller `"114"` blir
  `"0114"`. Tidigare gav text som `"6"` och tal som `114` inga rader alls. Ett prefix som
  matchar behåller sin betydelse: `"148"` ger fortfarande kommunerna 1480–1489. Två siffror är
  alltid en hel länskod och ändras inte (`"11"` ger inga rader).

#### Rättat

* `func_hamta_dim_region()`: `fa_region_kod` var `"382"` och `"483"` i stället för `"0382"` och
  `"0483"` för Östhammar, Vingåker och Katrineholm, så de föll bort vid koppling på koden.
* `func_hamta_dim_region()`: riket har `län_kod` `"00"` (tidigare `"0"`), samma som `region_kod`.
* `func_hamta_dim_region()`: `NA` i `region_kod_prefix` ignoreras. Tidigare gav det rader där alla
  kolumner var `NA`. Bara `NA` ger ett fel.

### 0.4.0 (2026-11-12)

#### Ändrat

* **Inloggningen till geodatabasen sparas i Windows Autentiseringshanteraren.**
  Användarnamn och lösenord är inte längre inbyggda i paketet.
  `func_gis_hamta_con()`, `func_gis_hamta_pgstring()` och
  `func_gis_hamta_geoobjekt()` läser dem med keyring under tjänsten
  `geodata.vgregion.se`. Finns inga sparade frågar de efter dem första gången och
  sparar dem. **Bakåtinkompatibelt:** skript som körs med `Rscript` eller
  schemalagt stoppar tills uppgifterna har sparats en gång i en interaktiv
  session, t.ex. med `func_gis_satt_inloggning()` i RStudio.
* `func_gis_satt_inloggning()` sparar uppgifterna igen: den frågar efter
  användarnamn (om `anvandare` inte anges) och lösenord, ersätter tidigare
  sparade uppgifter och provar anslutningen (`testa = TRUE`). Den returnerar
  användarnamnet osynligt. `metod` används inte.
* `func_gis_hamta_con()` säger att användarnamnet eller lösenordet inte godtogs,
  och hänvisar till `func_gis_satt_inloggning()`, när servern nekar inloggningen.
* `func_gis_hamta_geoobjekt()` lämnar lösenordet till GDAL via `PGPASSWORD` i
  stället för i anslutningssträngen.
* Paketet keyring är ett nytt beroende.

### 0.3.0 (2026-10-21)

#### Nytt

* `func_graf_spridningsdiagram()` (även under namnet `func_graf_scatterplot()`): nytt
  spridningsdiagram, en punkt per rad med ett numeriskt värde på varje axel. Parametrarna
  följer `func_graf_linjediagram()`. Det som bara finns här:
  * `group` färgar punkterna per grupp.
  * `point_size_column` gör ett bubbeldiagram där punktens yta växer med t.ex.
    befolkningen; `point_size`, `point_alpha` och `point_border_color` styr punkterna.
  * `data_label_column` skriver namn vid punkterna, och `data_label_filter` visar bara
    några av dem.
  * `trend_line` lägger till en linjär trendlinje, för alla punkter eller per grupp, med
    ett konfidensband om `trend_line_se = TRUE`.
  * `x_break_line` och `y_break_line` kan vara ett eller flera tal, eller `"mean"` och
    `"median"` för medelvärdet eller medianen.
* `func_graf_histogram()`: nytt histogram, fördelningen av ett numeriskt värde i lika breda
  intervall.
  * Intervallens bredd väljs automatiskt med jämna gränser, eller anges med `bin_width`,
    `bins` och `bin_boundary`.
  * `histogram_y` ger antal, andel eller täthet.
  * Med `group` staplas grupperna, ställs bredvid varandra eller ritas över varandra
    (`bar_type`); andelen räknas då inom panelen respektive inom varje grupp.
  * x-axelns markeringar ligger på intervallgränserna, och `x_break_line` kan visa
    medelvärdet eller medianen.
  * Intervallen räknas fram i funktionen, så att `func_d3_histogram()` i funcVGRD3 får
    exakt samma intervall.

### 0.2.0 (2026-10-13)

#### Nytt

* `func_graf_linjediagram()`: etiketter som inte flyttas av ggrepel klipps inte längre
  vid x-axelns ändar. Axeln får det utrymme som etiketterna behöver
  (`data_label_repel = FALSE`, och slutetiketterna från `group_highlight` med en färg per
  grupp), och en etikett som ändå inte ryms, t.ex. i smala paneler, flyttas in mot mitten.
  Utan etiketter är axeln oförändrad: 5 % luft till vänster och 10 % till höger.
* `func_graf_barchart()`: samma sak för stående staplar på en kategoriaxel. De yttersta
  staplarnas etiketter klipptes förut vid panelkanten ("1 842,0" blev "842,0"). Liggande
  staplar med etiketter `"outside"` får plats på värdeaxeln efter etiketternas längd och
  textstorlek, i stället för fasta 20 %.
* `func_graf_dumbbell()`: stående hantlar får plats för etiketterna i kategoririktningen,
  och kategoritexten glesas ut när den inte ryms.

#### Ändrat

* `func_graf_barchart()`, staplade staplar (`"stacked"`, `"filled"`) med etiketter
  `"outside"`:
  * `data_label_first_last` och `data_label_skip` räknar staplar, inte grupper.
  * `data_label_y_values` jämförs med stapelns totalsumma.
  * `data_label_show_group` och `data_label_group_values` gäller inte totalsummor, och
    `data_label_color = "auto"` ger dem svart text.
  * En stapel utan några värden får ingen etikett.
* `func_graf_barchart()`: med `bar_type = "filled"` fyller positiva och negativa delar
  var sin 100 % (0 till 1 och −1 till 0), som ggplot2 ritar dem, och etiketterna placeras
  på samma sätt. Förut räknades etiketternas lägen mot nettosumman, så de hamnade fel när
  en stapel hade negativa delar.
* `func_graf_barchart()`: avståndet mellan stapel och etikett (`"outside"`) är 3 % av
  spannet från 0 till staplarnas ändar (förut från lägsta till högsta värde). Etiketterna
  hamnar därför något längre från staplarna, och det blir ett avstånd även när alla staplar
  är lika höga. Med paneler och fri y-skala räknas avståndet per panel.
* `func_graf_barchart()`: `data_label_width` radbryter även etiketter med gruppnamn först
  (`data_label_show_group = TRUE`). Ett ensamt tal radbryts aldrig.
* `func_graf_linjediagram()`: `x_axis_clip_off = TRUE` gäller även en kategoriaxel.
* `func_graf_dumbbell()`: `data_label_axis_padding = 1` är anpassat för ett diagram på
  cirka 6 × 4 tum (förut 8 × 5 tum). Etiketterna får något mer plats i mindre bilder.
  Använd ett värde under 1 för stora bilder.
* `func_graf_barchart()`, `func_graf_karta()` och `func_graf_karta_change()`: `font`
  kan vara R:s generiska `"sans"`, `"serif"` eller `"mono"`, som i de andra diagrammen.
  Förut gav de en varning och blev `"sans"`. Ett typsnitt som saknas ger nu ett meddelande
  i stället för en varning.

#### Rättat

* Dataetiketterna i `func_graf_linjediagram()`, `func_graf_barchart()`,
  `func_graf_karta()`, `func_graf_karta_change()` och `func_graf_karta_heatmap()`, och
  slutetiketterna från `group_highlight`, använder typsnittet i `font`. Förut föll de
  tillbaka på grafikenhetens standardtypsnitt.
* `func_graf_linjediagram()`: slutetiketterna från `group_highlight` hamnar på samma
  plats varje gång diagrammet ritas.
* `func_graf_barchart()`: `color_palette = "plasma"` gav färgskalan cividis.
* `func_graf_barchart()`: `data_label_color = "auto"` utan `group` gav fel. Etiketterna
  får nu stapelns färg.
* `func_graf_dumbbell()`: jämna stora tal som 200 000 skrevs som "2e+05" i etiketterna.

### 0.1.7 (2026-10-12)

#### Rättat

* `func_graf_linjediagram()`: slutetiketterna från `group_highlight` fick en ram
  trots `group_highlight_label_box = FALSE` med ggrepel 0.9.8 och ggplot2 4.0.
  Ramen tas nu bort både i nya och äldre versioner, så den tillfälliga lösningen
  att nollställa `linewidth` i lagren efteråt behövs inte längre.
* `func_graf_linjediagram()`: samma rättning för `data_label_box = TRUE`.
  Rutan bakom datavärdena har inte längre någon ram, och ggplot2 varnar inte
  längre för att `label.size` är föråldrad.

### 0.1.6 (2026-10-06)

#### Nytt

* `func_graf_dumbbell()`: ändringarna i skriptet i `func_vgr` från 2 oktober 2026
  är införda:
  * `text_scale` multiplicerar alla textstorlekar med samma faktor, t.ex.
    `text_scale = 1.3` för en stor export.
  * `show_major_grid` och `show_minor_grid` kan vara `"x"` eller `"y"` för
    stödlinjer i bara en riktning, och `x_axis_line` och `y_axis_line` slår av och
    på axellinjerna, som i `func_graf_linjediagram()` och `func_graf_barchart()`.
  * Etiketterna använder typsnittet i `font`.

#### Ändrat

* **Inloggningen till geodatabasen är inbyggd.** `func_gis_hamta_con()`,
  `func_gis_hamta_pgstring()` och `func_gis_hamta_geoobjekt()` ansluter till
  `geodata.vgregion.se` med en inbyggd användare, utan att något behöver sparas.
  Det som krävs är VGR:s nätverk. Inloggningsuppgifter i `.Renviron`
  (`GEODATA_USER`, `GEODATA_PASSWORD`) och i Windows Autentiseringshanteraren
  används inte längre och kan tas bort. Värd, port och databas går inte längre att
  ändra med `GEODATA_HOST`, `GEODATA_PORT` och `GEODATA_DBNAME`.
* `func_gis_satt_inloggning()` behövs inte längre. Den finns kvar så att äldre
  skript fungerar, men sparar ingenting och skriver bara ut ett meddelande.
* `func_gis_hamta_pgstring()` tar som standard med lösenordet
  (`med_losenord = TRUE`), så att strängen kan användas direkt i `sf::st_read()`.
* `func_graf_dumbbell()`: **mindre text som standard**, som i de andra
  diagrammen sedan 0.1.4. Rubrik 16 punkter, underrubrik 13, `caption` 10,
  axeltext, förklaring och förklaringsrubrik 11, panelrubriker 12 och etiketter
  3,5 mm. Tidigare var rubriken 18 punkter, axeltexten 14 och etiketterna 6 mm. Ange
  storlekarna eller `text_scale` för att få större text.
* `func_graf_heatmap_coordinats()`:
  * `df`, `df_varde` och `basemap` har inget standardvärde längre och måste anges.
    Funktionen krävde dem redan, men stoppade med obegripliga fel ("argument is of
    length zero", "crs not found"). Nu säger R att argumentet saknas, eller så
    förklarar funktionen vad som är fel.
  * Diagrammet får ingen text längst ner och ingen rubrik om de inte anges. Tidigare
    fick varje diagram texten "Här kan man skriva text." och rubriken "Basemap".
* `func_censur_brus()`: `seed` gäller bara inne i funktionen. Tidigare ändrades
  slumpgeneratorn för resten av sessionen. Samma `seed` ger samma brus som förut.
* `func_hamta_dim_region()`: meddelandet om filtreringen med `region_kod_prefix` är
  ett vanligt meddelande, som kan tystas med `suppressMessages()`.

#### Rättat

* `func_scb_publiceringskalender()` och `func_scb_publicering()` fungerade inte:
  SCB:s publiceringskalender laddar numera tabellen i efterhand, så funktionen hittade
  inga rader och stoppade med "Kunde inte hämta någon data från SCB:s
  publiceringskalender". Kalendern hämtas nu från samma adress som SCB:s sida
  använder. Med `returnera_df = TRUE` följer kolumnerna SCB:s nya tabell
  (`statistikansvar` och `publiceras_hos` är nya); undersökningens namn står som
  förut i `statistik_kontakter_m_m`.
* `func_graf_karta_change()`:
  * Med `percentage_growth = TRUE` kraschade funktionen om något område hade
    startvärdet 0. Sådana områden visas nu som saknade värden, med en varning.
  * Funktionen varnar när områden saknar en rad med samma geometri för det första
    året och därför inte visas, och när data bara har ett år.
* `func_scb_hamta_tabell_id()`: en sökning utan träffar gav felet "missing value
  where TRUE/FALSE needed" i stället för "Ingen SCB-tabell hittades".
* `func_skapa_pptx()`: objekt som varken är ggplot, flextable, basgrafik
  (`recordPlot()`) eller lattice skrevs ut i konsolen och gav en tom bild utan
  varning. Nu varnar funktionen.
* `func_las_filtyper(retur = "df")`: om en kolumn hade olika typ i olika filer
  stoppade funktionen med ett fel från dplyr. Nu läses alla kolumner som text, med
  en varning.
* `func_graf_karta()` och `func_graf_karta_change()`: ett `df` utan
  geometrikolumnen `geom_col` ger ett tydligt fel i stället för en tom karta.
* `func_fargtema()`: flera palettnamn på en gång ger ett tydligt fel.

#### Dokumentation

* Exemplen för varje funktion ligger i egna filer i `inst/examples/` och visas som
  förut på hjälpsidorna. Exempel som kräver nätverk eller inloggning körs bara när
  det som behövs finns (tidigare låg de i `\dontrun{}` eller `\donttest{}` och kördes
  inte alls):
  * Geodatabasen: bara när `geodata.vgregion.se` går att nå.
  * SCB: bara med internetanslutning.
  * PNG-exporten i `func_graf_tabell()`: bara interaktivt.
* Exemplen anropar alla funktioner på varje hjälpsida, även
  `func_gis_hamta_pgstring()` och de äldre namnen `graf_karta_heatmap()` och
  `func_scb_publicering()`. Exemplet för `func_utskriftsmapp()` visar mappen som
  skapas i stället för ett diagram, och exemplet för `func_hamta_dim_region()` visar
  korta utdrag i stället för hela tabeller.
* `func_utskriftsmapp()`: `filvag` var felaktigt markerad som obligatorisk.
* Vignetten visar samma exempel som hjälpsidorna och tar upp alla funktioner, med
  ett nytt avsnitt om filer och mappar och en översiktstabell.
* README har en versionshistorik och en tabell med vad varje funktion gör.
* `func_graf_dumbbell()` har ett nytt exempel med stående hantlar, stödlinjer i en
  riktning och `text_scale`.

### 0.1.5 (2026-10-05)

#### Dokumentation

* Hjälpsidorna markerar de parametrar som måste anges med "Obligatorisk." sist
  i beskrivningen, t.ex. `df`, `x_value` och `y_value` i diagramfunktionerna och
  `df`, `basemap` och `geom_col` i `func_graf_karta()`. Parametrar som bara
  behövs i vissa fall, som `df_value` i `func_graf_karta()` när `group` anges,
  är inte markerade. Funktionerna fungerar som i 0.1.4.
* README visar vilka parametrar som är obligatoriska i varje funktion.

### 0.1.4 (2026-10-02)

Ändringarna i skripten i `func_vgr` från 30 september–2 oktober 2026 är införda i
paketet.

#### Nytt

* `text_scale` i `func_graf_linjediagram()`, `func_graf_barchart()`,
  `func_graf_karta()`, `func_graf_karta_change()` och
  `func_graf_karta_heatmap()` multiplicerar alla textstorlekar med samma faktor,
  t.ex. `text_scale = 1.3` för en stor export.
* `colors` kan vara en namngiven vektor, t.ex.
  `c("Kvinnor" = "#1a9fb3", "Män" = "#ffc107")`, så att varje grupp får en
  bestämd färg. Det gäller `func_graf_linjediagram()`, `func_graf_barchart()`,
  `func_graf_karta()` och `func_graf_karta_heatmap()`. Alla grupper måste då ha
  en färg.
* `func_graf_karta()`: med `group` färgas områdena efter en kategori, med en
  färg per grupp (`colors`), i stället för en färgskala. `df_value` behövs då
  inte. Förklaringen visas till höger om `legend_position` inte anges.
* `func_graf_karta_heatmap()`: `colors` styr punkternas färger när `group` anges.
* `func_graf_linjediagram()` och `func_graf_barchart()`: `show_major_grid` och
  `show_minor_grid` kan vara `"x"` eller `"y"` för stödlinjer i bara en riktning.
  `x_axis_line` och `y_axis_line` slår av och på axellinjerna.
* `func_graf_barchart()`: `bar_line_color` och `bar_line_width` ger en kantlinje
  runt staplarna.
* `func_graf_dumbbell()`:
  * `data_label_side` väljer vilken sida om punkten etiketten hamnar på.
  * `data_label_axis_padding` styr utrymmet på värdeaxeln för etiketterna när
    `data_label_repel = FALSE`.
  * `x_axis_clip_off = TRUE` visar etiketter även utanför panelens kant.
* `func_fargtema()`: ny palett `"ru_kontrast"` med sju tydligt olika färger.
* `func_hamta_dim_region()`: `region_kod_prefix` tar även tal. Ensiffriga tal får
  en inledande nolla, så `c(14, 6)` ger `c("14", "06")`.

#### Ändrat beteende

Följande ändringar kan ge andra resultat än tidigare:

* **Mindre text som standard** i diagram och kartor. Rubrik 16 punkter,
  underrubrik 13, `caption` 10, axeltext och förklaring 11 och panelrubriker 12.
  Etiketterna är 3,5 mm i diagram och 3 mm i kartor. Tidigare var rubriken
  18–24 punkter och axeltexten 14–18. `func_graf_karta_change()` hade etiketter
  på 9 mm. Ange storlekarna eller `text_scale` för att få större text.
* `func_fargtema("ru")` har ny ordning: de fyra första färgerna är tydligt olika,
  och den ljusblå färgen ligger sist. Diagram med `"ru"` (standard i flera
  funktioner) får därför andra färger från den tredje gruppen och framåt.
* **Gruppordningen för färger** följer samma regel i linjediagram,
  stapeldiagram och kartor: faktornivåer (oanvända nivåer tas bort), tal i
  storleksordning, annars den ordning grupperna först förekommer. `NA` tar inte
  längre en färg.
* `func_graf_barchart()`:
  * Staplarna har en tunn svart kantlinje. `bar_line_color = NULL` ger staplar
    utan kantlinje som tidigare.
  * Etiketter `"outside"` placeras med kanten mot stapeln, så att de inte
    överlappar stapeln oavsett textstorlek. Negativa staplar får etiketten under
    stapeln och plats för den på axeln.
  * I staplade diagram med negativa delar hamnar `"outside"`-etiketten utanför
    stapelns ände i totalsummans riktning.
* `func_graf_dumbbell()`: etiketterna hamnar som standard på den sida som pekar
  bort från den andra punkten (`data_label_side = "value"`), inte efter period.
  Etiketter flyttas förbi riktningspilarna. Utan ggrepel får värdeaxeln plats för
  etiketterna, och axelns markeringar glesas ut om de inte får plats.
* `func_graf_karta()`: värden i etiketterna har inte längre inledande blanksteg
  (`"Borås:  63"`).

### 0.1.3 (2026-10-01)

#### Nytt

* Nytt dataset `vg_kommuner`: gränserna för Västra Götalands 49 kommuner som
  `sf`-objekt i SWEREF 99 TM, från SCB:s generaliserade kommungränser.
  Exemplen för `func_graf_karta()`, `func_graf_karta_change()`,
  `func_graf_karta_heatmap()` och `func_graf_heatmap_coordinats()`, vignetten och
  README visar nu riktiga kartor över länet i stället för ett påhittat rutnät,
  som såg ut som en heatmap.

#### Buggrättningar

* `func_graf_karta_heatmap()`: förklaringen visade tätheten i punkter per
  kvadratmeter, t.ex. `0,00000016`, och etiketterna gick in i varandra när
  förklaringen låg nederst. Tätheten visas nu i punkter per km², t.ex. `0,15`,
  oavsett kartans koordinatsystem. Kartan ritas som tidigare i bakgrundskartans
  koordinatsystem och ser likadan ut; bara talen i förklaringen ändras.

### 0.1.2 (2026-10-01)

#### Buggrättningar

* Diagram gav varningen "font family not found in Windows font database" på
  Windows egen grafikenhet (Rgui, `png()` och RStudios backend "Default") och
  ritades med ett annat typsnitt. Typsnittet registreras nu hos Windows
  grafikenhet, så att Verdana används. Det gäller alla diagramfunktioner och
  `func_tema_vgr()`, och även andra typsnitt som anges med `font`.
* `func_graf_heatmap_coordinats()` saknade kontroll av typsnittet. Ett typsnitt
  som inte är installerat ersätts nu med `"sans"`, som i övriga
  diagramfunktioner.

#### Övrigt

* Oanvända anrop till `systemfonts::register_variant()` i `func_graf_karta()`,
  `func_graf_karta_change()` och `func_graf_barchart()` är borttagna. Diagrammen
  ser likadana ut.
* README och vignetten rekommenderar grafikenheten AGG i RStudio (paketet ragg),
  som använder datorns typsnitt direkt via systemfonts. ragg ligger bland de
  valfria paketen.

### 0.1.1 (2026-09-30)

#### Nytt

* Vignetten "Kom igång med funcVGR" går igenom ett typiskt arbetsflöde, från
  diagram och kartor till en PowerPoint-presentation:
  `vignette("funcVGR", package = "funcVGR")`.
* README med installation, inloggning och exempel.
* Alla hjälpsidor har körbara exempel med egna exempeldata. Exemplen för
  geodatabasen kräver VGR:s nätverk och inloggning, och exemplen för SCB kräver
  internet.
* `func_gis_satt_inloggning()` sparar inloggningsuppgifterna till geodatabasen i
  `.Renviron` (standard) eller krypterat i Windows Autentiseringshanteraren
  (`metod = "keyring"`). Den testar anslutningen innan uppgifterna sparas.
* `func_hamta_dim_region()`: `region_kod_prefix` tar flera prefix, t.ex.
  `c("12", "14")` för Skåne och Västra Götaland.

#### Ändrat beteende

Följande ändringar kan ge andra resultat än tidigare:

* **Inloggning till geodatabasen**: användarnamn och lösenord finns inte längre
  i koden. De söks i ordningen `.Renviron` (`GEODATA_USER`,
  `GEODATA_PASSWORD`), keyring och en fråga i ett dialogfönster. Saknas de stoppas
  körningen med instruktioner. Alla användare behöver spara uppgifterna en gång
  med `func_gis_satt_inloggning()`.
* `func_gis_hamta_pgstring()` tar inte längre med lösenordet i
  anslutningssträngen, om inte `med_losenord = TRUE` anges.
  `func_gis_hamta_geoobjekt()` lämnar lösenordet till GDAL via `PGPASSWORD`,
  bara under själva hämtningen.
* **Typsnitt** hanteras med systemfonts i stället för showtext. `func_fargtema()`
  och `func_tema_vgr()` slår inte längre på showtext för hela sessionen.
  showtext och sysfonts är inte längre beroenden. Med R:s `pdf()`-enhet används
  Helvetica i stället för Verdana. Använd `device = cairo_pdf` för Verdana i PDF.
* `func_graf_dumbbell()`:
  * Perioderna ordnas i tidsordning oavsett radordning i data.
  * Med fler än två perioder jämförs den första och den sista, inte de två
    första.
  * I liggande diagram hamnar den första kategorin i sorteringen överst, så att
    `sort_direction = "desc"` ger högsta värdet överst.
* `func_graf_barchart()`:
  * Liggande staplar med `sort_by` har den första stapeln i sorteringen överst.
  * Staplade staplar med etiketter `"outside"` får en etikett per stapel med
    totalsumman i stället för en per del.
* `func_graf_karta_change()`: `breaks_num_group` ger exakt så många klasser.
  Tidigare blev det en klass till, som bara innehöll maxvärdet.
* `func_graf_tabell()`:
  * `decimal_digits` har nu effekt.
  * Kolumner med bara heltal visas utan decimaler.
  * Årskolumner (`år`, `ar`, `årtal`, `artal`, `year`) visas utan
    tusentalsavgränsare.
  * PhantomJS installeras bara om PNG-exporten med webshot2 misslyckas.
* `func_hamta_dim_region()` ändrar inte längre sessionens språkinställning
  (`Sys.setlocale()`).
* `func_skapa_pptx()` varnar alltid när ett diagram inte går att lägga in.
  Tidigare blev bilden tom utan meddelande om inte `verbose = TRUE`.

#### Buggrättningar

##### Data och uppslag

* `func_hamta_dim_region()`: SKR-kolumnerna var fel för 205 kommuner. De flesta
  kommuner utanför Norrland, även Stockholm, Göteborg och Malmö, stod som
  "Pendlingskommun nära storstad". Kolumnerna följer nu SKR:s
  kommungruppsindelning 2023, hämtad från Kolada och kontrollerad mot de
  kommuner som redan hade rätt värden.
* `func_hamta_dim_sni07()` gav fel bransch när SNI-kolumnen var en faktor, t.ex.
  "Utbildning" → "Utvinning av mineral".
* `func_censur_brus()` trunkerade tyst steg som inte var heltal (t.ex. `0.5`
  till 0) och tog emot negativa sannolikheter. Båda ger nu ett fel.

##### Diagram

* `func_graf_linjediagram()`:
  * `highlight_groups` kraschade med standardfärgerna, gav fel linjetjocklek och
    gjorde fel grupp fet i förklaringen.
  * Att ange bara `y_axis_min` eller bara `y_axis_max` gav fel.
  * Datum med klockslag (POSIXct) på x-axeln gav fel.
  * `x_axis_n_breaks` ignorerades för datumaxlar.
  * `data_label_first_last` valde fel punkter när data inte var sorterad.
  * Korta årsserier fick dubbla årtal på x-axeln ("2022, 2022, 2023").
  * `group_highlight` gav varningar om okända parametrar.
* `func_graf_barchart()`:
  * Etiketterna hamnade utanför diagrammet med `bar_type = "filled"`.
  * `data_label_first_last` valde fel staplar när data inte var sorterad.
  * Korta årsserier fick dubbla årtal på x-axeln.
  * `x_axis_title` doldes i diagram med `facet_var`.
* `func_graf_dumbbell()`:
  * Etiketterna fylldes ut med blanksteg (`"  2,0"`).
  * Stilen för `facet_var` skrevs över av grundtemat.
  * Med data sorterad med senaste perioden först räknades den som start, med
    omvänd förändring och fel etiketter.
* `func_graf_tabell()`: stora tal avrundades till 7 värdesiffror, och tabeller
  utan rader gav fel.

##### Kartor

* `func_graf_karta()` och `func_graf_karta_change()`:
  * `breaks_num_group = 1` gav fel.
  * Med decimaldata märktes klasserna fel, t.ex. hamnade 9,5 i klassen "5–9".
* `func_graf_karta_heatmap()`:
  * Förklaringen var tom.
  * Förklaringen visade "0.00000" för data i SWEREF 99 TM.
  * En dold förklaring för punkterna visades ändå.
* `func_graf_heatmap_coordinats()`: kartutsnittet tog bara hänsyn till
  bakgrundskartan och inte till hav, sjöar och vägar. Föråldrad syntax
  (`..level..`) är ersatt.
* Diagram och kartor gick inte att spara med R:s `pdf()`-enhet
  ("invalid font type").

##### SCB och filer

* `func_scb_publiceringskalender()`:
  * Vissa dagar i månadsskiften (t.ex. 31 december) blev datumintervallet `NA`
    och hämtningen misslyckades.
  * Svenska månadsnamn tolkades enligt datorns språkinställning, så t.ex. "maj"
    och "oktober" försvann på en engelskspråkig dator.
* `func_las_filtyper()` hittade inga filer när filtypen angavs med punkt
  (`".csv"`).
* `func_skapa_pptx()` lämnade en grafikenhet öppen om ett diagram inte gick att
  rita.

### 0.1.0 (2026-09-30)

* Första versionen som paket. Funktionerna i skripten i `func_vgr` har samlats i
  paketet med samma namn och argument, och varje funktion har en hjälpsida.
* Paket laddas via paketets beroenden i stället för med `library()` och
  `pacman::p_load()` i funktionerna. Skript som själva använder t.ex. dplyr
  eller ggplot2 behöver ladda dem med `library()`.
* PowerPoint-mallen `format_ppt_ru.pptx` följer med paketet och används som
  standard i `func_skapa_pptx()`.
* De äldre namnen `graf_karta_heatmap()` och `func_scb_publicering()` finns kvar
  som alias.
