#' Karta över förändring mellan första och sista året
#'
#' Beräknar förändringen i `df_value` mellan det tidigaste och det senaste
#' året i `year_column`, per område (matchat på geometrin). Förändringen kan
#' vara absolut eller i procent. Resultatet visas som en klassindelad
#' koropletkarta. Årsintervallet läggs automatiskt till i underrubriken.
#'
#' Eftersom åren matchas på geometrin måste geometrin för ett område vara
#' identisk alla år. Områden som inte hittas för det första året visas inte,
#' och funktionen varnar för dem. Har `df` bara ett år blir förändringen 0
#' överallt, också med en varning.
#'
#' @inheritParams func_graf_karta
#' @param df Data frame/`sf`-objekt med tidsseriedata. Varje område finns en
#'   gång per år och har en geometrikolumn. Obligatorisk.
#' @param df_value Namn på kolumnen med värden, t.ex. `"befolkning"`.
#'   Obligatorisk.
#' @param year_column Namn på kolumnen med år/tid.
#' @param subtitle Underrubrik. Årsintervallet (t.ex. `"2015-2024"`) läggs
#'   alltid till.
#' @param color Basfärg för färgskalan (den mörkaste färgen).
#' @param color_low Färg för den ljusa änden av färgskalan.
#' @param color_position Vilken ände som får mörkast färg: `"highest"` (höga
#'   värden mörka) eller `"lowest"`.
#' @param breaks_round_labels `TRUE` flyttar upp den nedre gränsen i varje
#'   intervall ett steg för renare etiketter (t.ex. `"5,0 – 5,9"` i stället
#'   för `"4,9 – 5,9"`).
#' @param percentage_growth `TRUE` = procentuell förändring i stället för
#'   absolut förändring. Områden med startvärdet 0 får då inget värde och visas
#'   som saknade, med en varning.
#' @param data_label_decimals Antal decimaler i etiketternas värden.
#' @param data_label_column Kolumn med etikettext. `NULL` = förändringsvärdet.
#' @param data_label_show_value Om `TRUE` och `data_label_column` anges visas
#'   både text och förändringsvärde, t.ex. `"Borås: 123"`.
#' @param data_label_thousands_sep Använd tusentalsavgränsare i etiketterna.
#' @param data_label_thousands_mark Tusentalsavgränsare, t.ex. `" "`
#'   (hårt mellanslag), `","` eller `"."`.
#' @param debug `TRUE` returnerar data med beräknad förändring
#'   (`value_diff`) och klassindelning i stället för diagrammet.
#'
#' @return Ett `ggplot`-objekt, eller en data frame om `debug = TRUE`.
#' @seealso [func_graf_karta()]
#' @export
#'
#' @example inst/examples/func_graf_karta_change.R
func_graf_karta_change <- function(
    
  # === REQUIRED PARAMETERS ===
  df,                                        # Data frame with time-series data (must have year column and geometry)
  df_value,                                  # Column name with values to visualize (e.g., "befolkning")
  basemap,                                   # sf object: Background map (e.g., län/region boundaries)
  geom_col,                                  # Column name containing geometry data (e.g., "geom", "geometry")
  year_column = "year",                      # Column name for year/time variable
  
  # === MAP STYLING ===
  basemap_color = "#d3d3d3",                 # Fill color for background map areas
  basemap_color_line = "white",              # Border color for background map areas
  data_color_line = "#969696",                 # Border color for data regions/municipalities (color between polygons)
  data_line_size = 0.2,                      # Border thickness for data regions (typical range: 0.1-1)
  
  # === TITLE AND TEXT ===
  title = NULL,                              # Main map title
  text_scale = 1,                            # Multiplies every text size (title, subtitle, caption, legend, data labels) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                           # Title font size (points) (before 2026-10-01: 22)
  title_text_size = 16,                      # Alias for title_size (backward compatibility)
  title_width = 50,                          # Title wrap width (characters)
  title_margin_top = 2,                      # Top margin above title (points)
  title_position = "plot",                   # Title position: "plot" (full width) or "panel" (over map only)
  subtitle = NULL,                           # Subtitle text (year range is appended automatically)
  subtitle_text_size = 13,                   # Subtitle font size (points) (before 2026-10-01: 18)
  caption = NULL,                            # Caption text at bottom
  caption_size = 10,                         # Caption font size (points) (before 2026-10-01: 18)
  caption_text_size = 10,                    # Alias for caption_size (backward compatibility)
  
  # === MAP MARGINS ===
  margin_top = 10,                           # Top margin in points
  margin_right = 30,                         # Right margin in points
  margin_bottom = 10,                        # Bottom margin in points
  margin_left = 10,                          # Left margin in points
  
  # === LEGEND ===
  legend_title = NULL,                       # Legend title
  legend_name = NULL,                        # Alias for legend_title (backward compatibility)
  legend_position = "none",                  # Position: "none", "top", "bottom", "left", "right"
  legend_key_width = 7,                      # Legend key width in mm (typical range: 5-30)
  legend_key_height = 7,                     # Legend key height in mm (typical range: 5-30)
  legend_text_size = 11,                     # Legend text size (points, typical range: 9-14) (before 2026-10-01: 16)
  legend_key_shape = "square",               # Legend icon shape: "square" or "circle"
  
  # === COLOR SCHEME ===
  color = "#005b89",                         # Base color for gradient (the darkest/most saturated color)
  color_low = "white",                       # Color for the lowest value end of the gradient (e.g., "white", "#f0f0f0")
  color_position = "highest",               # Which end gets darkest color: "highest" (high = dark) or "lowest" (low = dark)
  
  # === DATA BREAKS/CATEGORIES ===
  breaks_method = "equal",                   # Method: "equal" (equal intervals), "quantile" (equal counts), "custom" (user-defined)
  breaks_custom = NULL,                      # Custom break points (numeric vector, only used when breaks_method = "custom")
  breaks_num_group = 7,                      # Number of color categories/groups (1-20)
  breaks_decimals = 0,                       # Number of decimal places for break labels (0 = integers, 1 = one decimal, etc.)
  breaks_round_labels = FALSE,               # Nudge lower bound of each interval for cleaner display: TRUE = "5.0-5.9", FALSE = "4.9-5.9"
  percentage_growth = FALSE,                 # Calculate as percentage growth instead of absolute change: TRUE/FALSE
  
  # === DATA LABELS - BASIC ===
  data_label_show = TRUE,                    # Show labels on map: TRUE/FALSE
  data_label_text_size = 3,                  # Label font size in mm (geom_sf_text units; 3 mm ≈ 8.5 pt; smaller than charts' 3.5 because maps are dense) (before 2026-10-01: 9 mm ≈ 26 pt)
  data_label_text_color = "black",           # Label text color (name or hex code, e.g., "#FF0000")
  data_label_box = TRUE,                     # Background box around labels: TRUE/FALSE
  data_label_box_color = "white",            # Box background color (name or hex code)
  data_label_box_alpha = 1,                  # Box transparency (0 = fully transparent, 1 = fully opaque)
  data_label_decimals = 1,                   # Number of decimal places for label values (0 = integers, 1 = one decimal)
  
  # === DATA LABELS - GLOW EFFECT ===
  data_label_glow = FALSE,                   # Add glow/halo effect to labels (requires ggfx): TRUE/FALSE
  data_label_glow_color = "white",           # Glow effect color (name or hex code)
  data_label_glow_sigma = 3,                 # Glow blur amount — higher = more spread (typical range: 1-10)
  data_label_glow_expand = 1,               # Glow expansion size — higher = larger glow area (typical range: 1-5)
  
  # === DATA LABELS - CONTENT ===
  data_label_column = NULL,                  # Column for label text (NULL = uses the change value from df_value)
  data_label_show_value = FALSE,             # Combine column text AND change value: TRUE = "Name: 123", FALSE = value only
  data_label_separator = ": ",              # Separator between column text and value (only when data_label_show_value = TRUE)
  data_label_thousands_sep = TRUE,           # Add thousand separator to numeric labels: TRUE/FALSE
  data_label_thousands_mark = "\u00a0",     # Thousand separator: "\u00a0" (Swedish non-breaking space), "," (English), "." (European)
  
  # === DATA LABELS - SMART POSITIONING ===
  data_label_repel = FALSE,                  # Use ggrepel to avoid label overlaps: TRUE/FALSE
  data_label_force = 2,                      # Repulsion force between labels (higher = more separation, typical range: 0.5-5)
  data_label_max_overlaps = 10,              # Max allowed label overlaps (higher = more labels shown)
  data_label_nudge_x = 0,                   # Horizontal label offset in map units (positive = right)
  data_label_nudge_y = 0,                   # Vertical label offset in map units (positive = up)
  
  # === DATA LABELS - CONNECTING LINES ===
  data_label_line = TRUE,                    # Show connecting lines from label to region (only when repel = TRUE): TRUE/FALSE
  data_label_line_color = "gray50",          # Connecting line color (name or hex code)
  data_label_line_size = 0.3,               # Connecting line thickness (typical range: 0.1-1)
  
  # === DATA LABELS - OUTSIDE MAP ===
  data_label_outside_map = FALSE,            # Push labels outside map boundaries (requires repel = TRUE): TRUE/FALSE
  data_label_expand_factor = 0.5,           # Map expansion when outside_map = TRUE (0.5 = 50% added on each side)
  
  # === DATA LABELS - FILTERING ===
  data_label_filter = NULL,                  # Show labels only for these regions (character vector of names/codes, NULL = all)
  data_label_filter_column = NULL,           # Column to filter on (NULL = auto-detects "region_kod" or "kommun")
  
  # === ADVANCED ===
  debug = FALSE,                             # Return debug data instead of plot: TRUE (returns data frame), FALSE (returns plot)
  font = "Verdana"                           # Font family (must be installed, falls back to "sans" if not found)
  
) {
  
  # ── Package loading ──────────────────────────────────────────────────────────
  
  if (data_label_repel) {
    if (!requireNamespace("ggrepel", quietly = TRUE)) {
      warning("ggrepel not available. Falling back to standard labels.")
      data_label_repel <- FALSE
    }
  }
  
  if (data_label_glow && data_label_show) {
    if (!requireNamespace("ggfx", quietly = TRUE)) {
      warning("ggfx not available. Install with: install.packages('ggfx'). Falling back to box method.")
      data_label_glow <- FALSE
      data_label_box  <- TRUE
    } else {
    }
  }
  
  # ── Validation ───────────────────────────────────────────────────────────────
  stopifnot("Missing required arguments" = !any(sapply(list(df, df_value, basemap, geom_col), is.null)))
  if (!geom_col %in% names(df) || !inherits(df[[geom_col]], "sfc")) {
    stop("`df` saknar en geometrikolumn `", geom_col, "`. Ange ett sf-objekt och namnet på ",
         "dess geometrikolumn, t.ex. geom_col = \"geometry\".", call. = FALSE)
  }
  
  # ── Font ─────────────────────────────────────────────────────────────────────
  font <- valj_typsnitt(font)   # installed, or "sans"/"serif"/"mono"; otherwise "sans" (see zzz.R)

  # ── Resolve alternative parameter names (last-one-wins if both are supplied) ─
  title_size_final   <- if (!missing(title_text_size))   title_text_size   else title_size
  caption_size_final <- if (!missing(caption_text_size)) caption_text_size else caption_size

  # text_scale: one factor for every text size
  title_size_final     <- title_size_final     * text_scale
  caption_size_final   <- caption_size_final   * text_scale
  subtitle_text_size   <- subtitle_text_size   * text_scale
  legend_text_size     <- legend_text_size     * text_scale
  data_label_text_size <- data_label_text_size * text_scale
  legend_title_final <- if (!missing(legend_name))       legend_name       else legend_title

  # ── Compute change between min and max year ──────────────────────────────────
  min_year <- min(df[[year_column]], na.rm = TRUE)
  max_year <- max(df[[year_column]], na.rm = TRUE)
  if (min_year == max_year) {
    warning("`df` innehåller bara ett år (", min_year, "), så förändringen blir 0 överallt. ",
            "Ange data för minst två år i `", year_column, "`.", call. = FALSE)
  }

  # Rename just the value column on each side before joining, so only that column collides
  # (suffix = c("_max","_min") on the raw join used to suffix EVERY shared column, e.g. turning
  # "kommun"/"region_kod" into "kommun_max"/"kommun_min", which broke downstream auto-detection
  # of the filter/label column). Other shared columns (kommun, region_kod, geometry, ...) now
  # come through unsuffixed from the max-year side.
  # The join partner must not itself be sf-classed, or dplyr's sf-dispatch refuses a plain
  # attribute join ("y should not have class sf; for spatial joins, use st_join") — as.data.frame()
  # strips the sf class while keeping the geometry list-column's raw values intact for matching.
  df_diff <- df %>% filter(!!sym(year_column) == max_year) %>%
    rename(!!paste0(df_value, "_max") := !!sym(df_value)) %>%
    inner_join(as.data.frame(df %>% filter(!!sym(year_column) == min_year) %>%
                 select(!!sym(geom_col), !!paste0(df_value, "_min") := !!sym(df_value))),
               by = geom_col) %>%
    mutate(value_diff = !!sym(paste0(df_value, "_max")) - !!sym(paste0(df_value, "_min")))

  # The years are matched on the geometry, so an area whose boundary differs between the
  # years (or that lacks a row for the first year) drops out of the map; say so
  n_max_year <- sum(df[[year_column]] == max_year, na.rm = TRUE)
  if (nrow(df_diff) < n_max_year) {
    warning(n_max_year - nrow(df_diff), " av ", n_max_year, " områden saknar en rad med samma ",
            "geometri för ", min_year, " och visas inte på kartan. Kontrollera att `", geom_col,
            "` är identisk för alla år.", call. = FALSE)
  }

  if (percentage_growth) {
    # A start value of 0 gives an infinite (or undefined) percentage, which previously
    # crashed the class breaks; such areas get no value and are drawn as missing
    start_values <- df_diff[[paste0(df_value, "_min")]]
    noll_start <- !is.na(start_values) & start_values == 0
    if (any(noll_start)) {
      warning(sum(noll_start), " område(n) har startvärdet 0 för ", min_year, ". Procentuell ",
              "förändring går inte att räkna ut för dem, så de visas som saknade värden.", call. = FALSE)
    }
    df_diff <- df_diff %>%
      mutate(value_diff = ifelse(noll_start, NA_real_, (value_diff / !!sym(paste0(df_value, "_min"))) * 100))
  }
  
  # ── Breaks and labels ────────────────────────────────────────────────────────
  calc_breaks <- function(values, method, custom = NULL, n_groups = 7, decimals = 0) {
    # Drop both endpoints (min and max) before wrapping with -Inf/Inf, so n_groups+1 points give
    # n_groups-1 interior breaks -> n_groups intervals (dropping only the min, as before, gave
    # n_groups+1 classes where the top class "max +" held nothing but the maximum value)
    interior <- function(x) x[-c(1, length(x))]
    breaks <- switch(method,
                     "equal"    = c(-Inf, unique(round(interior(seq(min(values, na.rm = TRUE),
                                                                    max(values, na.rm = TRUE),
                                                                    length.out = n_groups + 1)), decimals)), Inf),
                     "quantile" = c(-Inf, unique(round(interior(quantile(values, probs = seq(0, 1, length.out = n_groups + 1),
                                                                         na.rm = TRUE)), decimals)), Inf),
                     "custom"   = { if (is.null(custom)) stop("Custom breaks required when breaks_method = 'custom'")
                       c(-Inf, sort(unique(custom)), Inf) },
                     stop("Invalid breaks_method. Choose 'equal', 'quantile', or 'custom'.")
    )
    
    has_dec <- any(breaks[!is.infinite(breaks)] != floor(breaks[!is.infinite(breaks)]))
    dp      <- if (has_dec) max(1, decimals) else 0
    # Swedish decimal comma, as in the data labels (previously "1.4" in the legend but "1,4" on the map)
    fmt     <- function(x) format(x, nsmall = dp, big.mark = "\u00a0", decimal.mark = ",", scientific = FALSE, trim = TRUE)
    
    n <- length(breaks)
    labels <- c(
      paste0("< ", fmt(breaks[2])),
      if (n > 3) sapply(2:(n - 2), function(i) {
        lower <- breaks[i]; upper <- breaks[i + 1]
        lo_disp <- if (breaks_round_labels && has_dec && i > 2) lower + 10^(-dp) else lower
        if (upper == Inf) paste0(fmt(lo_disp), " +")
        # Spaced en dash between the bounds - a plain "-" gave "-1.6--0.5" for negative ranges
        else if (has_dec)  paste0(fmt(lo_disp), " – ", fmt(upper))
        # "upper - 1" only labels [lower, upper) correctly when all values are whole numbers
        else if (all(values == round(values), na.rm = TRUE)) paste0(fmt(lower), " – ", fmt(upper - 1))
        else               paste0(fmt(lower), " – ", fmt(upper))
      }) else character(0),
      paste0(fmt(breaks[n - 1]), " +")
    )
    # A single class (breaks = c(-Inf, Inf)) would otherwise get the two labels "< Inf" and "-Inf +"
    if (n == 2) labels <- "Alla värden"

    if (debug) { cat("Breaks:", toString(breaks), "\nLabels:", toString(labels), "\n") }
    list(breaks = breaks, labels = labels)
  }
  
  break_info          <- calc_breaks(df_diff$value_diff, breaks_method, breaks_custom, breaks_num_group, breaks_decimals)
  df_diff$category    <- cut(df_diff$value_diff, breaks = break_info$breaks, labels = break_info$labels,
                             include.lowest = TRUE, right = FALSE)
  # Genuinely-NA categories are left NA so scale_fill_manual's na.value = "grey80" renders them as no-data

  if (debug) print(table(df_diff$category))
  
  # ── Color palette ────────────────────────────────────────────────────────────
  color_palette <- colorRampPalette(
    if (color_position == "highest") c(color_low, color) else c(color, color_low)
  )(length(break_info$labels))
  
  # ── Label bounds (outside-map mode) ─────────────────────────────────────────
  calc_label_bounds <- function() {
    if (!data_label_outside_map || !data_label_repel) return(list(xlim = NULL, ylim = NULL))
    bb      <- st_bbox(st_union(st_geometry(basemap), df_diff[[geom_col]]))
    xr      <- bb["xmax"] - bb["xmin"]; yr <- bb["ymax"] - bb["ymin"]
    list(xlim = c(bb["xmin"] - xr * data_label_expand_factor, bb["xmax"] + xr * data_label_expand_factor),
         ylim = c(bb["ymin"] - yr * data_label_expand_factor, bb["ymax"] + yr * data_label_expand_factor))
  }
  bounds <- calc_label_bounds()
  
  # ── Label text helpers ───────────────────────────────────────────────────────
  fmt_num <- function(x) {
    if (data_label_thousands_sep && is.numeric(x))
      format(round(x, data_label_decimals), nsmall = data_label_decimals, big.mark = data_label_thousands_mark,
            decimal.mark = ",", scientific = FALSE, trim = TRUE)
    else as.character(round(as.numeric(x), data_label_decimals))
  }
  
  make_label <- function(d) {
    if (!is.null(data_label_column) && data_label_show_value)
      paste0(d[[data_label_column]], data_label_separator, fmt_num(d$value_diff))
    else if (!is.null(data_label_column))
      as.character(d[[data_label_column]])
    else
      fmt_num(d$value_diff)
  }
  
  # ── Base plot ────────────────────────────────────────────────────────────────
  geom_data_args <- list(data = df_diff,
                         mapping = aes(geometry = !!sym(geom_col), fill = category),
                         color = data_color_line, linewidth = data_line_size)
  
  if (legend_key_shape == "circle") {
    p <- ggplot() +
      geom_sf(data = basemap, fill = basemap_color, color = basemap_color_line) +
      do.call(geom_sf, c(geom_data_args, list(key_glyph = "point"))) +
      scale_fill_manual(values = color_palette, na.value = "grey80")
  } else {
    p <- ggplot() +
      geom_sf(data = basemap, fill = basemap_color, color = basemap_color_line) +
      do.call(geom_sf, geom_data_args) +
      scale_fill_manual(values = color_palette, na.value = "grey80")
  }
  
  # ── Labels ───────────────────────────────────────────────────────────────────
  if (data_label_show) {
    
    filter_col <- data_label_filter_column %||%
      ifelse("region_kod" %in% names(df_diff), "region_kod",
             ifelse("kommun" %in% names(df_diff), "kommun", names(df_diff)[1]))
    
    df_lbl <- if (!is.null(data_label_filter)) {
      filtered <- df_diff[df_diff[[filter_col]] %in% data_label_filter, ]
      if (nrow(filtered) == 0) {
        warning("No matching regions found. Available: ", toString(head(unique(df_diff[[filter_col]]), 10)))
        df_diff
      } else filtered
    } else df_diff
    
    df_lbl$label_text <- make_label(df_lbl)
    
    if (data_label_repel) {
      # Shared repel params
      rp <- list(
        data            = df_lbl,
        mapping         = aes(geometry = !!sym(geom_col), label = label_text),
        stat            = "sf_coordinates",
        size            = data_label_text_size,
        family          = font,   # map font (labels fell back to the device default)
        max.overlaps    = data_label_max_overlaps,
        nudge_x         = data_label_nudge_x,
        nudge_y         = data_label_nudge_y,
        box.padding     = 0.3,
        point.padding   = 0.3,
        show.legend     = FALSE,
        segment.color   = if (data_label_line) data_label_line_color else NA,
        segment.size    = if (data_label_line) data_label_line_size  else 0,
        min.segment.length = if (data_label_line) 0 else Inf
      )
      if (data_label_outside_map && !is.null(bounds$xlim)) {
        rp$force        <- data_label_force * 3
        rp$xlim         <- bounds$xlim
        rp$ylim         <- bounds$ylim
        rp$box.padding  <- 1.0
        rp$point.padding <- 1.5
      } else {
        rp$force <- data_label_force
      }
      
      box_extra <- if (data_label_box) list(color = data_label_text_color,
                                            fill  = alpha(data_label_box_color, data_label_box_alpha)) else
                                              list(color = data_label_text_color)
      geom_repel <- if (data_label_box) ggrepel::geom_label_repel else ggrepel::geom_text_repel
      repel_layer <- do.call(geom_repel, c(rp, box_extra))
      
      p <- p + if (data_label_glow)
        ggfx::with_outer_glow(repel_layer, colour = data_label_glow_color,
                        sigma = data_label_glow_sigma, expand = data_label_glow_expand)
      else repel_layer
      
    } else {
      # Standard (non-repel) labels
      la <- list(data    = df_lbl,
                 mapping = aes(geometry = !!sym(geom_col), label = label_text),
                 size    = data_label_text_size,
                 family  = font,
                 color   = data_label_text_color,
                 nudge_x = data_label_nudge_x,
                 nudge_y = data_label_nudge_y)
      
      if (data_label_glow) {
        p <- p + ggfx::with_outer_glow(do.call(geom_sf_text, la),
                                 colour = data_label_glow_color,
                                 sigma  = data_label_glow_sigma,
                                 expand = data_label_glow_expand)
      } else {
        if (data_label_box) la$fill <- alpha(data_label_box_color, data_label_box_alpha)
        p <- p + do.call(if (data_label_box) geom_sf_label else geom_sf_text, la)
      }
    }
  }
  
  # ── Theme and labels ─────────────────────────────────────────────────────────
  p <- p +
    theme_void() +
    theme(
      plot.title           = element_text(size = title_size_final, hjust = 0.5, family = font,
                                          margin = margin(t = title_margin_top)),
      plot.title.position  = title_position,
      plot.subtitle        = element_text(size = subtitle_text_size, hjust = 0.5, family = font),
      plot.caption         = element_text(hjust = 0.5, size = caption_size_final, family = font),
      legend.position      = legend_position,
      legend.justification = c(1, 0.5),
      legend.key.width     = unit(legend_key_width, "mm"),
      legend.key.height    = unit(legend_key_height, "mm"),
      legend.text          = element_text(size = legend_text_size, family = font),
      legend.title         = element_text(size = legend_text_size, family = font),
      plot.margin          = margin(t = margin_top, r = margin_right, b = margin_bottom, l = margin_left)
    ) +
    labs(
      title    = if (!is.null(title)) str_wrap(title, width = title_width),
      subtitle = str_wrap(paste0(if (!is.null(subtitle)) paste0(subtitle, " "), min_year, "-", max_year), width = title_width),
      fill     = legend_title_final,
      caption  = caption
    )
  
  # Circle legend override
  if (legend_key_shape == "circle")
    p <- p + guides(fill = guide_legend(override.aes = list(shape = 21, size = 6, stroke = 0.5)))
  
  # Coordinate system — expand map view if outside-map labels are active
  p <- p + if (!is.null(bounds$xlim))
    coord_sf(xlim = bounds$xlim, ylim = bounds$ylim, expand = FALSE)
  else
    coord_sf(expand = FALSE)
  
  return(if (debug) df_diff else p)
}
