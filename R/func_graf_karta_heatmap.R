#' Heatmap (täthetskarta) över punktdata
#'
#' Ritar en tvådimensionell täthetsskattning (konturpolygoner) av punkter på en
#' bakgrundskarta. Punkterna kan också visas, och färgas efter en grupp. Vägar,
#' hav, sjöar och kommunnamn kan läggas till som extra lager. Kartutsnittet
#' följer bakgrundskartans utbredning plus en marginal.
#'
#' Kartan ritas i bakgrundskartans koordinatsystem. Tätheten i förklaringen är
#' antal punkter per km², oavsett koordinatsystem. För kartor i grader (t.ex.
#' WGS 84) gäller omräkningen till km² exakt i punkternas mitt och ungefärligt
#' längre norrut eller söderut.
#'
#' `graf_karta_heatmap()` är ett bakåtkompatibelt alias. Funktionen hette
#' tidigare så, utan prefixet `func_`.
#'
#' @inheritParams func_graf_karta
#' @param df `sf`-objekt med punktgeometrier. Obligatorisk.
#' @param df_value Namn på en numerisk kolumn i `df`. Används för punkternas
#'   färgmappning. Obligatorisk.
#' @param basemap `sf`-objekt som bakgrundskarta, t.ex. kommun- eller
#'   regiongränser. `df` transformeras till dess koordinatsystem.
#'   Obligatorisk.
#' @param group Kolumn som punkterna färgas efter, t.ex. `"kategori"`. Grupperna
#'   ordnas efter faktornivåerna (oanvända nivåer tas bort). Tal sorteras, och
#'   annan text får ordningen den först förekommer i `df`. Punkter där gruppen
#'   saknas (`NA`) ritas grå. `NULL` = ingen gruppering.
#' @param colors Punkternas färger per grupp när `group` anges. En namnlös
#'   vektor fördelas i gruppordning och återanvänds om den är för kort. En
#'   namngiven vektor matchas mot gruppnamnen, t.ex.
#'   `c("Industri" = "#1a9fb3")`, och alla grupper måste då ha en färg.
#'   `NULL` = `func_fargtema("ru")`.
#' @param adjust_value Justering av bandbredden i täthetsskattningen. Lägre ger
#'   tätare kluster, högre ger jämnare yta.
#' @param heatmap_alpha Heatmap-polygonernas opacitet (0–1).
#' @param bins Antal konturnivåer (typiskt 5–15).
#' @param low_color,high_color Färg för lägst respektive högst täthet.
#' @param show_points Visa de enskilda punkterna.
#' @param point_size Punkternas storlek (typiskt 1–5).
#' @param point_color Punkternas färg när `group = NULL`.
#' @param point_alpha Punkternas opacitet (0–1).
#' @param title_size Rubrikens teckenstorlek i punkter.
#' @param caption_size Teckenstorlek för `caption` i punkter.
#' @param legend_title Förklaringens rubrik.
#' @param legend_breaks Önskat antal steg i förklaringen. `NULL` = automatiskt.
#' @param legend_format Talformat i förklaringen: `"number"` (undviker
#'   vetenskaplig notation) eller `"auto"` (ggplot2:s standard).
#' @param bbox_padding Marginal runt kartutsnittet som andel av utbredningen,
#'   så att konturerna inte klipps (typiskt 0,04–0,06; 0 = ingen).
#' @param element_road `sf`-lager med vägar. `NULL` = inget.
#' @param element_ocean `sf`-lager med hav. `NULL` = inget.
#' @param element_lake `sf`-lager med sjöar. `NULL` = inget.
#' @param element_municipality_names `sf`-lager med kommunnamn i kolumnen
#'   `Kommunnamn`. `NULL` = inga namn.
#' @param font Typsnitt, t.ex. `"Verdana"`, `"Arial"`, `"sans"`. Används
#'   `"sans"` om typsnittet saknas.
#' @param debug `TRUE` returnerar en lista med data, kartutsnitt och
#'   grupper i stället för diagrammet.
#' @param ... Argument som skickas vidare till `func_graf_karta_heatmap()`.
#'
#' @return Ett `ggplot`-objekt, eller en lista om `debug = TRUE`.
#' @seealso [func_graf_heatmap_coordinats()], [func_graf_karta()]
#' @export
#'
#' @example inst/examples/func_graf_karta_heatmap.R
func_graf_karta_heatmap <- function(
    # === REQUIRED PARAMETERS ===
  df,                                      # Data frame: Must be sf object with point geometries
  df_value,                                # Character: Column name with numeric values for coloring points
  basemap,                                 # sf object: Background map (e.g., municipality/region boundaries)
  
  # === GROUPING ===
  group = NULL,                            # Character: Column name for categorizing points (e.g., "category", "type") | NULL = no grouping
  colors = func_fargtema("ru"),            # Vector: Point colors per group (only used when group is set) | NULL = func_fargtema("ru") | unnamed = assigned
                                           #   in group order (factor levels, unused dropped; numeric sorted; else first appearance; recycled if too few),
                                           #   named = matched by group name, e.g. c("Industri" = "#1a9fb3") | NA group is drawn grey50

  # === MAP STYLING ===
  basemap_color = "white",                 # Character: Fill color for background map areas
  basemap_color_line = "#969696",          # Character: Border color for background map areas
  
  # === HEATMAP SETTINGS ===
  adjust_value = 0.5,                      # Numeric: Bandwidth adjustment for density estimation | Lower = tighter clusters, Higher = smoother
  heatmap_alpha = 0.5,                     # Numeric: Transparency of heatmap polygons | Range: 0 (invisible) to 1 (solid)
  bins = 10,                               # Numeric: Number of contour levels in heatmap | Typical: 5-15
  low_color = "black",                     # Character: Color for lowest density areas | Hex code or color name
  high_color = "red",                      # Character: Color for highest density areas | Hex code or color name
  
  # === POINTS DISPLAY ===
  show_points = TRUE,                      # Logical: Show individual data points on map | TRUE/FALSE
  point_size = 2,                          # Numeric: Size of data points | Typical: 1-5
  point_color = "black",                   # Character: Color of data points | Hex code or color name
  point_alpha = 1,                         # Numeric: Transparency of data points | Range: 0 (invisible) to 1 (solid)
  
  # === TITLE AND TEXT ===
  title = NULL,                            # Character: Main map title | NULL = no title
  text_scale = 1,                          # Numeric: Multiplies every text size (title, subtitle, caption, legend, municipality names) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                         # Numeric: Title font size in points | Typical: 14-18 (before 2026-10-01: 22)
  title_text_size = 16,                    # Numeric: Alias for title_size (kept for backward compatibility)
  title_width = 100,                       # Numeric: Title wrap width in characters | Typical: 80-120
  title_margin_top = 2,                    # Numeric: Top margin above title in points
  title_position = "plot",                 # Character: Title position | Options: "plot" (full width), "panel" (over map)
  subtitle = NULL,                         # Character: Subtitle text below title | NULL = no subtitle
  subtitle_text_size = 13,                 # Numeric: Subtitle font size in points | Typical: 11-14 (before 2026-10-01: 18)
  caption = NULL,                          # Character: Caption text at bottom | NULL = no caption
  caption_size = 10,                       # Numeric: Caption font size in points | Typical: 8-11 (before 2026-10-01: 18)
  caption_text_size = 10,                  # Numeric: Alias for caption_size (kept for backward compatibility)
  
  # === MAP MARGINS ===
  margin_top = 5,                          # Numeric: Top margin in points
  margin_right = 5,                        # Numeric: Right margin in points
  margin_bottom = 5,                       # Numeric: Bottom margin in points
  margin_left = 5,                         # Numeric: Left margin in points
  
  # === LEGEND ===
  legend_title = NULL,                     # Character: Legend title | NULL = uses df_value or group column name
  legend_name = NULL,                      # Character: Alias for legend_title (kept for backward compatibility)
  legend_position = "none",                # Character: Legend placement | Options: "none", "top", "bottom", "left", "right"
  legend_text_size = 11,                   # Numeric: Legend text size in points | Typical: 9-14 (before 2026-10-01: 16)
  legend_key_shape = "square",             # Character: Legend icon shape | Options: "square", "circle"
  legend_breaks = NULL,                    # Numeric: Number of legend breaks | NULL = auto (typically 5), e.g., 4, 6, 8
  legend_format = "number",                # Character: Number format | Options: "number" (avoid scientific), "auto" (ggplot default)
  
  # === BBOX EXPANSION ===
  bbox_padding = 0.05,                     # Numeric: Padding around bbox to prevent contour cutoff | Range: 0-0.1 | Typical: 0.04-0.06 | Set to 0 for no padding
  
  # === ADDITIONAL LAYERS ===
  element_road = NULL,                     # sf object: Road layer for map
  element_ocean = NULL,                    # sf object: Ocean/water layer for map
  element_lake = NULL,                     # sf object: Lake layer for map
  element_municipality_names = NULL,       # sf object: Municipality names layer with "Kommunnamn" column
  
  # === ADVANCED ===
  font = "Verdana",                        # Character: Font family | Options: "Verdana", "Arial", "sans", "serif", "mono"
  debug = FALSE                            # Logical: Return debug info instead of plot | TRUE/FALSE
) {
  
  # === SETUP ===
  
  # Validate font using systemfonts (same approach as line chart function)
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
    message("Available fonts include: Arial, Calibri, Times New Roman, Verdana, etc.")
    message("Run: View(systemfonts::system_fonts()) to see all available fonts")
    font_to_use <- "sans"
  }
  
  font <- font_to_use
  registrera_typsnitt(font)  # så att Windows- och PDF-enheterna hittar typsnittet (se zzz.R)

  # Resolve alternative parameter names (last-one-wins if both are supplied)
  title_size_final   <- if (!missing(title_text_size))   title_text_size   else title_size
  caption_size_final <- if (!missing(caption_text_size)) caption_text_size else caption_size

  # text_scale: one factor for every text size
  title_size_final   <- title_size_final   * text_scale
  caption_size_final <- caption_size_final * text_scale
  subtitle_text_size <- subtitle_text_size * text_scale
  legend_text_size   <- legend_text_size   * text_scale
  legend_title_final <- if (!missing(legend_name))       legend_name       else legend_title

  # === VALIDATE INPUTS ===
  if (is.null(df) || nrow(df) == 0) stop("Error: 'df' must be a non-empty data frame")
  if (!df_value %in% names(df)) stop(paste("Error: Column", df_value, "not found in df"))
  if (!is.null(group) && !group %in% names(df)) stop(paste("Error: Column", group, "not found in df"))

  # === GROUP COLORS (same rule in linjediagram, stapeldiagram, karta and karta_heatmap) ===
  # Factor: its level order, unused levels dropped. Numeric: sorted. Otherwise: order of first appearance.
  # NA never takes a color slot (drawn grey50, ggplot's na.value)
  group_levels  <- NULL
  color_mapping <- NULL
  if (!is.null(group)) {
    if (is.numeric(df[[group]])) df[[group]] <- factor(df[[group]])
    group_levels <- if (is.factor(df[[group]])) setdiff(levels(droplevels(df[[group]])), NA)
                    else unique(stats::na.omit(as.character(df[[group]])))
    if (is.null(colors)) colors <- func_fargtema("ru")
    if (!is.null(names(colors))) {
      missing_groups <- setdiff(group_levels, names(colors))
      if (length(missing_groups) > 0) stop("colors is named but has no color for: ", toString(missing_groups))
      color_mapping <- colors[group_levels]
    } else {
      color_mapping <- setNames(rep(colors, length.out = length(group_levels)), group_levels)
    }
  }

  # === PREPARE DATA ===
  # Ensure same CRS
  df <- st_transform(df, crs = st_crs(basemap))
  
  # Extract coordinates
  df <- df %>%
    mutate(data_x = st_coordinates(.)[, 1],
           data_y = st_coordinates(.)[, 2])
  
  if (any(is.na(df$data_x)) || any(is.na(df$data_y))) {
    stop("Error: Coordinates contain missing values")
  }
  
  # === CALCULATE BOUNDING BOX ===
  # Calculate bbox from basemap only (not ocean/lake which extend beyond area of interest)
  # This ensures a zoomed-in view focused on the basemap extent
  bbox <- st_bbox(basemap)
  
  # Add explicit padding for density contours (coord_sf uses expand=FALSE for precise control)
  # Default 5% padding accommodates kernel density spread beyond data points
  # Adjust bbox_padding parameter if you see contour cutoff (increase) or excessive whitespace (decrease)
  if (bbox_padding > 0) {
    x_range <- bbox["xmax"] - bbox["xmin"]
    y_range <- bbox["ymax"] - bbox["ymin"]
    padding_x <- x_range * bbox_padding
    padding_y <- y_range * bbox_padding
    
    bbox["xmin"] <- bbox["xmin"] - padding_x
    bbox["xmax"] <- bbox["xmax"] + padding_x
    bbox["ymin"] <- bbox["ymin"] - padding_y
    bbox["ymax"] <- bbox["ymax"] + padding_y
  }
  
  # Debug output
  if (debug) {
    return(list(
      data = df,
      bbox = bbox,
      bbox_padding_applied = bbox_padding,
      group_levels = group_levels,
      n_points = nrow(df)
    ))
  }
  
  # stat_density_2d gives points per map unit squared: per m² in SWEREF 99 TM (~1e-7, long legend
  # labels that overlapped in a horizontal legend), per square degree in WGS 84. Show points per
  # km² instead, keeping the map's own CRS: measure how many map units² one km² covers, using a
  # 1 x 1 km equal-area square at the centre of the points. Exact for metric CRSs; for degrees it
  # holds at the centre (a square degree shrinks towards the poles).
  km2_i_kartenheter <- function() {
    centrum <- st_bbox(st_transform(st_geometry(df), 4326))
    laea <- sprintf("+proj=laea +lat_0=%.6f +lon_0=%.6f +units=m",
                    mean(centrum[c("ymin", "ymax")]), mean(centrum[c("xmin", "xmax")]))
    ruta <- st_sfc(st_polygon(list(rbind(c(-500, -500), c(500, -500), c(500, 500),
                                         c(-500, 500), c(-500, -500)))), crs = laea)
    xy <- st_coordinates(st_transform(ruta, st_crs(df)))[, 1:2]
    abs(sum(xy[-nrow(xy), 1] * xy[-1, 2] - xy[-1, 1] * xy[-nrow(xy), 2])) / 2  # shoelace area
  }
  dens_skala <- km2_i_kartenheter()

  # === CREATE BASE PLOT ===
  p <- ggplot(df) +
    # Basemap
    {if (!is.null(basemap)) geom_sf(data = basemap, fill = basemap_color, color = basemap_color_line)} +
    
    # Additional layers
    {if (!is.null(element_road)) geom_sf(data = element_road, fill = "#5e5e5e", color = "#5e5e5e")} +
    {if (!is.null(element_ocean)) geom_sf(data = element_ocean, fill = "#b5c7eb", color = "#b5c7eb")} +
    {if (!is.null(element_lake)) geom_sf(data = element_lake, fill = "#b5c7eb", color = "#b5c7eb")} +
    
    # Heatmap density
    stat_density_2d(
      aes(x = data_x, y = data_y, fill = after_stat(level * dens_skala)),
      bins = bins,
      geom = "polygon",
      contour_var = "count",
      adjust = adjust_value,
      show.legend = (legend_position != "none"),
      alpha = heatmap_alpha
    )
  
  # Color scale for heatmap with better number formatting
  if (legend_format == "number") {
    p <- p + scale_fill_gradient(
      low = low_color,
      high = high_color,
      name = legend_title_final,
      # waiver() = ggplot2's default breaks; NULL would remove all breaks and leave the legend empty
      breaks = if (!is.null(legend_breaks)) scales::breaks_pretty(n = legend_breaks) else waiver(),
      labels = function(x) {
        # Avoid scientific notation and format numbers readably
        if (max(abs(x), na.rm = TRUE) < 1) {
          # Small numbers: two significant digits. A fixed 5 decimals printed "0.00000" for
          # projected data (e.g. SWEREF 99 TM), where density per square metre is ~1e-8.
          # One value at a time, since format() on a vector pads to a common width.
          vapply(x, function(v) if (is.na(v)) NA_character_ else
            format(signif(v, 2), scientific = FALSE, decimal.mark = ",", trim = TRUE,
                   drop0trailing = TRUE), character(1))
        } else {
          # For regular numbers, use non-breaking space as thousands separator
          format(round(x, 2), big.mark = " ", decimal.mark = ",", scientific = FALSE, trim = TRUE)
        }
      }
    )
  } else {
    p <- p + scale_fill_gradient(
      low = low_color,
      high = high_color,
      name = legend_title_final,
      breaks = if (!is.null(legend_breaks)) scales::breaks_pretty(n = legend_breaks) else waiver()
    )
  }
  
  # Add municipality names
  if (!is.null(element_municipality_names)) {
    p <- p + geom_sf_text(data = element_municipality_names, aes(label = Kommunnamn), 
                          color = "black", size = 2 * text_scale, family = font)   # map font, not the device default
  }
  
  # === ADD POINTS ===
  if (show_points) {
    if (!is.null(group)) {
      # Points colored by group
      p <- p + geom_sf(data = df, aes(color = !!sym(group)), 
                       size = point_size, alpha = point_alpha, show.legend = TRUE) +
        scale_color_manual(values = color_mapping, na.value = "grey50")
    } else {
      # Single color points
      p <- p + geom_sf(data = df, aes(color = as.numeric(!!sym(df_value))), 
                       size = point_size, alpha = point_alpha, show.legend = FALSE) +
        scale_color_gradient(low = point_color, high = point_color, guide = "none")  # show.legend = FALSE alone still drew a colorbar
    }
  }
  
  # === APPLY THEME AND STYLING ===
  p <- p +
    theme_void() +
    theme(
      text = element_text(family = font),
      plot.title = element_text(size = title_size_final, hjust = 0.5, family = font,
                                margin = margin(t = title_margin_top)),
      plot.title.position = title_position,
      plot.subtitle = element_text(size = subtitle_text_size, hjust = 0.5, family = font),
      plot.caption = element_text(hjust = 0.5, size = caption_size_final, family = font),
      legend.position = legend_position,
      legend.justification = c(0.5, 0.5),
      legend.text = element_text(size = legend_text_size, family = font),
      legend.title = element_text(size = legend_text_size, family = font),
      legend.spacing.x = unit(0.5, "cm"),        # Horizontal spacing between legend items
      legend.spacing.y = unit(0.3, "cm"),        # Vertical spacing between legend rows
      legend.key.width = unit(1.5, "cm"),        # Width of legend keys
      legend.key.height = unit(0.5, "cm"),       # Height of legend keys
      legend.box.spacing = unit(0.5, "cm"),      # Space between legend and plot
      plot.margin = margin(t = margin_top, r = margin_right, 
                           b = margin_bottom, l = margin_left)
    ) +
    labs(
      title = if (!is.null(title)) str_wrap(title, width = title_width) else NULL,
      subtitle = subtitle,
      caption = caption,
      fill = legend_title_final,
      color = if (!is.null(group)) (legend_title_final %||% group) else NULL
    ) +
    coord_sf(
      xlim = c(bbox["xmin"], bbox["xmax"]),
      ylim = c(bbox["ymin"], bbox["ymax"]),
      expand = FALSE
    )
  
  # Add legend shape customization for group points
  if (!is.null(group) && show_points && legend_key_shape == "circle") {
    p <- p + guides(color = guide_legend(override.aes = list(shape = 21, size = 6, stroke = 0.5)))
  }
  
  return(p)
}

# Backward-compatible alias: original function name lacked the func_ prefix
#' @rdname func_graf_karta_heatmap
#' @export
graf_karta_heatmap <- function(...) func_graf_karta_heatmap(...)
