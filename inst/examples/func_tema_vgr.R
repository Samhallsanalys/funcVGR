df <- data.frame(ar = rep(2020:2024, 2),
                 region = rep(c("Västra Götaland", "Riket"), each = 5),
                 andel = c(8.3, 7.9, 6.8, 7.0, 7.4, 8.5, 8.8, 7.5, 7.7, 8.4))

ggplot2::ggplot(df, ggplot2::aes(ar, andel, color = region)) +
  ggplot2::geom_line(linewidth = 1.2) +
  ggplot2::scale_color_manual(values = func_fargtema("vgr")) +
  ggplot2::labs(title = "Arbetslöshet", x = NULL, y = "Procent", color = NULL) +
  func_tema_vgr()
