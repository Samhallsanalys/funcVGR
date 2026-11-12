#' Färgpaletter i VGR:s grafiska profil
#'
#' Returnerar en av de fördefinierade färgpaletterna ("vgr", "ru",
#' "ru_kontrast" eller "hos"), eller `n` färger interpolerade från paletten.
#'
#' I `"ru"` är de fyra första färgerna tydligt olika, och den ljusblå färgen,
#' som syns dåligt mot vit bakgrund, ligger sist. `"ru_kontrast"` har sju
#' tydligt olika färger. Alla utom gult (amber) har minst 3:1 i kontrast mot vit
#' bakgrund, så paletten passar diagram med många grupper.
#'
#' @param fargtema Namn på paletten: `"vgr"`, `"ru"`, `"ru_kontrast"` eller
#'   `"hos"` (skiftlägesokänsligt). `NULL` ger `"vgr"`.
#' @param n Antal färger som ska genereras. `NULL` = returnera paletten
#'   oförändrad (6 färger, 7 för `"ru_kontrast"`).
#'
#' @return En teckenvektor med hexkoder.
#' @export
#'
#' @example inst/examples/func_fargtema.R
func_fargtema <- function(fargtema = "vgr", n = NULL) {

  # NULL means "use the default palette" (mirrors the fargtema = "vgr" default)
  if (is.null(fargtema)) {
    fargtema <- "vgr"
  }
  # A vector of several names previously failed with "the condition has length > 1"
  if (!is.character(fargtema) || length(fargtema) != 1) {
    stop("`fargtema` ska vara ett palettnamn: \"vgr\", \"ru\", \"ru_kontrast\" eller \"hos\".",
         call. = FALSE)
  }

  # Ensure input is lowercase
  fargtema <- tolower(fargtema)

  # Define base color palettes
  
  palettes <- list(
    # ru (ordning ändrad 2026-10-01): de fyra första är tydligt olika; ljusblått sist (syns dåligt mot vitt)
    ru = c("#1a9fb3", "#ffc107", "#37474F", "#A48C83", "#1FBBD3", "#b3ebf2"),
    # ru_kontrast (ny 2026-10-01): sju distinkta färger, alla utom amber har minst 3:1 kontrast mot vit bakgrund
    # (teal 3,2 · skiffer 9,7 · amber 1,6 · korall 4,1 · grön 4,0 · lila 5,2 · taupe 3,2)
    ru_kontrast = c("#1a9fb3", "#37474F", "#ffc107", "#D0573A", "#5B8C3A", "#7E57C2", "#A48C83"),
    hos = c("#005b89", "#1a9fb3", "#e7e1df", "#37474F", "#1FBBD3", "#A48C83" ),
    vgr = c("#9575CD","#A48C83", "#1FBBD3", "#37474F", "#1a9fb3", "#ffc107")
  )
  
  # Validate input
  if (!fargtema %in% names(palettes)) {
    stop("Invalid choice. Please choose 'VGR', 'RU', 'RU_kontrast' or 'HOS'.")
  }
  
  # Return the original palette if n is NULL
  if (is.null(n)) {
    return(palettes[[fargtema]])
  }
  
  # Generate n shades from the selected palette
  color_generator <- colorRampPalette(palettes[[fargtema]])
  new_colors <- color_generator(n)
  
  return(new_colors)
}
