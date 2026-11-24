#' Lådagram
#'
#' Lådagram (boxplot) i VGR:s stil: fördelningen av ett numeriskt värde per
#' kategori. Lådan går från första till tredje kvartilen med medianen som ett
#' streck, morrhåren når de mest extrema värdena inom 1,5 kvartilavstånd från
#' lådan, och värden utanför ritas som punkter (avvikande värden). Med `group`
#' ritas en låda per grupp bredvid varandra, och diagrammet kan delas upp i
#' paneler. Medelvärdet och de enskilda värdena kan visas ovanpå. Siffror
#' formateras på svenska. `func_graf_boxplot()` är samma funktion under ett
#' engelskt namn.
#'
#' Statistiken räknas fram i funktionen (inte av ggplot2), med samma metod som
#' ggplot2:s `geom_boxplot()` (kvartiler med `quantile()`, typ 7), så att
#' `func_d3_ladagram()` i funcVGRD3 får exakt samma lådor.
#'
#' Parametrarna med `x_` (`x_axis_title`, `x_axis_text_size`, `x_angle`) gäller
#' kategoriaxeln och de med `y_` värdeaxeln, även när lådorna ligger
#' (`horizontal = TRUE`). Undantag: `x_axis_line`, `y_axis_line` och `"x"`/`"y"` i
#' `show_major_grid` och `show_minor_grid` gäller de ritade axlarna (x = den nedre). Med `group` har varje grupp en fast plats i varje
#' kategori, så att samma grupp står på samma ställe även där en annan grupp saknas.
#'
#' @inheritParams func_graf_spridningsdiagram
#' @param df Data frame med ett värde per rad. Ett `sf`-objekt går också bra
#'   (geometrin används inte). Obligatorisk.
#' @param y_value Namn på den numeriska kolumn vars fördelning ska visas, som
#'   text. Obligatorisk.
#' @param x_value Kolumn med kategorierna, en låda per kategori. `NULL`
#'   (standard) ger en låda för alla värden.
#' @param group Kolumn som delar upp lådorna i färger bredvid varandra inom
#'   varje kategori, t.ex. kön. `NULL` = en färg.
#' @param legend_position Förklaringens placering: `"right"`, `"left"`,
#'   `"top"`, `"bottom"` eller `"none"`. Anges den inte blir det `"right"` med
#'   `group`, annars `"none"`.
#' @param horizontal `TRUE` ger liggande lådor (kategorierna på den lodräta
#'   axeln), som passar långa kategorinamn.
#' @param sort_by Lådornas ordning: `"value_asc"` eller `"value_desc"` (efter
#'   medianen), `"name_asc"` eller `"name_desc"`. `NULL` = kategoriernas
#'   ordning (faktornivåer, annars förekomstordning).
#' @param box_width Lådornas bredd (0–1 av utrymmet per kategori).
#' @param box_alpha Lådornas opacitet (0–1).
#' @param box_line_color Färg på lådornas kantlinje, medianstreck och morrhår.
#' @param box_line_width Kantlinjens tjocklek (ggplot2:s `linewidth`).
#' @param box_whisker_range Hur långt morrhåren når, i kvartilavstånd (IQR) från
#'   lådan. 1,5 är Tukeys standard; `Inf` låter morrhåren nå minsta och största
#'   värdet, och då finns inga avvikande värden.
#' @param box_outliers Rita avvikande värden (utanför morrhåren) som punkter.
#' @param box_mean Visa medelvärdet som en romb i lådan.
#' @param point_show Rita alla enskilda värden som punkter ovanpå lådorna,
#'   spridda i sidled. Avvikande värden ritas då inte en gång till.
#' @param point_size Punkternas storlek (ggplot2:s storleksenhet).
#' @param point_alpha Punkternas opacitet (0–1).
#' @param point_jitter Hur mycket punkterna sprids i sidled, som andel av
#'   lådans bredd (0 = på en linje).
#' @param y_break_line Referenslinje på värdeaxeln (lodrät när lådorna ligger): ett eller flera tal, `"mean"` eller
#'   `"median"` av alla värden. `NULL` = ingen.
#' @param data_labels Skriv medianen bredvid varje låda, i höjd med
#'   medianstrecket (ovanför lådan när den ligger ned).
#' @param data_label_decimals Antal decimaler i medianetiketterna.
#' @param data_label_color Etiketternas färg.
#' @param x_angle Rotation av kategoriaxelns text i grader. Sätts automatiskt
#'   till 45 vid fler än 8 stående kategorier.
#' @param y_axis_min,y_axis_max Min- och maxvärde för värdeaxeln. `NULL` =
#'   automatiskt. Lådorna räknas ändå på alla värden.
#'
#' @return Ett `ggplot`-objekt, en lista om `debug = TRUE` (med statistiken
#'   per låda i `boxes`), eller `NULL` (med varning) om det inte finns några
#'   värden.
#' @seealso [func_graf_histogram()], [func_graf_barchart()]
#' @export
#'
#' @example inst/examples/func_graf_ladagram.R
func_graf_ladagram <- function(
  # === REQUIRED PARAMETERS ===
  df,                                   # Data frame: Your dataset, one value per row (an sf object also works)
  x_value = NULL,                       # Character: Column with the categories, one box each (NULL = one box for all values) | same position as in the other charts
  y_value,                              # Character: Numeric column whose distribution is shown

  # === GROUPING AND FACETING ===
  group = NULL,                        # Character: Column for coloured boxes side by side within each category, e.g. sex (NULL = one colour)
  facet_var = NULL,                     # Character: Column for separate subplot panels (NULL = no facets)
  facet_ncol = NULL,                    # Numeric: Number of columns for facets (NULL = auto-calculated)
  facet_scales = "fixed",               # Character: Axis scales across facets - "fixed" (comparable panels), "free", "free_x", "free_y"
  facet_same_y_scale = TRUE,            # Logical: Same value axis in all panels | Only applies when facet_scales is not given (as func_graf_barchart) | FALSE = free
  facet_title_size = 12,                # Numeric: Facet panel title size in points
  facet_title_wrap = NULL,              # Numeric: Wrap facet titles at N characters (NULL = no wrapping)

  # === TITLES AND LABELS ===
  title = NULL,                         # Character: Main plot title (NULL = no title)
  title_width = 100,                    # Numeric: Title wrap width in characters
  subtitle = NULL,                      # Character: Plot subtitle (NULL = no subtitle)
  subtitle_width = 100,                 # Numeric: Subtitle wrap width in characters
  caption = NULL,                       # Character: Plot caption/footer (NULL = no caption)
  x_axis_title = NULL,                  # Character: Category axis label (NULL = no label)
  y_axis_title = NULL,                  # Character: Value axis label (NULL = no label)
  legend_title = NULL,                  # Character: Legend title (NULL = group column name)

  # === STYLING ===
  colors = func_fargtema("ru"),         # Vector: Colors for groups, same rules as func_graf_linjediagram (NULL = viridis) | without group: the first color
  font = "Verdana",                     # Character: Font family name - installed font, or "sans", "serif", "mono"

  # === ARRANGEMENT ===
  horizontal = FALSE,                   # Logical: TRUE = horizontal boxes (categories on the vertical axis), good for long names
  sort_by = NULL,                       # Character: Box order - "value_asc"/"value_desc" (by median), "name_asc"/"name_desc" (NULL = category order)

  # === BOXES ===
  box_width = 0.6,                      # Numeric: Box width, 0-1 of the space per category
  box_alpha = 0.8,                      # Numeric: Box fill opacity, 0-1
  box_line_color = "black",             # Character: Colour of box outline, median line and whiskers
  box_line_width = 0.3,                 # Numeric: Outline thickness (ggplot linewidth)
  box_whisker_range = 1.5,              # Numeric: Whisker reach in IQRs from the box (1.5 = Tukey) | Inf = to min/max (no outliers)
  box_outliers = TRUE,                  # Logical: Draw values outside the whiskers as points (TRUE/FALSE)
  box_mean = FALSE,                     # Logical: Show the mean as a diamond in the box (TRUE/FALSE)

  # === POINTS ===
  point_show = FALSE,                   # Logical: Draw every value as a point on top of the boxes, spread sideways (outliers then aren't drawn twice)
  point_size = 1.5,                     # Numeric: Point size (ggplot size units)
  point_alpha = 0.4,                    # Numeric: Point opacity, 0-1
  point_jitter = 0.4,                   # Numeric: Sideways spread of the points as a share of the box width (0 = in a line)

  # === TEXT SIZING (in points) ===
  text_scale = 1,                       # Numeric: Multiplies every text size (titles, axes, legend, facet titles, data labels) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                      # Numeric: Title font size
  subtitle_size = 13,                   # Numeric: Subtitle font size
  caption_size = 10,                    # Numeric: Caption font size
  x_axis_text_size = 11,                # Numeric: Category axis tick label font size
  y_axis_text_size = 11,                # Numeric: Value axis tick label font size
  legend_text_size = 11,                # Numeric: Legend text font size

  # === LAYOUT ===
  legend_position = "none",             # Character: Legend placement - "right", "left", "top", "bottom", "none" (not set: "right" with group)
  show_major_grid = FALSE,              # Logical/Character: Major grid lines | TRUE = both directions, FALSE = none, "y" = horizontal only, "x" = vertical only
  show_minor_grid = FALSE,              # Logical/Character: Minor grid lines | Same options as show_major_grid
  x_axis_line = TRUE,                   # Logical: Draw a line along the x-axis (TRUE/FALSE)
  y_axis_line = TRUE,                   # Logical: Draw a line along the y-axis (TRUE/FALSE)
  x_angle = 0,                          # Numeric: Category axis text rotation in degrees (auto 45 with more than 8 vertical categories)

  # === REFERENCE LINE ===
  y_break_line = NULL,                  # Numeric/Character: Reference line on the value axis - one or more numbers, "mean" or "median" of all values (NULL = none)

  # === DATA LABELS ===
  data_labels = FALSE,                  # Logical: Write the median next to each box (TRUE/FALSE)
  data_label_text_size = 3.5,           # Numeric: Label font size in mm (ggplot text units; 3.5 mm ≈ 10 pt)
  data_label_color = "black",           # Character: Label text color
  data_label_decimals = 0,              # Numeric: Decimal places in the median labels

  # === AXIS LIMITS ===
  y_axis_min = NULL,                    # Numeric: Minimum of the value axis - boxes are still computed from all values (NULL = auto)
  y_axis_max = NULL,                    # Numeric: Maximum of the value axis (NULL = auto)

  # === ADVANCED ===
  custom_theme = NULL,                  # ggplot2 theme object: Appended after default theme (NULL = use default only)
  debug = FALSE                         # Logical: TRUE returns a list of diagnostics (incl. the box statistics) instead of the plot
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
  if (!legend_position %in% c("none", "top", "bottom", "left", "right"))
    stop("legend_position must be one of: right, left, top, bottom, none")

  # --- Input checks ---
  df_work <- if (inherits(df, "sf")) sf::st_drop_geometry(df) else as.data.frame(df)
  missing_cols <- setdiff(c(y_value, x_value, group, facet_var), names(df_work))
  if (length(missing_cols) > 0) stop("Missing columns in data: ", paste(missing_cols, collapse = ", "))
  if (!is.numeric(df_work[[y_value]])) stop("y_value must be a numeric column: ", y_value)
  # facet_scales wins when given; otherwise facet_same_y_scale = FALSE frees the value axis (as func_graf_barchart)
  if (missing(facet_scales) && !facet_same_y_scale) facet_scales <- "free_y"
  facet_scales <- match.arg(facet_scales, c("fixed", "free", "free_x", "free_y"))
  if (!is.null(sort_by)) sort_by <- match.arg(sort_by, c("value_asc", "value_desc", "name_asc", "name_desc"))
  if (!(is.numeric(box_whisker_range) && length(box_whisker_range) == 1 && isTRUE(box_whisker_range >= 0)))
    stop("box_whisker_range must be one number of at least 0 (Inf = to min/max)")
  grid_ok <- function(v) isTRUE(v) || isFALSE(v) || identical(v, "x") || identical(v, "y")
  if (!grid_ok(show_major_grid)) stop("show_major_grid must be TRUE, FALSE, \"x\" or \"y\"")
  if (!grid_ok(show_minor_grid)) stop("show_minor_grid must be TRUE, FALSE, \"x\" or \"y\"")

  # Values that can't be placed in a box are left out
  finite <- is.finite(df_work[[y_value]])
  if (any(!finite)) {
    message(sprintf("func_graf_ladagram: %d rows without a value left out", sum(!finite)))
    df_work <- df_work[finite, , drop = FALSE]
  }
  if (nrow(df_work) == 0) {
    warning("func_graf_ladagram: no values to draw. Check your filter and y_value. Returning NULL.")
    return(NULL)
  }

  # --- Categories: one box for all values without x_value; a missing category is its own "NA" box, last unless sort_by sorts it among the others ---
  x_col <- x_value %||% ".alla"
  if (is.null(x_value)) df_work$.alla <- factor("")
  cat_levels <- if (is.factor(df_work[[x_col]])) setdiff(levels(droplevels(df_work[[x_col]])), NA)
                else unique(stats::na.omit(as.character(df_work[[x_col]])))
  if (anyNA(as.character(df_work[[x_col]]))) cat_levels <- c(cat_levels, "NA")
  df_work$.x <- as.character(df_work[[x_col]]); df_work$.x[is.na(df_work$.x)] <- "NA"

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
    # A missing group is its own grey "NA" group last (as func_d3_ladagram)
    g_chr <- as.character(df_work[[group]])
    if (anyNA(g_chr)) { g_chr[is.na(g_chr)] <- "NA"; group_levels <- c(group_levels, "NA"); color_mapping[["NA"]] <- "grey50" }
    df_work[[group]] <- factor(g_chr, levels = group_levels)
  }
  box_color <- if (!is.null(colors)) unname(colors[1]) else "#2E86AB"   # single colour without group

  # ============================================================
  #  STATISTICS PER BOX (as geom_boxplot: quantile() type 7, whiskers at the most extreme value within the range)
  # ============================================================
  box_by <- c(facet_var, ".x", group)
  boxes <- df_work %>%
    group_by(across(all_of(box_by))) %>%
    summarise(
      .n      = n(),
      .q1     = stats::quantile(.data[[y_value]], 0.25, names = FALSE),
      .median = stats::median(.data[[y_value]]),
      .q3     = stats::quantile(.data[[y_value]], 0.75, names = FALSE),
      .mean   = mean(.data[[y_value]]),
      # Whiskers: the most extreme values within box_whisker_range IQRs of the box, never inside the box
      # (as stat_boxplot: with box_whisker_range = 0 they end at the quartiles)
      .reach  = if (is.infinite(box_whisker_range)) Inf else box_whisker_range * (.q3 - .q1),   # Inf * 0 would be NaN
      .lower  = min(c(.q1, .data[[y_value]][.data[[y_value]] >= .q1 - .reach])),
      .upper  = max(c(.q3, .data[[y_value]][.data[[y_value]] <= .q3 + .reach])),
      .groups = "drop") %>%
    select(-.reach) %>%
    as.data.frame()

  # Category order: data order, or by median / name with sort_by (the median of all values in the category)
  if (!is.null(sort_by)) {
    cat_med <- tapply(df_work[[y_value]], df_work$.x, stats::median)[cat_levels]
    cat_levels <- switch(sort_by,
      value_asc  = cat_levels[order(cat_med)],
      value_desc = cat_levels[order(-cat_med)],
      name_asc   = sort(cat_levels),
      name_desc  = sort(cat_levels, decreasing = TRUE))
  }
  # Horizontal boxes: the first category at the top (coord_flip draws the first level at the bottom)
  axis_levels <- if (horizontal) rev(cat_levels) else cat_levels
  df_work$.x <- factor(df_work$.x, levels = axis_levels)
  boxes$.x   <- factor(boxes$.x, levels = axis_levels)

  # Reference line: a number, or the mean/median of all values
  y_line <- if (is.null(y_break_line)) NULL
    else if (identical(y_break_line, "mean")) mean(df_work[[y_value]])
    else if (identical(y_break_line, "median")) stats::median(df_work[[y_value]])
    else if (is.numeric(y_break_line)) y_break_line
    else stop("y_break_line must be one or more numbers, \"mean\" or \"median\"")

  # --- Debug mode ---
  if (debug) return(list(data = df_work, boxes = boxes, categories = cat_levels, group_levels = group_levels,
                         color_mapping = color_mapping, y_break_line = y_line))

  # ============================================================
  #  BOXES, POINTS, MEAN, LABELS
  # ============================================================
  # Each box gets its own position on the category axis: the category (1, 2, ...) shifted for the group. Every
  # group keeps its slot in every category (as func_d3_ladagram), and on horizontal boxes the first group is at
  # the top, in the same order as the legend. Boxes, means, points and labels are all drawn at this position.
  n_grp   <- if (is.null(group)) 1 else length(group_levels)
  dodge_w <- if (is.null(group)) 1 else 0.8   # the part of a category the boxes share
  box_w   <- box_width * dodge_w / n_grp      # one box
  slot_of <- function(d) {
    slot <- if (is.null(group)) rep(1L, nrow(d)) else as.integer(d[[group]])
    if (horizontal) slot <- n_grp + 1L - slot
    as.numeric(d$.x) + (slot - (n_grp + 1) / 2) * dodge_w / n_grp
  }
  boxes$.pos   <- slot_of(boxes)
  boxes$.box_i <- seq_len(nrow(boxes))
  p <- ggplot(boxes, aes(x = .pos)) +
    geom_blank(aes(x = as.numeric(.x)))   # the category axis spans the categories in each panel, as a discrete axis
  if (!is.null(y_line)) p <- p + geom_hline(yintercept = y_line, linewidth = 0.5, linetype = "solid", color = "black")

  box_aes <- aes(x = .pos, ymin = .lower, lower = .q1, middle = .median, upper = .q3, ymax = .upper, group = .box_i)
  if (!is.null(group)) box_aes$fill <- rlang::quo(.data[[group]])
  box_args <- list(mapping = box_aes, stat = "identity", width = box_w,
                   alpha = box_alpha, colour = box_line_color, linewidth = box_line_width)
  if (is.null(group)) box_args$fill <- box_color
  p <- p + do.call(geom_boxplot, box_args)

  # Points: all values (spread sideways) or only the outliers (on the box's centre line).
  # Only the columns the layer uses, so the plot object does not carry the rest of df.
  pt_data <- df_work[, unique(c(y_value, ".x", group, facet_var)), drop = FALSE]
  shown_points <- if (point_show) pt_data
    else if (box_outliers) pt_data %>%
      left_join(boxes[, c(box_by, ".lower", ".upper")], by = box_by) %>%
      filter(.data[[y_value]] < .lower | .data[[y_value]] > .upper) %>%
      as.data.frame()
    else pt_data[0, ]
  if (nrow(shown_points) > 0) {
    shown_points$.pos <- slot_of(shown_points)
    # point_jitter is a share of the box width: the points spread over point_jitter * box_w (position_jitter takes half)
    pt_pos <- position_jitter(width = if (point_show) point_jitter * box_w / 2 else 0, height = 0, seed = 42)
    p <- p + geom_point(data = shown_points, mapping = aes(x = .pos, y = .data[[y_value]]), position = pt_pos, inherit.aes = FALSE,
                        size = point_size, alpha = if (point_show) point_alpha else 1,
                        colour = if (point_show) "grey20" else box_line_color, shape = 16)
  }
  if (box_mean) {
    p <- p + geom_point(data = boxes, mapping = aes(x = .pos, y = .mean), inherit.aes = FALSE, shape = 23, size = 2.5, fill = "white", colour = box_line_color)
  }
  if (data_labels) {
    boxes$label_text <- format(round(boxes$.median, data_label_decimals), nsmall = data_label_decimals,
                               big.mark = " ", decimal.mark = ",", trim = TRUE, scientific = FALSE)
    # Beside the box at the median's height (above it on horizontal boxes), clear of whiskers and outliers.
    # With many groups the gap to the next box is narrow and a long label can reach into it.
    boxes$.label_x <- boxes$.pos + box_w / 2 + 0.03
    p <- p + geom_text(data = boxes, mapping = aes(x = .label_x, y = .median, label = label_text),
                       inherit.aes = FALSE, size = data_label_text_size, family = font, colour = data_label_color,
                       hjust = if (horizontal) 0.5 else 0, vjust = if (horizontal) 0 else 0.5)
  }

  # ============================================================
  #  SCALES (each added once)
  # ============================================================
  if (!is.null(group)) p <- p + scale_fill_manual(values = color_mapping, name = legend_title %||% group)
  # Numeric positions, labelled as a discrete category axis (no minor lines, 0.6 categories of space at the ends)
  p <- p + scale_x_continuous(breaks = seq_along(axis_levels), labels = if (is.null(x_value)) NULL else axis_levels,
                              minor_breaks = NULL, expand = expansion(add = 0.6)) +
    scale_y_continuous(labels = label_number(big.mark = " ", decimal.mark = ","),
                       expand = expansion(mult = c(0.05, 0.05)),
                       # NA = automatic end, so only one of min/max can be given; outside values are kept for the boxes
                       limits = if (is.null(y_axis_min) && is.null(y_axis_max)) NULL else c(y_axis_min %||% NA, y_axis_max %||% NA),
                       oob = scales::oob_keep)
  if (horizontal) p <- p + coord_flip()

  if (!is.null(facet_var)) {
    n_facets <- length(unique(df_work[[facet_var]]))
    ncol_val <- facet_ncol %||% max(1L, if (n_facets <= 2) n_facets else if (n_facets <= 4) 2L else 3L)
    p <- p + facet_wrap(vars(.data[[facet_var]]), scales = facet_scales, ncol = ncol_val)
  }

  # Not for horizontal boxes, where the category names are read along the rows
  if (x_angle == 0 && length(cat_levels) > 8 && !horizontal) x_angle <- 45

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
      axis.text.x         = element_text(size = x_axis_text_size, angle = x_angle, hjust = if (x_angle > 0) 1 else 0.5),
      axis.text.y         = element_text(size = y_axis_text_size),
      legend.text         = element_text(size = legend_text_size),
      axis.title          = element_text(size = rel(text_scale), inherit.blank = TRUE),
      legend.title        = element_text(size = rel(text_scale), inherit.blank = TRUE),
      legend.position     = legend_position,
      plot.background     = element_rect(fill = "white", color = NA)
    )
  # With horizontal boxes the category text is on the y axis: its size and angle follow the category settings
  if (horizontal) p <- p + theme(axis.text.y = element_text(size = x_axis_text_size, angle = x_angle),
                                 axis.text.x = element_text(size = y_axis_text_size, angle = 0, hjust = 0.5))

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

#' @rdname func_graf_ladagram
#' @export
func_graf_boxplot <- func_graf_ladagram
