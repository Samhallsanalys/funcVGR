#' Enkel heatmap över punktkoordinater (äldre variant)
#'
#' Äldre och enklare variant av [func_graf_karta_heatmap()]. Ritar en
#' täthetsskattning av punkter på en bakgrundskarta med valfria lager för
#' vägar, hav, sjöar och kommunnamn. Kartutsnittet täcker alla lager som
#' skickas in.
#'
#' @param df `sf`-objekt med punktgeometrier. Obligatorisk.
#' @param df_varde Namn på en numerisk kolumn i `df`. Används för punkternas
#'   färgmappning. Obligatorisk.
#' @param legend_namn Förklaringens rubrik.
#' @param basemap `sf`-objekt som bakgrundskarta. `df` transformeras till dess
#'   koordinatsystem. Obligatorisk.
#' @param title Rubrik. `NULL` (standard) ger ingen rubrik.
#' @param basemap_color Fyllnadsfärg för bakgrundskartan.
#' @param basemap_color_line Linjefärg för bakgrundskartans gränser.
#' @param annotation_text Text längst ner i diagrammet, t.ex. källa. `NULL`
#'   (standard) ger ingen text.
#' @param adjust_value Justering av bandbredden i täthetsskattningen.
#' @param transparency Opacitet för heatmap och punkter (0–1).
#' @param bins Antal konturnivåer.
#' @param low_color,high_color Färg för lägst respektive högst täthet.
#' @param show_legend Visa förklaringen.
#' @param legend_position Förklaringens placering, t.ex. `"bottom"`.
#' @param element_road `sf`-lager med vägar. `NULL` = inget.
#' @param element_ocean `sf`-lager med hav. `NULL` = inget.
#' @param element_lake `sf`-lager med sjöar. `NULL` = inget.
#' @param element_municipality_names `sf`-lager med kommunnamn i kolumnen
#'   `Kommunnamn`. `NULL` = inga namn.
#' @param point_size Punkternas storlek.
#' @param point_color Punkternas färg.
#' @param show_points Visa de enskilda punkterna.
#' @param font Typsnitt. Används `"sans"` om det saknas.
#'
#' @return Ett `ggplot`-objekt.
#' @seealso [func_graf_karta_heatmap()]
#' @export
#'
#' @example inst/examples/func_graf_heatmap_coordinats.R
func_graf_heatmap_coordinats <- function(df,
                         df_varde,
                         legend_namn = NULL,
                         basemap,
                         title = NULL,
                         basemap_color = "white",
                         basemap_color_line = "#969696",
                         annotation_text = NULL,
                         adjust_value = 0.5,  # Adjust the bandwidth
                         transparency = 0.7,  # Renamed alpha_value to transparency
                         bins = 10,           # Added bins parameter
                         low_color = "black", # Added low_color parameter
                         high_color = "red",  # Added high_color parameter
                         show_legend = FALSE,  # Option to show/hide the legend
                         legend_position = "bottom", # Position of the legend
                         element_road = NULL, # Road layer
                         element_ocean = NULL, # Ocean layer
                         element_lake = NULL, # Lake layer
                         element_municipality_names = NULL,  # Municipality names layer
                         point_size = 2,      # Point size (renamed from punktstorlek)
                         point_color = "black",  # Point color
                         show_points = TRUE,
                         font = "Verdana")  # Option to show/hide points
{

  # Font validation via systemfonts (same approach as the other chart functions)
  if (!font %in% c(systemfonts::system_fonts()$family, "sans", "serif", "mono")) {
    message(sprintf("Font '%s' not found. Using 'sans'.", font))
    font <- "sans"
  }
  registrera_typsnitt(font)  # så att Windows- och PDF-enheterna hittar typsnittet (se zzz.R)

  # Check if df is provided and not NULL
  if (is.null(df)) {
    stop("Error: The input dataframe `df` is NULL.")
  }
  
  # Check if df has rows
  if (nrow(df) == 0) {
    stop("Error: The input dataframe `df` is empty.")
  }

  # df_varde and basemap are required; checked here so the error is clear instead of
  # "argument is of length zero" or "crs not found" further down
  if (!is.character(df_varde) || length(df_varde) != 1 || !df_varde %in% names(df)) {
    stop("`df_varde` måste vara namnet på en kolumn i `df`.", call. = FALSE)
  }
  if (!inherits(basemap, c("sf", "sfc"))) {
    stop("`basemap` måste vara ett sf-objekt, t.ex. vg_kommuner.", call. = FALSE)
  }

  # Ensure df and basemap have the same CRS
  df <- st_transform(df, crs = st_crs(basemap))  # Transform df to match basemap's CRS
  
  # Extract x and y coordinates from sf object
  df <- df %>%
    mutate(data_x = st_coordinates(.)[, 1],
           data_y = st_coordinates(.)[, 2])
  
  # Check for missing values in coordinates
  if (any(is.na(df$data_x)) || any(is.na(df$data_y))) {
    stop("Error: Coordinates contain missing values.")
  }
  
  # Calculate the bounding box for all elements (basemap, roads, ocean, lake, etc.)
  bbox_layers <- list(basemap, element_road, element_ocean, element_lake, element_municipality_names)
  
  # Initialize empty list for bounding boxes
  combined_bbox <- lapply(bbox_layers, function(layer) {
    if (!is.null(layer)) {
      st_bbox(layer)
    }
  })
  
  # Combine all bounding boxes into a single vector, removing NULL values
  combined_bbox <- do.call(c, combined_bbox)
  
  # Get the extent for the combined bounding box. Index with names(...) == rather than
  # combined_bbox["xmin"]: the combined vector has one "xmin" per layer and ["xmin"] only
  # returns the first (the basemap's), which ignored the extent of all other layers
  bbox_values <- function(name) combined_bbox[names(combined_bbox) == name]
  bbox <- c(xmin = min(bbox_values("xmin"), na.rm = TRUE),
            xmax = max(bbox_values("xmax"), na.rm = TRUE),
            ymin = min(bbox_values("ymin"), na.rm = TRUE),
            ymax = max(bbox_values("ymax"), na.rm = TRUE))
  
  # Create the ggplot
  p <- ggplot(df) +
    # Plot basemap only if it exists
    {if (!is.null(basemap)) geom_sf(data = basemap, fill = basemap_color, color = basemap_color_line)} +
    
    # Plot additional layers if they exist
    {if (!is.null(element_road)) geom_sf(data = element_road, fill = "#5e5e5e", color = "#5e5e5e")} +
    {if (!is.null(element_ocean)) geom_sf(data = element_ocean, fill = "#b5c7eb", color = "#b5c7eb")} +
    {if (!is.null(element_lake)) geom_sf(data = element_lake, fill = "#b5c7eb", color = "#b5c7eb")} +
    
    # Add municipality names as text labels if provided
    {if (!is.null(element_municipality_names))
      geom_sf_text(data = element_municipality_names, aes(label = Kommunnamn),
                   color = "black", size = 2)} +
    
    # 2D Density plot with polygon geom (Heatmap)
    stat_density_2d(
      aes(
        x = data_x,
        y = data_y,
        fill = after_stat(level)
      ),
      bins = bins,  # Use the bins parameter here
      geom = "polygon",
      contour_var = "count",
      adjust = adjust_value,  # Adjust the bandwidth here
      show.legend = show_legend,  # Show or hide the legend
      alpha = transparency  # Use the transparency parameter here
    ) +
    
    # Specify color scale with user-defined low and high colors
    scale_fill_gradient(low = low_color, high = high_color) +
    
    # Add points layer (from the same df dataset) if show_points is TRUE
    {if (show_points)
      geom_sf(data = df, aes(color = as.numeric(!!sym(df_varde))), size = point_size, alpha = transparency, show.legend = FALSE)} +  # Points layer
    
    # Customizing the color scale for points
    scale_color_gradient(low = point_color, high = point_color) +  # Set point color
    
    # Customize the theme
    theme(
      plot.title = element_text(size = 12, face = "bold", hjust = 0.5, family = font),
      legend.title = element_text(size = 8, family = font),
      legend.text = element_text(size = 8, family = font),
      legend.position = legend_position,  # Adjust the legend position
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      plot.caption = element_text(hjust = 0.5, size = 10, color = "black", family = font)
    ) +
    
    # Set the title, legend, and caption
    labs(
      title = title,
      fill = legend_namn,
      caption = annotation_text
    ) +
    
    # Adjust the map limits and allow for expansion if necessary
    coord_sf(
      xlim = c(bbox["xmin"], bbox["xmax"]),
      ylim = c(bbox["ymin"], bbox["ymax"]),
      expand = TRUE  # Ensure some padding around the map
    )
  
  return(p)
}
