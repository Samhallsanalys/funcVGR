# Fungerar bara i RStudio, med ett sparat skript öppet
if (rstudioapi::isAvailable()) {
  tidigare <- getwd()
  func_setwd()
  setwd(tidigare)  # återställ arbetskatalogen efter exemplet
}
