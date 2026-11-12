#' Koropletkarta med klassindelade värden
#'
#' Ritar en karta där områden (t.ex. kommuner) färgas efter ett värde som delas
#' in i klasser. Klasserna kan vara lika breda intervall, kvantiler eller egna
#' gränser. Med `group` färgas områdena i stället efter en kategori, med en färg
#' per grupp. Etiketterna kan ha ruta, glöd-effekt eller smart placering med
#' \pkg{ggrepel}, även utanför kartan. Siffror formateras på svenska
#' (decimalkomma, mellanslag som tusentalsavgränsare).
#'
#' @param df Data frame/`sf`-objekt med data och geometri. Obligatorisk.
#' @param df_value Namn på kolumnen med värden som ska visas. Kan utelämnas
#'   när `group` anges. Med `group` används `df_value` bara till etiketterna.
#' @param basemap `sf`-objekt som bakgrundskarta, t.ex. läns- eller
#'   regiongräns. Obligatorisk.
#' @param geom_col Namn på geometrikolumnen i `df`, t.ex. `"geom"` eller
#'   `"geometry"`. Obligatorisk.
#' @param group Kolumn med kategorier som områdena färgas efter, t.ex.
#'   `"kategori"`. Då får varje grupp en egen färg, och `breaks_*`, `color` och
#'   `color_position` används inte. Grupperna ordnas efter faktornivåerna
#'   (oanvända nivåer tas bort). Tal sorteras, och annan text får ordningen den
#'   först förekommer i `df`. Det är samma regel som i [func_graf_linjediagram()]
#'   och [func_graf_barchart()], så samma data får samma färger. Använd en faktor
#'   för att styra ordningen. Områden där gruppen saknas (`NA`) ritas grå och
#'   får ingen etikett när det är gruppkolumnen som visas. `NULL` = färgskala
#'   efter `df_value`.
#' @param colors Färger för grupperna när `group` anges. En namnlös vektor
#'   fördelas i gruppordning och återanvänds om den är för kort. En namngiven
#'   vektor matchas mot gruppnamnen, t.ex.
#'   `c("Fler födda, fler inflyttare" = "#1a9fb3")`, och alla grupper måste då
#'   ha en färg. `NULL` = `func_fargtema("ru")`.
#' @param text_scale Faktor som alla teckenstorlekar multipliceras med
#'   (rubriker, axlar, förklaring och etiketter). 1 = storlekarna som de är
#'   angivna, t.ex. 1.3 för stora exporter.
#' @param basemap_color Fyllnadsfärg för bakgrundskartan.
#' @param basemap_color_line Linjefärg för bakgrundskartans gränser.
#' @param data_color_line Linjefärg mellan dataområdena.
#' @param data_line_size Linjetjocklek för dataområdenas gränser (typiskt
#'   0,1–1).
#' @param title Huvudrubrik. `NULL` = ingen rubrik.
#' @param title_size Rubrikens teckenstorlek i punkter.
#' @param title_text_size Alias för `title_size` (bakåtkompatibilitet). Vinner
#'   om den anges.
#' @param title_width Antal tecken innan rubriken radbryts.
#' @param title_margin_top Marginal ovanför rubriken i punkter.
#' @param title_position Rubrikens placering: `"plot"` (hela bredden) eller
#'   `"panel"` (över kartan).
#' @param subtitle Underrubrik. `NULL` = ingen.
#' @param subtitle_text_size Underrubrikens teckenstorlek i punkter.
#' @param caption Text längst ner (källa, noter). `NULL` = ingen.
#' @param caption_size Teckenstorlek för `caption` i punkter.
#' @param caption_text_size Alias för `caption_size` (bakåtkompatibilitet).
#'   Vinner om den anges.
#' @param margin_top,margin_right,margin_bottom,margin_left Kartans marginaler
#'   i punkter.
#' @param legend_title Förklaringens rubrik. `NULL` = ingen rubrik, eller
#'   namnet på `group`-kolumnen när `group` anges.
#' @param legend_name Alias för `legend_title` (bakåtkompatibilitet). Vinner om
#'   den anges.
#' @param legend_position Förklaringens placering: `"none"`, `"top"`,
#'   `"bottom"`, `"left"` eller `"right"`. Om den inte anges och `group` är
#'   satt blir den `"right"`, eftersom en karta med grupper inte går att läsa
#'   utan förklaring.
#' @param legend_key_width,legend_key_height Storlek på förklaringens
#'   symboler i mm (typiskt 5–30).
#' @param legend_text_size Förklaringens teckenstorlek i punkter.
#' @param legend_key_shape Symbolform i förklaringen: `"square"` eller
#'   `"circle"`.
#' @param color Basfärg för färgskalan. Används inte när `group` anges (använd
#'   `colors`).
#' @param color_position Vilka värden som får mörkast färg: `"highest"` eller
#'   `"lowest"`. Används inte när `group` anges.
#' @param breaks_method Klassindelning: `"equal"` (lika breda intervall),
#'   `"quantile"` (lika många i varje klass) eller `"custom"` (egna gränser i
#'   `breaks_custom`). Används inte när `group` anges.
#' @param breaks_custom Numerisk vektor med egna klassgränser. Används bara
#'   när `breaks_method = "custom"`.
#' @param breaks_num_group Antal klasser (1–20). Används inte när `group`
#'   anges.
#' @param breaks_decimals Antal decimaler i klassgränsernas etiketter.
#' @param data_label_show Visa etiketter på kartan.
#' @param data_label_text_size Etiketternas teckenstorlek i mm (ggplot2:s
#'   textenhet, 3 mm ≈ 8,5 punkter).
#' @param data_label_text_color Etiketternas textfärg.
#' @param data_label_box Visa en ruta bakom etiketterna.
#' @param data_label_box_color Rutans bakgrundsfärg.
#' @param data_label_box_alpha Rutans opacitet (0 = genomskinlig, 1 = helt
#'   täckande).
#' @param data_label_decimals Antal decimaler i etiketternas värden.
#' @param data_label_decimal Alias för `data_label_decimals`
#'   (bakåtkompatibilitet). Vinner om den anges.
#' @param data_label_glow Lägg en glöd-effekt runt etiketterna (kräver
#'   \pkg{ggfx}, annars används ruta).
#' @param data_label_glow_color Glödens färg.
#' @param data_label_glow_sigma Glödens oskärpa; högre = mer spridning
#'   (typiskt 1–10).
#' @param data_label_glow_expand Glödens storlek (typiskt 1–5).
#' @param data_label_column Kolumn med etikettext. `NULL` = värdet i
#'   `df_value`, eller gruppen om `df_value` inte anges.
#' @param data_label_show_value Om `TRUE` och `data_label_column` anges visas
#'   både text och värde, t.ex. `"Borås: 123"`.
#' @param data_label_separator Avskiljare mellan text och värde.
#' @param data_label_repel Använd \pkg{ggrepel} för att undvika överlappande
#'   etiketter.
#' @param data_label_force Repelleringskraft mellan etiketter (typiskt 0,5–5).
#' @param data_label_max_overlaps Max antal tillåtna överlapp (högre = fler
#'   etiketter visas).
#' @param data_label_nudge_x,data_label_nudge_y Förskjutning av etiketterna i
#'   kartans enheter.
#' @param data_label_line Visa linjer från etikett till område (bara med
#'   `data_label_repel = TRUE`).
#' @param data_label_line_color Linjernas färg.
#' @param data_label_line_size Linjernas tjocklek (typiskt 0,1–1).
#' @param data_label_outside_map Tvinga ut etiketterna utanför kartan (kräver
#'   `data_label_repel = TRUE`).
#' @param data_label_expand_factor Hur mycket kartytan utökas när
#'   `data_label_outside_map = TRUE` (0,5 = 50 % på varje sida).
#' @param data_label_filter Teckenvektor med de områden (namn eller koder) som
#'   ska få etikett. `NULL` = alla.
#' @param data_label_filter_column Kolumn som `data_label_filter` matchas mot.
#'   `NULL` = `"region_kod"` eller `"kommun"` om de finns, annars första
#'   kolumnen.
#' @param debug `TRUE` returnerar data med klassindelning i stället för
#'   diagrammet och skriver ut brytpunkter.
#' @param font Typsnitt: ett installerat typsnitt eller `"sans"`, `"serif"` eller
#'   `"mono"`. Annars används `"sans"`.
#'
#' @return Ett `ggplot`-objekt, eller en data frame om `debug = TRUE`.
#' @seealso [func_graf_karta_change()], [func_graf_karta_heatmap()]
#' @export
#'
#' @example inst/examples/func_graf_karta.R
func_graf_karta <- function(
    # === REQUIRED PARAMETERS ===
  df,                              # Data frame with data to map (must have geometry column)
  df_value = NULL,                 # Column name with values to visualize (e.g., "arbetslöshet_andel") | may be left out when group is set
  basemap,                         # sf object: Background map (e.g., län/region boundaries)
  geom_col,                        # Column name containing geometry data (e.g., "geom", "geometry")

  # === GROUPING (categorical map) ===
  group = NULL,                    # Column name with categories to color by (e.g., "kategori_text") | NULL = numeric gradient from df_value
                                   #   When set: fill = one color per group, breaks_* and color/color_position are ignored,
                                   #   df_value (if given) is still used for labels. Missing groups (NA) are drawn grey80
                                   #   (and get no label when the group column is what's labelled).
                                   #   Group order = factor levels (unused levels dropped), numeric = sorted, else order of first appearance in df
                                   #   (same rule as linjediagram/stapeldiagram, so the same data gets the same colors) - use a factor to control the order
  colors = func_fargtema("ru"),    # Colors for groups (only used when group is set) | unnamed vector = assigned in group order (recycled if too few),
                                   #   named vector = matched by group name, e.g. c("Fler födda, fler inflyttare" = "#1a9fb3") | NULL = func_fargtema("ru")

  # === MAP STYLING ===
  basemap_color = "#d3d3d3",       # Fill color for background map areas
  basemap_color_line = "white",    # Border color for background map areas
  data_color_line = "#969696",      # Border color for data regions/municipalities (color between polygons)
  data_line_size = 0.2,            # Border thickness for data regions (typical range: 0.1-1)
  
  # === TITLE AND TEXT ===
  title = NULL,                    # Main map title
  text_scale = 1,                  # Multiplies every text size (title, subtitle, caption, legend, data labels) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                 # Title font size (points) (before 2026-10-01: 22)
  title_text_size = 16,            # Title font size (points) (alias for title_size, kept for backward compatibility)
  title_width = 100,               # Title wrap width (characters)
  title_margin_top = 2,            # Top margin above title (points)
  title_position = "plot",         # Title position: "plot" (full width) or "panel" (over map)
  subtitle = NULL,                 # Subtitle text below title
  subtitle_text_size = 13,         # Subtitle font size (points) (before 2026-10-01: 18)
  caption = NULL,                  # Caption text at bottom
  caption_size = 10,               # Caption font size (points) (before 2026-10-01: 18)
  caption_text_size = 10,          # Caption font size (points) (alias for caption_size, kept for backward compatibility)
  
  # === MAP MARGINS ===
  margin_top = 2,                  # Top margin (points)
  margin_right = 2,                # Right margin (points)
  margin_bottom = 2,               # Bottom margin (points)
  margin_left = 2,                 # Left margin (points)
  
  # === LEGEND ===
  legend_title = NULL,             # Legend title | NULL = no title, or the group column name when group is set
  legend_name = NULL,              # Legend title (alias for legend_title, kept for backward compatibility)
  legend_position = "none",        # Position: "none", "top", "bottom", "left", "right" | if not given and group is set, defaults to "right"
  legend_key_width = 7,            # Legend key width in mm (typical range: 5-30)
  legend_key_height = 7,           # Legend key height in mm (typical range: 5-30)
  legend_text_size = 11,           # Legend text size (points, typical range: 9-14) (before 2026-10-01: 16)
  legend_key_shape = "square",     # Legend icon shape: "square" (default) or "circle"

  # === COLOR SCHEME ===
  color = "#005b89",               # Base color for gradient (ignored when group is set - use colors)
  color_position = "highest",      # Which values get darkest: "highest" or "lowest" (ignored when group is set)

  # === DATA BREAKS/CATEGORIES ===
  breaks_method = "equal",         # Method: "equal" (equal intervals), "quantile" (equal counts), "custom" (user-defined)
  breaks_custom = NULL,            # Custom break points (numeric vector, only used when breaks_method = "custom")
  breaks_num_group = 4,            # Number of color categories/groups (1-20) (gradient mode only, ignored when group is set)
  breaks_decimals = 0,             # Decimal places in break interval labels (0 = integers, 1 = one decimal, etc.)

  # === DATA LABELS - BASIC ===
  data_label_show = TRUE,          # Show labels on map: TRUE/FALSE
  data_label_text_size = 3,        # Label font size in mm (geom_sf_text units; 3 mm ≈ 8.5 pt) — smaller than the charts' 3.5 because maps are dense
  data_label_text_color = "black", # Label text color (name or hex code, e.g., "#FF0000")
  data_label_box = TRUE,           # Background box around labels: TRUE/FALSE
  data_label_box_color = "white",  # Box background color (name or hex code)
  data_label_box_alpha = 1,        # Box transparency (0 = fully transparent, 1 = fully opaque)
  data_label_decimals = 0,         # Decimal places shown in label values (0 = integers, 1 = one decimal, etc.)
  data_label_decimal = 0,          # Decimal places shown in label values (0 = integers, 1 = one decimal, etc.) (alias for data_label_decimals, kept for backward compatibility)
  
  # === DATA LABELS - GLOW EFFECT ===
  data_label_glow = FALSE,         # Add glow/halo effect to labels (requires ggfx package): TRUE/FALSE
  data_label_glow_color = "white", # Glow effect color (name or hex code, e.g., "white", "#FFFFFF")
  data_label_glow_sigma = 3,       # Glow blur amount - higher = more spread (typical range: 1-10)
  data_label_glow_expand = 1,      # Glow expansion size - higher = larger glow area (typical range: 1-5)
  
  # === DATA LABELS - CONTENT ===
  data_label_column = NULL,        # Column name for label text (NULL = use df_value column, or the group column if df_value is not given)
  data_label_show_value = FALSE,   # Show both column text AND value: TRUE (shows "Name: 123"), FALSE (shows only "Name" or value)
  data_label_separator = ": ",     # Separator between column text and value (only used when data_label_show_value = TRUE)
  
  # === DATA LABELS - SMART POSITIONING ===
  data_label_repel = FALSE,        # Use ggrepel for smart positioning to avoid overlaps: TRUE/FALSE
  data_label_force = 2,            # Repulsion force between labels (higher = more separation, typical range: 0.5-5)
  data_label_max_overlaps = 10,    # Maximum number of overlaps allowed (higher = more labels shown)
  data_label_nudge_x = 0,          # Horizontal adjustment in map units (positive = right, negative = left)
  data_label_nudge_y = 0,          # Vertical adjustment in map units (positive = up, negative = down)
  
  # === DATA LABELS - CONNECTING LINES ===
  data_label_line = TRUE,          # Show connecting lines from label to region (only when repel = TRUE): TRUE/FALSE
  data_label_line_color = "gray50", # Line color (name or hex code)
  data_label_line_size = 0.3,      # Line thickness (typical range: 0.1-1)
  
  # === DATA LABELS - OUTSIDE MAP ===
  data_label_outside_map = FALSE,  # Force labels outside map boundaries (requires repel = TRUE): TRUE/FALSE
  data_label_expand_factor = 0.5,  # Map expansion amount when outside_map = TRUE (0.5 = 50% expansion on each side)
  
  # === DATA LABELS - FILTERING ===
  data_label_filter = NULL,        # Only show labels for these regions (character vector with region names/codes, NULL = show all)
  data_label_filter_column = NULL, # Column to use for filtering (NULL = auto-detect "region_kod" or "kommun")
  
  # === ADVANCED ===
  debug = FALSE,                   # Return debug info instead of plot: TRUE (returns data frame), FALSE (returns plot)
  font = "Verdana"                 # Font family (must be installed on system, fallback to "sans" if not available)
) {
  
  # Load packages
  if (data_label_repel && !requireNamespace("ggrepel", quietly = TRUE)) {
    warning("ggrepel not available. Falling back to standard labels.")
    data_label_repel <- FALSE
  }
  
  # Handle glow effects
  if (data_label_glow && data_label_show) {
    if (!requireNamespace("ggfx", quietly = TRUE)) {
      warning("ggfx package not available. Install with: install.packages('ggfx'). Falling back to box method.")
      data_label_glow <- FALSE
      data_label_box <- TRUE
    } else {
    }
  }
  
  stopifnot("Missing required arguments" = !any(sapply(list(df, basemap, geom_col), is.null)))
  # Without this check a df without geometry gave only a cryptic stat_sf() warning and an empty map
  if (!geom_col %in% names(df) || !inherits(df[[geom_col]], "sfc")) {
    stop("`df` saknar en geometrikolumn `", geom_col, "`. Ange ett sf-objekt och namnet på ",
         "dess geometrikolumn, t.ex. geom_col = \"geometry\".", call. = FALSE)
  }
  if (is.character(df)) {
    stop("df must be a data frame, not a text string. Write df = ", df, " (without quotes).")
  }
  if (is.null(df_value) && is.null(group)) stop("Either df_value or group must be given")
  if (!is.null(df_value) && !df_value %in% names(df)) stop("df_value column '", df_value, "' not found in df")
  if (!is.null(group) && !group %in% names(df)) stop("group column '", group, "' not found in df")

  # A categorical map without a legend is unreadable, so show it unless the user chose otherwise
  if (!is.null(group) && missing(legend_position)) legend_position <- "right"

  # Font validation — installed, or "sans"/"serif"/"mono"; otherwise "sans" (see zzz.R)
  font <- valj_typsnitt(font)

  # Resolve alternative parameter names (last-one-wins if both are supplied)
  title_size_final          <- if (!missing(title_text_size))    title_text_size    else title_size
  caption_size_final        <- if (!missing(caption_text_size))  caption_text_size  else caption_size

  # text_scale: one factor for every text size
  title_size_final     <- title_size_final     * text_scale
  caption_size_final   <- caption_size_final   * text_scale
  subtitle_text_size   <- subtitle_text_size   * text_scale
  legend_text_size     <- legend_text_size     * text_scale
  data_label_text_size <- data_label_text_size * text_scale
  legend_title_final       <- if (!missing(legend_name))        legend_name        else legend_title
  data_label_decimals_final <- if (!missing(data_label_decimal)) data_label_decimal else data_label_decimals

  # Calculate breaks with support for decimals
  calc_breaks <- function(values, method, custom = NULL, n_groups = 7, decimals = 0) {
    min_val <- min(values, na.rm = TRUE)
    max_val <- max(values, na.rm = TRUE)
    
    breaks <- switch(method,
                     "equal" = {
                       raw_breaks <- seq(min_val, max_val, length.out = n_groups + 1)
                       # Drop both endpoints (min and max) before wrapping with -Inf/Inf, so n_groups
                       # interior points -> n_groups+1 breakpoints -> n_groups intervals via cut()
                       c(-Inf, unique(round(raw_breaks[-c(1, length(raw_breaks))], decimals)), Inf)
                     },
                     "quantile" = {
                       raw_breaks <- quantile(values, probs = seq(0, 1, length.out = n_groups + 1), na.rm = TRUE)
                       # Drop both endpoints (min and max) before wrapping with -Inf/Inf, so n_groups
                       # interior points -> n_groups+1 breakpoints -> n_groups intervals via cut()
                       c(-Inf, unique(round(raw_breaks[-c(1, length(raw_breaks))], decimals)), Inf)
                     },
                     "custom" = {
                       if (is.null(custom)) stop("Custom breaks required when breaks_method = 'custom'")
                       c(-Inf, sort(unique(custom)), Inf)
                     },
                     stop("Invalid breaks_method"))
    
    has_decimals <- any(breaks[!is.infinite(breaks)] != floor(breaks[!is.infinite(breaks)]))
    # "lower - (upper - 1)" is only a correct label for [lower, upper) when all values are whole numbers;
    # otherwise e.g. 9.5 falls in [5, 10) but would be labelled "5 - 9"
    values_whole <- all(values == round(values), na.rm = TRUE)

    labels <- c(
      paste("<", format(breaks[2], nsmall = if(has_decimals) max(1, decimals) else 0, big.mark = "\u00a0", decimal.mark = ",", scientific = FALSE)),
      if (length(breaks) > 3) sapply(2:(length(breaks)-2), function(i) {
        lower <- breaks[i]
        upper <- breaks[i+1]
        if (upper == Inf) {
          paste(format(lower, nsmall = if(has_decimals) max(1, decimals) else 0, big.mark = " ", decimal.mark = ",", scientific = FALSE), "+")
        } else if (has_decimals) {
          paste(format(lower, nsmall = max(1, decimals), big.mark = " ", decimal.mark = ",", scientific = FALSE), "-", format(upper, nsmall = max(1, decimals), big.mark = " ", decimal.mark = ",", scientific = FALSE))
        } else if (values_whole) {
          paste(format(lower, big.mark =" ", scientific = FALSE), "-", format(upper - 1, big.mark = " ", scientific = FALSE))
        } else {
          paste(format(lower, big.mark = " ", scientific = FALSE), "-", format(upper, big.mark = " ", scientific = FALSE))
        }
      }) else character(0),
      paste(format(breaks[length(breaks)-1], nsmall = if(has_decimals) max(1, decimals) else 0, big.mark = " ", decimal.mark = ",", scientific = FALSE), "+")
    )
    # A single class (breaks = c(-Inf, Inf)) would otherwise get the two labels "< Inf" and "-Inf +"
    if (length(breaks) == 2) labels <- "Alla värden"

    if (debug) {
      cat("Breaks:", toString(breaks), "\n")
      cat("Labels:", toString(labels), "\n")
      cat("Has decimals:", has_decimals, "\n")
    }
    
    list(breaks = breaks, labels = labels)
  }
  
  # Calculate label bounds for outside-map positioning
  calc_label_bounds <- function(basemap, df, geom_col, expand_factor) {
    if (!data_label_outside_map || !data_label_repel) return(list(xlim = NULL, ylim = NULL, original_bbox = NULL))
    
    basemap_geom <- if (inherits(basemap, "sf")) st_geometry(basemap) else basemap[[geom_col]]
    df_geom <- if (inherits(df, "sf")) st_geometry(df) else df[[geom_col]]
    
    original_bbox <- st_bbox(st_union(basemap_geom, df_geom))
    x_range <- original_bbox["xmax"] - original_bbox["xmin"]
    y_range <- original_bbox["ymax"] - original_bbox["ymin"]
    
    xlim <- c(original_bbox["xmin"] - x_range * expand_factor, original_bbox["xmax"] + x_range * expand_factor)
    ylim <- c(original_bbox["ymin"] - y_range * expand_factor, original_bbox["ymax"] + y_range * expand_factor)
    
    if (debug) {
      cat("Original bounds - X:", toString(c(original_bbox["xmin"], original_bbox["xmax"])), 
          "Y:", toString(c(original_bbox["ymin"], original_bbox["ymax"])), "\n")
      cat("Expanded bounds - X:", toString(xlim), "Y:", toString(ylim), "\n")
    }
    
    list(xlim = xlim, ylim = ylim, original_bbox = original_bbox)
  }
  
  # Format a numeric value using data_label_decimals (or legacy data_label_decimal), with Swedish number formatting
  fmt_label_val <- function(x) {
    # trimws: format() pads all values to a common width, which puts stray spaces in labels ("Kommun:  63")
    trimws(format(round(as.numeric(x), data_label_decimals_final),
                  nsmall = data_label_decimals_final,
                  big.mark = "\u00a0",
                  decimal.mark = ",",
                  scientific = FALSE))
  }
  
  # Create label text: either value only, column only, or "column: value"
  create_label_text <- function(df_labels, display_col, value_col, show_value, separator) {
    is_numeric_col <- is.numeric(df_labels[[display_col]])
    display_text <- if (is_numeric_col) fmt_label_val(df_labels[[display_col]]) else df_labels[[display_col]]
    
    if (!is.null(data_label_column) && show_value && !is.null(value_col)) {
      paste0(display_text, separator, fmt_label_val(df_labels[[value_col]]))
    } else {
      display_text
    }
  }
  
  # Categorize data: either by group (one color per group) or by numeric breaks (gradient)
  if (!is.null(group)) {
    # Factor: keep its level order but drop levels not in the data, so they don't use up a color.
    # Otherwise: order of first appearance, same as linjediagram/stapeldiagram
    # Numeric groups -> factor with numerically sorted levels (1, 2, 10), as in linjediagram/stapeldiagram
    if (is.numeric(df[[group]])) df[[group]] <- factor(df[[group]])
    # setdiff(NA) also removes an explicit NA level (from addNA() / fct_na_value_to_level()) - NA is always drawn grey
    group_levels <- if (is.factor(df[[group]])) setdiff(levels(droplevels(df[[group]])), NA) else unique(stats::na.omit(as.character(df[[group]])))
    df$category <- factor(as.character(df[[group]]), levels = group_levels)

    if (is.null(colors)) colors <- func_fargtema("ru")
    if (!is.null(names(colors))) {
      missing_groups <- setdiff(group_levels, names(colors))
      if (length(missing_groups) > 0) stop("colors is named but has no color for: ", toString(missing_groups))
      color_mapping <- colors[group_levels]
    } else {
      color_mapping <- setNames(rep(colors, length.out = length(group_levels)), group_levels)
    }
  } else {
    break_info <- calc_breaks(df[[df_value]], breaks_method, breaks_custom, breaks_num_group, breaks_decimals)
    df$category <- cut(df[[df_value]], breaks = break_info$breaks, labels = break_info$labels,
                       include.lowest = TRUE, right = FALSE)
    color_mapping <- colorRampPalette(if (color_position == "highest") c("white", color) else c(color, "white"))(length(break_info$labels))
  }

  if (debug) print(table(df$category))

  # Expanded bounds for outside-map labels
  bounds <- calc_label_bounds(basemap, df, geom_col, data_label_expand_factor)
  
  # Base plot
  if (legend_key_shape == "circle") {
    p <- ggplot() +
      geom_sf(data = basemap, fill = basemap_color, color = basemap_color_line) +
      geom_sf(data = df, aes(geometry = !!sym(geom_col), fill = category),
              color = data_color_line, linewidth = data_line_size, key_glyph = "point") +
      scale_fill_manual(values = color_mapping, na.value = "grey80")
  } else {
    p <- ggplot() +
      geom_sf(data = basemap, fill = basemap_color, color = basemap_color_line) +
      geom_sf(data = df, aes(geometry = !!sym(geom_col), fill = category),
              color = data_color_line, linewidth = data_line_size) +
      scale_fill_manual(values = color_mapping, na.value = "grey80")
  }
  
  # Add labels
  if (data_label_show) {
    display_col <- data_label_column %||% df_value %||% group
    filter_col <- data_label_filter_column %||% 
      ifelse("region_kod" %in% names(df), "region_kod",
             ifelse("kommun" %in% names(df), "kommun", names(df)[1]))
    
    stopifnot("Label display column not found" = display_col %in% names(df))
    
    df_labels <- if (!is.null(data_label_filter)) {
      filtered <- df[df[[filter_col]] %in% data_label_filter, ]
      if (nrow(filtered) == 0) {
        warning("No matching regions found. Available: ", toString(head(unique(df[[filter_col]]), 10)))
        df
      } else filtered
    } else df

    # Regions with a missing group are drawn grey - skip their label instead of printing "NA"
    if (!is.null(group) && display_col == group) df_labels <- df_labels[!is.na(as.character(df_labels[[group]])), ]

    if (nrow(df_labels) > 0) {
      df_labels$label_text <- create_label_text(df_labels, display_col, df_value, data_label_show_value, data_label_separator)
      
      if (data_label_repel) {
        repel_params <- list(
          data = df_labels, 
          mapping = aes(geometry = !!sym(geom_col), label = label_text),
          stat = "sf_coordinates",
          size = data_label_text_size,
          family = font,   # map font (labels fell back to the device default)
          max.overlaps = data_label_max_overlaps, 
          nudge_x = data_label_nudge_x, 
          nudge_y = data_label_nudge_y,
          box.padding = 0.3, 
          point.padding = 0.3, 
          show.legend = FALSE,
          segment.color = if (data_label_line) data_label_line_color else NA,
          segment.size = if (data_label_line) data_label_line_size else 0,
          min.segment.length = if (data_label_line) 0 else Inf
        )
        
        if (data_label_outside_map && !is.null(bounds$xlim)) {
          repel_params$force <- data_label_force * 3
          repel_params$xlim <- bounds$xlim
          repel_params$ylim <- bounds$ylim
          repel_params$box.padding <- 1.0
          repel_params$point.padding <- 1.5
        } else {
          repel_params$force <- data_label_force
        }
        
        if (data_label_glow && requireNamespace("ggfx", quietly = TRUE)) {
          geom_fn <- if (data_label_box) ggrepel::geom_label_repel else ggrepel::geom_text_repel
          extra <- if (data_label_box) list(color = data_label_text_color, fill = alpha(data_label_box_color, data_label_box_alpha)) else list(color = data_label_text_color)
          p <- p + ggfx::with_outer_glow(do.call(geom_fn, c(repel_params, extra)),
                                   colour = data_label_glow_color, sigma = data_label_glow_sigma, expand = data_label_glow_expand)
        } else {
          geom_fn <- if (data_label_box) ggrepel::geom_label_repel else ggrepel::geom_text_repel
          extra <- if (data_label_box) list(color = data_label_text_color, fill = alpha(data_label_box_color, data_label_box_alpha)) else list(color = data_label_text_color)
          p <- p + do.call(geom_fn, c(repel_params, extra))
        }
      } else {
        label_args <- list(
          data = df_labels, 
          mapping = aes(geometry = !!sym(geom_col), label = label_text),
          size = data_label_text_size,
          family = font,
          color = data_label_text_color,
          nudge_x = data_label_nudge_x, 
          nudge_y = data_label_nudge_y
        )
        
        if (data_label_glow && requireNamespace("ggfx", quietly = TRUE)) {
          p <- p + ggfx::with_outer_glow(do.call(geom_sf_text, label_args),
                                   colour = data_label_glow_color, sigma = data_label_glow_sigma, expand = data_label_glow_expand)
        } else {
          geom_func <- if (data_label_box) geom_sf_label else geom_sf_text
          if (data_label_box) label_args$fill <- alpha(data_label_box_color, data_label_box_alpha)
          p <- p + do.call(geom_func, label_args)
        }
      }
    }
  }
  
  # Apply theme and legend styling
  p <- p +
    theme_void() +
    theme(
      plot.title = element_text(size = title_size_final, hjust = 0.5, family = font,
                                 margin = margin(t = title_margin_top)),
      plot.title.position = title_position,
      plot.subtitle = element_text(size = subtitle_text_size, hjust = 0.5, family = font),
      plot.caption = element_text(hjust = 0.5, size = caption_size_final, family = font),
      legend.position = legend_position, 
      legend.justification = c(1, 0.5),
      legend.key.width = unit(legend_key_width, "mm"),
      legend.key.height = unit(legend_key_height, "mm"),
      legend.text = element_text(size = legend_text_size, family = font),
      legend.title = element_text(size = legend_text_size, family = font),
      plot.margin = margin(t = margin_top, r = margin_right, b = margin_bottom, l = margin_left)
    ) +
    labs(
      title = if (!is.null(title)) str_wrap(title, width = title_width),
      subtitle = subtitle, 
      fill = if (!is.null(group)) (legend_title_final %||% group) else legend_title_final,
      caption = caption
    )
  
  if (legend_key_shape == "circle") {
    p <- p + guides(fill = guide_legend(override.aes = list(shape = 21, size = 6, stroke = 0.5)))
  }
  
  if (!is.null(bounds$xlim)) {
    p <- p + coord_sf(xlim = bounds$xlim, ylim = bounds$ylim, expand = FALSE)
  } else {
    p <- p + coord_sf(expand = FALSE)
  }
  
  return(if (debug) df else p)
}
