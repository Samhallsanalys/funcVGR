# Typsnitt i R:s egna grafikenheter
#
# Diagrammen använder ett typsnitt från datorns installerade typsnitt (standard Verdana,
# kontrollerat med systemfonts). Enheter som bygger på systemfonts (ragg, svglite, rvg) hittar
# det direkt, men två av R:s egna enheter har egna register och känner bara till "sans",
# "serif" och "mono":
#
# * Windows grafikenhet (windows(), png(type = "windows"), Rgui och RStudios "Default"-backend)
#   varnar "font family not found in Windows font database" och använder ett standardtypsnitt.
#   Här registreras typsnittet med sitt Windows-namn, så att äkta Verdana används.
# * pdf()/postscript() avbryter med "invalid font type". De kan inte använda systemets typsnitt,
#   så här registreras Helvetica som ersättning. Äkta Verdana i PDF fås med cairo_pdf,
#   t.ex. ggsave("fil.pdf", device = cairo_pdf).
#
# Befintliga registreringar ändras aldrig.
registrera_typsnitt <- function(family) {
  if (is.null(family) || length(family) != 1 || is.na(family) || !nzchar(family) ||
      family %in% c("sans", "serif", "mono")) {
    return(invisible(family))
  }

  if (.Platform$OS.type == "windows") {
    # windowsFonts()/windowsFont() finns bara i grDevices på Windows
    win_fonts <- get("windowsFonts", envir = asNamespace("grDevices"))
    win_font  <- get("windowsFont",  envir = asNamespace("grDevices"))
    if (!family %in% names(win_fonts())) {
      do.call(win_fonts, stats::setNames(list(win_font(family)), family))
    }
  }

  if (!family %in% names(grDevices::pdfFonts())) {
    do.call(grDevices::pdfFonts, stats::setNames(list(grDevices::pdfFonts()$Helvetica), family))
  }
  if (!family %in% names(grDevices::postscriptFonts())) {
    do.call(grDevices::postscriptFonts,
            stats::setNames(list(grDevices::postscriptFonts()$Helvetica), family))
  }
  invisible(family)
}

# Typsnittet som diagrammen använder: ett installerat typsnitt eller R:s generiska "sans", "serif"
# och "mono". Annars "sans", med ett meddelande. Registreras för Windows- och PDF-enheterna (ovan).
valj_typsnitt <- function(font) {
  if (!font %in% c(systemfonts::system_fonts()$family, "sans", "serif", "mono")) {
    message(sprintf("Font '%s' not found. Using 'sans'. Run View(systemfonts::system_fonts()) to see available fonts.", font))
    font <- "sans"
  }
  registrera_typsnitt(font)
  font
}

.onLoad <- function(libname, pkgname) {
  # Standardtypsnittet registreras direkt, så att det även fungerar i egna ggplot2-diagram
  # med func_tema_vgr() och i diagram som skrivs ut innan någon funktion har anropats
  registrera_typsnitt("Verdana")
}
