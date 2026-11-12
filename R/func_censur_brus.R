# Lägg till diskret brus i valda kolumner.
# - Endast värden inom target_range påverkas (inklusive gränser).
# - Efter justering klipps de justerade värdena till intervallet 'clip'.
# - Värden utanför target_range lämnas helt orörda.
# - NA lämnas orört. Heltalskolumner förblir heltal.
#' Lägg till diskret brus i valda kolumner (röjandeskydd)
#'
#' Adderar slumpade heltalssteg till värden i valda numeriska kolumner, t.ex.
#' för att skydda små antal mot röjande.
#'
#' * Endast värden inom `target_range` (inklusive gränserna) påverkas.
#' * Efter justering klipps de justerade värdena till intervallet `clip`.
#' * Värden utanför `target_range` och `NA` lämnas orörda.
#' * Heltalskolumner förblir heltal. Icke-numeriska kolumner lämnas orörda.
#'
#' @param .data En data frame. Obligatorisk.
#' @param cols Kolumner som ska få brus, anges med tidyselect, t.ex.
#'   `starts_with("q")` eller `c(q1, q2)`. Obligatorisk.
#' @param target_range Numerisk vektor av längd 2: vilka ursprungsvärden som
#'   får brus.
#' @param clip Numerisk vektor av längd 2: min- och maxgräns som de justerade
#'   värdena klipps till.
#' @param probs Namngiven numerisk vektor med sannolikheter där namnen är de
#'   heltalssteg som adderas, t.ex. `` c(`-1` = .25, `0` = .5, `1` = .25) ``.
#'   Normaliseras om den inte summerar till 1.
#' @param seed Valfritt frö till slumpgeneratorn för reproducerbarhet. Fröet
#'   gäller bara inne i funktionen; slumpgeneratorn i din session är som förut
#'   efteråt. `NULL` = inget frö sätts.
#'
#' @return `.data` med brus adderat i de valda kolumnerna.
#' @export
#'
#' @example inst/examples/func_censur_brus.R
func_censur_brus <- function(.data,
                     cols,                          # tidyselect, t.ex. starts_with("q") eller c(q1, q2)
                     target_range = c(1, 4),        # vilka ursprungsvärden som får brus
                     clip = c(0, 5),                # klippgränser efter brus (min, max)
                     probs = c(`-2`=.05, `-1`=.225, `0`=.45, `1`=.225, `2`=.05),
                     seed = NULL) {
  
  stopifnot(is.data.frame(.data))
  # Restore the session's random number generator on exit; set.seed() alone changed it
  # for the rest of the session. (withr::local_seed() did not restore it in testing.)
  if (!is.null(seed)) {
    withr::local_preserve_seed()
    set.seed(seed)
  }
  
  # Validera intervall
  if (length(target_range) != 2 || any(!is.finite(target_range))) {
    stop("`target_range` måste vara en numerisk vektor av längd 2.")
  }
  if (length(clip) != 2 || any(!is.finite(clip))) {
    stop("`clip` måste vara en numerisk vektor av längd 2.")
  }
  target_range <- sort(target_range)
  clip <- sort(clip)
  
  # Validera sannolikheter
  steg_num <- suppressWarnings(as.numeric(names(probs)))
  # Stegen måste vara heltal: as.integer() nedan trunkerade tidigare t.ex. "0.5" tyst till 0
  if (is.null(names(probs)) || any(is.na(steg_num)) || any(steg_num != round(steg_num))) {
    stop("`probs` måste vara en NAMNGIVEN numerisk vektor där namnen är heltalssteg (t.ex. -2,-1,0,1,2).")
  }
  if (!is.numeric(probs) || any(is.na(probs)) || any(probs < 0) || sum(probs) <= 0) {
    stop("`probs` måste innehålla icke-negativa sannolikheter med en summa större än 0.")
  }
  probs <- probs / sum(probs)         # normalisera om de inte summerar till 1
  steps <- as.integer(names(probs))   # heltalssteg att addera
  
  # Lös kolumnurval (stöd för tidyselect-uttryck)
  sel <- tidyselect::eval_select(rlang::enquo(cols), .data)
  if (length(sel) == 0) return(.data)
  
  dplyr::mutate(
    .data,
    dplyr::across(dplyr::all_of(names(sel)), \(x) {
      if (!is.numeric(x)) return(x)
      
      is_target <- !is.na(x) & x >= target_range[1] & x <= target_range[2]
      n <- sum(is_target)
      if (n == 0) return(x)
      
      draws <- sample(steps, size = n, replace = TRUE, prob = probs)
      
      y <- x
      y_adj <- x[is_target] + draws
      # Klipp ENDAST de justerade värdena
      y[is_target] <- pmin(clip[2], pmax(clip[1], y_adj))
      
      if (is.integer(x)) y <- as.integer(y)
      y
    })
  )
}
