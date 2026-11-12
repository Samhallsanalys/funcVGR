#' Linjediagram
#'
#' Flexibelt linjediagram i VGR:s stil. x-axeln kan vara datum, tal eller
#' kategorier. Linjerna kan grupperas och diagrammet delas upp i paneler.
#' Grupper kan lyftas fram på två sätt: `highlight_groups` ger vald färg och
#' tjocklek, `group_highlight` tonar ner övriga linjer via \pkg{gghighlight}.
#' Det finns referenslinjer och värdeetiketter som går att filtrera.
#' Siffror formateras på svenska.
#'
#' @inheritParams func_graf_barchart
#' @inheritParams func_graf_karta
#' @param facet_same_y_scale `TRUE` = samma y-skala i alla paneler, `FALSE` =
#'   oberoende skalor.
#' @param caption_x,caption_y Koordinater för fritt placerad `caption` i
#'   diagrammets enheter. `NULL` = standardplacering nere till höger.
#' @param caption_hjust,caption_vjust Justering av fritt placerad `caption`
#'   (0 = vänster/nederkant, 1 = höger/överkant).
#' @param colors Färger för grupperna. En namnlös vektor fördelas i
#'   gruppordning och återanvänds om den är för kort. Grupperna ordnas efter
#'   faktornivåerna (oanvända nivåer tas bort). Tal sorteras, och annan text får
#'   ordningen den först förekommer i data. En namngiven vektor matchas mot
#'   gruppnamnen, t.ex. `c("Göteborg" = "#1a9fb3", "Borås" = "#ffc107")`, och
#'   alla grupper måste då ha en färg. `NULL` = viridis-färger.
#' @param line_size Linjetjocklek.
#' @param line_type Linjetyp: `"solid"`, `"dashed"`, `"dotted"` eller
#'   `"dashdot"`.
#' @param x_angle Rotation av x-axelns text (0–90 grader).
#' @param x_angle_auto `TRUE` roterar x-axelns text 45 grader automatiskt när
#'   det finns fler än 8 värden.
#' @param x_axis_n_breaks Antal markeringar på x-axeln. Fungerar för tal,
#'   datum och kategorier. Första och sista värdet behålls alltid. `NULL` =
#'   automatiskt (alla värden för kategorier).
#' @param x_break_line Position för en lodrät, streckad referenslinje (tal
#'   eller datum). `NULL` = ingen.
#' @param y_break_line Position för en vågrät referenslinje. `NULL` = ingen.
#' @param show_major_grid,show_minor_grid Större respektive mindre stödlinjer:
#'   `TRUE` = i båda riktningarna, `FALSE` = inga, `"y"` = bara linjer från
#'   y-axeln (vågräta), `"x"` = bara linjer från x-axeln (lodräta).
#' @param x_axis_line,y_axis_line Rita en linje längs x- respektive y-axeln.
#' @param data_label_text_size Etiketternas teckenstorlek i mm (ggplot2:s
#'   textenhet, 3,5 mm ≈ 10 punkter).
#' @param data_label_color Etiketternas färg, eller `"auto"` för linjens
#'   färg.
#' @param data_label_format Etikettformat: `"value_only"` eller `"x_y"`
#'   (visar `"x: y"`; `"both"` ger samma).
#' @param data_label_repel Använd \pkg{ggrepel} för att undvika överlapp.
#' @param data_label_box_alpha Rutans opacitet (0–1).
#' @param data_label_direction Riktning för \pkg{ggrepel}: `"auto"` (utgår
#'   från nudge-värdena), `"both"`, `"x"` eller `"y"`.
#' @param highlight_groups Grupper som ritas i `highlight_color` med tjockare
#'   linje. `NULL` = ingen markering.
#' @param highlight_color Färg för markerade grupper.
#' @param highlight_line_size Linjetjocklek för markerade grupper.
#' @param highlight_bold Visa markerade grupper med fet linje i förklaringen.
#' @param group_highlight Grupper som behåller sin färg medan övriga tonas ned
#'   i grått (kräver \pkg{gghighlight}). Kan inte kombineras med `facet_var`.
#' @param group_highlight_label Skriv gruppnamnet i slutet av varje
#'   framhävd linje.
#' @param group_highlight_label_size Teckenstorlek för slutetiketterna i mm
#'   (ggplot2:s textenhet, 3,5 mm ≈ 10 punkter).
#' @param group_highlight_label_box Visa en ruta bakom slutetiketterna.
#'   `FALSE` (standard) ger bara text, utan ruta och utan ram.
#' @param group_highlight_label_color Färg för slutetiketterna. `"inherit"`
#'   ger linjens färg. En vektor ger en färg per grupp och färgar då även
#'   linjerna.
#' @param group_highlight_unhighlighted_color Färg för de nedtonade linjerna.
#' @param group_highlight_unhighlighted_alpha Opacitet för de nedtonade
#'   linjerna (0–1).
#' @param x_axis_min,x_axis_max Min- och maxvärde för x-axeln (tal eller
#'   datum). `NULL` = automatiskt.
#' @param y_axis_min,y_axis_max Min- och maxvärde för y-axeln. `NULL` =
#'   automatiskt.
#' @param x_axis_clip_off `FALSE` (standard) ger x-axeln 5 % luft till vänster
#'   och 10 % till höger, mer när etiketter utan repel eller slutetiketterna
#'   behöver det, och klipper vid panelens kant. `TRUE` ritar etiketter även
#'   utanför panelen (tal- och datumaxel utökas då 25 % åt höger).
#' @param x_date_labels Datumformat (strftime) för datumaxel, t.ex. `"%Y"`
#'   eller `"%b %Y"`.
#' @param x_date_breaks Avstånd mellan datummarkeringar: `"auto"` eller t.ex.
#'   `"1 year"`, `"6 months"`.
#'
#' @return Ett `ggplot`-objekt, en lista om `debug = TRUE`, eller `NULL` (med
#'   varning) om `df` saknar rader.
#' @seealso [func_graf_barchart()], [func_fargtema()]
#' @export
#'
#' @example inst/examples/func_graf_linjediagram.R
func_graf_linjediagram <- function(
    # === REQUIRED PARAMETERS ===
  df,                                    # Data frame: Your dataset
  x_value,                              # Character: Column name for x-axis
  y_value,                              # Character: Column name for y-axis
  
  # === GROUPING AND FACETING ===
  group = NULL,                         # Character: Column for grouping lines by color/category (NULL = single line)
  facet_var = NULL,                     # Character: Column for separate subplot panels (NULL = no facets)
  facet_ncol = NULL,                    # Numeric: Number of columns for facets (NULL = auto-calculated)
  facet_same_y_scale = FALSE,           # Logical: TRUE = same y-scale across facets, FALSE = independent scales
  facet_title_size = 12,                # Numeric: Facet panel title size in points (before 2026-10-01: 20)
  facet_title_wrap = NULL,              # Numeric: Wrap facet titles at N characters (NULL = no wrapping)
  
  # === TITLES AND LABELS ===
  title = NULL,                         # Character: Main plot title (NULL = no title)
  title_width = 100,                    # Numeric: Title wrap width in characters
  subtitle = NULL,                      # Character: Plot subtitle (NULL = no subtitle)
  subtitle_width = 100,                 # Numeric: Subtitle wrap width in characters
  caption = NULL,                       # Character: Plot caption/footer (NULL = no caption)
  caption_x = NULL,                    # Numeric/Date: X coordinate for free-placed caption (NULL = default bottom-right)
  caption_y = NULL,                    # Numeric: Y coordinate for free-placed caption (NULL = default bottom-right)
  caption_hjust = 0,                   # Numeric: Horizontal justification for free-placed caption - 0 = left, 1 = right
  caption_vjust = 0,                   # Numeric: Vertical justification for free-placed caption - 0 = bottom, 1 = top
  x_axis_title = NULL,                  # Character: X-axis label (NULL = no label)
  y_axis_title = NULL,                  # Character: Y-axis label (NULL = no label)
  legend_title = NULL,                  # Character: Legend title (NULL = group column name)
  
  # === STYLING ===
  colors = func_fargtema("ru"),         # Vector: Custom colors for groups (NULL = auto viridis colors) | unnamed = assigned in group order
                                        #   (factor levels, unused dropped; numeric sorted; else first appearance; recycled if too few), named = matched by group name,
                                        #   e.g. c("Göteborg" = "#1a9fb3", "Borås" = "#ffc107")
  line_size = 1.2,                      # Numeric: Line thickness
  line_type = "solid",                  # Character: Line style - "solid", "dashed", "dotted", "dashdot"
  font = "Verdana",                     # Character: Font family name (must be installed on system)

  # === TEXT SIZING (in points) ===
  # Defaults lowered 2026-10-01 (before: title 24, subtitle 20, caption 16, axis 18, legend 16) — use text_scale to scale all text
  text_scale = 1,                       # Numeric: Multiplies every text size (titles, axes, legend, facet titles, data/end-of-line labels) | 1 = as set, e.g. 1.3 for large exports
  title_size = 16,                      # Numeric: Title font size
  subtitle_size = 13,                   # Numeric: Subtitle font size
  caption_size = 10,                    # Numeric: Caption font size
  x_axis_text_size = 11,               # Numeric: X-axis tick label font size
  y_axis_text_size = 11,               # Numeric: Y-axis tick label font size
  legend_text_size = 11,               # Numeric: Legend text font size

  # === LAYOUT ===
  legend_position = "none",            # Character: Legend placement - "right", "left", "top", "bottom", "none"
  show_major_grid = FALSE,             # Logical/Character: Major background grid lines | TRUE = both directions, FALSE = none,
                                       #   "y" = only lines from the y-axis (horizontal), "x" = only lines from the x-axis (vertical)
  show_minor_grid = FALSE,             # Logical/Character: Minor background grid lines | Same options as show_major_grid
  x_axis_line = TRUE,                  # Logical: Draw a line along the x-axis (TRUE/FALSE)
  y_axis_line = TRUE,                  # Logical: Draw a line along the y-axis (TRUE/FALSE)
  x_angle = 0,                         # Numeric: X-axis text rotation angle (0-90 degrees)
  x_angle_auto = FALSE,                # Logical: Auto-rotate x-axis text when many values (TRUE/FALSE)
  x_axis_n_breaks = NULL,              # Numeric: Number of x-axis tick labels - works for numeric, date and character/factor x (NULL = auto; for character/factor = show all values). First and last value are always kept.
  
  # === REFERENCE LINES ===
  x_break_line = NULL,                 # Numeric/Date: Vertical reference line position (NULL = no line)
  y_break_line = NULL,                 # Numeric: Horizontal reference line position (NULL = no line)
  
  # === DATA LABELS ===
  data_labels = FALSE,                 # Logical: Show data labels on points (TRUE/FALSE)
  data_label_text_size = 3.5,          # Numeric: Label font size in mm (ggplot text units; 3.5 mm ≈ 10 pt) (before 2026-10-01: 6)
  data_label_color = "black",          # Character: Label text color - "auto" (match line color) or any color/hex
  data_label_format = "value_only",    # Character: Label format - "value_only", "x_y" (shows "x: y"; "both" is the same)
  data_label_filter = NULL,            # Vector: Alias for data_label_x_values (kept for compatibility)
  data_label_x_values = NULL,          # Vector: Show labels only at these x-values (NULL = all points)
  data_label_y_values = NULL,          # Vector: Show labels only at these y-values (NULL = all points)
  data_label_first_last = FALSE,       # Logical: Show labels only on first and last point per group (TRUE/FALSE)
  data_label_skip = NULL,              # Numeric: Show every Nth label per group/facet (NULL = all, 2 = every 2nd, etc.)
  data_label_repel = TRUE,             # Logical: Use ggrepel to avoid label overlap (TRUE/FALSE)
  data_label_box = TRUE,               # Logical: Add white background box to labels (TRUE/FALSE)
  data_label_box_color = "white",      # Character: Label box background color (only when data_label_box = TRUE)
  data_label_box_alpha = 0.8,          # Numeric: Label box transparency, 0-1 (only when data_label_box = TRUE)
  data_label_nudge_x = 0,              # Numeric: Horizontal label offset
  data_label_nudge_y = 0,              # Numeric: Vertical label offset
  data_label_direction = "auto",       # Character: ggrepel direction - "auto" (inferred from nudge), "both", "x", "y"
  data_label_decimals = 0,             # Numeric: Decimal places shown in data labels
  data_label_show_group = FALSE,       # Logical: Prepend group name to label text (TRUE/FALSE)
  data_label_group_separator = ": ",   # Character: Separator between group name and value in label
  data_label_glow = FALSE,             # Logical: Add glow/halo effect around labels (requires ggfx package)
  data_label_glow_color = "white",     # Character: Glow color (only when data_label_glow = TRUE)
  data_label_glow_sigma = 3,           # Numeric: Glow blur radius, 1-10 - higher = more spread
  data_label_glow_expand = 1,          # Numeric: Glow size expansion - higher = larger glow area
  
  # === GROUP HIGHLIGHTING (color override method) ===
  highlight_groups = NULL,             # Vector: Group values to highlight with a different color/weight (NULL = no highlighting)
  highlight_color = "red",             # Character: Color for highlighted groups
  highlight_line_size = 2,             # Numeric: Line thickness for highlighted groups
  highlight_bold = TRUE,               # Logical: Make highlighted group bold in legend (TRUE/FALSE)
  
  # === GGHIGHLIGHT (fade-out method) ===
  group_highlight = NULL,              # Vector: Groups to keep vivid, all others faded to grey | e.g. c("Goteborg", "Malmo") | incompatible with facet_var
  group_highlight_label = TRUE,        # Logical: Add group name label at end of each highlighted line (TRUE/FALSE)
  group_highlight_label_size = 3.5,    # Numeric: Font size for end-of-line labels in mm (ggplot text units; 3.5 mm ≈ 10 pt) (before 2026-10-01: 4)
  group_highlight_label_box = FALSE,   # Logical: Add box background behind end-of-line labels (FALSE = plain text)
  group_highlight_label_color = "inherit",  # Character: Color for end-of-line labels - "inherit" = match line color, or any color/hex
  group_highlight_unhighlighted_color = "grey80",  # Character: Color applied to all non-highlighted lines
  group_highlight_unhighlighted_alpha = 0.6,       # Numeric: Opacity for non-highlighted lines, 0-1
  
  # === AXIS LIMITS ===
  x_axis_min = NULL,                   # Numeric/Date: Minimum x-axis value (NULL = auto)
  x_axis_max = NULL,                   # Numeric/Date: Maximum x-axis value (NULL = auto)
  y_axis_min = NULL,                   # Numeric: Minimum y-axis value (NULL = auto)
  y_axis_max = NULL,                   # Numeric: Maximum y-axis value (NULL = auto)
  x_axis_clip_off = FALSE,             # Logical: FALSE = room 5% left / 10% right (more when unrepelled labels or the end labels need it), clipped to the panel | TRUE = show all labels past the panel edge (numeric/date x: 25% right)
  
  # === DATE X-AXIS FORMATTING ===
  x_date_labels = "%b %Y",             # Character: strftime format for date x-axis, e.g. "%Y", "%b %Y"
  x_date_breaks = "auto",              # Character: Date break interval - "auto", "1 year", "6 months", "3 months", etc.
  
  # === NUMERIC X-AXIS FORMATTING ===
  x_number_format = "whole",           # Character: Number format for x-axis labels - "whole" (no separators), "thousands" (space separator)
  
  # === ADVANCED ===
  custom_theme = NULL,                 # ggplot2 theme object: Appended after default theme (NULL = use default only)
  debug = FALSE                        # Logical: TRUE returns a list of diagnostics instead of the plot
) {
  
  # --- Package loading ---
  
  if (data_label_glow && data_labels) {
    if (!requireNamespace("ggfx", quietly = TRUE)) {
      warning("ggfx not installed. Falling back to box method. Install with: install.packages('ggfx')")
      data_label_glow <- FALSE
      data_label_box  <- TRUE
    } else {
    }
  }
  
  # --- Font validation ---
  font <- valj_typsnitt(font)   # installed, or "sans"/"serif"/"mono"; otherwise "sans" (see zzz.R)

  # --- text_scale: one factor for every text size ---
  title_size       <- title_size       * text_scale
  subtitle_size    <- subtitle_size    * text_scale
  caption_size     <- caption_size     * text_scale
  x_axis_text_size <- x_axis_text_size * text_scale
  y_axis_text_size <- y_axis_text_size * text_scale
  legend_text_size <- legend_text_size * text_scale
  facet_title_size <- facet_title_size * text_scale
  data_label_text_size       <- data_label_text_size       * text_scale
  group_highlight_label_size <- group_highlight_label_size * text_scale

  # --- Input handling ---
  df_work <- df
  
  # Allow vector inputs by injecting them as temporary columns
  if (!is.character(x_value) && length(x_value) > 1) {
    tmp <- paste0("tmp_x_", sample(1000:9999, 1)); df_work[[tmp]] <- x_value; x_value <- tmp
  }
  if (!is.character(y_value) && length(y_value) > 1) {
    tmp <- paste0("tmp_y_", sample(1000:9999, 1)); df_work[[tmp]] <- y_value; y_value <- tmp
  }
  
  # Validate columns exist
  required_cols <- c(x_value, y_value, group, facet_var)
  missing_cols  <- setdiff(required_cols[!sapply(required_cols, is.null)], names(df_work))
  if (length(missing_cols) > 0) stop("Missing columns in data: ", paste(missing_cols, collapse = ", "))
  
  # Guard against empty data frames
  if (nrow(df_work) == 0) {
    warning("func_graf_linjediagram: data frame has 0 rows. Check your filter and factor levels. Returning NULL.")
    return(NULL)
  }
  
  # --- Type detection ---
  # Date-times are drawn on a date axis (scale_x_date only accepts Date, and errored for POSIXct)
  if (inherits(df_work[[x_value]], "POSIXt")) df_work[[x_value]] <- as.Date(df_work[[x_value]])
  is_date       <- inherits(df_work[[x_value]], c("Date", "POSIXct", "POSIXt"))
  is_discrete_x <- !is.numeric(df_work[[x_value]]) && !is_date
  
  # Convert numeric grouping to factor for proper color mapping
  if (!is.null(group) && is.numeric(df_work[[group]])) df_work[[group]] <- factor(df_work[[group]])
  
  # Mark highlighted groups (color-override method)
  if (!is.null(group) && !is.null(highlight_groups))
    df_work$is_highlighted <- df_work[[group]] %in% highlight_groups
  
  # --- Facet text wrapping ---
  if (!is.null(facet_var) && !is.null(facet_title_wrap) && facet_title_wrap > 0) {
    wrap_text <- function(text, width) {
      sapply(as.character(text), function(t) {
        w <- str_wrap(t, width)
        if (any(nchar(strsplit(w, "\n")[[1]]) > width)) {
          chars  <- strsplit(t, "")[[1]]
          chunks <- sapply(seq(1, length(chars), width - 1), function(i) {
            chunk <- paste0(chars[i:min(i + width - 2, length(chars))], collapse = "")
            if (i + width - 1 <= length(chars)) paste0(chunk, "-") else chunk
          })
          paste(chunks, collapse = "\n")
        } else w
      })
    }
    df_work[[facet_var]] <- wrap_text(df_work[[facet_var]], facet_title_wrap)
  }
  if (!is.null(facet_var) && !is.factor(df_work[[facet_var]]))
    df_work[[facet_var]] <- factor(df_work[[facet_var]], levels = unique(df_work[[facet_var]]))
  
  # --- Auto x-axis angle ---
  if (x_angle_auto && x_angle == 0 && length(unique(df_work[[x_value]])) > 8) x_angle <- 45
  
  # --- Auto date breaks ---
  if (is.null(x_axis_n_breaks)) {
    if (is_date) {
      date_range <- as.numeric(difftime(max(df_work[[x_value]], na.rm = TRUE),
                                        min(df_work[[x_value]], na.rm = TRUE), units = "days"))
      if (x_date_breaks == "auto") x_date_breaks <- dplyr::case_when(
        date_range > 3650 ~ "2 years", date_range > 1825 ~ "1 year",
        date_range > 730  ~ "6 months", date_range > 365  ~ "3 months",
        TRUE ~ "2 months"
      )
    } else if (!is_discrete_x) {
      x_axis_n_breaks <- 5
    }
  }
  
  # --- Group order (same rule in linjediagram, stapeldiagram and karta, so the same data gets the same colors) ---
  # Factor: its level order, unused levels dropped. Otherwise: order of first appearance.
  # NA never takes a color slot (drawn in ggplot's na.value color)
  group_levels <- NULL
  if (!is.null(group)) {
    group_levels <- if (is.factor(df_work[[group]])) setdiff(levels(droplevels(df_work[[group]])), NA)
                    else unique(stats::na.omit(as.character(df_work[[group]])))
  }

  # --- Debug mode ---
  if (debug) return(list(
    data = df_work, x_type = class(df_work[[x_value]]), y_type = class(df_work[[y_value]]),
    is_date = is_date, is_discrete_x = is_discrete_x, x_angle = x_angle,
    x_axis_n_breaks = x_axis_n_breaks, x_date_breaks = if (is_date) x_date_breaks else NULL,
    group_levels = group_levels,
    highlighted_groups = highlight_groups
  ))

  # --- Color mapping ---
  color_mapping    <- NULL
  uses_color_scale <- !is.null(group)

  if (uses_color_scale) {
    n_groups     <- length(group_levels)
    if (is.null(colors)) colors <- viridisLite::viridis(n_groups, option = "D")
    if (!is.null(names(colors))) {
      # Named colors: matched by group name
      missing_groups <- setdiff(group_levels, names(colors))
      if (length(missing_groups) > 0) stop("colors is named but has no color for: ", toString(missing_groups))
      color_mapping <- colors[group_levels]
    } else {
      # Unnamed colors: assigned in group order, recycled if too few
      color_mapping <- setNames(rep(colors, length.out = n_groups), group_levels)
    }
    if (!is.null(highlight_groups))
      for (hg in highlight_groups)
        if (hg %in% names(color_mapping)) color_mapping[[hg]] <- highlight_color
    # When group_highlight_label_color is a vector, apply those same colors to the lines
    if (!is.null(group_highlight) && length(group_highlight_label_color) > 1) {
      gg_line_colors <- setNames(
        rep(group_highlight_label_color, length.out = length(group_highlight)),
        group_highlight
      )
      for (g in names(gg_line_colors))
        if (g %in% names(color_mapping)) color_mapping[[g]] <- gg_line_colors[[g]]
    }
  }

  # --- Facet layout (before the x scale: the label room below depends on the panel width) ---
  if (!is.null(facet_var)) {
    n_facets <- length(unique(df_work[[facet_var]]))
    ncol_val <- facet_ncol %||% max(1L, if (n_facets <= 2) n_facets else if (n_facets <= 4) 2L else 3L)
  }

  # --- Category order on a discrete x axis (as ggplot draws it: factor levels, otherwise sorted values) ---
  # Used by the x scale and by the end labels' position check below
  if (is_discrete_x) {
    x_levels <- if (is.factor(df_work[[x_value]])) levels(droplevels(df_work[[x_value]]))
                else sort(unique(as.character(df_work[[x_value]])))
  }

  # --- Label room at the x-axis ends ---
  # Labels that are not repelled stay where they are put, so the panel edge clipped them: data labels without
  # repel are centred on the first/last points (half the label sticks out), and the per-colour end-of-line
  # labels start just right of the last point. Room needed beyond the outermost x, in pt, from the longest
  # label (~0.65 em per character: Verdana is wide; + geom_label padding). Repelled labels (the default, and
  # gghighlight's own end labels) are kept inside the panel by ggrepel and need none
  label_left_pt  <- 0
  label_right_pt <- 0
  if (data_labels && !data_label_repel && any(!is.na(df_work[[y_value]]))) {
    n_char <- max(nchar(format(round(df_work[[y_value]], data_label_decimals), big.mark = " ", decimal.mark = ",",
                               nsmall = data_label_decimals, trim = TRUE)), na.rm = TRUE) +
              (if (data_label_format %in% c("both", "x_y")) max(nchar(as.character(df_work[[x_value]])), na.rm = TRUE) + 2 else 0) +
              (if (data_label_show_group && !is.null(group)) max(nchar(as.character(df_work[[group]])), na.rm = TRUE) +
                 nchar(data_label_group_separator) else 0)
    label_width_pt <- .label_width_pt(n_char, data_label_text_size, data_label_box)
    label_left_pt  <- label_width_pt / 2 + 2   # + 2 pt to the edge
    label_right_pt <- label_width_pt / 2 + 2
  }
  if (!is.null(group_highlight) && !is.null(group) && is.null(facet_var) &&
      group_highlight_label && length(group_highlight_label_color) > 1) {
    # Width of one end label in pt (text + box padding); the same function sizes the room here and the hjust
    # check at the labels, so a label that got its room is never moved
    end_label_w_pt <- function(labels) .label_width_pt(nchar(as.character(labels)), group_highlight_label_size,
                                                       group_highlight_label_box)
    end_label_pt <- max(end_label_w_pt(group_highlight)) * 1.1 + 2   # hjust = -0.1: starts a tenth of its width right of the point
    label_right_pt <- max(label_right_pt, end_label_pt)
  }
  # Convert to x units (days for dates, categories for discrete x). The panel width is only known when drawn —
  # assumed a 6 in (432 pt) wide chart minus the y-axis text (estimated) and, with the legend left or right, its
  # estimated width, split over the facet columns. Wider charts get some extra room; narrower ones or very large
  # text can still clip a little. The x axis normally leaves 5 % of the span on the left and 10 % on the right
  # (discrete: 5 % each side); the room grows only when the labels need more, and never past half the span on
  # either side, so the data keeps at least half the panel (labels wider than that would be clipped anyway).
  # Iterated because the added room itself narrows the scale. Not with x_axis_clip_off, which draws labels
  # outside the panel anyway
  label_room <- NULL
  label_fit <- NULL   # set below when room is made: estimated pt per x unit and the axis limits
  if ((label_left_pt > 0 || label_right_pt > 0) && !x_axis_clip_off) {
    # Discrete: an NA x value is drawn as its own category at the end
    x_span <- if (is_discrete_x) length(unique(df_work[[x_value]])) - 1
              else as.numeric((x_axis_max %||% max(df_work[[x_value]], na.rm = TRUE)) - (x_axis_min %||% min(df_work[[x_value]], na.rm = TRUE)),
                              units = "days")
    if (!is.na(x_span) && x_span > 0) {
      base_room <- if (is_discrete_x) c(0.05, 0.05) * x_span else c(0.05, 0.10) * x_span
      shift     <- if (!is_discrete_x && data_labels && !data_label_repel) data_label_nudge_x else 0   # labels moved right
      legend_pt <- if (!is.null(group) && legend_position %in% c("left", "right")) {
        .legend_width_pt(c(group_levels, legend_title %||% group), legend_text_size)
      } else 0
      # y-axis text from the tick labels as the axis shows them (minus sign, decimals, pretty breaks); once, or
      # per panel with free y scales, where every panel has its own axis
      y_vals    <- df_work[[y_value]][is.finite(df_work[[y_value]])]
      y_tick_chars <- if (length(y_vals)) {
        max(nchar(scales::label_number(big.mark = " ", decimal.mark = ",")(pretty(range(y_vals)))), na.rm = TRUE)
      } else 1
      n_cols    <- if (!is.null(facet_var)) min(ncol_val, n_facets) else 1
      panel_pt  <- .panel_width_pt(legend_pt, y_tick_chars, y_axis_text_size, n_cols,
                                   own_y_axis = !is.null(facet_var) && !facet_same_y_scale)
      label_room <- base_room
      for (i in 1:10) {
        pt_per_unit <- panel_pt / (x_span + sum(label_room))
        label_room  <- pmax(base_room, c(label_left_pt / pt_per_unit - shift, label_right_pt / pt_per_unit + shift))
        label_room  <- pmin(label_room, pmax(base_room, 0.5 * x_span))   # data keeps at least half the panel
      }
      # Kept for the non-repel labels below: the estimated scale and the axis limits in the same units (discrete:
      # category positions 1..n), so a label that would still stick out (cap reached: narrow facets, large text)
      # can be shifted inwards instead of being cut
      first_x <- if (is_discrete_x) 1 else as.numeric(x_axis_min %||% min(df_work[[x_value]], na.rm = TRUE))
      label_fit <- list(pt_per_unit = pt_per_unit,
                        limits = c(first_x - label_room[1], first_x + x_span + label_room[2]))
    }
  }

  # --- X-axis scale setup ---
  x_final_limits <- c(x_axis_min, x_axis_max)
  x_final_expand <- expansion(mult = c(0.05, 0.05))
  x_final_breaks <- NULL
  x_final_labels <- NULL
  # x_axis_clip_off draws labels past the panel edge on every x type (a category axis keeps its normal room;
  # numeric/date x also get the 25 % right margin below)
  use_coord_cartesian_clip_off <- x_axis_clip_off

  if (is_date || is.numeric(df_work[[x_value]])) {
    x_min <- if (!is.null(x_axis_min)) x_axis_min else min(df_work[[x_value]], na.rm = TRUE)
    x_max <- if (!is.null(x_axis_max)) x_axis_max else max(df_work[[x_value]], na.rm = TRUE)

    if (x_axis_clip_off) {
      pct <- if (is_date) {
        dr <- as.numeric(difftime(x_max, x_min, units = "days"))
        list(left = dr * 0.05, right = dr * 0.25)
      } else {
        xr <- x_max - x_min; list(left = xr * 0.05, right = xr * 0.25)
      }
      x_final_limits <- c(x_min - pct$left, x_max + pct$right)
      x_final_expand <- c(0, 0)
      if (is_date) {
        x_final_breaks <- if (x_date_breaks %in% c("auto", NULL))
          as.Date(scales::breaks_pretty(n = x_axis_n_breaks %||% 8)(c(as.numeric(x_min), as.numeric(x_max))), origin = "1970-01-01")
        else seq(x_min, x_max, by = x_date_breaks)
      } else {
        x_final_breaks <- scales::breaks_pretty(n = x_axis_n_breaks %||% 5)(c(x_min, x_max))
        # "whole" labels print as.integer(x), so fractional breaks (2022.5) duplicated years
        if (x_number_format == "whole") x_final_breaks <- x_final_breaks[x_final_breaks == round(x_final_breaks)]
        x_final_labels <- if (x_number_format == "whole") function(x) as.character(as.integer(x)) else label_number(big.mark = " ", decimal.mark = ",")
      }
    } else {
      pct <- if (is_date) {
        dr <- as.numeric(difftime(x_max, x_min, units = "days"))
        list(left = dr * 0.05, right = dr * 0.10)
      } else {
        xr <- x_max - x_min; list(left = xr * 0.05, right = xr * 0.10)
      }
      if (!is.null(label_room)) pct <- list(left = label_room[1], right = label_room[2])   # room for labels (above)
      x_final_limits <- c(x_min - pct$left, x_max + pct$right)
      x_final_expand <- c(0, 0)
      if (is_date) {
        # x_axis_n_breaks was previously ignored for dates (always n = 8)
        all_brk <- if (x_date_breaks %in% c("auto", NULL))
          as.Date(scales::breaks_pretty(n = x_axis_n_breaks %||% 8)(c(as.numeric(x_min), as.numeric(x_max))), origin = "1970-01-01")
        else seq(x_min, x_max, by = x_date_breaks)
        x_final_breaks <- all_brk[all_brk >= x_min & all_brk <= x_max]
      } else {
        all_brk <- scales::breaks_pretty(n = x_axis_n_breaks %||% 5)(c(x_min, x_max))
        # "whole" labels print as.integer(x), so fractional breaks (2022.5) duplicated years
        if (x_number_format == "whole") all_brk <- all_brk[all_brk == round(all_brk)]
        x_final_breaks <- all_brk[all_brk >= x_min & all_brk <= x_max]
        x_final_labels <- if (x_number_format == "whole") function(x) as.character(as.integer(x)) else label_number(big.mark = " ", decimal.mark = ",")
      }
    }
  }
  
  # ============================================================
  #  BASE PLOT
  # ============================================================
  if (!is.null(group_highlight) && !is.null(group))
    df_work$.gg_flag <- df_work[[group]] %in% group_highlight

  # ggplot() snapshots df_work at call time, so any column used in aes() must be added before this call
  if (!is.null(group) && !is.null(highlight_groups))
    df_work$line_size_var <- ifelse(df_work$is_highlighted, highlight_line_size, line_size)

  p <- ggplot(df_work, aes(x = .data[[x_value]], y = .data[[y_value]]))

  # --- Lines ---
  if (!is.null(group)) {
    if (!is.null(highlight_groups)) {
      # scale_linewidth_identity(): line_size_var holds actual widths - the default continuous
      # linewidth scale rescaled them to the range 1-6, ignoring line_size/highlight_line_size
      p <- p + geom_line(aes(group = .data[[group]], color = .data[[group]], linewidth = line_size_var),
                         linetype = line_type, show.legend = c(color = TRUE, linewidth = FALSE)) +
        scale_linewidth_identity()
    } else {
      p <- p + geom_line(aes(group = .data[[group]], color = .data[[group]]),
                         linewidth = line_size, linetype = line_type)
    }
    if (!is.null(highlight_groups) && highlight_bold) {
      # override.aes follows the legend order, i.e. the color scale's (sorted) levels - not the
      # data order of names(color_mapping), which bolded the wrong legend keys for unsorted data
      legend_levels <- if (is.factor(df_work[[group]])) levels(droplevels(df_work[[group]]))
                       else sort(unique(as.character(df_work[[group]])))
      p <- p + guides(color = guide_legend(override.aes = list(
        linewidth = ifelse(legend_levels %in% highlight_groups, highlight_line_size, line_size))))
    }
  } else {
    line_color <- if (!is.null(colors)) colors[1] else "#2E86AB"
    p <- p + geom_line(aes(group = 1), color = line_color, linewidth = line_size, linetype = line_type)
  }
  
  # --- Color scale ---
  if (uses_color_scale && !is.null(color_mapping))
    p <- p + scale_color_manual(values = color_mapping, name = legend_title %||% group)
  
  # --- gghighlight (fade-out method) ---
  if (!is.null(group_highlight) && !is.null(facet_var)) {
    warning("group_highlight is not compatible with facet_var and will be skipped. Use highlight_groups instead.")
    group_highlight <- NULL
  }
  
  if (!is.null(group_highlight) && !is.null(group)) {
    if (!requireNamespace("gghighlight", quietly = TRUE)) stop("Paketet 'gghighlight' krävs för group_highlight. Installera med install.packages('gghighlight').")
    
    use_manual_label_colors <- length(group_highlight_label_color) > 1 ||
      (length(group_highlight_label_color) == 1 &&
         group_highlight_label_color != "inherit")
    use_per_group_colors    <- length(group_highlight_label_color) > 1
    
    if (use_per_group_colors) {
      gg_label_color_map <- setNames(
        rep(group_highlight_label_color, length.out = length(group_highlight)),
        group_highlight
      )
    }
    
    # Chart font (labels fell back to the device default); fixed seed so ggrepel places them the same way every
    # time (they moved between renders), like the data labels
    lbl_params <- list(size = group_highlight_label_size, family = font, seed = 42)
    if (!group_highlight_label_box) {
      # gghighlight draws the end labels with ggrepel::geom_label_repel()
      lbl_params <- c(lbl_params, list(fill = NA),
                      .label_border_off(ggrepel::geom_label_repel, ggrepel::GeomLabelRepel))
    }
    if (use_manual_label_colors && !use_per_group_colors)
      lbl_params$colour <- group_highlight_label_color
    
    p <- p + gghighlight::gghighlight(
      .gg_flag,
      use_direct_label     = if (use_per_group_colors) FALSE else group_highlight_label,
      label_key            = !!sym(group),
      label_params         = lbl_params,
      unhighlighted_params = list(
        color = group_highlight_unhighlighted_color,
        alpha = group_highlight_unhighlighted_alpha
      )
    )
    
    if (group_highlight_label && use_per_group_colors) {
      df_end <- df_work %>%
        filter(.data[[group]] %in% group_highlight) %>%
        group_by(.data[[group]]) %>%
        slice_max(order_by = .data[[x_value]], n = 1, with_ties = FALSE) %>%
        ungroup() %>%
        mutate(.label_color = gg_label_color_map[as.character(.data[[group]])])
      
      # geom_text has no box, so it takes no fill/label.size (passing them only gave warnings)
      geom_fn  <- if (group_highlight_label_box) geom_label else geom_text
      # Start just right of the point (hjust -0.1); when the axis room could not cover the label (see "Label
      # room": narrow chart, wide legend) it is shifted left just enough to end at the panel edge instead of
      # being cut. Vector hjust is fine here: group_highlight is not allowed with facets, so rows keep their order
      end_hjust <- rep(-0.1, nrow(df_end))
      if (!is.null(label_fit) && nrow(df_end) > 0) {
        # x as a position in the same units as label_fit$limits: discrete x = category position (level order as
        # on the axis: factor levels, otherwise sorted values), not the label's text
        x_end <- if (is_discrete_x) {
          match(as.character(df_end[[x_value]]), x_levels)
        } else as.numeric(df_end[[x_value]])
        w_units <- end_label_w_pt(df_end[[group]]) / label_fit$pt_per_unit
        gap     <- 2 / label_fit$pt_per_unit   # the same 2 pt to the edge as the room
        # right edge = x + (1 - hjust) * width must stay within the limit
        end_hjust <- pmin(pmax(-0.1, 1 - (label_fit$limits[2] - gap - x_end) / w_units), 1)
        end_hjust[is.na(end_hjust)] <- -0.1
      }

      p <- p + do.call(geom_fn, list(
        data    = df_end,
        mapping = aes(label = .data[[group]]),
        x       = df_end[[x_value]],
        y       = df_end[[y_value]],
        color   = df_end$.label_color,
        size    = group_highlight_label_size,
        family  = font,
        hjust   = end_hjust,
        show.legend = FALSE
      ))
    }
  }
  
  # --- Reference lines ---
  if (!is.null(x_break_line)) p <- p + geom_vline(xintercept = x_break_line, linewidth = 0.5, linetype = "dashed", color = "black")
  if (!is.null(y_break_line)) p <- p + geom_hline(yintercept = y_break_line, linewidth = 0.5, linetype = "solid",  color = "black")
  
  # --- X-axis scale ---
  if (is_date) {
    p <- p + if (!is.null(x_final_breaks))
      scale_x_date(date_labels = x_date_labels, breaks = x_final_breaks, limits = x_final_limits, expand = x_final_expand)
    else
      scale_x_date(date_labels = x_date_labels, date_breaks = x_date_breaks, limits = x_final_limits, expand = x_final_expand)
  } else if (is_discrete_x) {
    # Discrete x (character/factor): thin out tick labels to ~x_axis_n_breaks evenly spaced levels
    # (x_levels: the axis order, see "Category order" above)
    n_keep   <- min(x_axis_n_breaks %||% length(x_levels), length(x_levels))
    # seq(...) always includes index 1 and the last index -> first and last category are never dropped
    keep_idx <- if (n_keep >= 2) unique(round(seq(1, length(x_levels), length.out = n_keep))) else 1
    # Room for labels at the ends (see "Label room" above): label_room includes the 5 % already given by mult
    discrete_add <- if (!is.null(label_room)) label_room - 0.05 * x_span else c(0, 0)
    p <- p + scale_x_discrete(breaks = if (n_keep < length(x_levels)) x_levels[keep_idx] else waiver(),
                              expand = expansion(mult = c(0.05, 0.05), add = discrete_add))
  } else {
    p <- p + scale_x_continuous(labels = x_final_labels, limits = x_final_limits, expand = x_final_expand,
                                breaks = x_final_breaks, n.breaks = if (is.null(x_final_breaks)) x_axis_n_breaks else NULL)
  }
  
  p <- p + scale_y_continuous(labels = label_number(big.mark = " ", decimal.mark = ","),
                              # NA = automatic end; c(y_axis_min, y_axis_max) had length 1 and errored
                              # when only one of them was given
                              limits = if (is.null(y_axis_min) && is.null(y_axis_max)) NULL
                                       else c(y_axis_min %||% NA, y_axis_max %||% NA),
                              expand = expansion(mult = c(0.05, 0.15)))
  
  # --- Facets ---
  if (!is.null(facet_var)) {   # n_facets / ncol_val: see "Facet layout" above
    p <- p + facet_wrap(vars(.data[[facet_var]]),
                        scales = if (facet_same_y_scale) "fixed" else "free_y",
                        ncol = ncol_val)
  }
  
  # ============================================================
  #  DATA LABELS
  # ============================================================
  if (data_labels) {
    df_labels <- df_work
    x_filter  <- data_label_filter %||% data_label_x_values
    
    # Filter: first/last points only
    if (data_label_first_last) {
      grp_vars  <- c(if (!is.null(group)) group, if (!is.null(facet_var)) facet_var)
      # Sort on x first - slice() takes rows in data order, so unsorted data gave arbitrary points
      df_labels <- if (length(grp_vars) > 0)
        df_labels %>% group_by(across(all_of(grp_vars))) %>% arrange(.data[[x_value]], .by_group = TRUE) %>%
          slice(unique(c(1, n()))) %>% ungroup()
      else df_labels %>% arrange(.data[[x_value]]) %>% slice(unique(c(1, n())))
    }
    
    # Filter: specific x / y values
    if (!is.null(x_filter))            df_labels <- df_labels %>% filter(.data[[x_value]] %in% x_filter)
    if (!is.null(data_label_y_values)) df_labels <- df_labels %>% filter(.data[[y_value]] %in% data_label_y_values)
    
    # Show every Nth label per group/facet
    if (!is.null(data_label_skip) && data_label_skip > 1) {
      skip_vars <- c(if (!is.null(group)) group, if (!is.null(facet_var)) facet_var)
      if (length(skip_vars) > 0) {
        df_labels <- df_labels %>%
          group_by(across(all_of(skip_vars))) %>%
          arrange(.data[[x_value]], .by_group = TRUE) %>%
          filter(row_number() %% data_label_skip == 1) %>% ungroup()
      } else {
        df_labels <- df_labels %>% arrange(.data[[x_value]]) %>% filter(row_number() %% data_label_skip == 1)
      }
    }
    
    # Deduplicate
    dedup_vars <- c(if (!is.null(group)) group, if (!is.null(facet_var)) facet_var, x_value)
    df_labels  <- df_labels %>% group_by(across(all_of(dedup_vars))) %>% slice(1) %>% ungroup()
    
    # Build label text
    df_labels <- df_labels %>% mutate(
      base_val   = format(round(.data[[y_value]], data_label_decimals), big.mark = " ", decimal.mark = ",", nsmall = data_label_decimals, trim = TRUE),
      label_text = if (data_label_format %in% c("both", "x_y"))
        paste0(.data[[x_value]], ": ", base_val)
      else base_val
    )
    if (data_label_show_group && !is.null(group))
      df_labels <- df_labels %>%
      mutate(label_text = paste0(.data[[group]], data_label_group_separator, label_text))
    
    # Label colors
    df_labels$label_color <- if (data_label_color == "auto" && !is.null(group) && !is.null(color_mapping))
      color_mapping[as.character(df_labels[[group]])]
    else data_label_color
    
    labels_use_color_aes <- data_label_color == "auto" && !is.null(group)
    
    label_fontface <- if (!is.null(highlight_groups) && "is_highlighted" %in% names(df_labels))
      ifelse(df_labels$is_highlighted, "bold", "plain")
    else "plain"
    
    if (nrow(df_labels) > 0) {
      use_glow <- data_label_glow && requireNamespace("ggfx", quietly = TRUE)
      
      lbl_aes <- if (labels_use_color_aes)
        aes(x = .data[[x_value]], y = .data[[y_value]], label = label_text, color = .data[[group]])
      else
        aes(x = .data[[x_value]], y = .data[[y_value]], label = label_text)
      
      if (data_label_repel) {
        
        # Resolve repel direction from nudge values when "auto"
        resolved_direction <- if (data_label_direction != "auto") {
          data_label_direction
        } else if (data_label_nudge_x != 0 && data_label_nudge_y == 0) {
          "x"
        } else if (data_label_nudge_y != 0 && data_label_nudge_x == 0) {
          "y"
        } else {
          "both"
        }
        
        repel_args <- list(
          data = df_labels, mapping = lbl_aes, inherit.aes = FALSE,
          size = data_label_text_size, family = font, show.legend = FALSE, fontface = label_fontface,
          na.rm = TRUE, max.overlaps = Inf,
          nudge_x = data_label_nudge_x, nudge_y = data_label_nudge_y,
          direction = resolved_direction, force = 20, force_pull = 0.5,
          box.padding = 1.0, point.padding = 1.0, min.segment.length = 0,
          segment.color = "grey50", segment.size = 0.3, seed = 42
        )
        if (!labels_use_color_aes) repel_args$color <- df_labels$label_color
        
        if (data_label_box && !use_glow) {
          repel_args  <- c(repel_args, list(fill = alpha(data_label_box_color, data_label_box_alpha)),
                           .label_border_off(geom_label_repel, ggrepel::GeomLabelRepel, label_size = NA))
          label_layer <- do.call(geom_label_repel, repel_args)
        } else {
          label_layer <- do.call(geom_text_repel, repel_args)
        }
        
      } else {
        # Non-repel
        df_labels <- df_labels %>% mutate(
          x_nudged = if (is_date) as.Date(.data[[x_value]]) + data_label_nudge_x
          else if (is_discrete_x) .data[[x_value]]
          else .data[[x_value]] + data_label_nudge_x,
          y_nudged = .data[[y_value]] + data_label_nudge_y
        )
        # Centred on the point (hjust 0.5), unless the estimate says the label would stick out past the axis
        # limits even with the label room (its cap reached: narrow facets, large text): then hjust moves it just
        # inside (0 = starts at the point, 1 = ends there), like the D3 version. Labels that fit keep 0.5, so
        # charts with enough room are unchanged. A mapped column (not a vector) so it follows each label when
        # ggplot reorders rows by facet
        df_labels$.hjust <- 0.5
        if (!is.null(label_fit)) {
          x_lab <- if (is_discrete_x) match(as.character(df_labels[[x_value]]), x_levels)
                   else as.numeric(df_labels[[x_value]]) + data_label_nudge_x
          df_labels$.hjust <- .label_hjust_inside(df_labels$label_text, x_lab, label_fit$limits[1], label_fit$limits[2],
                                                  label_fit$pt_per_unit, data_label_text_size, data_label_box)
        }
        nr_aes <- if (labels_use_color_aes)
          aes(x = x_nudged, y = y_nudged, label = label_text, color = .data[[group]], hjust = .hjust)
        else
          aes(x = x_nudged, y = y_nudged, label = label_text, hjust = .hjust)

        nr_args <- list(data = df_labels, mapping = nr_aes, inherit.aes = FALSE,
                        size = data_label_text_size, family = font, show.legend = FALSE, fontface = label_fontface,
                        na.rm = TRUE)
        if (!labels_use_color_aes) nr_args$color <- df_labels$label_color
        
        if (data_label_box && !use_glow) {
          nr_args     <- c(nr_args, list(fill = alpha(data_label_box_color, data_label_box_alpha)),
                           .label_border_off(geom_label, ggplot2::GeomLabel, label_size = NA))
          label_layer <- do.call(geom_label, nr_args)
        } else {
          label_layer <- do.call(geom_text, nr_args)
        }
      }
      
      p <- p + if (use_glow)
        ggfx::with_outer_glow(label_layer, colour = data_label_glow_color,
                        sigma = data_label_glow_sigma, expand = data_label_glow_expand)
      else label_layer
    }
  }
  
  # ============================================================
  #  THEME AND STYLING
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
      # Axis and legend titles have no own size parameter: relative to the inherited text size (11 pt, or
      # whatever a later theme(text = ...) sets, e.g. func_skapa_pptx's 12), scaled by text_scale.
      # inherit.blank keeps a later theme(title = element_blank()) working
      axis.title          = element_text(size = rel(text_scale), inherit.blank = TRUE),
      legend.title        = element_text(size = rel(text_scale), inherit.blank = TRUE),
      legend.position     = legend_position,
      plot.background     = element_rect(fill = "white", color = NA)
    )

  # Grid and axis lines. TRUE/FALSE set the parent element exactly as before, so a later
  # custom_theme / + theme(panel.grid...) still reaches both directions; "x"/"y" blank the parent
  # and draw only that child. Axis lines are only set when switched on (default TRUE = as before)
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

  if (use_coord_cartesian_clip_off) p <- p + coord_cartesian(clip = "off")
  
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
    caption  = if (!is.null(caption_x) && !is.null(caption_y)) NULL else caption,
    x = x_axis_title, y = y_axis_title
  )
  
  # Free-placed caption
  if (!is.null(caption) && !is.null(caption_x) && !is.null(caption_y)) {
    p <- p + annotate(
      "text",
      x      = caption_x,
      y      = caption_y,
      label  = caption,
      size   = caption_size / ggplot2::.pt,
      hjust  = caption_hjust,
      vjust  = caption_vjust,
      family = font,
      color  = "grey40"
    )
  }
  
  if (!is.null(custom_theme)) p <- p + custom_theme

  return(p)
}

# Parameters that remove the border around labels from geom_label()/geom_label_repel().
# Newer versions (ggplot2 >= 3.5.0, ggrepel 0.9.8) draw the border from the linewidth
# aesthetic and ignore or deprecate label.size; older versions only know label.size.
# geom_fun is the layer function, geom its ggproto (e.g. ggrepel::GeomLabelRepel).
# label_size is the value used on older versions (0 or NA, as before).
#' @noRd
.label_border_off <- function(geom_fun, geom, label_size = 0) {
  if (!"linewidth" %in% names(geom$default_aes)) return(list(label.size = label_size))
  params <- list(linewidth = 0)
  # linewidth 0 can still give a hairline on some devices; border.colour removes it
  if ("border.colour" %in% names(formals(geom_fun))) params$border.colour <- NA
  params
}
