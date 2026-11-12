df <- data.frame(kommun = rep(c("Borås", "Göteborg", "Skövde", "Trollhättan"), 2),
                 ar = rep(c("2014", "2024"), each = 4),
                 andel = c(8.1, 7.4, 5.2, 10.3, 6.9, 6.8, 4.1, 9.2))

func_graf_dumbbell(df, x_value = "kommun", y_value = "andel", group = "ar",
                   highlight_x_values = "Göteborg",
                   title = "Arbetslöshet 2014 och 2024")

# Sorterat på förändring, med pilar och etiketter på båda punkterna
func_graf_dumbbell(df, x_value = "kommun", y_value = "andel", group = "ar",
                   sort_axis_by = "change", show_direction_arrow = TRUE,
                   data_label_position = "both", legend_position = "bottom")

# Utan ggrepel: etiketterna hamnar på den sida som pekar bort från den andra
# punkten (data_label_side = "value"), och axeln får plats för etiketterna.
# clip off visar etiketter som ändå hamnar utanför panelen.
func_graf_dumbbell(df, x_value = "kommun", y_value = "andel", group = "ar",
                   data_label_position = "both", data_label_repel = FALSE,
                   x_axis_clip_off = TRUE)

# Stående, med bara vågräta stödlinjer, utan y-axellinje och med större text
# för export
func_graf_dumbbell(df, x_value = "kommun", y_value = "andel", group = "ar",
                   dumbbell_horizontal = FALSE, show_major_grid = "y",
                   y_axis_line = FALSE, text_scale = 1.3)
