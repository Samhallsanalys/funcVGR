df <- data.frame(id = 1:10, q1 = sample(1:4, 10, replace = TRUE))
func_censur_brus(df, cols = q1, seed = 42)

# Klipp till [1, 4] och egna sannolikheter
func_censur_brus(df, cols = dplyr::starts_with("q"), clip = c(1, 4),
                 probs = c(`-1` = .25, `0` = .5, `1` = .25), seed = 1)
