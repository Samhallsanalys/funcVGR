# Påhittade data: disponibel inkomst (tkr) för 1 200 personer i fyra delregioner
set.seed(1)
regioner <- c("Göteborgsregionen", "Sjuhärad", "Fyrbodal", "Skaraborg")
inkomst <- data.frame(
  region  = rep(regioner, each = 300),
  kon     = rep(c("Kvinnor", "Män"), 600),
  inkomst = round(c(rlnorm(300, log(320), 0.35), rlnorm(300, log(290), 0.3),
                    rlnorm(300, log(280), 0.3), rlnorm(300, log(285), 0.28)))
)

# Enklaste anropet: en låda för alla värden
func_graf_ladagram(inkomst, y_value = "inkomst")

# En låda per delregion, sorterade efter medianen, med medelvärdet som romb och
# medianen som etikett
func_graf_ladagram(inkomst, x_value = "region", y_value = "inkomst",
                   sort_by = "value_desc", box_mean = TRUE, data_labels = TRUE,
                   data_label_decimals = 0, y_axis_title = "Disponibel inkomst (tkr)",
                   title = "Inkomst per delregion")

# Kvinnor och män bredvid varandra i varje delregion, liggande lådor
func_graf_ladagram(inkomst, x_value = "region", y_value = "inkomst", group = "kon",
                   horizontal = TRUE, y_break_line = "median")

# Samma diagram under det engelska namnet, med alla värden som punkter
func_graf_boxplot(inkomst[inkomst$region %in% regioner[1:2], ], x_value = "region",
                  y_value = "inkomst", point_show = TRUE)
