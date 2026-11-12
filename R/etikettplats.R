# Internal helpers for the label room at the axis ends (func_graf_linjediagram, func_graf_barchart).
# ggplot only knows the panel size when the chart is drawn, so the room is estimated beforehand from an
# assumed 6 x 4 in chart and the label lengths. func_graf_dumbbell has its own calibration (0.57 em, other
# margins) and does not use these.

# Width of a label in pt: ~0.65 em per character (Verdana is wide) plus geom_label's padding when boxed.
# n_char: characters on the longest line, size: text size in mm (ggplot units), box: drawn with a box
.label_width_pt <- function(n_char, size, box) {
  n_char * size * ggplot2::.pt * 0.65 + (if (box) 2 * 0.25 * size * ggplot2::.pt else 0)
}

# Estimated width of a legend placed left or right, in pt (longest text + key and spacing)
.legend_width_pt <- function(labels, size) {
  max(nchar(labels), na.rm = TRUE) * size * 0.65 + 30
}

# Assumed panel width in pt: a 6 in (432 pt) wide chart minus plot margins, the spacing between facet
# columns, the y-axis text (y_tick_chars characters at y_size pt; per panel when every panel has its own
# y axis) and the legend, split over the facet columns. Never below 40 pt
.panel_width_pt <- function(legend_pt, y_tick_chars, y_size, n_cols, own_y_axis) {
  y_axis_pt <- y_tick_chars * y_size * 0.65 + 12
  frame_pt  <- 20 + (n_cols - 1) * 6
  panel_pt  <- if (own_y_axis) (432 - frame_pt - legend_pt) / n_cols - y_axis_pt
               else (432 - frame_pt - y_axis_pt - legend_pt) / n_cols
  max(panel_pt, 40)
}

# hjust that keeps centred labels inside the axis limits [lo, hi]: 0.5 when the label fits, otherwise
# moved just inside (0 = starts at the point, 1 = ends there). A label wider than the whole axis can't fit
# anywhere and stays centred (as the D3 version). centre, lo, hi in axis units; pt_per_unit converts the
# estimated label width (longest line of label_text, + 4 pt) to those units
.label_hjust_inside <- function(label_text, centre, lo, hi, pt_per_unit, size, box) {
  longest <- vapply(strsplit(label_text, "\n"), function(l) max(nchar(l)), numeric(1))
  w_units <- (.label_width_pt(longest, size, box) + 4) / pt_per_unit
  h <- pmin(pmax(0.5, (centre + w_units - hi) / w_units), (centre - lo) / w_units)
  ifelse(is.na(h) | w_units > hi - lo, 0.5, pmin(pmax(h, 0), 1))
}
