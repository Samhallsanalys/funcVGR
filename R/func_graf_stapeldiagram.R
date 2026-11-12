#' Stapeldiagram
#'
#' Flexibelt stapeldiagram i VGR:s stil. Staplarna kan grupperas (sida vid
#' sida), staplas eller fyllas till 100 % och ritas lodrätt eller vågrätt.
#' Diagrammet kan delas upp i paneler (facets), och x-axeln kan vara datum,
#' tal eller kategorier. Etiketterna går att filtrera och placera på olika
#' sätt. Siffror formateras på svenska (decimalkomma, mellanslag som
#' tusentalsavgränsare).
#'
#' @param df Data frame med data. Obligatorisk.
#' @param x_value Kolumnnamn för x-axeln (kategorier, tal eller datum), eller
#'   en vektor med värden. Obligatorisk.
#' @param y_value Kolumnnamn för de numeriska värdena, eller en vektor med
#'   värden. Obligatorisk.
#' @param group Kolumn som staplarna färgas och grupperas efter. `NULL` = en
#'   färg för alla staplar.
#' @param facet_var Kolumn som delar upp diagrammet i paneler. `NULL` = ett
#'   diagram.
#' @param facet_ncol Antal kolumner med paneler. `NULL` = automatiskt.
#' @param facet_scales Panelernas axelskalor: `"fixed"`, `"free"`,
#'   `"free_x"` eller `"free_y"`.
#' @param facet_same_y_scale Samma y-skala i alla paneler. Används bara när
#'   `facet_scales` inte anges uttryckligen.
#' @param facet_title_size Panelrubrikernas teckenstorlek i punkter.
#' @param facet_title_wrap Radbryt panelrubriker efter så här många tecken.
#'   Långa ord avstavas. `NULL` = ingen radbrytning.
#' @param bar_type Stapeltyp: `"grouped"` (sida vid sida), `"stacked"`
#'   (staplade) eller `"filled"` (100 % staplade; positiva och negativa delar
#'   fyller var sin 100 %, etiketterna visar de ursprungliga värdena).
#' @param horizontal `TRUE` ger liggande staplar.
#' @param title Huvudrubrik. `NULL` = ingen.
#' @param title_width Antal tecken innan rubriken radbryts.
#' @param subtitle Underrubrik. `NULL` = ingen.
#' @param subtitle_width Antal tecken innan underrubriken radbryts.
#' @param caption Text längst ner (källa, noter). `NULL` = ingen.
#' @param x_axis_title,y_axis_title Axelrubriker. `NULL` = ingen rubrik.
#' @param x_date_format Datumformat (strftime) för datumaxel, t.ex. `"%Y-%m"`.
#'   `NULL` = automatiskt.
#' @param x_date_breaks Avstånd mellan datummarkeringar, t.ex. `"3 months"`.
#'   `NULL` = automatiskt.
#' @param x_date_minor_breaks Avstånd mellan mindre datummarkeringar. `NULL` =
#'   inga.
#' @param x_number_format Format för numerisk x-axel: `"whole"` (utan
#'   avgränsare, t.ex. 2000) eller `"thousands"` (med mellanslag, t.ex. 2 000).
#' @param legend_title Förklaringens rubrik. `NULL` = namnet på
#'   `group`-kolumnen.
#' @param colors Färger för staplar/grupper. En namnlös vektor fördelas i
#'   gruppordning och återanvänds om den är för kort. Grupperna ordnas efter
#'   faktornivåerna (oanvända nivåer tas bort). Tal sorteras, och annan text får
#'   ordningen den först förekommer i data efter `sort_by`. En namngiven vektor
#'   matchas mot gruppnamnen, t.ex. `c("Kvinnor" = "#1a9fb3", "Män" = "#ffc107")`,
#'   och alla grupper måste då ha en färg. `NULL` = färger enligt
#'   `color_palette`.
#' @param color_palette Färgskala när `colors = NULL`: `"viridis"`,
#'   `"plasma"`, `"blues"` eller `"reds"`.
#' @param font Typsnitt för all text: ett installerat typsnitt eller `"sans"`,
#'   `"serif"` eller `"mono"`. Används `"sans"` om det saknas.
#' @param text_scale Faktor som alla teckenstorlekar multipliceras med
#'   (rubriker, axlar, förklaring, panelrubriker och etiketter). 1 =
#'   storlekarna som de är angivna, t.ex. 1.3 för stora exporter.
#' @param title_size Rubrikens teckenstorlek i punkter.
#' @param title_text_size Alias för `title_size` (bakåtkompatibilitet). Vinner
#'   om den anges.
#' @param subtitle_size Underrubrikens teckenstorlek i punkter.
#' @param subtitle_text_size Alias för `subtitle_size` (bakåtkompatibilitet).
#'   Vinner om den anges.
#' @param caption_size Teckenstorlek för `caption` i punkter.
#' @param axis_text_size Standardstorlek för båda axlarnas skaltext. Används
#'   när `x_axis_text_size`/`y_axis_text_size` inte anges.
#' @param x_axis_text_size,y_axis_text_size Teckenstorlek för x- respektive
#'   y-axelns skaltext.
#' @param legend_text_size Förklaringens teckenstorlek.
#' @param legend_title_size Teckenstorlek för förklaringens rubrik.
#' @param x_axis_title_size,y_axis_title_size Teckenstorlek för axelrubrikerna.
#' @param legend_position Förklaringens placering: `"right"`, `"left"`,
#'   `"top"`, `"bottom"` eller `"none"`.
#' @param show_major_grid,show_minor_grid Större respektive mindre stödlinjer:
#'   `TRUE` = i båda riktningarna, `FALSE` = inga, `"y"` = bara linjer från
#'   y-axeln (vågräta), `"x"` = bara linjer från x-axeln (lodräta). Gäller de
#'   axlar som visas, så med `horizontal = TRUE` ger `"x"` linjer vid värdena.
#' @param x_axis_line,y_axis_line Rita en linje längs x- respektive y-axeln.
#'   x-axelns linje ritas vid panelens kant, inte vid y = 0.
#' @param x_angle Rotation av x-axelns text i grader. Sätts automatiskt till
#'   45 vid många kategorier eller långa datumetiketter.
#' @param x_axis_title_angle Rotation av x-axelns rubrik.
#' @param data_labels Visa värdeetiketter.
#' @param data_label_position Etikettplacering: `"outside"` (utanför stapeln),
#'   `"top"` (strax innanför toppen), `"middle"` (mitten) eller `"inside"`
#'   (10 % från toppen). För staplade diagram ger `"outside"` en etikett per
#'   stapel med stapelns totalsumma. Övriga placeringar ger en etikett per del.
#'   Totalsummor får inget gruppnamn (`data_label_show_group`) och filtreras
#'   inte med `data_label_group_values`; `data_label_y_values` jämförs med
#'   totalsumman. Stående staplar på en kategoriaxel får plats för etiketterna
#'   vid axelns ändar, och en etikett som ändå inte ryms flyttas in mot mitten.
#' @param data_label_size Etiketternas teckenstorlek i mm (ggplot2:s
#'   textenhet, 3,5 mm ≈ 10 punkter).
#' @param data_label_text_size Alias för `data_label_size`
#'   (bakåtkompatibilitet). Vinner om den anges.
#' @param data_label_color Etiketternas färg, eller `"auto"` för gruppens
#'   färg (utan `group`: stapelns färg; totalsummor: svart).
#' @param data_label_box Visa en ruta bakom etiketterna.
#' @param data_label_box_color Rutans bakgrundsfärg.
#' @param data_label_format Etikettformat: `"number"` (1 234),
#'   `"percentage"` (12,3 %) eller `"x_y"` (x- och y-värde, t.ex.
#'   `"2000: 2 122"`).
#' @param data_label_decimals Antal decimaler i etiketterna.
#' @param data_label_accuracy Alias för `data_label_decimals`
#'   (bakåtkompatibilitet). Vinner om den anges.
#' @param data_label_width Radbryt etikettext efter så här många tecken.
#'   Gäller etiketter med text (formatet `"x_y"` eller gruppnamn med
#'   `data_label_show_group`); ett ensamt tal radbryts aldrig. `NULL` = ingen
#'   radbrytning.
#' @param data_label_nudge_x,data_label_nudge_y Förskjutning av etiketterna.
#' @param data_label_repel Använd \pkg{ggrepel} för att undvika överlapp.
#'   Används inte för staplade diagram.
#' @param data_label_force Repelleringskraft (typiskt 0,5–3).
#' @param data_label_max_overlaps Max antal överlapp innan en etikett döljs.
#' @param data_label_filter Visa etiketter bara för dessa x-värden. Alias för
#'   `data_label_x_values`.
#' @param data_label_x_values Visa etiketter bara för dessa x-värden.
#' @param data_label_y_values Visa etiketter bara där y har dessa värden.
#' @param data_label_group_values Visa etiketter bara för dessa grupper
#'   (kräver `group`).
#' @param data_label_first_last Visa etiketter bara på första och sista
#'   stapeln per grupp/panel.
#' @param data_label_skip Visa var N:e etikett per grupp/panel. `NULL` = alla.
#' @param data_label_show_group Skriv gruppnamnet före värdet i etiketten,
#'   t.ex. `"2023: 5,2"`.
#' @param data_label_group_separator Avskiljare mellan gruppnamn/x-värde och
#'   värde.
#' @param sort_by Sortering av staplarna: `"value_asc"`, `"value_desc"`,
#'   `"name_asc"` eller `"name_desc"`. `NULL` = ursprunglig ordning. Används
#'   inte för datumaxel.
#' @param y_axis_min,y_axis_max Min- och maxvärde för y-axeln. `NULL` =
#'   automatiskt.
#' @param y_min,y_max Alias för `y_axis_min`/`y_axis_max`
#'   (bakåtkompatibilitet).
#' @param y_axis_breaks Egna markeringar på y-axeln, t.ex. `c(0, 50, 100)`.
#' @param y_breaks Alias för `y_axis_breaks` (bakåtkompatibilitet).
#' @param y_axis_n_breaks Önskat antal markeringar på y-axeln. `NULL` =
#'   automatiskt.
#' @param y_n_breaks Alias för `y_axis_n_breaks` (bakåtkompatibilitet).
#' @param y_axis_auto_breaks Använd "snygga" markeringar med
#'   [scales::breaks_pretty()].
#' @param y_auto_breaks Alias för `y_axis_auto_breaks` (bakåtkompatibilitet).
#' @param bar_width Stapelbredd. `NULL` = automatiskt (0,8 för kategorier,
#'   anpassat till avståndet för datum).
#' @param bar_line_color Färg på kantlinjen runt staplarna. Kantlinjen ger
#'   bättre kontrast för personer med nedsatt syn och skiljer delarna åt i
#'   staplade diagram. `NULL` = ingen kantlinje.
#' @param bar_line_width Kantlinjens tjocklek (ggplot2:s `linewidth`, typiskt
#'   0,2–0,5).
#' @param custom_theme Ett ggplot2-tema som läggs sist och skriver över
#'   standardinställningarna. `NULL` = inget.
#' @param debug `TRUE` returnerar en lista med diagnostik i stället för
#'   diagrammet.
#'
#' @return Ett `ggplot`-objekt, eller en lista om `debug = TRUE`.
#' @seealso [func_graf_linjediagram()], [func_graf_dumbbell()]
#' @export
#'
#' @example inst/examples/func_graf_barchart.R
func_graf_barchart <- function(
    # === REQUIRED DATA ===
  df,                                   # Data frame: Your dataset
  x_value,                              # Character: Column name for categories (e.g., "region", "product") OR vector of values
  y_value,                              # Character: Column name for numeric values (e.g., "sales", "count") OR vector of values
  
  # === GROUPING ===
  group = NULL,                         # Character: Column name for grouping bars by color/category | NULL = single color for all bars
  
  # === FACETING (SMALL MULTIPLES) ===
  facet_var = NULL,                     # Character: Column name to split into separate plots | NULL = single plot
  facet_ncol = NULL,                    # Numeric: Number of columns for facet layout | NULL = automatic
  facet_scales = "free_y",              # Character: Facet axis scaling | Options: "fixed" (same scales), "free" (all free), "free_x", "free_y"
  facet_same_y_scale = TRUE,            # Logical: Use same y-axis across facets | Only applies when facet_scales is not explicitly supplied | TRUE = comparable, FALSE = optimized
  facet_title_size = 12,                # Numeric: Facet panel title (strip text) size in points | Typical: 10-14 (before 2026-10-01: 20)
  facet_title_wrap = NULL,              # Numeric: Wrap facet titles at N characters | NULL = no wrapping, e.g. 20 for long database names
  
  # === BAR ARRANGEMENT ===
  bar_type = "grouped",                 # Character: Bar arrangement | Options: "grouped" (side-by-side), "stacked" (on top), "filled" (100% stacked; positive and negative parts each fill 100 %, labels show the raw values)
  horizontal = FALSE,                   # Logical: Create horizontal bars | TRUE = horizontal, FALSE = vertical
  
  # === TEXT - TITLES ===
  title = NULL,                         # Character: Main plot title | NULL = no title
  title_width = 100,                    # Numeric: Characters before title wraps to new line | Typical: 50-80
  subtitle = NULL,                      # Character: Subtitle below title | NULL = no subtitle
  subtitle_width = 60,                  # Numeric: Characters before subtitle wraps | Typical: 50-80
  caption = NULL,                       # Character: Footer text (source, notes) | NULL = no caption
  
  # === TEXT - AXES ===
  x_axis_title = NULL,                  # Character: Label for x-axis | NULL = no label
  y_axis_title = NULL,                  # Character: Label for y-axis | NULL = no label
  
  # === DATE X-AXIS ===
  x_date_format = NULL,                 # Character: Date label format (strftime) | NULL = auto, e.g. "%Y-%m", "%b %Y", "%Y-Q%q"
  x_date_breaks = NULL,                 # Character: Interval between date ticks | NULL = auto, e.g. "1 month", "3 months", "1 year"
  x_date_minor_breaks = NULL,           # Character: Minor tick interval for dates | NULL = none, e.g. "1 month" when major is "3 months"
  x_number_format = "whole",            # Character: Formatting for continuous numeric x-axis | Options: "whole" (no separators, e.g. 2000), "thousands" (with separators, e.g. 2 000)
  
  # === LEGEND ===
  legend_title = NULL,                  # Character: Title above legend | NULL = uses group column name
  
  # === COLORS ===
  colors = func_fargtema("ru"),         # Vector: Colors for bars/groups | NULL = auto-generated, e.g., c("#FF5733", "#33FF57") | unnamed = assigned
                                        #   in group order (factor levels, unused dropped; numeric sorted; else first appearance after sort_by; recycled if too few),
                                        #   named = matched by group name,
                                        #   e.g. c("Kvinnor" = "#1a9fb3", "Män" = "#ffc107")
  color_palette = "viridis",            # Character: Color scheme when colors=NULL | Options: "viridis", "plasma", "blues", "reds" (own colours: use colors =)

  # === FONTS AND SIZES ===
  font = "Verdana",                     # Character: Font family for all text | Options: "Verdana", "Arial", "Times", "sans", "serif"
  # Defaults lowered 2026-10-01 (before: title 18, subtitle 16, caption 14, axis/legend 14) — use text_scale to scale all text
  text_scale = 1,                       # Numeric: Multiplies every text size (titles, axes, legend, facet titles, data labels) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                      # Numeric: Title font size in points | Typical: 14-18
  title_text_size = 16,                 # Numeric: Alternative for title_size (alias for backward compatibility)
  subtitle_size = 13,                   # Numeric: Subtitle font size in points | Typical: 11-14
  subtitle_text_size = 13,              # Numeric: Alternative for subtitle_size (alias for backward compatibility)
  caption_size = 10,                    # Numeric: Caption font size in points | Typical: 8-11
  axis_text_size = 11,                  # Numeric: Default for both axis tick labels | Overridden by x/y specific params below
  x_axis_text_size = 11,                # Numeric: X-axis tick label font size | Overrides axis_text_size
  y_axis_text_size = 11,                # Numeric: Y-axis tick label font size | Overrides axis_text_size
  legend_text_size = 11,                # Numeric: Legend text font size | Typical: 10-12
  legend_title_size = 11,               # Numeric: Legend title font size | Typical: 10-12
  x_axis_title_size = 11,               # Numeric: X-axis title font size | Typical: 10-12
  y_axis_title_size = 11,               # Numeric: Y-axis title font size | Typical: 10-12

  # === LAYOUT ===
  legend_position = "right",            # Character: Legend placement | Options: "right", "left", "top", "bottom", "none"
  show_major_grid = FALSE,              # Logical/Character: Major background grid lines | TRUE = both directions, FALSE = none,
                                        #   "y" = only lines from the y-axis (horizontal), "x" = only lines from the x-axis (vertical) |
                                        #   refers to the displayed axes: with horizontal = TRUE use "x" for lines at the values
  show_minor_grid = FALSE,              # Logical/Character: Minor background grid lines | Same options as show_major_grid
  x_axis_line = FALSE,                  # Logical: Draw a line along the x-axis (at the panel edge, not at y = 0) | TRUE/FALSE
  y_axis_line = FALSE,                  # Logical: Draw a line along the y-axis | TRUE/FALSE
  x_angle = 0,                          # Numeric: X-axis text rotation | 0=horizontal, 45=diagonal, 90=vertical, auto-rotates if many categories
  x_axis_title_angle = 0,               # Numeric: X-axis title rotation | 0=horizontal, 90=vertical
  
  # === DATA LABELS - DISPLAY ===
  data_labels = FALSE,                  # Logical: Show numeric labels on/above bars | TRUE/FALSE
  data_label_position = "outside",      # Character: Label placement | Options: "outside" (above/below bar), "top" (just inside top), "middle" (center), "inside" (10% from top) |
                                        #   stacked/filled + "outside" = one label per stack with the stack's total (data_label_show_group
                                        #   and data_label_group_values don't apply to totals; data_label_y_values matches the total)
  data_label_size = 3.5,                # Numeric: Label font size in mm (ggplot text units; 3.5 mm ≈ 10 pt) | Typical: 3-4.5 (before 2026-10-01: 4)
  data_label_text_size = 3.5,           # Numeric: Alternative for data_label_size (alias for backward compatibility)
  data_label_color = "black",           # Character: Label text color | Hex code, color name, or "auto" (matches group colors; without group = the bar color; stack totals = black)
  data_label_box = FALSE,               # Logical: Show background box behind labels | TRUE/FALSE
  data_label_box_color = "white",       # Character: Label box background color | Only used if data_label_box=TRUE
  
  # === DATA LABELS - FORMATTING ===
  data_label_format = "number",         # Character: Label number format | Options: "number" (1 234), "percentage" (12,3%), "x_y" (2000: 2 122 — shows x and y value together)
  data_label_decimals = 1,              # Numeric: Decimal places for labels | 0=whole numbers, 1=one decimal, etc.
  data_label_accuracy = 1,              # Numeric: Alternative for data_label_decimals (alias for backward compatibility)
  data_label_width = NULL,              # Numeric: Max characters before label text wraps | NULL = no wrapping
  
  # === DATA LABELS - POSITIONING ===
  data_label_nudge_x = 0,               # Numeric: Horizontal label offset | Positive=right, Negative=left
  data_label_nudge_y = 0,               # Numeric: Vertical label offset | Positive=up, Negative=down
  data_label_repel = FALSE,              # Logical: Use ggrepel smart positioning to avoid overlaps | TRUE/FALSE | Note: disabled by default for stacked bars as repel fights intentional label_y positioning
  data_label_force = 1,                 # Numeric: Repel force strength | Higher = more separation | Typical: 0.5-3
  data_label_max_overlaps = 10,         # Numeric: Max overlaps before hiding a label | Higher = more tolerant | Typical: 3-10
  
  # === DATA LABELS - FILTERING ===
  data_label_filter = NULL,             # Vector: Label only specific x-axis categories | NULL = all | e.g., c("Stockholm", "Göteborg") | Alias for data_label_x_values
  data_label_x_values = NULL,           # Vector: Label only specific x-axis values | NULL = all | Alternative name for data_label_filter
  data_label_y_values = NULL,           # Vector: Label only rows where y matches these values | NULL = all | e.g., c(0, 100) to label extremes
  data_label_group_values = NULL,       # Vector: Label only specific group values | NULL = all groups | e.g., c("2023", "Göteborg") — requires group to be set
  data_label_first_last = FALSE,        # Logical: Show labels only on the first and last bar per group/facet | TRUE/FALSE
  data_label_skip = NULL,               # Numeric: Show every Nth label, skip N-1 between | NULL = show all | e.g. 2=every 2nd, 3=every 3rd (applied per group/facet)
  
  # === DATA LABELS - GROUP NAMES ===
  data_label_show_group = FALSE,        # Logical: Include group name in label text | TRUE = "2023: 5,2", FALSE = "5,2"
  data_label_group_separator = ": ",    # Character: Separator between group name and value | Only used when data_label_show_group=TRUE
  
  # === SORTING ===
  sort_by = NULL,                       # Character: Sort bars | NULL=original order | Options: "value_asc", "value_desc", "name_asc", "name_desc"
  
  # === AXIS LIMITS AND BREAKS ===
  y_axis_min = NULL,                    # Numeric: Minimum y-axis value | NULL = automatic
  y_min = NULL,                         # Numeric: Alternative for y_axis_min (alias for backward compatibility)
  y_axis_max = NULL,                    # Numeric: Maximum y-axis value | NULL = automatic
  y_max = NULL,                         # Numeric: Alternative for y_axis_max (alias for backward compatibility)
  y_axis_breaks = NULL,                 # Vector: Custom y-axis tick positions | NULL = automatic | e.g., c(0, 50, 100, 150)
  y_breaks = NULL,                      # Vector: Alternative for y_axis_breaks (alias for backward compatibility)
  y_axis_n_breaks = NULL,               # Numeric: Target number of y-axis ticks | NULL = automatic | Typical: 4-8 (useful for facets)
  y_n_breaks = NULL,                    # Numeric: Alternative for y_axis_n_breaks (alias for backward compatibility)
  y_axis_auto_breaks = TRUE,            # Logical: Use "pretty" breaks to avoid crowding | TRUE = smart spacing, FALSE = use y_axis_breaks/y_axis_n_breaks exactly
  y_auto_breaks = TRUE,                 # Logical: Alternative for y_axis_auto_breaks (alias for backward compatibility)
  
  # === BAR STYLING ===
  bar_width = NULL,                     # Numeric: Bar width | NULL = auto (smart default for dates vs categories) | Range: 0.1-1 for categories
  bar_line_color = "black",             # Character: Outline color around bars (better contrast for low vision) | NULL = no outline (before 2026-10-01: no outline)
  bar_line_width = 0.3,                 # Numeric: Outline thickness (ggplot linewidth) | Typical: 0.2-0.5

  # === ADVANCED ===
  custom_theme = NULL,                  # ggplot2 theme object: Apply custom styling on top of defaults | NULL = use built-in theme
  debug = FALSE                         # Logical: Return diagnostic info instead of plot | TRUE = debug list, FALSE = plot
) {
  
  # === SETUP ===
  
  # Validate font — installed, or "sans"/"serif"/"mono"; otherwise "sans" (see zzz.R)
  font <- valj_typsnitt(font)
  
  # Load ggrepel only if needed
  if (data_labels && data_label_repel) {
    if (!requireNamespace("ggrepel", quietly = TRUE)) {
      warning("ggrepel not available. Falling back to standard labels.")
      data_label_repel <- FALSE
    }
  }
  
  # Resolve alternative parameter names (last-one-wins if both are supplied)
  title_size_final          <- if (!missing(title_text_size))      title_text_size      else title_size
  subtitle_size_final       <- if (!missing(subtitle_text_size))   subtitle_text_size   else subtitle_size
  data_label_size_final     <- if (!missing(data_label_text_size)) data_label_text_size else data_label_size
  x_axis_text_size_final    <- if (!missing(x_axis_text_size))     x_axis_text_size     else axis_text_size
  y_axis_text_size_final    <- if (!missing(y_axis_text_size))     y_axis_text_size     else axis_text_size
  y_axis_min_final          <- if (!missing(y_min))                y_min                else y_axis_min
  y_axis_max_final          <- if (!missing(y_max))                y_max                else y_axis_max
  y_axis_breaks_final       <- if (!missing(y_breaks))             y_breaks             else y_axis_breaks
  y_axis_n_breaks_final     <- if (!missing(y_n_breaks))           y_n_breaks           else y_axis_n_breaks
  y_axis_auto_breaks_final  <- if (!missing(y_auto_breaks))        y_auto_breaks        else y_axis_auto_breaks
  data_label_decimals_final <- if (!missing(data_label_accuracy))  data_label_accuracy  else data_label_decimals

  # text_scale: one factor for every text size (after the aliases are resolved)
  title_size_final       <- title_size_final       * text_scale
  subtitle_size_final    <- subtitle_size_final    * text_scale
  data_label_size_final  <- data_label_size_final  * text_scale
  x_axis_text_size_final <- x_axis_text_size_final * text_scale
  y_axis_text_size_final <- y_axis_text_size_final * text_scale
  caption_size      <- caption_size      * text_scale
  legend_text_size  <- legend_text_size  * text_scale
  legend_title_size <- legend_title_size * text_scale
  x_axis_title_size <- x_axis_title_size * text_scale
  y_axis_title_size <- y_axis_title_size * text_scale
  facet_title_size  <- facet_title_size  * text_scale

  df_work <- df
  
  # Handle vector inputs — create temporary columns when raw vectors are passed
  if (!is.character(x_value) && length(x_value) > 1) {
    temp_x <- paste0("temp_x_", sample(1000:9999, 1))
    df_work[[temp_x]] <- x_value
    x_value <- temp_x
  }
  if (!is.character(y_value) && length(y_value) > 1) {
    temp_y <- paste0("temp_y_", sample(1000:9999, 1))
    df_work[[temp_y]] <- y_value
    y_value <- temp_y
  }
  
  # Validate that required columns exist in the data
  required_cols <- c(x_value, y_value)
  if (!is.null(group))     required_cols <- c(required_cols, group)
  if (!is.null(facet_var)) required_cols <- c(required_cols, facet_var)
  missing_cols <- setdiff(required_cols, names(df_work))
  if (length(missing_cols) > 0) stop("Missing columns in data: ", paste(missing_cols, collapse = ", "))
  
  # Convert numeric group to factor (ggplot needs discrete scale for fill)
  if (!is.null(group) && is.numeric(df_work[[group]])) df_work[[group]] <- factor(df_work[[group]])
  
  # Wrap long facet titles if requested
  if (!is.null(facet_var) && !is.null(facet_title_wrap) && facet_title_wrap > 0) {
    wrap_long_text <- function(text, width) {
      text <- as.character(text)
      sapply(text, function(x) {
        wrapped <- str_wrap(x, width = width)
        if (any(nchar(strsplit(wrapped, "\n")[[1]]) > width)) {
          chars <- strsplit(x, "")[[1]]
          chunks <- character(0)
          start <- 1
          while (start <= length(chars)) {
            end <- min(start + width - 2, length(chars))
            chunk <- paste0(chars[start:end], collapse = "")
            if (end < length(chars)) chunk <- paste0(chunk, "-")
            chunks <- c(chunks, chunk)
            start <- end + 1
          }
          paste(chunks, collapse = "\n")
        } else wrapped
      }, USE.NAMES = FALSE)
    }
    df_work[[facet_var]] <- wrap_long_text(df_work[[facet_var]], facet_title_wrap)
  }
  if (!is.null(facet_var) && !is.factor(df_work[[facet_var]])) {
    df_work[[facet_var]] <- factor(df_work[[facet_var]], levels = unique(df_work[[facet_var]]))
  }
  
  # === DETECT DATA TYPES ===
  # Date-times are drawn on a date axis (scale_x_date only accepts Date, and errored for POSIXct)
  if (inherits(df_work[[x_value]], "POSIXt")) df_work[[x_value]] <- as.Date(df_work[[x_value]])
  x_is_date       <- inherits(df_work[[x_value]], "Date") || inherits(df_work[[x_value]], "POSIXct")
  x_is_continuous <- is.numeric(df_work[[x_value]])
  y_is_continuous <- is.numeric(df_work[[y_value]])
  
  # === SORTING (skip for date x-axis — dates have natural order) ===
  if (!is.null(sort_by) && !x_is_date) {
    if (sort_by == "value_asc") {
      df_work <- df_work[order(df_work[[y_value]]), ]
    } else if (sort_by == "value_desc") {
      df_work <- df_work[order(-df_work[[y_value]]), ]
    } else if (sort_by == "name_asc") {
      df_work <- df_work[order(df_work[[x_value]]), ]
    } else if (sort_by == "name_desc") {
      df_work <- df_work[order(df_work[[x_value]], decreasing = TRUE), ]
    }
    sorted_levels <- unique(as.character(df_work[[x_value]]))
    # After coord_flip() the first level is drawn at the BOTTOM, so reverse for horizontal bars -
    # otherwise "value_desc" put the largest bar at the bottom instead of the top
    if (horizontal) sorted_levels <- rev(sorted_levels)
    df_work[[x_value]] <- factor(as.character(df_work[[x_value]]), levels = sorted_levels)
  }

  # === GROUP ORDER (same rule in linjediagram, stapeldiagram and karta, so the same data gets the same colors) ===
  # Factor: its level order, unused levels dropped. Otherwise: order of first appearance.
  # NA never takes a color slot (drawn in ggplot's na.value color)
  group_levels <- NULL
  if (!is.null(group)) {
    group_levels <- if (is.factor(df_work[[group]])) setdiff(levels(droplevels(df_work[[group]])), NA)
                    else unique(stats::na.omit(as.character(df_work[[group]])))
  }

  # Debug output
  if (debug) {
    return(list(data = df_work, x_type = class(df_work[[x_value]]), y_type = class(df_work[[y_value]]),
                x_is_date = x_is_date, x_is_continuous = x_is_continuous, y_is_continuous = y_is_continuous,
                group_levels = group_levels))
  }

  # === COLOR SETUP ===
  color_mapping <- NULL
  if (!is.null(group)) {
    n_groups <- length(group_levels)
    if (is.null(colors)) {
      colors <- switch(color_palette,
                       "viridis" = viridisLite::viridis(n_groups, option = "D"),
                       "plasma"  = viridisLite::viridis(n_groups, option = "C"),   # "C" = plasma ("E" gave cividis before funcVGR 0.2.0)
                       "blues"   = scales::brewer_pal(type = "seq", palette = "Blues")(n_groups),
                       "reds"    = scales::brewer_pal(type = "seq", palette = "Reds")(n_groups),
                       viridisLite::viridis(n_groups, option = "D"))
    }
    if (!is.null(names(colors))) {
      # Named colors: matched by group name
      missing_groups <- setdiff(group_levels, names(colors))
      if (length(missing_groups) > 0) stop("colors is named but has no color for: ", toString(missing_groups))
      color_mapping <- colors[group_levels]
    } else {
      # Unnamed colors: assigned in group order, recycled if too few
      color_mapping <- setNames(rep(colors, length.out = n_groups), group_levels)
    }
  }
  
  # Bar position type based on bar_type
  position_type <- switch(bar_type, "grouped" = "dodge", "stacked" = "stack", "filled" = "fill", "dodge")
  
  # Smart default bar width — wider relative units for dates, 0–1 for categories
  if (is.null(bar_width)) {
    if (x_is_date) {
      date_vals <- sort(unique(df_work[[x_value]]))
      bar_width <- if (length(date_vals) > 1) as.numeric(min(diff(date_vals))) * 0.8 else 20
    } else {
      bar_width <- 0.8
    }
  }
  
  # Relevel group to group_levels (factor levels, else row-appearance order) for stacked/filled bars
  # BEFORE the plot is built — ggplot2's position_stack renders bars in factor-level order, and the
  # stacked-label cumsum below assumes that same order, so both must be set from a single releveling
  # here (not re-levelled again later, which would only affect the label math and not the actual bars)
  if (!is.null(group) && bar_type %in% c("stacked", "filled")) {
    df_work[[group]] <- factor(as.character(df_work[[group]]), levels = group_levels)
  }

  # === CREATE BASE PLOT ===
  p <- ggplot(df_work, aes(x = !!sym(x_value), y = !!sym(y_value)))

  # Add bars — with or without group fill. Outline (bar_line_color) also separates stacked segments;
  # NA = no outline, which is what ggplot draws when colour is not set
  bar_outline <- if (is.null(bar_line_color)) NA else bar_line_color
  if (!is.null(group)) {
    p <- p + geom_col(aes(fill = !!sym(group)), position = position_type, width = bar_width,
                      colour = bar_outline, linewidth = bar_line_width)
    p <- p + scale_fill_manual(values = color_mapping, name = legend_title %||% group)
  } else {
    bar_color <- if (!is.null(colors)) colors[1] else "#2E86AB"
    p <- p + geom_col(fill = bar_color, width = bar_width, colour = bar_outline, linewidth = bar_line_width)
  }
  
  if (horizontal) p <- p + coord_flip()

  # === FACET LAYOUT === (before the scales: the category-axis room for labels depends on it)
  if (!is.null(facet_var)) {
    n_facets <- length(unique(df_work[[facet_var]]))
    ncol <- facet_ncol %||% if (n_facets <= 2) n_facets else if (n_facets <= 4) 2 else 3
    # facet_scales wins when the caller explicitly set it — facet_same_y_scale's default-driven
    # override only kicks in when the caller left facet_scales at its default (unsupplied)
    facet_scales_final <- if (!missing(facet_scales)) facet_scales else if (facet_same_y_scale) "fixed" else facet_scales
  }

  # === LABEL LENGTH ESTIMATE (used by both axis scales below) ===
  # Longest data label as it will be shown (stack totals for stacked "outside", x 100 and "%" for percentage,
  # group name / x value prefixes), in characters, and its width in pt (~0.65 em per character: Verdana is
  # wide; measured 0.55 for digits). The scales are set before the labels are built, so this is an estimate.
  # No values (0 rows / all NA) = no labels, so nothing to measure (max() of nothing would warn)
  # One stack = the bars at one x (per facet). Stacked/filled + "outside" shows one label per stack with its total
  # (see the data label section)
  stack_vars   <- c(x_value, if (!is.null(facet_var)) facet_var)
  is_stacked   <- bar_type %in% c("stacked", "filled") && !is.null(group)
  label_totals <- is_stacked && data_label_position == "outside"
  # Facet panel per row; a missing facet value is its own "NA" panel
  facet_key <- function(v) { k <- as.character(v); k[is.na(k)] <- "\rNA"; k }
  n_char <- 0
  label_width_pt <- 0
  if (data_labels && any(!is.na(df_work[[y_value]]))) {
    shown <- if (label_totals) {
      df_work %>% group_by(across(all_of(stack_vars))) %>%
        summarise(v = sum(!!sym(y_value), na.rm = TRUE), .groups = "drop") %>% pull(v)
    } else df_work[[y_value]]
    if (data_label_format == "percentage") shown <- 100 * shown
    num_char <- max(nchar(format(round(abs(shown), data_label_decimals_final),
                                 nsmall = data_label_decimals_final, big.mark = " ", scientific = FALSE, trim = TRUE)),
                    na.rm = TRUE) + 1 +
                (if (data_label_format == "percentage") 1 else 0)
    prefix_char <- (if (data_label_format == "x_y") max(nchar(as.character(df_work[[x_value]])), na.rm = TRUE) +
                      nchar(data_label_group_separator) else 0) +
                   (if (!is.null(group) && data_label_show_group && !label_totals)
                      max(nchar(as.character(df_work[[group]])), na.rm = TRUE) + nchar(data_label_group_separator) else 0)
    n_char <- num_char + prefix_char
    # Text labels wrap at data_label_width (see the data label section), so their widest line is shorter —
    # but the number itself never breaks (its thousands separator is a non-breaking space)
    if (!is.null(data_label_width) && prefix_char > 0) {
      n_char <- max(min(n_char, data_label_width), num_char)
    }
    label_width_pt <- .label_width_pt(n_char, data_label_size_final, data_label_box)
  }

  # === X-AXIS SCALE ===
  category_fit <- NULL   # set for vertical bars on a category axis when label room is made (below)
  # Grouped bars sit side by side (position_dodge); used by the label room below and by the data labels
  is_dodged <- !is.null(group) && bar_type == "grouped"
  if (x_is_date) {
    date_range_days <- as.numeric(diff(range(df_work[[x_value]], na.rm = TRUE)))
    if (is.null(x_date_breaks)) {
      x_date_breaks <- if      (date_range_days <= 90)   "1 month"
      else if (date_range_days <= 365)  "2 months"
      else if (date_range_days <= 730)  "3 months"
      else if (date_range_days <= 1825) "6 months"
      else "1 year"
    }
    if (is.null(x_date_format)) {
      x_date_format <- if      (grepl("year", x_date_breaks))        "%Y"
      else if (grepl("(6|3) month", x_date_breaks)) "%b %Y"
      else if (date_range_days <= 90)               "%Y-%m-%d"
      else "%b %Y"
    }
    scale_args <- list(date_labels = x_date_format, date_breaks = x_date_breaks,
                       expand = expansion(mult = c(0.02, 0.02)))
    if (!is.null(x_date_minor_breaks)) scale_args$minor_breaks <- x_date_minor_breaks
    p <- p + do.call(scale_x_date, scale_args)
    if (x_angle == 0 && nchar(x_date_format) > 4) x_angle <- 45
    
  } else if (x_is_continuous) {
    x_labels_fn <- if (x_number_format == "whole") function(x) as.character(as.integer(x)) else label_number(big.mark = " ", decimal.mark = ",")
    # "whole" labels print as.integer(x), so fractional breaks (2021.5) gave duplicated years -
    # keep only whole-number breaks in that case
    x_breaks_fn <- if (x_number_format == "whole") {
      function(lims) { b <- scales::breaks_pretty()(lims); b[b == round(b)] }
    } else waiver()
    p <- p + scale_x_continuous(labels = x_labels_fn, breaks = x_breaks_fn,
                                expand = expansion(mult = c(0.05, 0.05)))
  } else {
    n_categories <- length(unique(df_work[[x_value]]))
    # Not for horizontal bars: after coord_flip() axis.text.x is the VALUE axis, so the
    # auto-rotation tilted the numbers instead of the (now vertical) category names.
    if (x_angle == 0 && n_categories > 8 && !horizontal) x_angle <- 45
    # Vertical bars with labels: the outermost bars reach the panel edge, so a label wider than its bar was
    # clipped there ("1 842,0" drawn as "842,0"). Add room (category units) so half the widest label fits
    # beyond the outermost bar's centre. A category's width in pt depends on the panel width, which is only
    # known when drawn — assumed a 6 in (432 pt) wide chart minus the y-axis text (estimated) and, with the legend left
    # or right, its estimated width, split over the facet columns (same rule as func_graf_linjediagram). Wider
    # charts get some extra room at the ends; narrower ones or very large text (text_scale 2) can still clip a
    # few pt — then widen the chart or lower text_scale. The room never exceeds half the bars' own span on
    # either side, so the bars keep at least half the panel (labels wider than that would be clipped anyway).
    # Iterated because the added room itself narrows each category
    category_add <- 0
    if (data_labels && !horizontal && n_categories > 0) {
      # Dodged bars: one slot per group, plus one for NA when the group column has missing values
      n_dodge <- if (is_dodged) {
        max(length(group_levels) + any(is.na(df_work[[group]])), 1)
      } else 1
      legend_pt <- if (!is.null(group) && legend_position %in% c("left", "right")) {
        .legend_width_pt(c(group_levels, legend_title %||% group), legend_text_size)
      } else 0
      # y-axis text from the tick labels the axis will show (pretty() breaks over the bars, stack sums for
      # stacked, "100 %" for filled); once, or per panel when the facets have free y scales (own axis each)
      y_axis_values <- if (bar_type == "stacked" && !is.null(group)) {
        df_work %>% group_by(across(all_of(stack_vars))) %>%
          summarise(pos = sum(pmax(!!sym(y_value), 0), na.rm = TRUE), neg = sum(pmin(!!sym(y_value), 0), na.rm = TRUE),
                    .groups = "drop") %>% { c(.$pos, .$neg) }
      } else df_work[[y_value]]
      y_axis_values <- c(0, y_axis_values[is.finite(y_axis_values)])
      y_tick_chars <- if (bar_type == "filled") 5 else
        max(nchar(label_number(big.mark = " ", decimal.mark = ",")(pretty(range(y_axis_values)))), na.rm = TRUE)
      n_cols <- if (!is.null(facet_var)) min(ncol, n_facets) else 1
      panel_pt <- .panel_width_pt(legend_pt, y_tick_chars, y_axis_text_size_final, n_cols,
                                  own_y_axis = !is.null(facet_var) && facet_scales_final %in% c("free", "free_y"))
      # Free category axis in facets: each panel shows only its own categories
      n_cat_panel <- if (!is.null(facet_var) && facet_scales_final %in% c("free", "free_x")) {
        max(tapply(as.character(df_work[[x_value]]), facet_key(df_work[[facet_var]]), function(v) length(unique(v))), na.rm = TRUE)
      } else n_categories
      # Distance from the first category's centre to the outermost label's centre: dodged bars sit off-centre;
      # without dodge, data_label_nudge_x moves every label sideways (towards one edge)
      label_offset <- bar_width / 2 - bar_width / (2 * n_dodge) +
                      (if (!is_dodged) abs(data_label_nudge_x) else 0)
      for (i in 1:10) {
        panel_range <- max(n_cat_panel - 1 + bar_width, (n_cat_panel - 1) * 1.1 + 2 * category_add)
        half_label <- (label_width_pt / 2 + 2) / (panel_pt / panel_range)   # + 2 pt to the edge
        category_add <- max(0, label_offset + half_label - 0.05 * (n_cat_panel - 1))
        category_add <- min(category_add, (n_cat_panel - 1 + bar_width) / 2)   # bars keep at least half the panel
      }
      # Kept for the labels: where the cap is reached (narrow facets, large text) a label that would still
      # stick out is moved inwards with hjust (see the data label section)
      category_fit <- list(panel_pt = panel_pt, add = category_add)
    }
    p <- p + scale_x_discrete(expand = expansion(mult = c(0.05, 0.05), add = category_add))
  }
  
  # === Y-AXIS SCALE ===
  if (y_is_continuous) {
    expansion_mult <- if (data_labels) {
      if (!is.null(facet_var)) c(0.1, 0.25) else c(0.05, 0.20)
    } else c(0.05, 0.15)
    # "outside" labels on negative bars sit below the bar (edge-anchored), so they need the same room
    # at the low end as positive labels get at the top — otherwise they are clipped at the panel edge
    if (data_labels && data_label_position == "outside" && any(df_work[[y_value]] < 0, na.rm = TRUE)) {
      expansion_mult[1] <- expansion_mult[2]
    }
    # Horizontal bars: an "outside" label runs along the value axis, so the room it needs grows with its
    # length and text size — a fixed 20 % cut long labels ("-12 345,6") in narrow plots or with text_scale.
    # Label width from the estimate above (n_char, without the geom_label padding as before), on a ~200 pt
    # wide panel, plus the 3 % gap
    if (horizontal && data_labels && data_label_position == "outside") {
      need <- n_char * data_label_size_final * ggplot2::.pt * 0.65 / 200 + 0.03   # 0.65 em: Verdana is wide
      if (any(df_work[[y_value]] >= 0, na.rm = TRUE)) expansion_mult[2] <- max(expansion_mult[2], need)
      if (any(df_work[[y_value]] < 0,  na.rm = TRUE)) expansion_mult[1] <- max(expansion_mult[1], need)
    }

    scale_args <- list(
      labels = if (bar_type == "filled") percent else label_number(big.mark = " ", decimal.mark = ","),
      expand = expansion(mult = expansion_mult))
    
    if (!is.null(y_axis_breaks_final)) {
      scale_args$breaks <- y_axis_breaks_final
    } else if (y_axis_auto_breaks_final) {
      n_breaks_auto <- if (!is.null(y_axis_n_breaks_final)) y_axis_n_breaks_final else if (!is.null(facet_var)) 4 else 6
      scale_args$breaks <- scales::breaks_pretty(n = n_breaks_auto)
    }
    if (!is.null(y_axis_min_final) || !is.null(y_axis_max_final)) {
      scale_args$limits <- c(if (is.null(y_axis_min_final)) NA else y_axis_min_final, if (is.null(y_axis_max_final)) NA else y_axis_max_final)
    }
    
    p <- p + do.call(scale_y_continuous, scale_args)
  } else {
    p <- p + scale_y_discrete(expand = expansion(mult = c(0.05, 0.05)))
  }
  
  # === FACETING === (layout computed in FACET LAYOUT above)
  if (!is.null(facet_var)) {
    p <- p + facet_wrap(vars(!!sym(facet_var)), scales = facet_scales_final, ncol = ncol)
  }
  
  # === DATA LABELS ===
  if (data_labels) {
    
    # For stacked/filled charts: compute cumulative y on the FULL dataset BEFORE any label
    # filtering — if we filtered first, cumsum would only see the remaining segment(s) and
    # give the raw segment value instead of the true stack position.
    # IMPORTANT: cumsum order must match ggplot2's stacking order, which follows factor levels
    # derived from unique(group column). We also pre-compute the total bar height (stack_total)
    # for "outside" labels, which doesn't depend on stacking order at all.
    # (is_stacked, label_totals and stack_vars: see LABEL LENGTH ESTIMATE)
    if (is_stacked) {
      # Totals per stack (raw values) — stack_total is the value shown by "outside" labels;
      # stack_pos/stack_neg are the sums of the positive and negative segments
      stack_totals <- df_work %>%
        group_by(across(all_of(stack_vars))) %>%
        summarise(stack_total = sum(!!sym(y_value), na.rm = TRUE),
                  stack_pos   = sum(pmax(!!sym(y_value), 0), na.rm = TRUE),
                  stack_neg   = sum(pmin(!!sym(y_value), 0), na.rm = TRUE), .groups = "drop")

      # Positions in plot units, as ggplot2 draws them: positive segments stack upwards from 0 and
      # negative ones downwards, separately. "filled" (position_fill) normalises each part on its own:
      # positives to 0..1 by stack_pos, negatives to -1..0 by stack_neg (labels used raw values before,
      # on a 0..1 axis, which squashed the bars).
      # position_stack renders in REVERSE factor level order (level 1 = top, last level = bottom), so the
      # cumsum goes in reverse order too; group was already releveled before the plot was built.
      is_filled <- bar_type == "filled"
      df_work <- df_work %>%
        left_join(stack_totals, by = stack_vars) %>%
        group_by(across(all_of(stack_vars))) %>%
        arrange(desc(!!sym(group)), .by_group = TRUE) %>%   # desc = reverse = matches ggplot2
        mutate(
          .vp = if (is_filled) ifelse(!!sym(y_value) >= 0,
                                      ifelse(stack_pos > 0, !!sym(y_value) / stack_pos, 0),
                                      ifelse(stack_neg < 0, !!sym(y_value) / abs(stack_neg), 0))
                else !!sym(y_value),
          stack_top = ifelse(.vp >= 0, cumsum(pmax(.vp, 0, na.rm = TRUE)), cumsum(pmin(.vp, 0, na.rm = TRUE))),  # outer edge
          stack_mid = stack_top - .vp / 2,                                                                       # midpoint
          .end_pos  = if (is_filled) as.numeric(stack_pos > 0) else stack_pos,    # ends of the drawn stack
          .end_neg  = if (is_filled) -as.numeric(stack_neg < 0) else stack_neg
        ) %>%
        ungroup()
    }
    
    df_labels <- df_work

    # Stacked/filled + "outside": all segments of a stack would get a label at the same point (printed
    # on top of each other) — instead one label per stack, showing the stack's total. Chosen BEFORE
    # first/last and skip, which then count stacks (not groups — a total belongs to no group).
    # A stack whose values are all missing draws no bar, so it gets no label either
    label_group  <- if (label_totals) NULL else group   # grouping used by first/last and skip
    if (label_totals) {
      df_labels <- df_labels %>%
        group_by(across(all_of(stack_vars))) %>%
        filter(any(!is.na(!!sym(y_value)))) %>%
        slice(1) %>% ungroup()
    }

    # Merge x-filter aliases — data_label_filter and data_label_x_values are interchangeable
    x_filter <- data_label_filter %||% data_label_x_values

    # First/last: keep only the first and last bar per group/facet combination
    if (data_label_first_last) {
      grouping_vars <- c(label_group, facet_var)[!sapply(c(label_group, facet_var), is.null)]
      if (length(grouping_vars) > 0) {
        # Sort on x first - slice() takes rows in data order, so unsorted data gave arbitrary bars
        df_labels <- df_labels %>%
          group_by(across(all_of(grouping_vars))) %>%
          arrange(!!sym(x_value), .by_group = TRUE) %>%
          slice(unique(c(1, n()))) %>%
          ungroup()
      } else {
        df_labels <- df_labels %>% arrange(!!sym(x_value)) %>% slice(unique(c(1, n())))
      }
    }
    
    # Filter to specific x-axis categories if requested
    if (!is.null(x_filter)) df_labels <- df_labels %>% filter(!!sym(x_value) %in% x_filter)
    
    # Filter to specific y values if requested (e.g., label only bars at 0 or max) — for total labels
    # the shown value is the stack total, so that is what is matched
    if (!is.null(data_label_y_values)) {
      df_labels <- if (label_totals) df_labels %>% filter(stack_total %in% data_label_y_values)
                   else df_labels %>% filter(!!sym(y_value) %in% data_label_y_values)
    }

    # Filter to specific group values if requested (e.g., label only one series in a grouped bar chart).
    # Not for total labels: a stack total belongs to no single group
    if (!is.null(data_label_group_values) && !is.null(group) && !label_totals) {
      df_labels <- df_labels %>% filter(!!sym(group) %in% data_label_group_values)
    }

    # Ensure one label per bar (group by all relevant dimensions)
    group_vars <- c(x_value)
    if (!is.null(label_group)) group_vars <- c(group_vars, label_group)
    if (!is.null(facet_var))   group_vars <- c(group_vars, facet_var)
    df_labels <- df_labels %>% group_by(across(all_of(group_vars))) %>% slice(1) %>% ungroup()

    # Show every Nth label — applied per group/facet combination (per facet for total labels)
    if (!is.null(data_label_skip) && data_label_skip > 1) {
      skip_group_vars <- c(label_group, facet_var)[!sapply(c(label_group, facet_var), is.null)]
      if (length(skip_group_vars) > 0) {
        df_labels <- df_labels %>%
          group_by(across(all_of(skip_group_vars))) %>%
          arrange(!!sym(x_value), .by_group = TRUE) %>%
          filter(row_number() %% data_label_skip == 1) %>%
          ungroup()
      } else {
        df_labels <- df_labels %>%
          arrange(!!sym(x_value)) %>%
          filter(row_number() %% data_label_skip == 1)
      }
    }
    
    # Format label values — "x_y" combines x and y into a single label (e.g. "2000: 2 122")
    # Swedish format for every value: decimal comma and a fixed number of decimals
    # (1,5 and 2,0 - previously values under 1000 went through as.character() and
    # came out as "1.5" and "2"). Formatted one value at a time, since format() on a
    # vector pads all values to a common width.
    format_value <- function(val) {
      scaled  <- if (data_label_format == "percentage") 100 * val else val
      rounded <- round(scaled, data_label_decimals_final)
      txt <- vapply(rounded, function(v) {
        if (is.na(v)) return(NA_character_)
        format(v, nsmall = data_label_decimals_final, big.mark = " ", decimal.mark = ",",
               scientific = FALSE, trim = TRUE)
      }, character(1))
      if (data_label_format == "percentage") paste0(txt, "%") else txt
    }
    
    # Build label text — x_y handled via mutate (needs both columns); other formats use format_value()
    # Conditional must stay outside mutate() to avoid sym(NULL) crash on group
    df_labels <- if (label_totals) df_labels %>% mutate(base_value = format_value(stack_total))
                 else df_labels %>% mutate(base_value = format_value(!!sym(y_value)))
    df_labels <- if (data_label_format == "x_y") {
      df_labels %>% mutate(base_value = paste0(!!sym(x_value), data_label_group_separator, base_value))
    } else df_labels
    df_labels <- if (!is.null(group) && data_label_show_group && !label_totals) {   # a total has no single group
      df_labels %>% mutate(label_text = paste0(!!sym(group), data_label_group_separator, base_value))
    } else {
      df_labels %>% mutate(label_text = base_value)
    }
    
    # Auto-nudge to clear the bar end when labels are "outside": 3% of the span the bars cover, from 0
    # (bars start at 0) to the labelled ends, in plot units (0..1 for filled). Including 0 keeps a gap when
    # all ends are equal (filled = 1, shares summing to 100, a single labelled bar) — it used to be 0 there.
    # With facets on a free y-scale it is computed per facet, otherwise a small facet gets the large
    # facet's gap and its bars are squashed
    # Free VALUE axis: "free_y" on vertical bars; on horizontal bars coord_flip makes "free_x" free the value axis
    free_y <- !is.null(facet_var) && facet_scales_final %in% c("free", if (horizontal) "free_x" else "free_y")
    nudge_by <- if (free_y) facet_var else character(0)
    df_labels <- df_labels %>%
      mutate(.ref_end = if (is_stacked) ifelse(stack_total >= 0, .end_pos, .end_neg) else !!sym(y_value)) %>%
      group_by(across(all_of(nudge_by))) %>%
      mutate(auto_nudge = if (data_label_position == "outside" && data_label_nudge_y == 0)
                            (max(c(.ref_end, 0), na.rm = TRUE) - min(c(.ref_end, 0), na.rm = TRUE)) * 0.03
                          else 0) %>%
      ungroup()
    
    # Calculate y position for each label based on data_label_position
    # "outside" uses stack_total (total bar height, stacking-order-independent)
    # "top"/"middle"/"inside" use stack_top/stack_mid (segment-specific cumulative position)
    # data_label_position is a single value, so the choice is made with base if/else —
    # case_when() with scalar conditions is deprecated in dplyr 1.2.0. Only the sign test for
    # "outside" is row-wise and stays vectorised (ifelse).
    if (is_stacked) {
      df_labels <- df_labels %>%
        mutate(label_y =
          # "outside": beyond the end of the stack in the direction of its total (top of the positive part,
          # or bottom of the negative part) — the net sum lies inside the bar when the stack has negatives
          if (data_label_position == "outside")
            ifelse(stack_total >= 0, .end_pos + abs(auto_nudge), .end_neg - abs(auto_nudge)) + data_label_nudge_y
          else if (data_label_position == "top")    stack_top - .vp * 0.05 + data_label_nudge_y
          else if (data_label_position == "middle") stack_mid + data_label_nudge_y
          else if (data_label_position == "inside") stack_top - .vp * 0.10 + data_label_nudge_y
          else                                      stack_top + data_label_nudge_y)
    } else {
      df_labels <- df_labels %>%
        mutate(label_y =
          if (data_label_position == "outside")
            ifelse(!!sym(y_value) >= 0, !!sym(y_value) + abs(auto_nudge), !!sym(y_value) - abs(auto_nudge)) + data_label_nudge_y
          else if (data_label_position == "top")    !!sym(y_value) * 0.95 + data_label_nudge_y
          else if (data_label_position == "middle") (!!sym(y_value) / 2)  + data_label_nudge_y
          else if (data_label_position == "inside") !!sym(y_value) * 0.90 + data_label_nudge_y
          else                                      !!sym(y_value) + data_label_nudge_y)
    }
    
    # Wrap label text (only for labels with text: x_y format or a group-name prefix — a bare number never wraps)
    has_text <- !data_label_format %in% c("number", "percentage") || (!is.null(group) && data_label_show_group && !label_totals)
    if (!is.null(data_label_width) && has_text) {
      df_labels$label_text <- str_wrap(df_labels$label_text, width = data_label_width)
    }
    
    # Determine label color — "auto" maps to group colors, otherwise fixed color. A stack total has
    # no single group, and without group "auto" means the bar color ("auto" used to reach ggplot as
    # a color name and crash)
    labels_use_color_aes <- data_label_color == "auto" && !is.null(group) && !is.null(color_mapping) && !label_totals
    if (labels_use_color_aes) {
      df_labels$label_color <- color_mapping[as.character(df_labels[[group]])]
    } else if (data_label_color == "auto") {
      df_labels$label_color <- if (is.null(group) && !is.null(colors)) colors[[1]] else if (is.null(group)) "#2E86AB" else "black"
    } else {
      df_labels$label_color <- data_label_color
    }
    
    # Add labels to plot
    if (nrow(df_labels) > 0) {
      # position_nudge() and position_dodge() cannot be combined — nudge_x only applies without dodge (is_dodged above)
      # Stacked labels must use "identity" position — dodge would split them back to raw segment y
      # (is_stacked computed above; for stacked bars, label_y already encodes cumulative position)
      pos_setting <- if (is_dodged) position_dodge(width = bar_width)
      else if (data_label_nudge_x != 0) position_nudge(x = data_label_nudge_x)
      else "identity"
      use_repel <- data_label_repel && !is_stacked
      geom_fn <- if (use_repel) {
        # ggrepel only for non-stacked — repel fights intentional stack_top positioning
        if (data_label_box) geom_label_repel else geom_text_repel
      } else {
        if (data_label_box) geom_label else geom_text
      }
      
      # Build aes() outside to avoid sym(NULL) crash — !! is eagerly evaluated inside aes()
      if (!is.null(group) && labels_use_color_aes) {
        label_mapping <- aes(x = !!sym(x_value), y = label_y, label = label_text,
                             group = !!sym(group), color = !!sym(group))
      } else if (!is.null(group)) {
        label_mapping <- aes(x = !!sym(x_value), y = label_y, label = label_text,
                             group = !!sym(group))
      } else {
        label_mapping <- aes(x = !!sym(x_value), y = label_y, label = label_text)
      }
      
      label_args <- list(data = df_labels, mapping = label_mapping,
                         position = pos_setting, size = data_label_size_final, show.legend = FALSE,
                         family = font)   # labels in the chart font too (they fell back to the device default)
      if (!labels_use_color_aes) label_args$color <- df_labels$label_color
      if (data_label_box)        label_args$fill  <- data_label_box_color
      # "outside" with the automatic gap (data_label_nudge_y = 0): anchor the label's edge (not its centre)
      # at the gap point, so the text never overlaps the bar or its outline whatever the text size (text_scale).
      # Negative bars anchor the other way; on horizontal bars (coord_flip) the value axis is horizontal, so
      # hjust does it. Mapped as an aesthetic from a column, so it follows each label when ggplot reorders rows
      # (facets) — a fixed vector would be applied in the wrong order. A user-set nudge keeps centred labels.
      if (data_label_position == "outside" && data_label_nudge_y == 0 && !use_repel) {
        above <- if (is_stacked) df_labels$stack_total >= 0 else df_labels[[y_value]] >= 0
        df_labels$.label_just <- ifelse(is.na(above) | above, 0, 1)
        label_args$data <- df_labels
        label_args$mapping[[if (horizontal) "hjust" else "vjust"]] <- rlang::quo(.label_just)
      }
      # Vertical bars on a category axis: where the label room reached its cap (narrow facets, large text) a label
      # that would still stick out past the axis limits is moved just inside with hjust (0 = starts at its bar's
      # centre, 1 = ends there), as in func_graf_linjediagram and the D3 version. Labels that fit keep 0.5, so
      # charts with enough room are unchanged. Centres as ggplot draws them: category position on the axis (per
      # panel with a free category axis), spread by position_dodge over the labels at that category
      if (!is.null(category_fit) && !use_repel) {
        # Categories in axis order; ggplot draws a missing x (NA) as its own category last
        cat_levels <- function(v) c(if (is.factor(v)) levels(droplevels(v)) else sort(unique(as.character(v[!is.na(v)]))),
                                    if (anyNA(v)) NA)
        free_cats <- !is.null(facet_var) && facet_scales_final %in% c("free", "free_x")
        panel_key <- if (free_cats) facet_key(df_labels[[facet_var]]) else rep("", nrow(df_labels))
        work_key  <- if (free_cats) facet_key(df_work[[facet_var]]) else rep("", nrow(df_work))
        centre <- rep(NA_real_, nrow(df_labels)); n_panel <- rep(NA_real_, nrow(df_labels))
        for (pk in unique(panel_key)) {
          rows <- panel_key == pk
          lv <- cat_levels(df_work[[x_value]][work_key == pk])
          centre[rows] <- match(as.character(df_labels[[x_value]][rows]), lv)
          n_panel[rows] <- length(lv)
        }
        if (is_dodged) {
          # position_dodge spreads the labels present at a category, in group order
          slot_key <- paste(if (!is.null(facet_var)) df_labels[[facet_var]] else "", df_labels[[x_value]], sep = "\r")
          group_rank <- match(as.character(df_labels[[group]]), cat_levels(df_labels[[group]]))
          k <- stats::ave(group_rank, slot_key, FUN = function(r) rank(r, ties.method = "first"))
          n <- stats::ave(group_rank, slot_key, FUN = length)
          centre <- centre + (k - (n + 1) / 2) * bar_width / n
        } else centre <- centre + data_label_nudge_x
        lo <- pmin(1 - 0.05 * (n_panel - 1) - category_fit$add, 1 - bar_width / 2)
        hi <- pmax(n_panel + 0.05 * (n_panel - 1) + category_fit$add, n_panel + bar_width / 2)
        df_labels$.hjust <- .label_hjust_inside(df_labels$label_text, centre, lo, hi, category_fit$panel_pt / (hi - lo),
                                                data_label_size_final, data_label_box)
        label_args$data <- df_labels
        label_args$mapping$hjust <- rlang::quo(.hjust)
      }
      if (use_repel) {
        label_args$force        <- data_label_force        # repel force strength — only valid for ggrepel geoms
        label_args$max.overlaps <- data_label_max_overlaps  # max overlaps before hiding a label — only valid for ggrepel geoms
      }

      p <- p + do.call(geom_fn, label_args)

      # Back the aes(color=) used for "auto" label colors with the same color_mapping as the
      # bars' scale_fill_manual() — without this, ggplot2's default hue palette would drive
      # label colors instead, so labels would not match the bars they annotate
      if (labels_use_color_aes) p <- p + scale_color_manual(values = color_mapping, guide = "none")
    }
  }
  
  # === THEME ===
  bottom_margin <- if (x_angle > 0) 25 else 10
  
  p <- p + theme_minimal() +
    theme(text = element_text(family = font),
          plot.title = element_text(size = title_size_final, hjust = 0),
          plot.title.position = "plot",
          plot.subtitle = element_text(size = subtitle_size_final, hjust = 0),
          plot.caption = element_text(size = caption_size, hjust = 1),
          axis.text.x = element_text(size = x_axis_text_size_final, angle = x_angle,
                                     hjust = if (x_angle > 0) 1 else 0.5),
          axis.text.y = element_text(size = y_axis_text_size_final),
          axis.title.x = element_text(size = x_axis_title_size, angle = x_axis_title_angle, hjust = 0.5),
          axis.title.y = element_text(size = y_axis_title_size, hjust = 0.5),
          legend.text = element_text(size = legend_text_size),
          legend.title = element_text(size = legend_title_size),
          legend.position = legend_position,
          plot.background = element_rect(fill = "white", color = NA),
          plot.margin = margin(t = 10, r = 10, b = bottom_margin, l = 10, unit = "pt"))

  # Grid and axis lines. TRUE/FALSE set the parent element exactly as before, so a later
  # custom_theme / + theme(panel.grid...) still reaches both directions; "x"/"y" (the displayed
  # axis, also after coord_flip) blank the parent and draw only that child. Axis lines are only
  # set when switched on, so FALSE leaves theme_minimal's default (and custom_theme) in charge
  grid_ok <- function(v) isTRUE(v) || isFALSE(v) || identical(v, "x") || identical(v, "y")
  if (!grid_ok(show_major_grid)) stop("show_major_grid must be TRUE, FALSE, \"x\" or \"y\"")
  if (!grid_ok(show_minor_grid)) stop("show_minor_grid must be TRUE, FALSE, \"x\" or \"y\"")
  grid_theme <- list()
  for (g in list(list(val = show_major_grid, el = "panel.grid.major", col = "grey90"),
                 list(val = show_minor_grid, el = "panel.grid.minor", col = "grey95"))) {
    if (is.logical(g$val)) {
      grid_theme[[g$el]] <- if (g$val) element_line(color = g$col) else element_blank()
    } else {
      grid_theme[[g$el]] <- element_blank()
      grid_theme[[paste0(g$el, ".", g$val)]] <- element_line(color = g$col)
    }
  }
  if (x_axis_line) grid_theme$axis.line.x <- element_line(color = "black", linewidth = 0.5)
  if (y_axis_line) grid_theme$axis.line.y <- element_line(color = "black", linewidth = 0.5)
  p <- p + do.call(theme, grid_theme)

  # Facet-specific styling
  if (!is.null(facet_var)) {
    p <- p + theme(panel.spacing   = unit(0.8, "lines"),
                   panel.spacing.x = unit(0.8, "lines"),
                   panel.spacing.y = unit(0.8, "lines"),
                   panel.border    = element_rect(color = "grey70", fill = NA, linewidth = 0.3),
                   strip.background = element_rect(fill = "white", color = NA, linewidth = 0),
                   strip.text      = element_text(size = facet_title_size, face = "plain",
                                                  lineheight = 0.75,
                                                  margin = margin(t = 4, b = 12, l = 4, r = 4)),
                   # Axis titles are not blanked here: labs(x = NULL) already hides an unset
                   # title, and element_blank() also hid titles the caller explicitly supplied
                   plot.margin     = margin(t = 15, r = 15, b = bottom_margin + 5, l = 15, unit = "pt"))
  }
  
  # === LABELS ===
  p <- p + labs(title    = if (!is.null(title))    str_wrap(title,    width = title_width)    else NULL,
                subtitle = if (!is.null(subtitle)) str_wrap(subtitle, width = subtitle_width) else NULL,
                caption = caption, x = x_axis_title, y = y_axis_title)
  
  if (!is.null(custom_theme)) p <- p + custom_theme
  
  return(p)
}
