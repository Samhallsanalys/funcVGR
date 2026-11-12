#' funcVGR: Hjälpfunktioner för Samhällsanalys i Västra Götalandsregionen
#'
#' Paketet samlar de funktioner som tidigare låg som fristående R-skript i
#' katalogen `func_vgr`. Funktionerna är grupperade enligt nedan.
#'
#' @section Diagram:
#' * [func_graf_linjediagram()] – linjediagram
#' * [func_graf_barchart()] – stapeldiagram
#' * [func_graf_dumbbell()] – dumbbell-diagram (före/efter)
#' * [func_graf_tabell()] – tabell som PNG-bild eller flextable
#' * [func_fargtema()] och [func_tema_vgr()] – färger och ggplot2-tema
#'
#' @section Kartor:
#' * [func_graf_karta()] – koropletkarta
#' * [func_graf_karta_change()] – karta över förändring mellan två år
#' * [func_graf_karta_heatmap()] och [func_graf_heatmap_coordinats()] – heatmaps
#' * [vg_kommuner] – Västra Götalands 49 kommuner som `sf`-objekt, för exempel
#'   och översiktskartor
#' * [func_gis_hamta_con()] och [func_gis_hamta_geoobjekt()] – geodata från VGR:s PostGIS
#' * [func_gis_satt_inloggning()] – behövs inte längre (inloggningen är inbyggd)
#'
#' @section Data och uppslag:
#' * [func_hamta_dim_region()] – regionindelningar
#' * [func_hamta_dim_sni07()] – SNI 2007-kategorier
#' * [func_censur_brus()] – brus för röjandeskydd
#' * [func_scb_publiceringskalender()], [func_scb_hamta_uppdaterad()] – publiceringsdatum från SCB
#'
#' @section Filer och export:
#' * [func_skapa_pptx()] – PowerPoint från en lista med diagram
#' * [func_las_filtyper()], [func_las_rskript()], [func_setwd()], [func_utskriftsmapp()]
#'
#' @keywords internal
#' @import ggplot2
#' @import dplyr
#' @import sf
#' @import stringr
#' @importFrom rlang sym enquo .data := %||%
#' @importFrom tidyr pivot_wider pivot_longer
#' @importFrom ggrepel geom_text_repel geom_label_repel
#' @importFrom scales percent label_number
#' @importFrom flextable flextable colformat_double colformat_int autofit width padding valign
#' @importFrom flextable font fontsize align bg color bold border_remove
#' @importFrom flextable hline_top hline_bottom add_header_lines
#' @importFrom flextable add_footer_lines hrule save_as_image
#' @importFrom officer fp_border read_pptx layout_summary layout_properties
#' @importFrom officer add_slide ph_with ph_location_label external_img
#' @importFrom rvg dml
#' @importFrom magick image_read image_border image_write
#' @importFrom rvest read_html html_node html_table
#' @importFrom lubridate today ymd %m+% %m-%
#' @importFrom here here
#' @importFrom openxlsx read.xlsx
#' @importFrom grDevices colorRampPalette png dev.off
#' @importFrom graphics plot
#' @importFrom stats setNames quantile
#' @importFrom utils head read.csv
"_PACKAGE"
