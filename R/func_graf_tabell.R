#' Formaterad tabell som bild eller flextable
#'
#' Skapar en formaterad tabell med \pkg{flextable}. Den har färgad rubrikrad,
#' alternerande radfärger, markering av utvalda rader, rubrik och fotnoter.
#' Tal formateras på svenska. Tabellen sparas som PNG, eller returneras som
#' `flextable`-objekt, t.ex. för [func_skapa_pptx()]. Blanksteg i
#' kolumnnamn och textvärden trimmas.
#'
#' PNG-exporten kräver en webbläsarmotor: \pkg{webshot2} (Chrome) i första
#' hand, annars \pkg{webshot} med PhantomJS, som då installeras automatiskt om
#' det saknas.
#'
#' @param df Data frame som ska visas. Obligatorisk.
#' @param filename Filnamn för bilden, t.ex. `"tabell.png"`. `NULL` =
#'   `"tabell_<datum>.png"`.
#' @param file_path Katalog där filen sparas. `NULL` = arbetskatalogen.
#' @param title Tabellrubrik. `NULL` = ingen rubrik. Använd `\n` för
#'   radbrytning.
#' @param title_size Rubrikens teckenstorlek i punkter.
#' @param footer_text Fotnotstext. Flera rader separeras med `\n`.
#' @param footer_text_size Fotnotens teckenstorlek i punkter.
#' @param footer_wrap Antal tecken innan en fotnotsrad radbryts.
#' @param header_color Bakgrundsfärg för rubrikraden.
#' @param header_text_color Textfärg för rubrikraden.
#' @param row_color Färg för varannan rad. `NULL` = inga alternerande färger.
#' @param text_body_align Justering av textkolumner: `"left"`, `"center"`
#'   eller `"right"`.
#' @param text_header_align Justering av rubrikraden.
#' @param text_footer_align Justering av fotnoten.
#' @param text_numbers_align Justering av numeriska kolumner.
#' @param body_text_size Teckenstorlek i tabellkroppen.
#' @param header_text_size Teckenstorlek för kolumnrubrikerna.
#' @param decimal_digits Antal decimaler i numeriska kolumner som har
#'   decimaler. Kolumner med bara heltal visas utan decimaler.
#' @param big_mark Tusentalsavgränsare. Används inte för årskolumner (kolumner
#'   som heter `år`, `ar`, `årtal`, `artal` eller `year`).
#' @param decimal_mark Decimaltecken.
#' @param grid_lines Visa linjer runt rubrikraden och ovanför fotnoten.
#' @param grid_color Linjernas färg.
#' @param grid_thickness Linjernas tjocklek i punkter.
#' @param font Typsnitt. Används `"Verdana"` om det saknas.
#' @param table_width Max total tabellbredd i tum. Kolumnerna skalas ned
#'   proportionellt om tabellen blir bredare.
#' @param first_col_width Första kolumnens bredd i tum.
#' @param num_col_min_width Minsta bredd i tum för numeriska kolumner. Öka om
#'   formaterade tal radbryts.
#' @param image_padding Marginal runt tabellen i bilden, i pixlar.
#' @param padding_color Marginalens färg.
#' @param highlight_row Värde eller värden i första kolumnen vars rader ska
#'   markeras, t.ex. `"Västra Götaland"`. `NULL` = ingen markering.
#' @param highlight_bg Bakgrundsfärg för markerade rader.
#' @param highlight_text Textfärg för markerade rader.
#' @param return_object `TRUE` returnerar `flextable`-objektet i stället för
#'   att spara en fil.
#' @param quiet `TRUE` undertrycker meddelanden.
#'
#' @return Ett `flextable`-objekt, osynligt när bilden sparats till fil.
#' @seealso [func_skapa_pptx()]
#' @export
#'
#' @example inst/examples/func_graf_tabell.R
func_graf_tabell <- function(
    df,                          # Data frame to display in table
    filename = NULL,             # Output filename (e.g., "table.png"); if NULL, auto-generates based on date
    file_path = NULL,            # Directory path for saving file; if NULL, uses current working directory
    title = NULL,                # Table title text; if NULL, no title is displayed
    title_size = 18,             # Font size for title in points (e.g., 16, 18, 20)
    footer_text = NULL,          # Footer text (can include multiple lines separated by \n)
    footer_text_size = 14,       # Font size for footer in points (e.g., 10, 12, 14)
    footer_wrap = 150,           # Character width for wrapping footer text (e.g., 80, 100, 120, 150)
    header_color = "#1FBBD3",    # Background color for header row (hex code or color name, e.g., "#9B7BB3", "blue")
    header_text_color = "white", # Text color for header row (hex code or color name, e.g., "white", "black")
    row_color = "#e7e1df",       # Background color for alternating rows; if NULL, no alternating colors (e.g., "grey90", "#F7F7F7")
    text_body_align = "left",    # Text alignment for text/factor columns: "left", "center", "right"
    text_header_align = "center",# Text alignment for header: "left", "center", "right"
    text_footer_align = "left",  # Text alignment for footer: "left", "center", "right"
    text_numbers_align = "right",# Text alignment for numeric columns: "left", "center", "right"
    body_text_size = 14,         # Font size for table body in points (e.g., 10, 12, 14)
    header_text_size = 12,       # Font size for header column labels in points (e.g., 12, 14, 16)
    decimal_digits = 1,          # Number of decimal places for numeric columns (e.g., 0, 1, 2)
    big_mark = " ",         # Thousands separator (e.g., " " for non-breaking space, "," for comma, "" for none)
    decimal_mark = ",",          # Decimal separator (e.g., "," for Swedish format, "." for US format)
    grid_lines = TRUE,           # TRUE = show grid lines, FALSE = no grid lines
    grid_color = "gray90",       # Color of grid lines (hex code or color name, e.g., "gray", "#CCCCCC", "black")
    grid_thickness = 0.5,        # Thickness of grid lines in points (0.5 = thin, 1 = normal, 2 = thick)
    font = "Verdana",            # Font family name (e.g., "Verdana", "Arial", "Times New Roman", "Calibri")
    table_width = 6.5,           # Maximum table width in inches (default 6.5 inches)
    first_col_width = 2,         # Width of first column in inches (default 2 inches) - increase if text wraps
    num_col_min_width = 0.9,     # Minimum width in inches for numeric columns (default 0.9) - increase if large formatted numbers wrap (e.g. "363 220")
    image_padding = 10,          # Padding around the table in the image in pixels (e.g., 5, 10, 20)
    padding_color = "white",     # Background color for image padding (hex code or color name, e.g., "white", "#FFFFFF")
    highlight_row = NULL,        # Value(s) in first column to highlight (e.g., "Västra Götaland" or c("Västra Götaland", "Riket")); if NULL, no highlighting
    highlight_bg = "#FFF3CD",    # Background color for highlighted row(s) (hex code or color name, e.g., "#FFF3CD", "yellow")
    highlight_text = "black",    # Text color for highlighted row(s) (hex code or color name, e.g., "black", "#333333")
    return_object = FALSE,       # If TRUE, returns flextable object instead of saving to file
    quiet = FALSE                # TRUE = suppress messages, FALSE = show confirmation messages
) {
  
  
  # Trim column names, character values, AND factor values (factors with leading spaces cause misaligned first column)
  names(df) <- stringr::str_squish(names(df))
  df <- df |> mutate(across(where(is.character), stringr::str_squish))
  df <- df |> mutate(across(where(is.factor), ~ factor(stringr::str_squish(as.character(.)))))
  
  # Validate font
  available_fonts <- systemfonts::system_fonts()$family
  if (!font %in% available_fonts && !font %in% c("sans", "serif", "mono")) {
    if (!quiet) message(sprintf("Font '%s' not found. Using 'Verdana' instead.", font))
    font <- "Verdana"
  }
  
  if (!return_object) {
    if (is.null(file_path)) file_path <- getwd()
    if (is.null(filename)) filename <- paste0("tabell_", format(Sys.Date(), "%Y-%m-%d"), ".png")
    full_path <- file.path(file_path, filename)
    temp_path <- tempfile(fileext = ".png")
  }
  
  # Detect text (character/factor) and numeric columns for alignment
  text_cols <- which(sapply(df, function(x) is.character(x) || is.factor(x)))
  num_cols  <- which(sapply(df, is.numeric))
  
  # Number formats per column (colformat_num() has no digits argument - it was silently ignored,
  # and large numbers were rounded to 7 significant digits):
  # - year columns get no thousands separator ("2024", not "2 024")
  # - numeric columns holding only whole numbers get no decimals ("1 744 859", not "1 744 859,0")
  # - other numeric columns get decimal_digits decimals
  is_year_col  <- grepl("^(år|ar|årtal|artal|year)$", tolower(names(df)))
  is_num       <- vapply(df, is.numeric, logical(1))
  is_whole_col <- is_num & vapply(df, function(x) is.numeric(x) && all(x == round(x), na.rm = TRUE), logical(1))
  cols_year    <- names(df)[is_num & is_year_col]
  cols_whole   <- names(df)[is_whole_col & !is_year_col]
  cols_decimal <- names(df)[is_num & !is_whole_col & !is_year_col]

  ft <- flextable(df)
  if (length(cols_decimal)) ft <- colformat_double(ft, j = cols_decimal, big.mark = big_mark,
                                                   decimal.mark = decimal_mark, digits = decimal_digits)
  # colformat_double() only touches double columns and colformat_int() only integer columns
  if (length(cols_whole)) {
    ft <- colformat_double(ft, j = cols_whole, big.mark = big_mark, digits = 0)
    ft <- colformat_int(ft, j = cols_whole, big.mark = big_mark)
  }
  if (length(cols_year)) {
    ft <- colformat_double(ft, j = cols_year, big.mark = "", digits = 0)
    ft <- colformat_int(ft, j = cols_year, big.mark = "")
  }
  ft <- ft |>
    autofit(part = "all", add_w = 0.2, add_h = 0) |>
    width(j = 1, width = first_col_width)
  
  # Ensure numeric columns are wide enough for formatted values (e.g. "363 220" not "363220")
  # autofit() measures raw numbers before big_mark spacing is added, so we enforce a minimum width
  if (length(num_cols) > 0) {
    all_widths <- dim(ft)$widths
    for (j in num_cols) {
      current_w <- if (j <= length(all_widths)) all_widths[j] else 0
      if (is.na(current_w) || current_w < num_col_min_width) {
        ft <- ft |> width(j = j, width = num_col_min_width)
      }
    }
  }

  # Constrain total table width to table_width — if all column widths sum to more than
  # table_width, scale every column down proportionally so the total fits; never scale up
  current_widths <- dim(ft)$widths
  total_width <- sum(current_widths, na.rm = TRUE)
  if (!is.null(table_width) && total_width > table_width) {
    scale_factor <- table_width / total_width
    ft <- ft |> width(j = seq_along(current_widths), width = current_widths * scale_factor)
  }

  ft <- ft |>
    padding(padding.left = 5, padding.right = 5, part = "body") |>
    padding(padding.left = 5, padding.right = 5, part = "header") |>
    valign(valign = "center", part = "all") |>
    font(part = "all", fontname = font) |>
    fontsize(part = "header", size = header_text_size) |>
    fontsize(part = "body",   size = body_text_size) |>
    align(align = text_header_align, part = "header") |>
    bg(part = "header", bg = header_color) |>
    color(part = "header", color = header_text_color) |>
    bg(part = "body", bg = "white")
  
  # Apply column-type alignments only when columns of that type exist
  if (length(text_cols) > 0) ft <- ft |> align(j = text_cols, align = text_body_align,    part = "body")
  if (length(num_cols)  > 0) ft <- ft |> align(j = num_cols,  align = text_numbers_align, part = "body")
  
  # Alternating row colors — applied BEFORE final alignment override, because bg() can reset cell properties
  if (!is.null(row_color) && nrow(df) > 0) {  # seq(1, 0, 2) errors for an empty table
    ft <- ft |> bg(i = seq(1, nrow(df), 2), bg = row_color, part = "body")
  }
  
  # Highlight specific rows — also applied before final alignment override
  if (!is.null(highlight_row)) {
    first_col <- names(df)[1]
    highlight_rows <- which(as.character(df[[first_col]]) %in% highlight_row)
    
    if (length(highlight_rows) > 0) {
      ft <- ft |>
        bg(i = highlight_rows, bg = highlight_bg, part = "body") |>
        color(i = highlight_rows, color = highlight_text, part = "body") |>
        bold(i = highlight_rows, part = "body")
      if (!quiet) message("Highlighted ", length(highlight_rows), " row(s): ", paste(df[[first_col]][highlight_rows], collapse = ", "))
    } else {
      if (!quiet) message("Warning: No rows found matching '", paste(highlight_row, collapse = "', '"), "'")
    }
  }
  
  # Apply alignment LAST with explicit i+j (cell-level) — row-level bg() cannot override cell-level align()
  n_rows <- nrow(df)
  if (n_rows > 0) {
    if (length(text_cols) > 0) ft <- ft |> align(i = seq_len(n_rows), j = text_cols, align = text_body_align,    part = "body")
    if (length(num_cols)  > 0) ft <- ft |> align(i = seq_len(n_rows), j = num_cols,  align = text_numbers_align, part = "body")
  }
  
  ft <- ft |> border_remove()
  
  if (grid_lines) {
    border_style <- fp_border(color = grid_color, width = grid_thickness)
    ft <- ft |>
      hline_top(part = "header", border = border_style) |>
      hline_bottom(part = "header", border = border_style)
  }
  
  # Add title — no str_wrap here; flextable wraps text naturally within the cell width.
  # Use \n in your title string if you want manual line breaks.
  if (!is.null(title)) {
    ft <- ft |>
      add_header_lines(values = title, top = TRUE) |>
      fontsize(part = "header", i = 1, size = title_size) |>
      bg(part = "header", i = 1, bg = header_color) |>
      color(part = "header", i = 1, color = header_text_color) |>
      font(part = "header", i = 1, fontname = font) |>
      align(part = "header", i = 1, align = text_header_align) |>
      padding(part = "header", i = 1, padding.left = 5, padding.right = 5)
  }
  
  # Add footer — split on \n so each line becomes its own row, avoiding browser-wrap misalignment
  if (!is.null(footer_text)) {
    footer_lines <- stringr::str_split(footer_text, "\n")[[1]]
    footer_lines <- stringr::str_squish(footer_lines)
    footer_lines <- footer_lines[nchar(footer_lines) > 0]  # Remove empty lines
    
    for (i in seq_along(footer_lines)) {  # forward order; only the first line anchors at top, rest append below it in order
      wrapped_line <- stringr::str_wrap(footer_lines[i], width = footer_wrap)  # wrap at footer_wrap characters before adding
      ft <- ft |> add_footer_lines(values = wrapped_line, top = (i == 1))
    }
    
    ft <- ft |>
      bg(part = "footer", bg = "white") |>
      color(part = "footer", color = "black") |>
      font(part = "footer", fontname = font) |>
      fontsize(part = "footer", size = footer_text_size) |>
      align(part = "footer", align = text_footer_align) |>
      padding(part = "footer", padding.left = 5, padding.right = 5) |>
      hrule(rule = "auto", part = "footer")
    
    if (grid_lines) {
      ft <- ft |> hline_top(part = "footer", border = fp_border(color = grid_color, width = grid_thickness))
    }
  }
  
  # Save or return
  if (!return_object) {
    tryCatch({
      save_as_image(ft, path = temp_path, zoom = 3, expand = 0, webshot = "webshot2")
    }, error = function(e) {
      if (!quiet) message("webshot2 failed, falling back to webshot")
      # PhantomJS is only needed for this fallback - installing it up front downloaded it on
      # every first call, even with return_object = TRUE or when webshot2 works
      if (!webshot::is_phantomjs_installed()) webshot::install_phantomjs()
      save_as_image(ft, path = temp_path, zoom = 3, expand = 0, webshot = "webshot")
    })
    
    if (image_padding > 0) {
      img <- image_read(temp_path)
      img <- image_border(img, color = padding_color, geometry = paste0(image_padding, "x", image_padding))
      image_write(img, path = full_path)
      file.remove(temp_path)
    } else {
      file.copy(temp_path, full_path, overwrite = TRUE)
      file.remove(temp_path)
    }
    
    if (!quiet) message("Table saved to: ", full_path)
    return(invisible(ft))
  } else {
    if (!quiet) message("Returning flextable object")
    return(ft)
  }
}
