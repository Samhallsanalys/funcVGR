#' Skapa en PowerPoint-presentation från en lista med diagram
#'
#' Skapar en presentation från en PowerPoint-mall: en rubrikbild, en bild per
#' objekt i `plot_list` och en avslutande bild. Objekten kan vara
#' `ggplot`-diagram, `flextable`-tabeller, basgrafik sparad med
#' [grDevices::recordPlot()] eller lattice-diagram. Andra objekt ger en varning
#' och en bild utan innehåll. ggplot-diagram läggs in som PNG eller, om `use_png_instead_of_vector =
#' FALSE`, som redigerbar vektorgrafik via \pkg{rvg}. Platshållare för rubrik
#' och innehåll hittas automatiskt, både svenska och engelska namn.
#'
#' Paketet innehåller mallen `format_ppt_ru.pptx`, som används som standard.
#'
#' @param plot_list Lista med diagram/tabeller (se ovan vilka typer som går). Om
#'   listan är namngiven används namnen som bildrubriker. Obligatorisk.
#' @param template_path Sökväg till PowerPoint-mallen (.pptx).
#' @param output_path Sökväg där presentationen sparas (.pptx). Obligatorisk.
#' @param layout_name Layout för diagrambilderna.
#' @param first_slide_layout Layout för första bilden.
#' @param last_slide_layout Layout för sista bilden.
#' @param plot_width,plot_height Diagrammets bredd och höjd i tum.
#' @param use_png_instead_of_vector `TRUE` = alltid PNG, `FALSE` =
#'   vektorgrafik för ggplot-diagram.
#' @param ppt_font Typsnitt för vektorgrafik.
#' @param png_dpi Upplösning för PNG-bilder (typiskt 150–300).
#' @param slide_titles Vektor med bildrubriker. `NULL` = namnen i `plot_list`,
#'   annars "Plot 1", "Plot 2", ...
#' @param content_placeholder Namn på platshållaren för innehåll. `NULL` =
#'   hittas automatiskt (annars den största platshållaren).
#' @param title_placeholder Namn på platshållaren för rubrik. `NULL` = hittas
#'   automatiskt.
#' @param presentation_title Rubrik på första bilden.
#' @param verbose `TRUE` skriver ut förloppet och tillgängliga layouter.
#'
#' @return `output_path`, osynligt.
#' @seealso [func_graf_tabell()]
#' @export
#'
#' @example inst/examples/func_skapa_pptx.R
func_skapa_pptx <- function(
    plot_list, # List of plot objects (ggplot, base R plots, flextable, etc.) - REQUIRED
    template_path = system.file("extdata", "format_ppt_ru.pptx", package = "funcVGR"), # Path to PowerPoint template file (.pptx)
    output_path, # Path where to save output presentation (.pptx) - REQUIRED  
    
    layout_name = "Rubrik och innehåll", # Layout name for plot slides (default: "Rubrik och innehåll")
    first_slide_layout = "Rubrikbild", # Layout for first slide (default: "Rubrikbild")
    last_slide_layout = "Svart logo/Vit bakgrund", # Layout for last slide (default: "Svart logo/Vit bakgrund")
    
    plot_width = 10, # Plot width in inches (1-20, recommended: 6-12)
    plot_height = 4, # Plot height in inches (1-15, recommended: 4-10)
    use_png_instead_of_vector = TRUE, # Force PNG images instead of vector graphics (TRUE = always PNG, FALSE = vector for ggplot)
    ppt_font = "Verdana", # Font family for PowerPoint plots ("Verdana", "Arial", "Times New Roman", "Calibri", etc.)
    png_dpi = 150, # DPI resolution for PNG images (100-300, recommended: 150-300)
    
    slide_titles = NULL, # Vector of slide titles (NULL = auto-generate from plot names)
    content_placeholder = NULL, # Specific placeholder name for content (NULL = auto-detect)
    title_placeholder = NULL, # Specific placeholder name for title (NULL = auto-detect)
    presentation_title = "Presentation", # Title for first slide (any text string)
    verbose = FALSE # Show progress messages (TRUE/FALSE)
) {
  
  # Input validation
  if (missing(plot_list) || !is.list(plot_list) || length(plot_list) == 0) 
    stop("plot_list must be a non-empty list")
  if (missing(output_path)) stop("output_path is required")
  if (!file.exists(template_path)) stop("Template file not found: ", template_path)
  
  # Load template
  ppt <- read_pptx(template_path)
  layouts <- layout_summary(ppt)
  
  if (verbose) {
    cat("Available layouts:\n")
    print(layouts$layout)
  }
  
  # Check if required layouts exist
  required_layouts <- c(first_slide_layout, layout_name, last_slide_layout)
  missing_layouts <- setdiff(required_layouts, layouts$layout)
  
  if (length(missing_layouts) > 0) {
    stop("Missing required layouts: ", paste(missing_layouts, collapse = ", "), 
         "\nAvailable layouts: ", paste(layouts$layout, collapse = ", "))
  }
  
  if (verbose) cat("Using plot layout:", layout_name, "\n")
  
  # Get layout properties
  props <- layout_properties(ppt, layout = layout_name)
  if (verbose) {
    cat("Available placeholders in layout '", layout_name, "':\n")
    print(props$ph_label)
  }
  
  # Auto-detect placeholders
  if (is.null(title_placeholder)) {
    title_candidates <- c("Title 1", "Rubrik 1", "title", "Title")
    title_matched <- intersect(title_candidates, props$ph_label) # character(0) if no match
    title_placeholder <- if (length(title_matched) == 0) NULL else title_matched[1]
  }
  
  if (is.null(content_placeholder)) {
    # Swedish and English content placeholder candidates
    content_candidates <- c("Platshållare för innehåll 13", "Content Placeholder 2", "Graphic 4", "Graphic 28", 
                            "content", "Content", "body", "Platshållare för innehåll")
    content_matched <- intersect(content_candidates, props$ph_label) # character(0) if no match
    content_placeholder <- if (length(content_matched) == 0) NULL else content_matched[1]
    
    # If no standard content placeholder found, look for any "Platshållare för innehåll" pattern
    if (is.null(content_placeholder)) {
      content_match <- grep("Platshållare för innehåll", props$ph_label, value = TRUE)[1]
      if (!is.na(content_match)) content_placeholder <- content_match
    }
    
    # If still no content placeholder found, use largest placeholder
    if (is.null(content_placeholder) && nrow(props) > 0) {
      props$area <- props$width * props$height
      content_placeholder <- props$ph_label[which.max(props$area)]
    }
  }
  
  if (verbose) {
    cat("Using title placeholder:", ifelse(is.null(title_placeholder), "None", title_placeholder), "\n")
    cat("Using content placeholder:", ifelse(is.null(content_placeholder), "None", content_placeholder), "\n")
  }
  
  # Generate slide titles
  if (is.null(slide_titles)) {
    slide_titles <- if (!is.null(names(plot_list))) names(plot_list) else paste("Plot", seq_along(plot_list))
  }
  slide_titles <- rep_len(slide_titles, length(plot_list))
  
  # Add first slide (Rubrikbild)
  if (verbose) cat("Adding first slide (", first_slide_layout, ")\n")
  ppt <- add_slide(ppt, layout = first_slide_layout)
  
  # Try to add title to first slide
  first_props <- layout_properties(ppt, layout = first_slide_layout)
  first_title_candidates <- c("Title 1", "Rubrik 1", "title", "Title")
  first_title_matched <- intersect(first_title_candidates, first_props$ph_label) # character(0) if no match
  first_title_placeholder <- if (length(first_title_matched) == 0) NULL else first_title_matched[1]
  
  if (!is.null(first_title_placeholder)) {
    tryCatch({
      ppt <- ph_with(ppt, value = presentation_title, location = ph_location_label(first_title_placeholder))
    }, error = function(e) if (verbose) cat("Warning: Could not add title to first slide\n"))
  }
  
  # Add slides with plots
  for (i in seq_along(plot_list)) {
    if (verbose) cat("Adding plot slide", i, "of", length(plot_list), "\n")
    
    ppt <- add_slide(ppt, layout = layout_name)
    
    # Add title if placeholder exists
    if (!is.null(title_placeholder)) {
      tryCatch({
        ppt <- ph_with(ppt, value = slide_titles[i], location = ph_location_label(title_placeholder))
      }, error = function(e) if (verbose) cat("Warning: Could not add title to slide", i, "\n"))
    }
    
    # Add plot if placeholder exists
    if (!is.null(content_placeholder)) {
      tryCatch({
        # CHECK IF IT'S A FLEXTABLE FIRST
        if (inherits(plot_list[[i]], "flextable")) {
          # Handle flextable objects - use same placeholder as plots
          ppt <- ph_with(ppt, 
                         value = plot_list[[i]], 
                         location = ph_location_label(content_placeholder))
          
        } else if (inherits(plot_list[[i]], "ggplot") && !use_png_instead_of_vector) {
          # Fix fonts for PowerPoint using specified font
          plot_fixed <- plot_list[[i]] + 
            theme(text = element_text(family = ppt_font, size = 12),
                  plot.title = element_text(family = ppt_font, size = 14),
                  axis.text = element_text(family = ppt_font, size = 10),
                  legend.text = element_text(family = ppt_font, size = 10))
          
          # Vector graphics for ggplot with font mapping
          font_mapping <- list(sans = ppt_font, serif = "Times New Roman", mono = "Courier New")
          ppt <- ph_with(ppt, 
                         value = dml(ggobj = plot_fixed, width = plot_width, height = plot_height,
                                     fonts = font_mapping),
                         location = ph_location_label(content_placeholder))
        } else {
          # PNG image using ggsave for consistent rendering (matches RStudio output)
          temp_file <- tempfile(fileext = ".png")
          
          if (inherits(plot_list[[i]], "ggplot")) {
            # Use ggsave for ggplot objects (consistent with RStudio rendering)
            ggsave(filename = temp_file, 
                   plot = plot_list[[i]], 
                   width = plot_width, 
                   height = plot_height, 
                   dpi = png_dpi,
                   bg = "white",
                   device = "png")
          } else {
            # Only these classes draw a plot when printed; anything else (e.g. a text string)
            # was previously printed to the console and gave an empty slide without a warning.
            # The error is turned into a warning by the tryCatch around the slide.
            if (!inherits(plot_list[[i]], c("recordedplot", "trellis"))) {
              stop("objektet är varken ggplot, flextable, recordPlot() eller lattice (klass ",
                   class(plot_list[[i]])[1], ")")
            }
            # Use png() device for base R plots
            png(temp_file, width = plot_width * png_dpi, height = plot_height * png_dpi, res = png_dpi, bg = "white")
            # finally: close the device even if print() fails, so it is not left open
            tryCatch(print(plot_list[[i]]), finally = dev.off())
          }
          
          ppt <- ph_with(ppt,
                         value = external_img(temp_file, width = plot_width, height = plot_height),
                         location = ph_location_label(content_placeholder))
          unlink(temp_file)
        }
      }, error = function(e) {
        # Always warn: a failed plot otherwise silently left an empty slide unless verbose = TRUE
        warning("Could not add plot to slide ", i, " (", slide_titles[i], "): ", conditionMessage(e), call. = FALSE)
      })
    } else {
      if (verbose) cat("Warning: No suitable content placeholder found\n")
    }
  }
  
  # Add last slide (Svart logo/Vit bakgrund)
  if (verbose) cat("Adding last slide (", last_slide_layout, ")\n")
  ppt <- add_slide(ppt, layout = last_slide_layout)
  
  # Save presentation
  print(ppt, target = output_path)
  
  if (verbose) {
    cat("Presentation saved to:", output_path, "\n")
    cat("Structure: First slide (", first_slide_layout, ") + ", length(plot_list), " plot slides + Last slide (", last_slide_layout, ")\n")
    cat("Total slides:", length(plot_list) + 2, "\n")
  }
  
  invisible(output_path)
}
