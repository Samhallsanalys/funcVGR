#' Spridningsdiagram
#'
#' Spridningsdiagram (punktdiagram) i VGR:s stil: ett numeriskt värde på x-axeln
#' mot ett på y-axeln, en punkt per rad. Punkterna kan färgas efter grupp, få
#' storlek efter en tredje kolumn (bubbeldiagram) och namnges med etiketter.
#' En trendlinje (linjär regression) och referenslinjer, t.ex. vid medelvärdet,
#' visar sambandet och var punkterna ligger i förhållande till varandra.
#' Diagrammet kan delas upp i paneler. Siffror formateras på svenska.
#' `func_graf_scatterplot()` är samma funktion under ett engelskt namn.
#'
#' @inheritParams func_graf_linjediagram
#' @param df Data frame med en rad per punkt. Ett `sf`-objekt går också bra
#'   (geometrin används inte). Obligatorisk.
#' @param x_value Namn på den numeriska kolumnen för x-axeln, som text.
#'   Obligatorisk.
#' @param y_value Namn på den numeriska kolumnen för y-axeln, som text.
#'   Obligatorisk.
#' @param group Kolumn som punkterna färgas efter. `NULL` = en färg för alla.
#' @param facet_same_y_scale Samma y-skala i alla paneler. Används bara när
#'   `facet_scales` inte anges (som i [func_graf_barchart()]); `FALSE` ger fri y-axel.
#' @param facet_scales Panelernas axelskalor: `"fixed"` (samma skalor, så att
#'   panelerna går att jämföra), `"free"`, `"free_x"` eller `"free_y"`.
#' @param colors Färger för grupperna, med samma regler som i
#'   [func_graf_linjediagram()]. Utan `group` används den första färgen.
#'   `NULL` = viridis-färger för grupperna (utan `group`: blått, `"#2E86AB"`).
#' @param data_label_color Etiketternas färg, eller `"auto"` för punktens
#'   färg (gruppens färg med `group`).
#' @param legend_position Förklaringens placering: `"right"`, `"left"`,
#'   `"top"`, `"bottom"` eller `"none"`. Anges den inte blir det `"right"` med
#'   `group` eller `point_size_column`, annars `"none"`.
#' @param point_size Punkternas storlek (ggplot2:s storleksenhet). Används när
#'   `point_size_column` inte anges.
#' @param point_alpha Punkternas opacitet (0–1). Ett lägre värde visar var
#'   många punkter ligger på varandra.
#' @param point_size_column Numerisk kolumn som styr punkternas storlek
#'   (bubbeldiagram), t.ex. befolkning. Punktens yta växer med värdet.
#'   `NULL` = alla punkter lika stora.
#' @param point_size_range Minsta och största punktstorlek med
#'   `point_size_column`, som en vektor av längd 2.
#' @param point_size_title Rubrik för storleksförklaringen. `NULL` =
#'   kolumnnamnet i `point_size_column`.
#' @param point_border_color Färg på en kantlinje runt punkterna, t.ex.
#'   `"white"` så att punkter som överlappar skiljs åt. `NULL` = ingen
#'   kantlinje.
#' @param show_major_grid,show_minor_grid Större respektive mindre stödlinjer:
#'   `TRUE` = i båda riktningarna, `FALSE` = inga, `"y"` = bara vågräta linjer,
#'   `"x"` = bara lodräta linjer.
#' @param trend_line Trendlinje från en linjär regression (`lm`): `FALSE` =
#'   ingen, `TRUE` = en linje för alla punkter (per panel), `"group"` = en
#'   linje per grupp i gruppens färg (kräver `group`). En linje ritas bara där
#'   det finns minst tre punkter med olika x-värden.
#' @param trend_line_se Visa ett 95-procentigt konfidensband runt
#'   trendlinjen.
#' @param trend_line_color Trendlinjens färg när `trend_line = TRUE`.
#' @param trend_line_size Trendlinjens tjocklek.
#' @param x_break_line Lodrät, streckad referenslinje: ett eller flera tal, `"mean"`
#'   (medelvärdet av x för alla punkter) eller `"median"`. `NULL` = ingen.
#' @param y_break_line Vågrät referenslinje: ett eller flera tal, `"mean"` eller
#'   `"median"` av y. `NULL` = ingen.
#' @param data_labels Visa etiketter vid punkterna.
#' @param data_label_column Kolumn med etiketternas text, t.ex. kommunnamn.
#'   `NULL` = y-värdet, se `data_label_format`.
#' @param data_label_filter Visa etiketter bara för punkter vars värde i
#'   `data_label_column` finns i vektorn, t.ex. `c("Borås", "Skövde")`. `NULL`
#'   = alla punkter.
#' @param data_label_format När `data_label_column` saknas: `"value_only"`
#'   visar y-värdet och `"x_y"` visar `"x; y"` (`"both"` ger samma).
#' @param data_label_decimals Antal decimaler för tal i etiketterna.
#' @param data_label_box Visa en ruta bakom etiketterna. `FALSE` (standard)
#'   ger bara text, vilket blir luftigare när punkterna är många.
#' @param data_label_max_overlaps Största antal överlapp innan \pkg{ggrepel}
#'   hoppar över en etikett. `Inf` visar alla etiketter.
#' @param x_axis_min,x_axis_max,y_axis_min,y_axis_max Min- och maxvärde för
#'   axlarna. `NULL` = automatiskt.
#' @param x_number_format Format för x-axelns tal: `"thousands"` (mellanslag
#'   som tusentalsavgränsare, t.ex. 12 000) eller `"whole"` (utan avgränsare,
#'   t.ex. årtal).
#'
#' @return Ett `ggplot`-objekt, en lista om `debug = TRUE`, eller `NULL` (med
#'   varning) om `df` saknar rader.
#' @seealso [func_graf_linjediagram()], [func_graf_histogram()]
#' @export
#'
#' @example inst/examples/func_graf_spridningsdiagram.R
func_graf_spridningsdiagram <- function(
  # === REQUIRED PARAMETERS ===
  df,                                   # Data frame: Your dataset, one point per row (an sf object also works)
  x_value,                              # Character: Column name for the x-axis (numeric)
  y_value,                              # Character: Column name for the y-axis (numeric)

  # === GROUPING AND FACETING ===
  group = NULL,                         # Character: Column for coloring points by category (NULL = one color)
  facet_var = NULL,                     # Character: Column for separate subplot panels (NULL = no facets)
  facet_ncol = NULL,                    # Numeric: Number of columns for facets (NULL = auto-calculated)
  facet_scales = "fixed",               # Character: Axis scales across facets - "fixed" (comparable panels), "free", "free_x", "free_y"
  facet_same_y_scale = TRUE,            # Logical: Same y-axis in all panels | Only applies when facet_scales is not given (as func_graf_barchart) | FALSE = free y-axis
  facet_title_size = 12,                # Numeric: Facet panel title size in points
  facet_title_wrap = NULL,              # Numeric: Wrap facet titles at N characters (NULL = no wrapping)

  # === TITLES AND LABELS ===
  title = NULL,                         # Character: Main plot title (NULL = no title)
  title_width = 100,                    # Numeric: Title wrap width in characters
  subtitle = NULL,                      # Character: Plot subtitle (NULL = no subtitle)
  subtitle_width = 100,                 # Numeric: Subtitle wrap width in characters
  caption = NULL,                       # Character: Plot caption/footer (NULL = no caption)
  x_axis_title = NULL,                  # Character: X-axis label (NULL = no label)
  y_axis_title = NULL,                  # Character: Y-axis label (NULL = no label)
  legend_title = NULL,                  # Character: Color legend title (NULL = group column name)

  # === STYLING ===
  colors = func_fargtema("ru"),         # Vector: Colors for groups, same rules as func_graf_linjediagram (NULL = viridis) | without group: the first color
  font = "Verdana",                     # Character: Font family name - installed font, or "sans", "serif", "mono"

  # === POINTS ===
  point_size = 2.5,                     # Numeric: Point size (ggplot size units) - used when point_size_column is NULL
  point_alpha = 0.8,                    # Numeric: Point opacity, 0-1 - lower shows where points overlap
  point_size_column = NULL,             # Character: Numeric column that sets point size (bubble chart), e.g. population (NULL = equal size)
  point_size_range = c(1.5, 10),        # Numeric(2): Smallest and largest point size with point_size_column
  point_size_title = NULL,              # Character: Size legend title (NULL = point_size_column name)
  point_border_color = NULL,            # Character: Outline color around points, e.g. "white" to separate overlapping points (NULL = no outline)

  # === TEXT SIZING (in points) ===
  text_scale = 1,                       # Numeric: Multiplies every text size (titles, axes, legend, facet titles, data labels) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                      # Numeric: Title font size
  subtitle_size = 13,                   # Numeric: Subtitle font size
  caption_size = 10,                    # Numeric: Caption font size
  x_axis_text_size = 11,                # Numeric: X-axis tick label font size
  y_axis_text_size = 11,                # Numeric: Y-axis tick label font size
  legend_text_size = 11,                # Numeric: Legend text font size

  # === LAYOUT ===
  legend_position = "none",             # Character: Legend placement - "right", "left", "top", "bottom", "none" (not set: "right" with group or point_size_column)
  show_major_grid = FALSE,              # Logical/Character: Major grid lines | TRUE = both directions, FALSE = none, "y" = horizontal only, "x" = vertical only
  show_minor_grid = FALSE,              # Logical/Character: Minor grid lines | Same options as show_major_grid
  x_axis_line = TRUE,                   # Logical: Draw a line along the x-axis (TRUE/FALSE)
  y_axis_line = TRUE,                   # Logical: Draw a line along the y-axis (TRUE/FALSE)

  # === TREND AND REFERENCE LINES ===
  trend_line = FALSE,                   # Logical/Character: Linear trend line (lm) - FALSE = none, TRUE = one line for all points (per panel), "group" = one per group
  trend_line_se = FALSE,                # Logical: Show a 95 % confidence band around the trend line (TRUE/FALSE)
  trend_line_color = "grey30",          # Character: Trend line color when trend_line = TRUE (per-group lines use the group colors)
  trend_line_size = 0.8,                # Numeric: Trend line thickness
  x_break_line = NULL,                  # Numeric/Character: Vertical dashed reference line - a number, "mean" or "median" of x (NULL = no line)
  y_break_line = NULL,                  # Numeric/Character: Horizontal reference line - a number, "mean" or "median" of y (NULL = no line)

  # === DATA LABELS ===
  data_labels = FALSE,                  # Logical: Show labels next to the points (TRUE/FALSE)
  data_label_column = NULL,             # Character: Column with the label text, e.g. municipality name (NULL = the y value, see data_label_format)
  data_label_filter = NULL,             # Vector: Label only points whose data_label_column value is in this vector, e.g. c("Borås", "Skövde") (NULL = all)
  data_label_format = "value_only",     # Character: Without data_label_column - "value_only" (y) or "x_y" (shows "x; y")
  data_label_decimals = 0,              # Numeric: Decimal places for numbers in labels
  data_label_text_size = 3.5,           # Numeric: Label font size in mm (ggplot text units; 3.5 mm ≈ 10 pt)
  data_label_color = "black",           # Character: Label text color - "auto" (match point color) or any color/hex
  data_label_repel = TRUE,              # Logical: Use ggrepel so labels don't overlap points or each other (TRUE/FALSE)
  data_label_max_overlaps = 10,         # Numeric: ggrepel skips a label after this many overlaps (Inf = show all)
  data_label_box = FALSE,               # Logical: Add a background box to labels (FALSE = plain text, airier with many points)
  data_label_box_color = "white",       # Character: Label box background color (only when data_label_box = TRUE)
  data_label_box_alpha = 0.8,           # Numeric: Label box transparency, 0-1 (only when data_label_box = TRUE)

  # === AXIS LIMITS AND FORMAT ===
  x_axis_min = NULL,                    # Numeric: Minimum x-axis value (NULL = auto)
  x_axis_max = NULL,                    # Numeric: Maximum x-axis value (NULL = auto)
  y_axis_min = NULL,                    # Numeric: Minimum y-axis value (NULL = auto)
  y_axis_max = NULL,                    # Numeric: Maximum y-axis value (NULL = auto)
  x_number_format = "thousands",        # Character: X-axis numbers - "thousands" (space separator, e.g. 12 000) or "whole" (no separator, e.g. years)

  # === ADVANCED ===
  custom_theme = NULL,                  # ggplot2 theme object: Appended after default theme (NULL = use default only)
  debug = FALSE                         # Logical: TRUE returns a list of diagnostics instead of the plot
) {

  # --- Font validation ---
  font <- valj_typsnitt(font)   # installed, or "sans"/"serif"/"mono"; otherwise "sans" (see zzz.R)

  # --- text_scale: one factor for every text size ---
  title_size           <- title_size           * text_scale
  subtitle_size        <- subtitle_size        * text_scale
  caption_size         <- caption_size         * text_scale
  x_axis_text_size     <- x_axis_text_size     * text_scale
  y_axis_text_size     <- y_axis_text_size     * text_scale
  legend_text_size     <- legend_text_size     * text_scale
  facet_title_size     <- facet_title_size     * text_scale
  data_label_text_size <- data_label_text_size * text_scale

  # A legend is only useful when something is mapped to colour or size
  if (missing(legend_position) && (!is.null(group) || !is.null(point_size_column))) legend_position <- "right"

  # --- Input checks ---
  df_work <- if (inherits(df, "sf")) sf::st_drop_geometry(df) else as.data.frame(df)
  required_cols <- c(x_value, y_value, group, facet_var, point_size_column, data_label_column)
  missing_cols  <- setdiff(required_cols, names(df_work))
  if (length(missing_cols) > 0) stop("Missing columns in data: ", paste(missing_cols, collapse = ", "))
  if (!is.numeric(df_work[[x_value]])) stop("x_value must be a numeric column: ", x_value)
  if (!is.numeric(df_work[[y_value]])) stop("y_value must be a numeric column: ", y_value)
  if (!is.null(point_size_column) && !is.numeric(df_work[[point_size_column]]))
    stop("point_size_column must be a numeric column: ", point_size_column)
  # facet_scales wins when given; otherwise facet_same_y_scale = FALSE frees the y-axis (as func_graf_barchart)
  if (missing(facet_scales) && !facet_same_y_scale) facet_scales <- "free_y"
  facet_scales <- match.arg(facet_scales, c("fixed", "free", "free_x", "free_y"))
  data_label_format <- match.arg(data_label_format, c("value_only", "x_y", "both"))   # "both" = "x_y", som i func_graf_linjediagram
  grid_ok <- function(v) isTRUE(v) || isFALSE(v) || identical(v, "x") || identical(v, "y")
  if (!grid_ok(show_major_grid)) stop("show_major_grid must be TRUE, FALSE, \"x\" or \"y\"")
  if (!grid_ok(show_minor_grid)) stop("show_minor_grid must be TRUE, FALSE, \"x\" or \"y\"")
  if (!(isTRUE(trend_line) || isFALSE(trend_line) || identical(trend_line, "group")))
    stop("trend_line must be TRUE, FALSE or \"group\"")
  if (identical(trend_line, "group") && is.null(group)) {
    warning("trend_line = \"group\" needs group - drawing one trend line for all points instead")
    trend_line <- TRUE
  }

  # Points without both an x and a y value (or without a size) can't be drawn
  drawable <- is.finite(df_work[[x_value]]) & is.finite(df_work[[y_value]]) &
              (if (!is.null(point_size_column)) is.finite(df_work[[point_size_column]]) else TRUE)
  if (any(!drawable)) {
    message(sprintf("func_graf_spridningsdiagram: %d rows without x, y%s value left out", sum(!drawable),
                    if (!is.null(point_size_column)) " or size" else ""))
    df_work <- df_work[drawable, , drop = FALSE]
  }
  if (nrow(df_work) == 0) {
    warning("func_graf_spridningsdiagram: no rows to draw. Check your filter and the x/y columns. Returning NULL.")
    return(NULL)
  }

  # --- Facet text wrapping (same as func_graf_linjediagram) ---
  if (!is.null(facet_var) && !is.null(facet_title_wrap) && facet_title_wrap > 0) {
    df_work[[facet_var]] <- str_wrap(as.character(df_work[[facet_var]]), facet_title_wrap)
  }
  if (!is.null(facet_var) && !is.factor(df_work[[facet_var]]))
    df_work[[facet_var]] <- factor(df_work[[facet_var]], levels = unique(df_work[[facet_var]]))

  # --- Group order and colors (same rule as func_graf_linjediagram, so the same data gets the same colors) ---
  # Numbers are grouped as categories; factor = its level order, otherwise order of first appearance
  if (!is.null(group) && is.numeric(df_work[[group]])) df_work[[group]] <- factor(df_work[[group]])
  group_levels  <- NULL
  color_mapping <- NULL
  if (!is.null(group)) {
    group_levels <- if (is.factor(df_work[[group]])) setdiff(levels(droplevels(df_work[[group]])), NA)
                    else unique(stats::na.omit(as.character(df_work[[group]])))
    if (is.null(colors)) colors <- viridisLite::viridis(length(group_levels), option = "D")
    if (!is.null(names(colors))) {
      # Named colors: matched by group name
      missing_groups <- setdiff(group_levels, names(colors))
      if (length(missing_groups) > 0) stop("colors is named but has no color for: ", toString(missing_groups))
      color_mapping <- colors[group_levels]
    } else {
      # Unnamed colors: assigned in group order, recycled if too few
      color_mapping <- stats::setNames(rep(colors, length.out = length(group_levels)), group_levels)
    }
  }
  point_color <- if (!is.null(colors)) unname(colors[1]) else "#2E86AB"   # single color without group

  # --- Reference line positions: a number, or the mean/median of all drawn points ---
  break_position <- function(value, column) {
    if (is.null(value)) return(NULL)
    if (identical(value, "mean"))   return(mean(df_work[[column]]))
    if (identical(value, "median")) return(stats::median(df_work[[column]]))
    if (!is.numeric(value)) stop("x_break_line / y_break_line must be a number, \"mean\" or \"median\"")
    value
  }
  x_line <- break_position(x_break_line, x_value)
  y_line <- break_position(y_break_line, y_value)

  # --- Trend lines: lm(y ~ x) per panel (and per group with "group"), 80 points across each part's x range ---
  # Computed here rather than with geom_smooth(), so the D3 version can draw exactly the same lines
  trend_df <- NULL
  if (!isFALSE(trend_line)) {
    trend_by <- c(facet_var, if (identical(trend_line, "group")) group)
    parts    <- if (length(trend_by) > 0) split(df_work, df_work[trend_by], drop = TRUE) else list(df_work)
    trend_df <- do.call(rbind, lapply(parts, function(d) {
      if (length(unique(d[[x_value]])) < 3) return(NULL)   # a line through fewer distinct x values says nothing
      fit  <- stats::lm(d[[y_value]] ~ d[[x_value]])
      xs   <- seq(min(d[[x_value]]), max(d[[x_value]]), length.out = 80)
      pred <- cbind(1, xs) %*% stats::coef(fit)
      # 95 % confidence band for the fitted line: t * standard error of the prediction
      se   <- sqrt(rowSums((cbind(1, xs) %*% stats::vcov(fit)) * cbind(1, xs)))
      t95  <- stats::qt(0.975, df = fit$df.residual)
      out  <- data.frame(.x = xs, .y = as.vector(pred), .lo = as.vector(pred) - t95 * se, .hi = as.vector(pred) + t95 * se)
      for (b in trend_by) out[[b]] <- d[[b]][1]
      out$.trend_id <- paste(vapply(trend_by, function(b) as.character(d[[b]][1]), character(1)), collapse = "\r")
      out
    }))
  }

  # --- Debug mode ---
  if (debug) return(list(
    data = df_work, group_levels = group_levels, color_mapping = color_mapping,
    x_break_line = x_line, y_break_line = y_line, trend = trend_df, legend_position = legend_position
  ))

  # ============================================================
  #  BASE PLOT, TREND BAND, REFERENCE LINES, POINTS, TREND LINES
  # ============================================================
  p <- ggplot(df_work, aes(x = .data[[x_value]], y = .data[[y_value]]))
  per_group_trend <- identical(trend_line, "group")

  # Confidence band first, so the points are drawn on top of it
  if (!is.null(trend_df) && trend_line_se) {
    band_aes <- if (per_group_trend) aes(x = .x, ymin = .lo, ymax = .hi, group = .trend_id, fill = .data[[group]])
                else aes(x = .x, ymin = .lo, ymax = .hi, group = .trend_id)
    band_args <- list(data = trend_df, mapping = band_aes, inherit.aes = FALSE, alpha = 0.15, show.legend = FALSE)
    if (!per_group_trend) band_args$fill <- trend_line_color
    p <- p + do.call(geom_ribbon, band_args)
  }

  # Reference lines behind the points (same styles as func_graf_linjediagram)
  if (!is.null(x_line)) p <- p + geom_vline(xintercept = x_line, linewidth = 0.5, linetype = "dashed", color = "black")
  if (!is.null(y_line)) p <- p + geom_hline(yintercept = y_line, linewidth = 0.5, linetype = "solid",  color = "black")

  # Points: colour by group and/or size by column. With an outline the point is a filled circle (shape 21) whose
  # fill carries the group colour; otherwise a solid circle (shape 16) whose colour does
  with_border <- !is.null(point_border_color)
  point_aes <- aes()
  if (!is.null(group)) point_aes[[if (with_border) "fill" else "colour"]] <- rlang::quo(.data[[group]])
  if (!is.null(point_size_column)) point_aes$size <- rlang::quo(.data[[point_size_column]])
  point_args <- list(mapping = point_aes, alpha = point_alpha, shape = if (with_border) 21 else 16)
  if (with_border) { point_args$colour <- point_border_color; point_args$stroke <- 0.4 }
  if (is.null(group)) point_args[[if (with_border) "fill" else "colour"]] <- point_color
  if (is.null(point_size_column)) point_args$size <- point_size
  p <- p + do.call(geom_point, point_args)

  # Trend lines on top of the points
  if (!is.null(trend_df)) {
    line_aes  <- if (per_group_trend) aes(x = .x, y = .y, group = .trend_id, colour = .data[[group]])
                 else aes(x = .x, y = .y, group = .trend_id)
    line_args <- list(data = trend_df, mapping = line_aes, inherit.aes = FALSE, linewidth = trend_line_size,
                      show.legend = FALSE)
    if (!per_group_trend) line_args$colour <- trend_line_color
    p <- p + do.call(geom_line, line_args)
  }

  # ============================================================
  #  DATA LABELS
  # ============================================================
  if (data_labels) {
    df_labels <- df_work
    if (!is.null(data_label_filter)) {
      if (is.null(data_label_column)) stop("data_label_filter needs data_label_column (the values are matched against it)")
      df_labels <- df_labels[df_labels[[data_label_column]] %in% data_label_filter, , drop = FALSE]
    }
    fmt <- function(v) format(round(v, data_label_decimals), big.mark = " ", decimal.mark = ",",
                              nsmall = data_label_decimals, trim = TRUE, scientific = FALSE)
    df_labels$label_text <- if (!is.null(data_label_column)) as.character(df_labels[[data_label_column]])
      else if (data_label_format %in% c("x_y", "both")) paste0(fmt(df_labels[[x_value]]), "; ", fmt(df_labels[[y_value]]))
      else fmt(df_labels[[y_value]])
    df_labels <- df_labels[!is.na(df_labels$label_text) & df_labels$label_text != "", , drop = FALSE]

    if (nrow(df_labels) > 0) {
      labels_use_color_aes <- data_label_color == "auto" && !is.null(group)
      label_aes <- if (labels_use_color_aes) aes(label = label_text, colour = .data[[group]]) else aes(label = label_text)
      label_args <- list(data = df_labels, mapping = label_aes, size = data_label_text_size, family = font,
                         show.legend = FALSE, na.rm = TRUE)
      if (!labels_use_color_aes) label_args$colour <- if (data_label_color == "auto") point_color else data_label_color
      if (data_label_repel) {
        # Labels pushed away from the points (seed: the same placement every time the chart is drawn)
        label_args <- c(label_args, list(max.overlaps = data_label_max_overlaps, box.padding = 0.4, point.padding = 0.3,
                                         force = 3, max.iter = 20000, max.time = 1,
                                         min.segment.length = 0.3, segment.color = "grey50", segment.size = 0.3, seed = 42))
      } else {
        label_args$vjust <- -0.8   # just above the point
      }
      if (data_label_box) {
        label_args <- c(label_args, list(fill = alpha(data_label_box_color, data_label_box_alpha)),
                        .label_border_off(if (data_label_repel) geom_label_repel else geom_label,
                                          if (data_label_repel) ggrepel::GeomLabelRepel else ggplot2::GeomLabel,
                                          label_size = NA))
        p <- p + do.call(if (data_label_repel) geom_label_repel else geom_label, label_args)
      } else {
        p <- p + do.call(if (data_label_repel) geom_text_repel else geom_text, label_args)
      }
    }
  }

  # ============================================================
  #  SCALES (each added once)
  # ============================================================
  if (!is.null(group)) {
    # Colour for points/labels/trend lines and fill for outlined points/bands share one legend (same name and values).
    # Each scale only when a layer maps to it: an unused manual scale gives a "No shared levels" warning
    group_name   <- legend_title %||% group
    uses_colour  <- !with_border || per_group_trend || (data_labels && data_label_color == "auto")
    uses_fill    <- with_border || (per_group_trend && trend_line_se)
    if (uses_colour) p <- p + scale_colour_manual(values = color_mapping, name = group_name)
    if (uses_fill)   p <- p + scale_fill_manual(values = color_mapping, name = group_name)
  }
  if (!is.null(point_size_column)) {
    p <- p + scale_size(range = point_size_range, name = point_size_title %||% point_size_column,
                        labels = label_number(big.mark = " ", decimal.mark = ","))
  }
  x_labels <- if (x_number_format == "whole") function(x) as.character(round(x)) else label_number(big.mark = " ", decimal.mark = ",")
  p <- p +
    scale_x_continuous(labels = x_labels, expand = expansion(mult = c(0.05, 0.05)),
                       # NA = automatic end, so only one of min/max can be given
                       limits = if (is.null(x_axis_min) && is.null(x_axis_max)) NULL else c(x_axis_min %||% NA, x_axis_max %||% NA)) +
    scale_y_continuous(labels = label_number(big.mark = " ", decimal.mark = ","), expand = expansion(mult = c(0.05, 0.05)),
                       limits = if (is.null(y_axis_min) && is.null(y_axis_max)) NULL else c(y_axis_min %||% NA, y_axis_max %||% NA))

  # --- Facets (same column rule as func_graf_linjediagram) ---
  if (!is.null(facet_var)) {
    n_facets <- length(unique(df_work[[facet_var]]))
    ncol_val <- facet_ncol %||% max(1L, if (n_facets <= 2) n_facets else if (n_facets <= 4) 2L else 3L)
    p <- p + facet_wrap(vars(.data[[facet_var]]), scales = facet_scales, ncol = ncol_val)
  }

  # ============================================================
  #  THEME AND STYLING (as func_graf_linjediagram)
  # ============================================================
  p <- p + theme_minimal() +
    theme(
      text                = element_text(family = font),
      plot.title          = element_text(size = title_size, hjust = 0, lineheight = 1.1),
      plot.title.position = "plot",
      plot.subtitle       = element_text(size = subtitle_size, hjust = 0, lineheight = 1.2),
      plot.caption        = element_text(size = caption_size, hjust = 1),
      axis.text.x         = element_text(size = x_axis_text_size),
      axis.text.y         = element_text(size = y_axis_text_size),
      legend.text         = element_text(size = legend_text_size),
      axis.title          = element_text(size = rel(text_scale), inherit.blank = TRUE),
      legend.title        = element_text(size = rel(text_scale), inherit.blank = TRUE),
      legend.position     = legend_position,
      plot.background     = element_rect(fill = "white", color = NA)
    )

  # Grid and axis lines: TRUE/FALSE set the parent element, "x"/"y" draw only that direction
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
  if (is.null(facet_var)) {
    p <- p + theme(plot.margin = margin(t = 15, r = 10, b = 10, l = 10, unit = "pt"))
  } else {
    has_wrapped <- any(grepl("\\n", df_work[[facet_var]]))
    p <- p + theme(
      panel.spacing.x  = unit(if (has_wrapped) 0.3 else 0.6, "lines"),
      panel.spacing.y  = unit(if (has_wrapped) 0.2 else 0.8, "lines"),
      panel.border     = element_rect(color = "grey70", fill = NA, linewidth = 0.3),
      axis.line.x      = if (x_axis_line) element_line(color = "grey70", linewidth = 0.3) else element_blank(),
      axis.line.y      = if (y_axis_line) element_line(color = "grey70", linewidth = 0.3) else element_blank(),
      strip.background = element_rect(fill = "white", color = NA, linewidth = 0),
      strip.text       = element_text(size = facet_title_size, face = "plain", lineheight = 0.75,
                                      margin = margin(t = if (has_wrapped) 6 else 4,
                                                      b = if (has_wrapped) 8 else 12, l = 2, r = 2)),
      plot.margin      = margin(t = if (has_wrapped) 20 else 15, r = 10, b = 10, l = 10, unit = "pt")
    )
  }

  p <- p + labs(
    title    = if (!is.null(title))    str_wrap(title, width = title_width) else NULL,
    subtitle = if (!is.null(subtitle)) str_wrap(subtitle, width = subtitle_width) else NULL,
    caption  = caption,
    x = x_axis_title, y = y_axis_title
  )

  if (!is.null(custom_theme)) p <- p + custom_theme

  p
}

#' @rdname func_graf_spridningsdiagram
#' @export
func_graf_scatterplot <- func_graf_spridningsdiagram
