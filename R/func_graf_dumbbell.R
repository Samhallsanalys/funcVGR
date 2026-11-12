#' Dumbbell-diagram (före/efter)
#'
#' Jämför två perioder per kategori. Varje kategori visas som två punkter
#' förbundna med en linje. Om `group` har fler än två värden jämförs den första
#' och den sista perioden (med varning). Med `date_column` väljs automatiskt det tidigaste och
#' det senaste datumet. Kategorierna kan sorteras på slutvärde, startvärde,
#' förändring, spännvidd eller i bokstavsordning. Utvalda kategorier kan
#' markeras med bakgrundsfärg eller sidostapel, och pilar kan visa
#' förändringens riktning.
#'
#' @inheritParams func_graf_linjediagram
#' @inheritParams func_graf_barchart
#' @inheritParams func_graf_karta
#' @param x_value Kolumnnamn för kategorierna, t.ex. `"region"`. Obligatorisk.
#' @param y_value Kolumnnamn för de numeriska värdena. Måste vara numerisk.
#'   Obligatorisk.
#' @param group Kolumnnamn för perioden, t.ex. `"ar"`. Minst två värden krävs.
#'   Perioderna ordnas i tidsordning oberoende av radernas ordning: faktorer
#'   efter nivåordning, tal och datum stigande, och text som börjar med en
#'   siffra (t.ex. `"2014"`) sorteras. Annan text, t.ex. `"Före"`/`"Efter"`,
#'   behåller ordningen i data. Använd en faktor för att styra ordningen.
#'   Obligatorisk.
#' @param date_column Valfri datumkolumn. Om den anges används bara rader med
#'   det tidigaste och det senaste datumet. `NULL` = alla rader.
#' @param sort_axis_by Sortering av kategorierna: `"original"`,
#'   `"alphabetical"`, `"range"`, `"start_value"`, `"end_value"` eller
#'   `"change"`.
#' @param sort_direction Sorteringsordning: `"desc"` eller `"asc"`.
#' @param dumbbell_horizontal `TRUE` = liggande, `FALSE` = stående.
#' @param point_size Ändpunkternas storlek (typiskt 2–8).
#' @param point_shape Ändpunkternas form: 16 = cirkel, 15 = kvadrat,
#'   17 = triangel, 18 = romb.
#' @param line_size Tjocklek på linjen mellan punkterna.
#' @param line_type Linjetyp: `"solid"`, `"dashed"`, `"dotted"` eller
#'   `"dotdash"`.
#' @param line_color Linjens färg.
#' @param point_alpha Punkternas opacitet (0–1).
#' @param baseline_show Visa en referenslinje vid noll.
#' @param baseline_color Referenslinjens färg.
#' @param baseline_size Referenslinjens tjocklek.
#' @param show_direction_arrow Visa pilar för ökning (grön) eller minskning
#'   (röd).
#' @param change_threshold Minsta absoluta förändring för att en pil ska
#'   visas.
#' @param subtitle_text_size Underrubrikens teckenstorlek.
#' @param colors Två färger, för första och andra perioden.
#' @param color_darkest,color_lightest Alternativt färgpar. Används i stället
#'   för `colors` om båda anges.
#' @param before_color,after_color Färg för första respektive andra perioden.
#'   Går före övriga färgargument om båda anges.
#' @param highlight_x_values Kategorier som ska markeras. Måste matcha
#'   värdena i `x_value`.
#' @param highlight_background Färga bakgrunden för markerade kategorier.
#' @param highlight_background_color Bakgrundsfärg för markeringen.
#' @param highlight_background_alpha Markeringens opacitet (0–1).
#' @param highlight_background_full_width `TRUE` = markeringen går över hela
#'   diagrammet, `FALSE` = bara över dataområdet.
#' @param highlight_bar Visa en färgad sidostapel för markerade kategorier.
#' @param highlight_bar_color Sidostapelns färg. `NULL` = samma som
#'   `highlight_background_color`.
#' @param highlight_bar_width Sidostapelns bredd som andel av diagrammet
#'   (0,01–0,1).
#' @param highlight_bar_alpha Sidostapelns opacitet (0–1).
#' @param data_label_position Vilka punkter som får etikett:
#'   `"end"`/`"latest"`/`"right"` (sista perioden),
#'   `"start"`/`"first"`/`"left"` (första perioden) eller `"both"`/`"all"`.
#'   Väljer bara punkterna. Vilken sida etiketten hamnar på styrs av
#'   `data_label_side`.
#' @param data_label_side Vilken sida om punkten etiketten hamnar på:
#'   `"value"` (standard) lägger etiketten för den lägre punkten till vänster
#'   (liggande) eller under (stående), och den högre punktens etikett till
#'   höger eller över, så att etiketterna inte hamnar på linjen mellan
#'   punkterna. Med \pkg{ggrepel} kan en etikett ändå flyttas tillbaka till
#'   linjen. `"period"` lägger första periodens etikett till vänster/under och
#'   sista periodens till höger/över.
#' @param data_label_nudge_x,data_label_nudge_y Förskjutning av etiketterna. I
#'   liggande diagram anger `data_label_nudge_x` bara avståndet (riktningen
#'   styrs av `data_label_side`, minst 3 % av dataområdet), och
#'   `data_label_nudge_y` anges i kategorienheter (1 = en rad, t.ex. 0,3 =
#'   strax ovanför punkten). I stående diagram är det tvärtom:
#'   `data_label_nudge_x` anges i kategorienheter och `data_label_nudge_y` är
#'   avståndet.
#' @param data_label_axis_padding Skalar det extra utrymme på värdeaxeln som
#'   läggs till för etiketterna när `data_label_repel = FALSE`, så att de inte
#'   klipps vid panelkanten. 1 = anpassat för ett diagram på cirka 6 × 4 tum
#'   (före funcVGR 0.2.0: 8 × 5 tum), < 1 för större bilder, > 1 för mindre och
#'   0 = av (ggplot2:s standardaxel).
#' @param x_axis_clip_off `TRUE` visar alla etiketter, även utanför panelens
#'   kant (`coord_cartesian(clip = "off")`), men de kan då överlappa axeltext
#'   eller en intilliggande panel. `FALSE` klipper vid panelkanten. Gäller hela
#'   panelen i båda riktningarna. Utrymmet på axeln styrs av
#'   `data_label_axis_padding`.
#' @param data_label_color Etiketternas textfärg.
#' @param data_label_text_size Etiketternas teckenstorlek i mm (ggplot2:s
#'   enhet; 3,5 mm motsvarar ungefär 10 punkter). Skalas med `text_scale`.
#' @param data_label_width Max antal tecken innan etiketten radbryts.
#' @param data_label_angle Etiketternas rotation i grader.
#' @param data_label_only_first_last Visa etiketter bara för första och sista
#'   kategorin.
#' @param debug `TRUE` skriver ut diagnostik i konsolen. Diagrammet returneras
#'   ändå.
#'
#' @return Ett `ggplot`-objekt.
#' @seealso [func_graf_barchart()], [func_graf_linjediagram()]
#' @export
#'
#' @example inst/examples/func_graf_dumbbell.R
func_graf_dumbbell <- function(
    # === REQUIRED DATA ===
  df,                                   # Data frame: Your dataset
  x_value,                              # Character: Column name for categories (e.g., "region", "municipality")
  y_value,                              # Character: Column name for numeric values (e.g., "unemployment_rate")
  group,                                # Character: Column name for time periods (e.g., "year", "quarter")
  
  # === DATA PROCESSING ===
  date_column = NULL,                   # Character: Optional date column to auto-select first/last periods | NULL = use all groups
  sort_axis_by = "end_value",           # Character: How to sort categories | Options: "original", "alphabetical", "range", "start_value", "end_value", "change"
  sort_direction = "desc",              # Character: Sort order | Options: "desc" (highest first), "asc" (lowest first)
  dumbbell_horizontal = TRUE,           # Logical: Orientation | TRUE = horizontal bars, FALSE = vertical bars
  
  # === DUMBBELL STYLING ===
  point_size = 4,                       # Numeric: Size of endpoint dots | Typical: 2-8, Default: 4
  point_shape = 16,                     # Numeric: Shape of endpoints | Options: 16=circle, 15=square, 17=triangle, 18=diamond
  line_size = 2,                        # Numeric: Thickness of connecting lines | Typical: 0.5-3, Default: 2
  line_type = "solid",                  # Character: Line style | Options: "solid", "dashed", "dotted", "dotdash"
  line_color = "#37474F",               # Character: Color of connecting lines | Hex code or color name (e.g., "gray50")
  point_alpha = 1,                      # Numeric: Point transparency | Range: 0 (invisible) to 1 (solid)
  
  # === REFERENCE LINES ===
  baseline_show = FALSE,                # Logical: Show vertical/horizontal line at zero | TRUE/FALSE
  baseline_color = "#37474F",           # Character: Baseline color | Hex code or color name
  baseline_size = 0.5,                  # Numeric: Baseline thickness | Typical: 0.3-1
  show_direction_arrow = FALSE,         # Logical: Add arrows showing increase/decrease | TRUE/FALSE
  change_threshold = 0,                 # Numeric: Minimum change to show arrow | E.g., 0.5 = only show if change > 0.5
  
  # === TEXT - TITLES ===
  title = NULL,                         # Character: Main plot title | NULL = no title
  text_scale = 1,                       # Numeric: Multiplies every text size (titles, axes, legend, facet titles, data labels) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                      # Numeric: Title font size in points | Typical: 14-18 (before 2026-10-02: 18)
  title_text_size = 16,                 # Numeric: Alternative for title_size (alias for backward compatibility)
  title_width = 80,                     # Numeric: Characters before title wraps to new line | Typical: 60-100
  subtitle = NULL,                      # Character: Subtitle below title | NULL = no subtitle
  subtitle_text_size = 13,              # Numeric: Subtitle font size | Typical: 11-14 (before 2026-10-02: 16)
  
  # === TEXT - AXES ===
  x_axis_title = NULL,                  # Character: Label for x-axis | NULL = no label
  y_axis_title = NULL,                  # Character: Label for y-axis | NULL = no label
  x_axis_title_angle = 0,               # Numeric: Rotation of x-axis title | 0=horizontal, 90=vertical
  x_axis_text_size = 11,                # Numeric: Font size of x-axis tick labels | Typical: 9-12 (before 2026-10-02: 14)
  y_axis_text_size = 11,                # Numeric: Font size of y-axis tick labels | Typical: 9-12 (before 2026-10-02: 14)
  x_axis_clip_off = FALSE,              # Logical: Show all labels, even past the panel edge (coord_cartesian(clip = "off"), as in func_graf_linjediagram) | TRUE = labels never cut off but may overlap axis text or a neighbouring facet panel; FALSE = cut off at the panel edge. Applies to the whole panel in both orientations; axis room comes from data_label_axis_padding

  # === TEXT - CAPTION ===
  caption = NULL,                       # Character: Footer text (source, notes) | NULL = no caption
  caption_size = 10,                    # Numeric: Caption font size | Typical: 8-11 (before 2026-10-02: 14)
  caption_text_size = 10,               # Numeric: Alternative for caption_size (alias for backward compatibility)
  
  # === COLORS - ENDPOINTS ===
  colors = c("#1a9fb3", "#ffc107"),     # Vector: Colors for start/end points | Length 2, e.g., c("blue", "red")
  color_darkest = NULL,                 # Character: For gradient - darkest color | Overrides 'colors' when both color_darkest and color_lightest set
  color_lightest = NULL,                # Character: For gradient - lightest color | Overrides 'colors' when both color_darkest and color_lightest set
  before_color = NULL,                  # Character: Specific color for first period | Overrides 'colors'[1]
  after_color = NULL,                   # Character: Specific color for second period | Overrides 'colors'[2]
  
  # === HIGHLIGHTING - SELECTION ===
  highlight_x_values = NULL,            # Vector: Categories to highlight | Must match x_value exactly, e.g., c("Stockholm", "Göteborg")
  
  # === HIGHLIGHTING - BACKGROUND ===
  highlight_background = TRUE,          # Logical: Add colored background to highlighted rows | TRUE/FALSE
  highlight_background_color = "#005b89", # Character: Background highlight color | Hex code or color name
  highlight_background_alpha = 0.15,    # Numeric: Background transparency | Range: 0 (invisible) to 1 (solid), Default: 0.15 (subtle)
  highlight_background_full_width = TRUE, # Logical: Highlight extends to plot edges | TRUE = full width, FALSE = data area only
  
  # === HIGHLIGHTING - SIDEBAR ===
  highlight_bar = FALSE,                # Logical: Add colored bar on left side of highlighted rows | TRUE/FALSE
  highlight_bar_color = NULL,           # Character: Sidebar color | NULL = uses highlight_background_color
  highlight_bar_width = 0.02,           # Numeric: Sidebar width as fraction of plot | Range: 0.01-0.1, Default: 0.02 (2%)
  highlight_bar_alpha = 0.8,            # Numeric: Sidebar transparency | Range: 0-1, Default: 0.8
  
  # === LEGEND ===
  legend_title = NULL,                  # Character: Title above legend | NULL = uses group column name
  legend_position = "right",            # Character: Legend placement | Options: "right", "left", "top", "bottom", "none"
  legend_text_size = 11,                # Numeric: Legend text font size | Typical: 10-12 (before 2026-10-02: 14)
  legend_title_size = 11,               # Numeric: Legend title font size | Typical: 10-12 (before 2026-10-02: 14)
  
  # === DATA LABELS - DISPLAY ===
  data_labels = TRUE,                   # Logical: Show numeric labels on points | TRUE/FALSE
  data_label_position = "latest",       # Character: Which points to label | Options: "end"/"latest"/"right" (last period), "start"/"first"/"left" (first period), "both"/"all" (all points) | Selects points only; which side the label goes on is set by data_label_side
  data_label_color = "black",           # Character: Label text color | Hex code or color name
  data_label_box = TRUE,                # Logical: Show background box behind labels | TRUE/FALSE
  data_label_text_size = 3.5,           # Numeric: Label font size in mm (ggplot text units; 3.5 mm ≈ 10 pt) | Typical: 3-4.5 (before 2026-10-02: 6)
  
  # === DATA LABELS - POSITIONING ===
  data_label_nudge_x = 0.1,             # Numeric: Horizontal label offset | Positive=right, Negative=left, 0=centered | Horizontal dumbbells: distance only (sign set by data_label_side, min 3% of data range); Vertical: category units, only with data_label_repel = TRUE (without repel vertical labels stay centred on their point)
  data_label_nudge_y = 0,               # Numeric: Vertical label offset | Positive=up, Negative=down, 0=centered | Horizontal dumbbells: in category units (1 = one row, e.g. 0.3 = just above the point); Vertical: distance only (sign set by data_label_side)
  data_label_side = "value",            # Character: Which side of its point each label goes on | Options: "value" (lower point's label left (horizontal) / below (vertical), higher point's right / above, so labels don't sit on the connecting line; with repel, ggrepel may still move a label back onto it), "period" (first period left/below, last period right/above)
  data_label_axis_padding = 1,          # Numeric: Scales the automatic value-axis room for labels when data_label_repel = FALSE | 1 = tuned for ~6x4 in output (before funcVGR 0.2.0: ~8x5 in), <1 for larger output, >1 for smaller, 0 = off (ggplot default axis)
  data_label_width = 20,                # Numeric: Max characters before label wraps | Typical: 15-30
  data_label_angle = 0,                 # Numeric: Label rotation | 0=horizontal, 90=vertical, 45=diagonal
  data_label_repel = TRUE,              # Logical: Use smart positioning to avoid overlaps | TRUE/FALSE (requires ggrepel package)
  
  # === DATA LABELS - FILTERING ===
  data_label_skip = NULL,               # Numeric: Show every nth label | NULL=all, 2=every other, 3=every third
  data_label_only_first_last = FALSE,   # Logical: Label only first and last categories | TRUE/FALSE
  data_label_x_values = NULL,           # Vector: Label only specific categories | e.g., c("Stockholm", "Malmö")
  data_label_y_values = NULL,           # Vector: Label only specific values | e.g., c(5.0, 7.5, 10.0)
  
  # === DATA LABELS - STYLING ===
  data_label_box_color = "white",       # Character: Label box background color | Only if data_label_box=TRUE
  data_label_box_alpha = 0.8,           # Numeric: Label box transparency | Range: 0 (invisible) to 1 (solid)
  
  # === DATA LABELS - GLOW EFFECT ===
  data_label_glow = FALSE,              # Logical: Add glow/halo effect to labels (alternative to box) | TRUE/FALSE (requires ggfx package)
  data_label_glow_color = "white",      # Character: Glow effect color | Only if data_label_glow=TRUE
  data_label_glow_sigma = 3,            # Numeric: Glow blur amount (higher = more spread) | Range: 1-10, Default: 3
  data_label_glow_expand = 1,           # Numeric: Glow expansion size (higher = larger glow) | Typical: 0.5-2, Default: 1
  
  # === FACETING (SMALL MULTIPLES) ===
  facet_var = NULL,                     # Character: Column name to split into separate plots | NULL = single plot
  facet_same_y_scale = TRUE,            # Logical: Use same y-axis across all facets | TRUE = comparable, FALSE = each optimized
  facet_title_size = 12,                # Numeric: Font size of facet panel titles | Typical: 10-14 (before 2026-10-02: 11)
  facet_ncol = NULL,                    # Numeric: Number of columns for facet layout | NULL = automatic
  
  # === GRID LINES ===
  show_major_grid = TRUE,               # Logical/Character: Major background grid lines | TRUE = both directions, FALSE = none,
                                        #   "y" = only lines from the y-axis (horizontal), "x" = only lines from the x-axis (vertical)
  show_minor_grid = FALSE,              # Logical/Character: Minor background grid lines | Same options as show_major_grid
  x_axis_line = TRUE,                   # Logical: Draw a line along the x-axis (TRUE/FALSE)
  y_axis_line = TRUE,                   # Logical: Draw a line along the y-axis (TRUE/FALSE)
  
  # === ADVANCED ===
  custom_theme = NULL,                  # ggplot2 theme object: Apply custom styling | NULL = use default minimal theme
  font = "Verdana",                     # Character: Font family for all text | Options: "Verdana", "Arial", "Times", "sans", "serif"
  debug = FALSE                         # Logical: Return diagnostic info instead of plot | TRUE = debug info, FALSE = plot
) {
  
  # === SETUP ===
  
  # Validate font using systemfonts
  available_fonts <- systemfonts::system_fonts()$family
  
  if (font %in% available_fonts) {
    # Font exists in system - use it directly
    # No need to register_variant for system fonts as it can cause issues
    font_to_use <- font
  } else if (font %in% c("sans", "serif", "mono")) {
    # These are base R fonts, always available
    font_to_use <- font
  } else {
    # Font not found - inform user and use fallback
    message(sprintf("Font '%s' not found in system fonts. Using 'sans' instead.", font))
    message("Available fonts include: Arial, Calibri, Times New Roman, etc.")
    message("Run: View(systemfonts::system_fonts()) to see all available fonts")
    font_to_use <- "sans"
  }
  
  font <- font_to_use
  registrera_typsnitt(font)  # så att Windows- och PDF-enheterna hittar typsnittet (se zzz.R)

  data_label_side <- match.arg(data_label_side, c("value", "period"))

  # Fall back to plain labels if ggrepel is missing
  if (data_label_repel) {
    if (!requireNamespace("ggrepel", quietly = TRUE)) {
      warning("ggrepel not available. Falling back to standard labels.")
      data_label_repel <- FALSE
    }
  }
  
  # Handle glow effects
  if (data_label_glow && data_labels) {
    if (!requireNamespace("ggfx", quietly = TRUE)) {
      warning("ggfx package not available. Install with: install.packages('ggfx'). Falling back to box method.")
      data_label_glow <- FALSE
      data_label_box <- TRUE
    }
  }
  
  # Resolve alternative parameter names (last-one-wins if both are supplied)
  title_size_final   <- if (!missing(title_text_size))   title_text_size   else title_size
  caption_size_final <- if (!missing(caption_text_size)) caption_text_size else caption_size

  # text_scale: one factor for every text size (after the aliases). data_label_text_size also drives
  # the automatic label room (label_pt below), so that room scales with the text as well
  title_size_final     <- title_size_final     * text_scale
  caption_size_final   <- caption_size_final   * text_scale
  subtitle_text_size   <- subtitle_text_size   * text_scale
  x_axis_text_size     <- x_axis_text_size     * text_scale
  y_axis_text_size     <- y_axis_text_size     * text_scale
  legend_text_size     <- legend_text_size     * text_scale
  legend_title_size    <- legend_title_size    * text_scale
  facet_title_size     <- facet_title_size     * text_scale
  data_label_text_size <- data_label_text_size * text_scale

  # Validate inputs
  if (is.null(df) || !is.data.frame(df) || nrow(df) == 0) stop("'df' must be a non-empty data.frame")
  required_cols <- c(x_value, y_value, group)
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) stop(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
  if (length(table(df[[group]])) < 2) stop("At least 2 groups required")
  if (!is.numeric(df[[y_value]])) stop(paste("Column", y_value, "must be numeric"))
  
  # Debug output
  if (debug) {
    cat("\n=== DEBUG ===\n")
    cat(sprintf("Data: %d x %d | X: %s | Y: %s | Group: %s\n", nrow(df), ncol(df), x_value, y_value, group))
    if (!is.null(highlight_x_values)) cat(sprintf("Highlights: %s\n", paste(highlight_x_values, collapse = ", ")))
  }
  
  # === DATA PREPARATION ===
  prepare_data <- function(df, x_value, y_value, group, date_column = NULL, facet_var = NULL) {
    # Filter by date if specified
    if (!is.null(date_column) && date_column %in% names(df)) {
      if (!inherits(df[[date_column]], c("Date", "POSIXct", "POSIXt"))) df[[date_column]] <- as.Date(df[[date_column]])
      min_date <- min(df[[date_column]], na.rm = TRUE)
      max_date <- max(df[[date_column]], na.rm = TRUE)
      df_filtered <- df %>% filter(!!sym(date_column) %in% c(min_date, max_date))
    } else df_filtered <- df
    
    # Select columns
    select_cols <- c(x_value, y_value, group)
    if (!is.null(facet_var) && facet_var %in% names(df_filtered)) select_cols <- c(select_cols, facet_var)
    data_selected <- df_filtered %>% select(all_of(select_cols))
    
    # Reshape to wide format
    data_wide <- data_selected %>%
      group_by(across(all_of(c(x_value, if(!is.null(facet_var)) facet_var else NULL)))) %>%
      pivot_wider(names_from = !!sym(group), values_from = !!sym(y_value), values_fn = mean) %>%
      ungroup()
    
    # Get group columns
    group_cols <- setdiff(names(data_wide), c(x_value, facet_var))
    # Put the periods in time order. pivot_wider() creates the columns in data order, so data
    # sorted newest-first made the newest period the "start" (reversed change, wrong labels).
    # Factors keep their level order, numbers/dates and text starting with a digit ("2014",
    # "2024K1") are sorted; other text (e.g. "Före"/"Efter") keeps the data order.
    g <- df_filtered[[group]]
    period_order <- if (is.factor(g)) levels(droplevels(g))
      else if (is.numeric(g) || inherits(g, c("Date", "POSIXt"))) as.character(sort(unique(g)))
      else { u <- unique(as.character(g[!is.na(g)])); if (all(grepl("^[0-9]", u))) sort(u) else u }
    group_cols <- c(intersect(period_order, group_cols), setdiff(group_cols, period_order))
    if (length(group_cols) < 2) stop("Need at least 2 periods")
    if (length(group_cols) > 2) {
      # First and last period (previously the first two, e.g. 2014 vs 2015 for a 2014-2024 series)
      group_cols <- group_cols[c(1, length(group_cols))]
      warning(paste("More than two periods - comparing the first and last:",
                    paste(group_cols, collapse = " and ")))
    }
    
    # Calculate metrics
    data_wide <- data_wide %>%
      mutate(change = !!sym(group_cols[2]) - !!sym(group_cols[1]),
             range = abs(!!sym(group_cols[2]) - !!sym(group_cols[1])),
             start_value = !!sym(group_cols[1]), end_value = !!sym(group_cols[2]))
    
    # Reshape to long format for plotting
    data_long <- data_wide %>%
      select(all_of(c(x_value, if(!is.null(facet_var)) facet_var else NULL, "start_value", "end_value", "change", "range"))) %>%
      pivot_longer(cols = c("start_value", "end_value"), names_to = "period_type", values_to = "value") %>%
      mutate(!!sym(group) := case_when(period_type == "start_value" ~ group_cols[1],
                                       period_type == "end_value" ~ group_cols[2],
                                       TRUE ~ period_type)) %>%
      select(-period_type)
    
    list(data_long = data_long, data_wide = data_wide, group_values = group_cols)
  }
  
  data_result <- prepare_data(df, x_value, y_value, group, date_column, facet_var)
  data_long <- data_result$data_long
  data_wide <- data_result$data_wide
  group_values <- data_result$group_values
  
  # Mark highlighted categories
  if (!is.null(highlight_x_values)) {
    highlight_clean <- trimws(highlight_x_values)
    data_long$is_highlighted <- trimws(as.character(data_long[[x_value]])) %in% highlight_clean
    data_wide$is_highlighted <- trimws(as.character(data_wide[[x_value]])) %in% highlight_clean
  } else {
    data_long$is_highlighted <- FALSE
    data_wide$is_highlighted <- FALSE
  }
  
  # === SORTING ===
  if (sort_axis_by != "original") {
    use_desc <- tolower(sort_direction) == "desc"
    sort_data <- data_wide %>%
      arrange(if (sort_axis_by == "alphabetical") {
        if (use_desc) desc(!!sym(x_value)) else !!sym(x_value)
      } else if (sort_axis_by == "range") {
        if (use_desc) desc(range) else range
      } else if (sort_axis_by == "start_value") {
        if (use_desc) desc(start_value) else start_value
      } else if (sort_axis_by == "end_value") {
        if (use_desc) desc(end_value) else end_value
      } else if (sort_axis_by == "change") {
        if (use_desc) desc(change) else change
      } else !!sym(x_value))
    
    new_order <- unique(as.character(sort_data[[x_value]]))
    # A discrete y axis draws the first level at the BOTTOM, so for horizontal dumbbells the order is
    # reversed - otherwise "desc" (highest first) put the highest category at the bottom of the plot
    if (dumbbell_horizontal) new_order <- rev(new_order)
    data_long[[x_value]] <- factor(as.character(data_long[[x_value]]), levels = new_order)
    data_wide[[x_value]] <- factor(as.character(data_wide[[x_value]]), levels = new_order)
  } else {
    unique_levels <- unique(as.character(data_long[[x_value]]))
    # Keep the data order reading top-to-bottom in horizontal dumbbells (see above)
    if (dumbbell_horizontal) unique_levels <- rev(unique_levels)
    data_long[[x_value]] <- factor(as.character(data_long[[x_value]]), levels = unique_levels)
    data_wide[[x_value]] <- factor(as.character(data_wide[[x_value]]), levels = unique_levels)
  }
  
  # === COLOR ASSIGNMENT ===
  assign_colors <- function() {
    if (!is.null(before_color) && !is.null(after_color)) {
      colors_final <- c(before_color, after_color)
      names(colors_final) <- group_values
      return(colors_final)
    }
    if (!is.null(color_darkest) && !is.null(color_lightest)) {
      colors_final <- c(color_darkest, color_lightest)
      names(colors_final) <- group_values
      return(colors_final)
    }
    if (length(colors) >= 2) {
      colors_final <- colors[1:2]
      names(colors_final) <- group_values
      return(colors_final)
    }
    default_colors <- c("#F69541", "#699DC6")
    names(default_colors) <- group_values
    return(default_colors)
  }
  plot_colors <- assign_colors()
  bar_color <- highlight_bar_color %||% highlight_background_color
  
  # === CREATE BASE PLOT ===
  p <- if (dumbbell_horizontal) {
    ggplot(data_long, aes(x = value, y = !!sym(x_value)))
  } else ggplot(data_long, aes(x = !!sym(x_value), y = value))
  
  # === ADD BACKGROUND HIGHLIGHTS ===
  if (!is.null(highlight_x_values) && (highlight_background || highlight_bar)) {
    axis_levels <- levels(data_long[[x_value]])
    highlight_clean <- trimws(as.character(highlight_x_values))
    highlight_positions <- which(axis_levels %in% highlight_clean)
    
    if (length(highlight_positions) > 0) {
      for (pos in highlight_positions) {
        # Background highlight
        if (highlight_background) {
          if (dumbbell_horizontal) {
            if (highlight_background_full_width) {
              p <- p + annotate("rect", xmin = -Inf, xmax = Inf, ymin = pos - 0.4, ymax = pos + 0.4,
                                fill = highlight_background_color, alpha = highlight_background_alpha)
            } else {
              x_range <- range(data_long$value, na.rm = TRUE)
              x_expand <- diff(x_range) * 0.05
              p <- p + annotate("rect", xmin = x_range[1] - x_expand, xmax = x_range[2] + x_expand,
                                ymin = pos - 0.4, ymax = pos + 0.4,
                                fill = highlight_background_color, alpha = highlight_background_alpha)
            }
          } else {
            if (highlight_background_full_width) {
              p <- p + annotate("rect", xmin = pos - 0.4, xmax = pos + 0.4, ymin = -Inf, ymax = Inf,
                                fill = highlight_background_color, alpha = highlight_background_alpha)
            } else {
              y_range <- range(data_long$value, na.rm = TRUE)
              y_expand <- diff(y_range) * 0.05
              p <- p + annotate("rect", xmin = pos - 0.4, xmax = pos + 0.4,
                                ymin = y_range[1] - y_expand, ymax = y_range[2] + y_expand,
                                fill = highlight_background_color, alpha = highlight_background_alpha)
            }
          }
        }
        
        # Sidebar bar
        if (highlight_bar) {
          if (dumbbell_horizontal) {
            p <- p + annotate("rect", xmin = -Inf,
                              xmax = min(data_long$value, na.rm = TRUE) - diff(range(data_long$value, na.rm = TRUE)) * highlight_bar_width,
                              ymin = pos - 0.4, ymax = pos + 0.4, fill = bar_color, alpha = highlight_bar_alpha)
          } else {
            p <- p + annotate("rect", xmin = pos - 0.4, xmax = pos + 0.4, ymin = -Inf,
                              ymax = min(data_long$value, na.rm = TRUE) - diff(range(data_long$value, na.rm = TRUE)) * highlight_bar_width,
                              fill = bar_color, alpha = highlight_bar_alpha)
          }
        }
      }
    }
  }
  
  # === ADD BASELINE ===
  if (baseline_show) {
    if (dumbbell_horizontal) {
      p <- p + geom_vline(xintercept = 0, color = baseline_color, linewidth = baseline_size, alpha = 0.7)
    } else p <- p + geom_hline(yintercept = 0, color = baseline_color, linewidth = baseline_size, alpha = 0.7)
  }
  
  # === ADD DUMBBELLS ===
  p <- p + 
    geom_line(aes(group = !!sym(x_value)), color = line_color, linewidth = line_size, linetype = line_type, alpha = 0.8) +
    geom_point(aes(color = !!sym(group)), size = point_size, shape = point_shape, alpha = point_alpha) +
    scale_color_manual(values = plot_colors)
  
  # === ADD DIRECTION ARROWS ===
  # Arrow length; also used to move end labels clear of the arrow (0 when there are no values at all)
  arrow_offset <- if (any(!is.na(data_long$value))) max(abs(data_long$value), na.rm = TRUE) * 0.02 else 0
  if (show_direction_arrow) {
    arrow_data <- data_wide %>% filter(abs(change) > change_threshold)
    if (nrow(arrow_data) > 0) {
      if (dumbbell_horizontal) {
        p <- p + geom_segment(data = arrow_data,
                              aes(x = end_value, xend = end_value + sign(change) * arrow_offset,
                                  y = !!sym(x_value), yend = !!sym(x_value)),
                              arrow = arrow(length = unit(0.15, "cm"), type = "closed"),
                              color = ifelse(arrow_data$change > 0, "darkgreen", "darkred"), linewidth = 0.8)
      } else {
        p <- p + geom_segment(data = arrow_data,
                              aes(x = !!sym(x_value), xend = !!sym(x_value),
                                  y = end_value, yend = end_value + sign(change) * arrow_offset),
                              arrow = arrow(length = unit(0.15, "cm"), type = "closed"),
                              color = ifelse(arrow_data$change > 0, "darkgreen", "darkred"), linewidth = 0.8)
      }
    }
  }
  
  # === ADD DATA LABELS ===
  value_axis_expand <- waiver()   # ggplot default expansion unless non-repel labels need room (set below)
  value_axis_breaks <- scales::pretty_breaks(n = 5)   # replaced below when the axis is padded for labels
  category_axis_expand <- waiver()   # ggplot default (0.6 category) unless vertical non-repel labels need more
  if (data_labels) {
    # Select which points to label
    label_approach <- tolower(data_label_position)
    label_data <- if (label_approach %in% c("end", "latest", "right")) {
      data_long %>% filter(!!sym(group) == group_values[2])
    } else if (label_approach %in% c("start", "first", "left")) {
      data_long %>% filter(!!sym(group) == group_values[1])
    } else if (label_approach %in% c("both", "all")) {
      data_long
    } else data_long %>% filter(!!sym(group) == group_values[2])
    
    # Apply filters
    if (!is.null(data_label_skip) && data_label_skip > 0) label_data <- label_data[seq(1, nrow(label_data), by = data_label_skip), ]
    if (!is.null(data_label_x_values)) label_data <- label_data %>% filter(!!sym(x_value) %in% data_label_x_values)
    if (!is.null(data_label_y_values)) label_data <- label_data %>% filter(value %in% data_label_y_values)
    if (data_label_only_first_last) {
      x_levels <- levels(label_data[[x_value]])
      first_last <- c(x_levels[1], x_levels[length(x_levels)])
      label_data <- label_data %>% filter(!!sym(x_value) %in% first_last)
    }
    
    if (nrow(label_data) > 0) {
      # Create label text
      label_data$label_text <- format(round(label_data$value, 1), nsmall = 1, big.mark = " ", decimal.mark = ",",
                                      trim = TRUE,   # trim: format() otherwise pads every label to a common width
                                      scientific = FALSE)   # only round large values (200 000, 1 000 000) gave "2e+05"
      
      # Calculate intelligent positioning
      label_data_with_pairs <- label_data %>%
        left_join(data_wide %>% select(all_of(c(x_value, "start_value", "end_value", "change", if(!is.null(facet_var)) facet_var else NULL))),
                  by = c(x_value, if(!is.null(facet_var)) facet_var else NULL)) %>%
        mutate(is_start_point = !!sym(group) == group_values[1],
               is_end_point = !!sym(group) == group_values[2],
               # Which side of the dumbbell the label goes on (low = left/below, high = right/above).
               # data_label_side = "value": by value, so labels never sit on the connecting line; ties/NA fall back to by period
               use_period_side = data_label_side == "period" | is.na(start_value) | is.na(end_value) | start_value == end_value,
               label_on_low_side = case_when(use_period_side ~ is_start_point,
                                             is_start_point ~ start_value < end_value,
                                             is_end_point ~ end_value < start_value,
                                             TRUE ~ FALSE),
               label_on_high_side = case_when(use_period_side ~ is_end_point,
                                              is_start_point ~ start_value > end_value,
                                              is_end_point ~ end_value > start_value,
                                              TRUE ~ FALSE),
               intelligent_nudge_x = case_when(!dumbbell_horizontal ~ data_label_nudge_x,
                                               label_on_low_side ~ -abs(data_label_nudge_x),
                                               label_on_high_side ~ abs(data_label_nudge_x),
                                               TRUE ~ data_label_nudge_x),
               intelligent_nudge_y = case_when(dumbbell_horizontal ~ data_label_nudge_y,
                                               label_on_low_side ~ -abs(data_label_nudge_y),
                                               label_on_high_side ~ abs(data_label_nudge_y),
                                               TRUE ~ data_label_nudge_y),
               intelligent_hjust = case_when(!dumbbell_horizontal ~ 0.5, label_on_low_side ~ 1, label_on_high_side ~ 0, TRUE ~ 0.5),
               intelligent_vjust = case_when(dumbbell_horizontal ~ 0.5, label_on_low_side ~ 1, label_on_high_side ~ 0, TRUE ~ 0.5))
      
      # Dynamic nudge distance
      data_range <- max(label_data$value, na.rm = TRUE) - min(label_data$value, na.rm = TRUE)
      # Only the value-axis nudge sets the distance: the other one is in category units (horizontal:
      # data_label_nudge_y, vertical: data_label_nudge_x — default 0.1 would be a huge gap on a small value range)
      dynamic_nudge_distance <- if (dumbbell_horizontal) {
        max(data_range * 0.03, abs(data_label_nudge_x))
      } else max(data_range * 0.03, abs(data_label_nudge_y))
      
      # Sign from the label side, not from the nudge parameter: the default data_label_nudge_y = 0 would
      # otherwise give vertical labels no offset at all and put them on top of their points
      label_data_with_pairs <- label_data_with_pairs %>%
        mutate(intelligent_nudge_x = case_when(!dumbbell_horizontal ~ intelligent_nudge_x,
                                               label_on_low_side ~ -dynamic_nudge_distance,
                                               label_on_high_side ~ dynamic_nudge_distance,
                                               TRUE ~ intelligent_nudge_x),
               intelligent_nudge_y = case_when(dumbbell_horizontal ~ intelligent_nudge_y,
                                               label_on_low_side ~ -dynamic_nudge_distance,
                                               label_on_high_side ~ dynamic_nudge_distance,
                                               TRUE ~ intelligent_nudge_y))

      # Direction arrows start at the end point and point in the direction of change. When the end point's
      # label sits on that same side, move it 1.5 arrow lengths further out (arrow + small gap) so it doesn't cover the arrow
      if (show_direction_arrow) {
        label_data_with_pairs <- label_data_with_pairs %>%
          mutate(arrow_clearance = case_when(
                   is_end_point & abs(end_value - start_value) > change_threshold & end_value > start_value & label_on_high_side ~ 1.5 * arrow_offset,
                   is_end_point & abs(end_value - start_value) > change_threshold & end_value < start_value & label_on_low_side ~ -1.5 * arrow_offset,
                   TRUE ~ 0),
                 intelligent_nudge_x = if (dumbbell_horizontal) intelligent_nudge_x + arrow_clearance else intelligent_nudge_x,
                 intelligent_nudge_y = if (dumbbell_horizontal) intelligent_nudge_y else intelligent_nudge_y + arrow_clearance)
      }

      # Axis padding for labels without repel: the scale is trained on each label's anchor point, but not
      # on the text extent, so labels outside the outermost points get clipped at the panel edge. Widen the
      # value axis on each side that has labels by an estimate of the label size as a share of the panel.
      # Label sizes in pt (measured with Verdana: ~0.57 em per character, digits, spaces and commas alike;
      # geom_label padding ~0.62 em for both sides; one line incl. spacing ~1.45 em; glow halo ~10 pt, fixed).
      # The panel size is only known when drawn — assumed a 6 x 4 in chart (since funcVGR 0.2.0; was ~8 x 5 in)
      # like func_graf_linjediagram/barchart: width 432 pt minus the category axis text and a left/right legend,
      # height 288 pt minus title and axis text, split over the facet columns (horizontal) or rows (vertical).
      # data_label_axis_padding scales the result. Repel keeps labels inside by itself.
      if (!data_label_repel && data_label_axis_padding > 0) {
        n_panels <- if (!is.null(facet_var) && facet_var %in% names(data_long)) length(unique(data_long[[facet_var]])) else 1
        # c(rows, cols), same rule facet_wrap uses; facet_wrap never lays out more columns than panels
        panel_dims <- ggplot2::wrap_dims(n_panels, ncol = if (!is.null(facet_ncol)) min(facet_ncol, n_panels) else NULL)
        legend_pt <- if (legend_position %in% c("left", "right")) {
          max(nchar(c(as.character(group_values), if (is.null(legend_title)) group else legend_title)), na.rm = TRUE) *
            legend_text_size * 0.65 + 30
        } else 0
        # With free facet scales (facet_same_y_scale = FALSE) every panel draws its own axis text, so it is taken
        # off once per column rather than once for the chart
        free_axis <- !is.null(facet_var) && facet_var %in% names(data_long) && !facet_same_y_scale
        panel_pt <- if (dumbbell_horizontal) {
          category_axis_pt <- max(nchar(as.character(data_long[[x_value]])), na.rm = TRUE) * y_axis_text_size * 0.65 + 10
          if (free_axis) max((432 - legend_pt) / panel_dims[2] - category_axis_pt, 40)
          else max(432 - category_axis_pt - legend_pt, 100) / panel_dims[2]
        } else (288 - 70) / panel_dims[1]
        label_pt <- data_label_text_size * ggplot2::.pt
        box_pt  <- if (data_label_box && !data_label_glow) 0.62 * label_pt else 0   # box padding, scales with text size
        glow_pt <- if (data_label_glow) 10 else 0                                   # glow halo, fixed size
        drawn <- !is.na(label_data_with_pairs$value)   # NA rows are dropped by the geom, so they need no room
        low_labels <- label_data_with_pairs$label_text[drawn & label_data_with_pairs$label_on_low_side]
        high_labels <- label_data_with_pairs$label_text[drawn & label_data_with_pairs$label_on_high_side]
        # Share of the panel each side's widest label needs: width from character count (horizontal),
        # one text line high (vertical)
        side_share <- function(labels) {
          if (length(labels) == 0) return(0)
          extent_pt <- if (dumbbell_horizontal) max(nchar(labels)) * 0.57 * label_pt else 1.45 * label_pt
          (extent_pt + box_pt + glow_pt) * data_label_axis_padding / panel_pt
        }
        low_share <- side_share(low_labels)
        high_share <- side_share(high_labels)
        # Vertical: labels are centred on their point, so the widest one also needs half its width beyond the
        # first/last category (the category axis is horizontal here). Category width from the assumed chart width
        # (432 pt minus the value axis text and a left/right legend); iterated because the room narrows it
        if (!dumbbell_horizontal && any(drawn)) {
          half_label_pt <- (max(nchar(label_data_with_pairs$label_text[drawn])) * 0.57 * label_pt + box_pt + glow_pt) / 2 + 2
          n_cat <- length(unique(data_long[[x_value]]))
          width_pt <- if (free_axis) max((432 - legend_pt) / panel_dims[2] - 45, 40) else max(432 - 45 - legend_pt, 100) / panel_dims[2]
          category_add <- 0.6
          for (i in 1:10) {
            category_add <- max(0.6, half_label_pt * data_label_axis_padding / (width_pt / (n_cat - 1 + 2 * category_add)))
            category_add <- min(category_add, max(0.6, (n_cat - 1) / 2))   # categories keep at least half the panel
          }
          if (category_add > 0.6) category_axis_expand <- expansion(add = category_add)
        }
        # expansion mult is a share of the data range, but padding also widens the panel itself:
        # mult = share / (1 - low_share - high_share). Capped so the data keeps at least 25% of the panel.
        share_cap <- min(1, 0.75 / max(low_share + high_share, 1e-9))
        low_share <- low_share * share_cap
        high_share <- high_share * share_cap
        share_total <- low_share + high_share
        value_axis_expand <- expansion(mult = c(if (low_share > 0) low_share / (1 - share_total) else 0.05,   # 0.05 = ggplot default
                                                if (high_share > 0) high_share / (1 - share_total) else 0.05))
        # Breaks from the content range only (data, plus 0 when the baseline is drawn), so the padding doesn't
        # stretch the ticks far into the empty margin (pretty() may still add one step past the data).
        # Then thin them (every 2nd, 4th, ...) until there are at most 7 and the tick labels fit side by side:
        # tick label width uses the same ~0.57 em per character at the axis text size, against the same assumed
        # panel; vertical needs one line of height per tick instead.
        value_range <- range(c(data_long$value, if (baseline_show) 0), na.rm = TRUE)
        axis_text_pt <- if (dumbbell_horizontal) x_axis_text_size else y_axis_text_size
        tick_format <- scales::label_number(big.mark = " ", decimal.mark = ",")
        # (limits clamped to the content range, so free facet scales still get per-panel breaks;
        # zero-range content, e.g. all values equal, uses the full limits instead)
        value_axis_breaks <- function(limits) {
          break_range <- c(max(limits[1], value_range[1]), min(limits[2], value_range[2]))
          if (!(diff(break_range) > 0)) break_range <- limits
          breaks <- scales::breaks_pretty(n = 5)(break_range)
          tick_need <- if (dumbbell_horizontal) {
            (max(nchar(tick_format(breaks))) + 0.75) * 0.57 * axis_text_pt / panel_pt   # label + gap
          } else 1.3 * 1.45 * axis_text_pt / panel_pt                                    # line + gap
          panel_span <- diff(limits)   # ggplot passes the expanded limits, i.e. data units across the whole panel
          # pretty() treats n = 5 loosely (can return 9 breaks on a narrow range), so also cap at 7
          while (length(breaks) > 2 && (length(breaks) > 7 || min(diff(breaks)) / panel_span < tick_need)) {
            # keep multiples of the doubled step (2, 4, 6 rather than 3, 5, 7); fall back to every other break
            new_step <- 2 * min(diff(breaks))
            on_step <- abs(breaks / new_step - round(breaks / new_step)) < 1e-8
            breaks <- if (sum(on_step) >= 2) breaks[on_step] else breaks[seq(1, length(breaks), by = 2)]
          }
          breaks
        }
      }

      # Add labels with or without repel
      if (data_label_repel) {
        force_val <- if (label_approach %in% c("both", "all")) 8 else 5
        max_overlaps_val <- if (label_approach %in% c("both", "all")) 30 else 20
        box_padding_val <- if (label_approach %in% c("both", "all")) 0.5 else 0.3
        point_padding_val <- if (label_approach %in% c("both", "all")) 0.4 else 0.2

        # Direction arrows are not something ggrepel knows to avoid, and its pull drags labels back over
        # them. Rows with an empty label are not drawn but still repel labels, so add three such points
        # along each arrow (start, middle, tip)
        repel_data <- label_data_with_pairs
        if (show_direction_arrow) {
          arrow_points <- data_wide %>%
            filter(abs(change) > change_threshold) %>%
            select(all_of(c(x_value, if (!is.null(facet_var)) facet_var else NULL, "end_value", "change"))) %>%
            tidyr::crossing(arrow_step = c(0, 0.5, 1)) %>%
            mutate(value = end_value + sign(change) * arrow_offset * arrow_step,
                   label_text = "", intelligent_nudge_x = 0, intelligent_nudge_y = 0) %>%
            select(-end_value, -change, -arrow_step)
          repel_data <- bind_rows(label_data_with_pairs, arrow_points)
        }

        if (data_label_glow && requireNamespace("ggfx", quietly = TRUE)) {
          # Glow effect with repel
          p <- p + ggfx::with_outer_glow(
            geom_text_repel(data = repel_data, aes(label = label_text),
                            color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                            box.padding = unit(box_padding_val, "lines"),
                            point.padding = unit(point_padding_val, "lines"),
                            segment.color = "grey60", segment.size = 0.4, segment.alpha = 0.7,
                            max.overlaps = max_overlaps_val, force = force_val, force_pull = 2,
                            nudge_x = repel_data$intelligent_nudge_x,
                            nudge_y = repel_data$intelligent_nudge_y,
                            min.segment.length = 0.05, direction = "both", seed = 42),
            colour = data_label_glow_color,
            sigma = data_label_glow_sigma,
            expand = data_label_glow_expand
          )
        } else if (data_label_box) {
          p <- p + geom_label_repel(data = repel_data, aes(label = label_text),
                                    color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                                    fill = alpha(data_label_box_color, data_label_box_alpha), box.padding = unit(box_padding_val, "lines"),
                                    point.padding = unit(point_padding_val, "lines"), segment.color = "grey60",
                                    segment.size = 0.4, segment.alpha = 0.7, max.overlaps = max_overlaps_val,
                                    force = force_val, force_pull = 2, nudge_x = repel_data$intelligent_nudge_x,
                                    nudge_y = repel_data$intelligent_nudge_y, min.segment.length = 0.05,
                                    direction = "both", seed = 42)
        } else {
          p <- p + geom_text_repel(data = repel_data, aes(label = label_text),
                                   color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                                   box.padding = unit(box_padding_val, "lines"), point.padding = unit(point_padding_val, "lines"),
                                   segment.color = "grey60", segment.size = 0.4, segment.alpha = 0.7,
                                   max.overlaps = max_overlaps_val, force = force_val, force_pull = 2,
                                   nudge_x = repel_data$intelligent_nudge_x,
                                   nudge_y = repel_data$intelligent_nudge_y, min.segment.length = 0.05,
                                   direction = "both", seed = 42)
        }
      } else {
        # Standard labels without repel
        if (data_label_glow && requireNamespace("ggfx", quietly = TRUE)) {
          # Glow effect without repel
          # Horizontal: y is discrete, so the vertical nudge goes through position_nudge (in category units)
          if (dumbbell_horizontal) {
            p <- p + ggfx::with_outer_glow(
              geom_text(data = label_data_with_pairs,
                        aes(x = value + intelligent_nudge_x, y = !!sym(x_value), label = label_text),
                        color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                        hjust = label_data_with_pairs$intelligent_hjust,
                        vjust = label_data_with_pairs$intelligent_vjust,
                        position = position_nudge(y = label_data_with_pairs$intelligent_nudge_y)),
              colour = data_label_glow_color,
              sigma = data_label_glow_sigma,
              expand = data_label_glow_expand
            )
          } else {
            p <- p + ggfx::with_outer_glow(
              geom_text(data = label_data_with_pairs,
                        aes(x = !!sym(x_value), y = value + intelligent_nudge_y, label = label_text),
                        color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                        hjust = label_data_with_pairs$intelligent_hjust,
                        vjust = label_data_with_pairs$intelligent_vjust),
              colour = data_label_glow_color,
              sigma = data_label_glow_sigma,
              expand = data_label_glow_expand
            )
          }
        } else if (data_label_box) {
          if (dumbbell_horizontal) {
            p <- p + geom_label(data = label_data_with_pairs,
                                aes(x = value + intelligent_nudge_x, y = !!sym(x_value), label = label_text),
                                color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                                hjust = label_data_with_pairs$intelligent_hjust,
                                vjust = label_data_with_pairs$intelligent_vjust, fill = alpha(data_label_box_color, data_label_box_alpha),
                                position = position_nudge(y = label_data_with_pairs$intelligent_nudge_y))
          } else {
            p <- p + geom_label(data = label_data_with_pairs,
                                aes(x = !!sym(x_value), y = value + intelligent_nudge_y, label = label_text),
                                color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                                hjust = label_data_with_pairs$intelligent_hjust,
                                vjust = label_data_with_pairs$intelligent_vjust, fill = alpha(data_label_box_color, data_label_box_alpha))
          }
        } else {
          if (dumbbell_horizontal) {
            p <- p + geom_text(data = label_data_with_pairs,
                               aes(x = value + intelligent_nudge_x, y = !!sym(x_value), label = label_text),
                               color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                               hjust = label_data_with_pairs$intelligent_hjust,
                               vjust = label_data_with_pairs$intelligent_vjust,
                               position = position_nudge(y = label_data_with_pairs$intelligent_nudge_y))
          } else {
            p <- p + geom_text(data = label_data_with_pairs,
                               aes(x = !!sym(x_value), y = value + intelligent_nudge_y, label = label_text),
                               color = data_label_color, size = data_label_text_size, angle = data_label_angle, family = font,
                               hjust = label_data_with_pairs$intelligent_hjust,
                               vjust = label_data_with_pairs$intelligent_vjust)
          }
        }
      }
    }
  }
  
  # === FACETING ===
  if (!is.null(facet_var) && facet_var %in% names(data_long)) {
    scales_option <- if (facet_same_y_scale) "fixed" else "free_y"
    
    if (!is.null(facet_ncol) && facet_ncol == 1 && !facet_same_y_scale) {
      p <- p + facet_grid(rows = vars(!!sym(facet_var)), scales = scales_option,
                          space = if(scales_option == "free_y") "free_y" else "fixed")
    } else if (!is.null(facet_ncol)) {
      p <- p + facet_wrap(vars(!!sym(facet_var)), ncol = facet_ncol, scales = scales_option)
    } else p <- p + facet_wrap(vars(!!sym(facet_var)), scales = scales_option)
  }
  
  # === THEME ===
  p <- p + theme_minimal()

  p <- p + theme(text = element_text(family = font),
                 axis.text.x = element_text(size = x_axis_text_size, family = font),
                 axis.text.y = element_text(size = y_axis_text_size, family = font),
                 axis.title.x = element_text(angle = x_axis_title_angle, family = font),
                 # Axis titles have no own size parameter: relative to the inherited 11 pt, scaled by text_scale
                 axis.title = element_text(size = rel(text_scale), inherit.blank = TRUE),
                 plot.background = element_rect(fill = "white", color = NA),
                 panel.background = element_rect(fill = "white", color = NA),
                 panel.border = if (!is.null(facet_var) && facet_var %in% names(data_long)) {
                   element_rect(color = "grey80", fill = NA, linewidth = 0.5)
                 } else element_blank(),
                 strip.text = element_text(size = facet_title_size, family = font),
                 axis.text.x.top = element_blank(), axis.ticks.x.top = element_blank())

  # Facet styling after theme_minimal() (it used to be added before and was overwritten)
  if (!is.null(facet_var) && facet_var %in% names(data_long)) {
    p <- p + theme(strip.background = element_rect(fill = "white", color = NA, linewidth = 0),
                   panel.spacing = unit(0.5, "lines"))
    if (!facet_same_y_scale) p <- p + theme(axis.ticks.y = element_blank())
  }

  # Grid: same TRUE/FALSE/"x"/"y" rule as func_graf_linjediagram/barchart — TRUE/FALSE set the parent element
  # as before, so a later custom_theme / + theme(panel.grid...) still reaches both directions; "x"/"y" blank
  # the parent and draw only that child. Axis lines keep the dumbbell's own look (grey30, parent axis.line
  # when both are on, as before) rather than linje/barchart's black per-axis lines
  grid_ok <- function(v) isTRUE(v) || isFALSE(v) || identical(v, "x") || identical(v, "y")
  if (!grid_ok(show_major_grid)) stop("show_major_grid must be TRUE, FALSE, \"x\" or \"y\"")
  if (!grid_ok(show_minor_grid)) stop("show_minor_grid must be TRUE, FALSE, \"x\" or \"y\"")
  grid_theme <- list()
  for (g in list(list(val = show_major_grid, el = "panel.grid.major", col = "grey90", lw = 0.5),
                 list(val = show_minor_grid, el = "panel.grid.minor", col = "grey95", lw = 0.3))) {
    if (is.logical(g$val)) {
      grid_theme[[g$el]] <- if (g$val) element_line(color = g$col, linewidth = g$lw) else element_blank()
    } else {
      grid_theme[[g$el]] <- element_blank()
      grid_theme[[paste0(g$el, ".", g$val)]] <- element_line(color = g$col, linewidth = g$lw)
    }
  }
  axis_el <- element_line(color = "grey30", linewidth = 0.5)
  if (x_axis_line && y_axis_line) grid_theme$axis.line <- axis_el
  else {
    if (x_axis_line) grid_theme$axis.line.x <- axis_el
    if (y_axis_line) grid_theme$axis.line.y <- axis_el
  }
  p <- p + do.call(theme, grid_theme)
  
  # === LEGEND ===
  legend_title_final <- if (is.null(legend_title)) group else legend_title
  p <- p + guides(color = guide_legend(title = legend_title_final)) +
    theme(legend.position = legend_position,
          legend.title = element_text(family = font, size = legend_title_size),
          legend.text = element_text(family = font, size = legend_text_size))
  
  # === LABELS ===
  p <- p + labs(x = x_axis_title, y = y_axis_title,
                title = if (!is.null(title)) {
                  if (nchar(title) > title_width) str_wrap(title, width = title_width) else title
                } else NULL,
                subtitle = subtitle, caption = caption)
  
  title_theme <- theme()
  if (!is.null(title)) title_theme <- title_theme + theme(plot.title = element_text(size = title_size_final, family = font))
  if (!is.null(subtitle)) title_theme <- title_theme + theme(plot.subtitle = element_text(size = subtitle_text_size, family = font))
  if (!is.null(caption)) title_theme <- title_theme + theme(plot.caption = element_text(size = caption_size_final, family = font))
  p <- p + title_theme
  
  # === SCALES ===
  if (dumbbell_horizontal) {
    p <- p + scale_x_continuous(labels = scales::label_number(big.mark = " ", decimal.mark = ","), breaks = value_axis_breaks,
                                expand = value_axis_expand) +
      scale_y_discrete(limits = levels(data_long[[x_value]]))
  } else {
    p <- p + scale_y_continuous(labels = scales::label_number(big.mark = " ", decimal.mark = ","), breaks = value_axis_breaks,
                                expand = value_axis_expand) +
      scale_x_discrete(limits = levels(data_long[[x_value]]), expand = category_axis_expand)
  }

  # Labels outside the panel: drawn instead of cut off at the panel edge
  if (x_axis_clip_off) p <- p + coord_cartesian(clip = "off")

  # Append caller's custom theme last so it overrides the built-in theme defaults above
  if (!is.null(custom_theme)) p <- p + custom_theme

  return(p)
}
