# Påhittade data: ålder och kön för 2 000 personer
set.seed(1)
personer <- data.frame(
  alder = round(c(rnorm(1000, 42, 13), rnorm(1000, 47, 15))),
  kon   = rep(c("Kvinnor", "Män"), each = 1000),
  lan   = sample(c("Västra Götaland", "Skåne"), 2000, replace = TRUE)
)
personer <- personer[personer$alder >= 16 & personer$alder <= 90, ]

# Enklaste anropet: bara de obligatoriska parametrarna (intervallen väljs automatiskt)
func_graf_histogram(personer, x_value = "alder")

# Femårsklasser, staplat per kön, med medianen som referenslinje
func_graf_histogram(personer, x_value = "alder", group = "kon", bin_width = 5,
                    x_break_line = "median", x_axis_title = "Ålder", y_axis_title = "Antal",
                    title = "Åldersfördelning")

# Jämför fördelningarnas form: andel inom varje kön, grupperna över varandra
func_graf_histogram(personer, x_value = "alder", group = "kon", bin_width = 5,
                    bar_type = "overlay", histogram_y = "percent", y_axis_title = "Andel")

# En panel per län, med antal ovanför staplarna
func_graf_histogram(personer, x_value = "alder", facet_var = "lan", bin_width = 10,
                    data_labels = TRUE)
