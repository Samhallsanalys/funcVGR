# Modern ggplot2 theme using ink/paper system and new features
#' ggplot2-tema i VGR:s stil
#'
#' Minimalistiskt tema baserat på [ggplot2::theme_minimal()]: vit bakgrund,
#' inga stödlinjer, axellinjer nere och till vänster, fet rubrik och
#' förklaringen överst.
#'
#' Typsnittet hämtas från datorns installerade typsnitt via \pkg{systemfonts}.
#' Saknas det används `"sans"`, med ett meddelande.
#'
#' @param base_size Grundstorlek för text i punkter.
#' @param base_family Typsnitt. Måste vara installerat på datorn, se
#'   [systemfonts::system_fonts()].
#' @param ink Färg för primär text (rubrik, axelrubriker).
#' @param paper Bakgrundsfärg.
#' @param accent_ink Färg för sekundär text (underrubrik, skaltext,
#'   förklaring).
#' @param grid_ink Färg för stödlinjer (används inte, eftersom stödlinjerna
#'   är avstängda).
#' @param light_ink Färg för `caption`.
#'
#' @return Ett ggplot2-tema.
#' @export
#'
#' @example inst/examples/func_tema_vgr.R
func_tema_vgr <- function(base_size = 16, 
                               base_family = "Verdana",
                               ink = "#37474F",           # Primary text color
                               paper = "white",          # Background color
                               accent_ink = "#37474F",    # Secondary text color
                               grid_ink = "grey90",      # Grid color
                               light_ink = "#37474F") {   # Caption/light text color
  
  # Font validation via systemfonts (same approach as the chart functions): installed system
  # fonts are used directly by the graphics devices, so no registration is needed
  if (!base_family %in% c(systemfonts::system_fonts()$family, "sans", "serif", "mono")) {
    message(sprintf("Font '%s' not found. Using 'sans'. Run View(systemfonts::system_fonts()) to see available fonts.", base_family))
    base_family <- "sans"
  }
  registrera_typsnitt(base_family)  # så att Windows- och PDF-enheterna hittar typsnittet (se zzz.R)

  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      # Modern background system using paper parameter
      plot.background = element_rect(fill = paper, color = NA),
      panel.background = element_rect(fill = paper, color = NA),
      
      # Grid lines using ink-based colors (updated to use linewidth instead of size)
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      
      # Axes using ink parameter system
      axis.line = element_blank(),
      axis.line.x.bottom = element_line(),
      axis.line.y.left = element_line(),
      axis.ticks = element_blank(),
      axis.text.x = element_text(color = accent_ink, size = base_size, family = base_family),
      axis.text.y = element_text(color = accent_ink, size = base_size, family = base_family),
      axis.title.x = element_text(color = ink, size = base_size, margin = margin(t = 15)),
      axis.title.y = element_text(color = ink, size = base_size, margin = margin(r = 15)),
      
      # Typography hierarchy using ink system
      plot.title = element_text(
        color = ink, 
        family = base_family,
        size = base_size + 2, 
        face = "bold", 
        margin = margin(b = 5),
        lineheight = 1.2
      ),
      plot.subtitle = element_text(
        color = accent_ink, 
        family = base_family,
        size = base_size - 1, 
        margin = margin(b = 20),
        lineheight = 1.3
      ),
      
      # Modern legend styling
      legend.position = "top",
      legend.direction = "horizontal",
      legend.justification = "left",
      legend.title = element_text(color = ink, size = base_size, face = "bold"),
      legend.text = element_text(color = accent_ink, size = base_size, family = base_family),
      legend.key.size = unit(0.8, "cm"),
      legend.key = element_rect(fill = NA, color = NA),
      legend.margin = margin(b = 20),
      legend.box.spacing = unit(0.5, "cm"),
      legend.spacing.x = unit(0.3, "cm"),
      
      # Faceting with ink colors
      strip.background = element_blank(),
      strip.text = element_text(
        color = ink, 
        size = base_size,
        family = base_family,
        face = "bold",
        margin = margin(b = 10)
      ),
      
      # Responsive margins
      plot.margin = margin(20, 20, 20, 20),
      
      # Caption styling
      plot.caption = element_text(
        color = light_ink, 
        size = base_size - 2, 
        hjust = 1, 
        family = base_family,
        margin = margin(t = 15),
        lineheight = 1.2
      )
    )
}
