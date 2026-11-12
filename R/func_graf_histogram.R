#' Histogram
#'
#' Histogram i VGR:s stil: fördelningen av ett numeriskt värde, uppdelat i
#' lika breda intervall (staplar som ligger kant i kant). Staplarnas höjd kan
#' vara antal, andel eller täthet. Med `group` blir staplarna staplade, ritade
#' bredvid varandra eller ovanpå varandra med genomskinlighet, och diagrammet
#' kan delas upp i paneler. En referenslinje kan visa medelvärdet eller
#' medianen. Siffror formateras på svenska.
#'
#' Intervallen räknas fram i funktionen (inte av ggplot2), så att
#' `func_d3_histogram()` i funcVGRD3 får exakt samma intervall. Varje intervall
#' innehåller sin nedre gräns men inte den övre, utom det sista som också
#' innehåller den övre.
#'
#' @inheritParams func_graf_spridningsdiagram
#' @param df Data frame med ett värde per rad. Ett `sf`-objekt går också bra
#'   (geometrin används inte). Obligatorisk.
#' @param x_value Namn på den numeriska kolumn vars fördelning ska visas, som
#'   text. Obligatorisk.
#' @param legend_position Förklaringens placering: `"right"`, `"left"`,
#'   `"top"`, `"bottom"` eller `"none"`. Anges den inte blir det `"right"` med
#'   `group`, annars `"none"`.
#' @param group Kolumn som delar upp staplarna i färger, t.ex. kön. `NULL` = en
#'   färg.
#' @param bin_width Intervallens bredd, t.ex. `5` för femårsklasser. `NULL` =
#'   bestäms av `bins`, eller automatiskt.
#' @param bins Antal intervall, som ger bredden (värdenas spännvidd / `bins`).
#'   Används när `bin_width` inte anges. Med `bin_boundary` flyttas gränserna,
#'   så det kan bli ett intervall till. `NULL` = automatiskt: en jämn bredd (1,
#'   2, 2,5 eller 5 gånger en tiopotens) nära Freedman–Diaconis regel.
#' @param bin_boundary Ett värde som en intervallgräns ska ligga på. `NULL` =
#'   `0` (gränser på jämna tal, t.ex. 20, 25, 30), eller lägsta värdet när
#'   `bins` anges.
#' @param histogram_y Staplarnas höjd: `"count"` (antal), `"percent"` (andel av
#'   alla värden i panelen, eller i gruppen när `bar_type` är `"grouped"` eller
#'   `"overlay"`) eller `"density"` (andel per enhet på x-axeln, så att ytan
#'   blir 1).
#' @param bar_type Med `group`: `"stacked"` (grupperna ovanpå varandra),
#'   `"grouped"` (bredvid varandra inom intervallet) eller `"overlay"`
#'   (grupperna ritas över varandra med genomskinlighet, för att jämföra
#'   fördelningarnas form).
#' @param bar_alpha Staplarnas opacitet (0–1). `NULL` = 1, eller 0,5 med
#'   `bar_type = "overlay"`.
#' @param bar_line_color Färg på kantlinjen runt staplarna, som i
#'   [func_graf_barchart()]. Kantlinjen ger bättre kontrast för personer med
#'   nedsatt syn och skiljer intervallen åt. `NULL` = ingen kantlinje.
#' @param bar_line_width Kantlinjens tjocklek.
#' @param x_break_line Lodrät, streckad referenslinje: ett eller flera tal, `"mean"`
#'   (medelvärdet av alla värden) eller `"median"`. `NULL` = ingen.
#' @param data_labels Visa värdet ovanför staplarna (staplade grupper: summan
#'   för intervallet). Tomma intervall får ingen etikett.
#' @param data_label_color Etiketternas färg.
#' @param data_label_decimals Antal decimaler för andelar och täthet (antal
#'   visas alltid utan decimaler).
#' @param y_axis_max Maxvärde för y-axeln. `NULL` = automatiskt. y-axeln börjar
#'   alltid på 0.
#' @param x_axis_min,x_axis_max Min- och maxvärde för x-axeln. Värden utanför
#'   räknas ändå med i intervallen. `NULL` = automatiskt.
#'
#' @return Ett `ggplot`-objekt, en lista om `debug = TRUE` (med intervallen i
#'   `bins`), eller `NULL` (med varning) om det inte finns några värden.
#' @seealso [func_graf_barchart()], [func_graf_spridningsdiagram()]
#' @export
#'
#' @example inst/examples/func_graf_histogram.R
func_graf_histogram <- function(
  # === REQUIRED PARAMETERS ===
  df,                                   # Data frame: Your dataset, one value per row (an sf object also works)
  x_value,                              # Character: Numeric column whose distribution is shown

  # === GROUPING AND FACETING ===
  group = NULL,                         # Character: Column for splitting bars by color, e.g. sex (NULL = one color)
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
  legend_title = NULL,                  # Character: Legend title (NULL = group column name)

  # === STYLING ===
  colors = func_fargtema("ru"),         # Vector: Colors for groups, same rules as func_graf_linjediagram (NULL = viridis) | without group: the first color
  font = "Verdana",                     # Character: Font family name - installed font, or "sans", "serif", "mono"

  # === BINS ===
  bin_width = NULL,                     # Numeric: Width of each bin, e.g. 5 for five-year classes (NULL = from bins, or automatic)
  bins = NULL,                          # Numeric: Number of bins when bin_width is NULL (NULL = automatic, a round width near the Freedman-Diaconis suggestion)
  bin_boundary = NULL,                  # Numeric: A value that a bin edge falls on (NULL = 0, i.e. round edges; with bins: the lowest value)
  histogram_y = "count",                # Character: Bar height - "count", "percent" (share of the panel, or of the group when grouped/overlay), "density" (area = 1)

  # === BARS ===
  bar_type = "stacked",                 # Character: With group - "stacked" (on top of each other), "grouped" (side by side), "overlay" (drawn over each other, transparent)
  bar_alpha = NULL,                     # Numeric: Bar opacity, 0-1 (NULL = 1, or 0.5 with bar_type = "overlay")
  bar_line_color = "black",             # Character: Bar outline color, as func_graf_barchart - contrast for low vision, separates the bins (NULL = no outline)
  bar_line_width = 0.3,                 # Numeric: Bar outline thickness

  # === TEXT SIZING (in points) ===
  text_scale = 1,                       # Numeric: Multiplies every text size (titles, axes, legend, facet titles, data labels) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                      # Numeric: Title font size
  subtitle_size = 13,                   # Numeric: Subtitle font size
  caption_size = 10,                    # Numeric: Caption font size
  x_axis_text_size = 11,                # Numeric: X-axis tick label font size
  y_axis_text_size = 11,                # Numeric: Y-axis tick label font size
  legend_text_size = 11,                # Numeric: Legend text font size

  # === LAYOUT ===
  legend_position = "none",             # Character: Legend placement - "right", "left", "top", "bottom", "none" (not set: "right" with group)
  show_major_grid = FALSE,              # Logical/Character: Major grid lines | TRUE = both directions, FALSE = none, "y" = horizontal only, "x" = vertical only
  show_minor_grid = FALSE,              # Logical/Character: Minor grid lines | Same options as show_major_grid
  x_axis_line = TRUE,                   # Logical: Draw a line along the x-axis (TRUE/FALSE)
  y_axis_line = TRUE,                   # Logical: Draw a line along the y-axis (TRUE/FALSE)

  # === REFERENCE LINE ===
  x_break_line = NULL,                  # Numeric/Character: Vertical dashed reference line - a number, "mean" or "median" of all values (NULL = no line)

  # === DATA LABELS ===
  data_labels = FALSE,                  # Logical: Show the value above the bars (stacked groups: the bin total) (TRUE/FALSE)
  data_label_text_size = 3.5,           # Numeric: Label font size in mm (ggplot text units; 3.5 mm ≈ 10 pt)
  data_label_color = "black",           # Character: Label text color
  data_label_decimals = 0,              # Numeric: Decimal places for percent and density (counts never have decimals)

  # === AXIS LIMITS AND FORMAT ===
  x_axis_min = NULL,                    # Numeric: Minimum x-axis value - values outside still count in the bins (NULL = auto)
  x_axis_max = NULL,                    # Numeric: Maximum x-axis value (NULL = auto)
  y_axis_max = NULL,                    # Numeric: Maximum y-axis value - the y-axis always starts at 0 (NULL = auto)
  x_number_format = "thousands",        # Character: X-axis numbers - "thousands" (space separator, e.g. 12 000) or "whole" (no separator, e.g. years)

  # === ADVANCED ===
  custom_theme = NULL,                  # ggplot2 theme object: Appended after default theme (NULL = use default only)
  debug = FALSE                         # Logical: TRUE returns a list of diagnostics (incl. the bins) instead of the plot
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

  if (missing(legend_position) && !is.null(group)) legend_position <- "right"

  # --- Input checks ---
  df_work <- if (inherits(df, "sf")) sf::st_drop_geometry(df) else as.data.frame(df)
  missing_cols <- setdiff(c(x_value, group, facet_var), names(df_work))
  if (length(missing_cols) > 0) stop("Missing columns in data: ", paste(missing_cols, collapse = ", "))
  if (!is.numeric(df_work[[x_value]])) stop("x_value must be a numeric column: ", x_value)
  # facet_scales wins when given; otherwise facet_same_y_scale = FALSE frees the y-axis (as func_graf_barchart)
  if (missing(facet_scales) && !facet_same_y_scale) facet_scales <- "free_y"
  facet_scales <- match.arg(facet_scales, c("fixed", "free", "free_x", "free_y"))
  grid_ok <- function(v) isTRUE(v) || isFALSE(v) || identical(v, "x") || identical(v, "y")
  if (!grid_ok(show_major_grid)) stop("show_major_grid must be TRUE, FALSE, \"x\" or \"y\"")
  if (!grid_ok(show_minor_grid)) stop("show_minor_grid must be TRUE, FALSE, \"x\" or \"y\"")
  histogram_y  <- match.arg(histogram_y, c("count", "percent", "density"))
  bar_type     <- match.arg(bar_type, c("stacked", "grouped", "overlay"))
  if (!is.null(bin_width) && !(is.numeric(bin_width) && length(bin_width) == 1 && bin_width > 0))
    stop("bin_width must be one positive number")
  if (!is.null(bins) && !(is.numeric(bins) && length(bins) == 1 && bins >= 1))
    stop("bins must be one number of at least 1")

  # Values that can't be placed in a bin are left out
  finite <- is.finite(df_work[[x_value]])
  if (any(!finite)) {
    message(sprintf("func_graf_histogram: %d rows without a value left out", sum(!finite)))
    df_work <- df_work[finite, , drop = FALSE]
  }
  if (nrow(df_work) == 0) {
    warning("func_graf_histogram: no values to draw. Check your filter and x_value. Returning NULL.")
    return(NULL)
  }

  # --- Facets and groups (same rules as func_graf_linjediagram) ---
  if (!is.null(facet_var) && !is.null(facet_title_wrap) && facet_title_wrap > 0)
    df_work[[facet_var]] <- str_wrap(as.character(df_work[[facet_var]]), facet_title_wrap)
  if (!is.null(facet_var) && !is.factor(df_work[[facet_var]]))
    df_work[[facet_var]] <- factor(df_work[[facet_var]], levels = unique(df_work[[facet_var]]))
  if (!is.null(group) && is.numeric(df_work[[group]])) df_work[[group]] <- factor(df_work[[group]])
  group_levels  <- NULL
  color_mapping <- NULL
  if (!is.null(group)) {
    group_levels <- if (is.factor(df_work[[group]])) setdiff(levels(droplevels(df_work[[group]])), NA)
                    else unique(stats::na.omit(as.character(df_work[[group]])))
    if (is.null(colors)) colors <- viridisLite::viridis(length(group_levels), option = "D")
    if (!is.null(names(colors))) {
      missing_groups <- setdiff(group_levels, names(colors))
      if (length(missing_groups) > 0) stop("colors is named but has no color for: ", toString(missing_groups))
      color_mapping <- colors[group_levels]
    } else {
      color_mapping <- stats::setNames(rep(colors, length.out = length(group_levels)), group_levels)
    }
    # Stacking and legend follow the group order; a missing group is its own last category
    df_work[[group]] <- factor(as.character(df_work[[group]]), levels = group_levels)
  }
  bar_color <- if (!is.null(colors)) unname(colors[1]) else "#2E86AB"   # single color without group

  # ============================================================
  #  BINS (the same for every panel and group, so they line up)
  # ============================================================
  x <- df_work[[x_value]]
  x_range <- range(x)
  span    <- diff(x_range)
  width <- if (!is.null(bin_width)) bin_width
    else if (!is.null(bins)) (if (span > 0) span / bins else 1)
    else {
      # Freedman-Diaconis width (2 x IQR / n^(1/3)), rounded up to a round number (1, 2, 2.5 or 5 x a power of ten)
      fd <- 2 * stats::IQR(x) / length(x)^(1/3)
      if (!(fd > 0)) fd <- if (span > 0) span / 10 else 1
      fd <- max(fd, span / 50)   # never more than about 50 bins
      magnitude <- 10^floor(log10(fd))
      magnitude * c(1, 2, 2.5, 5, 10)[which(c(1, 2, 2.5, 5, 10) >= fd / magnitude - 1e-9)[1]]
    }
  boundary <- bin_boundary %||% (if (!is.null(bins) && is.null(bin_width)) x_range[1] else 0)
  first_edge <- boundary + floor((x_range[1] - boundary) / width + 1e-9) * width
  n_bins     <- max(1, ceiling((x_range[2] - first_edge) / width - 1e-9))
  # [lower, upper) for every bin, the last one also includes its upper edge. The bin is counted from the distance
  # to the first edge in bin widths, with a small tolerance: with decimal widths the edges aren't exact in floating
  # point (0.1 * 7 is 0.7000000000000001), and cut() against them put a value on an edge in the wrong bin or none
  df_work$.bin <- pmin(floor((x - first_edge) / width + 1e-9) + 1, n_bins)
  edges <- round(first_edge + (0:n_bins) * width, 10)   # for the axis and the bars: 0.3, not 0.30000000000000004

  # Counts per panel, group and bin - every bin present (also empty ones) so stacks and groups line up.
  # A missing group or panel value is its own category (dplyr keeps NA in grouping and joins)
  count_by <- c(facet_var, group)
  combos   <- if (length(count_by) > 0) distinct(df_work[count_by]) else tibble(.alla = 1)
  counted  <- df_work %>% count(across(all_of(c(count_by, ".bin"))), name = ".count")
  # Percent and density are shares of the panel, or of the group when the groups are compared side by side
  # or on top of each other (then each group's bars sum to 100 %)
  share_by <- c(facet_var, if (!is.null(group) && bar_type != "stacked") group)
  bins_df  <- cross_join(combos, tibble(.bin = seq_len(n_bins))) %>%
    left_join(counted, by = c(count_by, ".bin")) %>%
    mutate(.count = ifelse(is.na(.count), 0, .count),
           .xmin  = edges[.bin], .xmax = edges[.bin + 1], .mid = (.xmin + .xmax) / 2) %>%
    group_by(across(all_of(share_by))) %>%
    mutate(.y = switch(histogram_y,
                       count   = .count,
                       percent = if (sum(.count) > 0) .count / sum(.count) else 0,
                       density = if (sum(.count) > 0) .count / (sum(.count) * width) else 0)) %>%
    ungroup() %>%
    select(-any_of(".alla")) %>%
    arrange(.bin) %>%
    as.data.frame()

  # Reference line: a number, or the mean/median of all values
  x_line <- if (is.null(x_break_line)) NULL
    else if (identical(x_break_line, "mean")) mean(x)
    else if (identical(x_break_line, "median")) stats::median(x)
    else if (is.numeric(x_break_line)) x_break_line
    else stop("x_break_line must be a number, \"mean\" or \"median\"")

  # --- Debug mode ---
  if (debug) return(list(data = df_work, bins = bins_df, edges = edges, bin_width = width,
                         group_levels = group_levels, color_mapping = color_mapping, x_break_line = x_line))

  # ============================================================
  #  BARS
  # ============================================================
  alpha_value <- bar_alpha %||% (if (!is.null(group) && bar_type == "overlay") 0.5 else 1)
  outline     <- if (is.null(bar_line_color)) NA else bar_line_color
  bar_position <- if (is.null(group)) "identity" else switch(bar_type,
    stacked = position_stack(reverse = TRUE),   # first group at the bottom, as listed first in the legend
    grouped = position_dodge(width = width),
    overlay = "identity")
  bar_aes  <- if (!is.null(group)) aes(x = .mid, y = .y, fill = .data[[group]]) else aes(x = .mid, y = .y)
  bar_args <- list(data = bins_df, mapping = bar_aes, width = width, position = bar_position,
                   alpha = alpha_value, colour = outline, linewidth = bar_line_width)
  if (is.null(group)) bar_args$fill <- bar_color
  p <- ggplot() + do.call(geom_col, bar_args)

  if (!is.null(x_line)) p <- p + geom_vline(xintercept = x_line, linewidth = 0.5, linetype = "dashed", color = "black")

  # ============================================================
  #  DATA LABELS
  # ============================================================
  fmt_y <- function(v) {
    if (histogram_y == "count") return(format(v, big.mark = " ", trim = TRUE, scientific = FALSE))
    scaled <- if (histogram_y == "percent") 100 * v else v
    out <- format(round(scaled, data_label_decimals), nsmall = data_label_decimals, big.mark = " ",
                  decimal.mark = ",", trim = TRUE, scientific = FALSE)
    if (histogram_y == "percent") paste0(out, " %") else out
  }
  if (data_labels) {
    # Stacked groups: one label per bin with the total; otherwise one per bar
    label_df <- if (!is.null(group) && bar_type == "stacked") {
      bins_df %>% group_by(across(all_of(c(facet_var, ".mid")))) %>%
        summarise(.y = sum(.y), .count = sum(.count), .groups = "drop") %>% as.data.frame()
    } else bins_df
    # Empty bins get no label. Grouped bars keep their (empty) label row, so position_dodge spreads the labels
    # over the same number of groups as the bars and each label stays above its own bar
    if (!(!is.null(group) && bar_type == "grouped")) label_df <- label_df[label_df$.count > 0, , drop = FALSE]
    label_df$label_text <- ifelse(label_df$.count > 0, fmt_y(label_df$.y), "")
    if (nrow(label_df) > 0) {
      by_group <- !is.null(group) && bar_type != "stacked"
      label_aes <- if (by_group) aes(x = .mid, y = .y, label = label_text, group = .data[[group]])
                   else aes(x = .mid, y = .y, label = label_text)
      p <- p + geom_text(data = label_df, mapping = label_aes, vjust = -0.5, size = data_label_text_size,
                         family = font, colour = data_label_color,
                         position = if (by_group && bar_type == "grouped") position_dodge(width = width) else "identity")
    }
  }

  # ============================================================
  #  SCALES (each added once)
  # ============================================================
  if (!is.null(group)) p <- p + scale_fill_manual(values = color_mapping, name = legend_title %||% group)
  x_labels <- if (x_number_format == "whole") function(v) as.character(round(v)) else label_number(big.mark = " ", decimal.mark = ",")
  y_labels <- if (histogram_y == "percent") label_number(scale = 100, suffix = " %", big.mark = " ", decimal.mark = ",")
              else label_number(big.mark = " ", decimal.mark = ",")
  # x-axis marks on the bin edges (every edge, or every 2nd, 3rd ... so there are at most about 10)
  x_breaks <- edges[seq(1, length(edges), by = ceiling(length(edges) / 10))]
  p <- p +
    scale_x_continuous(labels = x_labels, breaks = x_breaks, expand = expansion(mult = c(0.02, 0.02)),
                       limits = if (is.null(x_axis_min) && is.null(x_axis_max)) NULL else c(x_axis_min %||% NA, x_axis_max %||% NA),
                       oob = scales::oob_keep) +   # bars partly outside the limits are kept, not dropped
    scale_y_continuous(labels = y_labels, limits = c(0, y_axis_max %||% NA),
                       # room above the bars for the labels
                       expand = expansion(mult = c(0, if (data_labels) 0.12 else 0.05)))

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
