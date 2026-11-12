# Hämtar geografiska objekt (sf-lager) från en PostGIS-databas.
# Returnerar en sf-dataframe, eller en lista med tillgängliga tabeller om table_name = NULL.

#' Hämta geografiska objekt från VGR:s PostGIS-databas
#'
#' Hämtar en tabell som `sf`-objekt från geodatabasen. Utan tabellnamn
#' returneras en lista över alla tillgängliga tabeller och vyer i alla scheman.
#'
#' När ingen anslutning anges skapas en med [func_gis_hamta_con()], som sedan
#' stängs automatiskt. Geometrin hämtas då via GDAL:s snabbare
#' PostgreSQL-drivrutin, med samma inloggningsuppgifter. En anslutning som
#' anroparen skickar in lämnas öppen. Då hämtas data via DBI, vilket kan
#' trunkera kolumnnamn till 10 tecken.
#'
#' Inloggningen är inbyggd i paketet (se [func_gis_hamta_con()]). Det som
#' krävs är att datorn är ansluten till VGR:s nätverk.
#'
#' @param con DBI-anslutning. Standard är en ny anslutning från
#'   [func_gis_hamta_con()].
#' @param table_name Namn på tabellen som ska hämtas. `NULL` returnerar en
#'   data frame med tillgängliga tabeller (schema, namn, antal kolumner).
#' @param schema Schemanamn, t.ex. `"public"`. `NULL` söker i alla scheman.
#'   Finns tabellen i flera scheman används det första med en varning.
#' @param print_map `TRUE` ritar geometrin efter hämtning.
#'
#' @return Ett `sf`-objekt, eller en data frame med tillgängliga tabeller om
#'   `table_name = NULL`.
#' @seealso [func_gis_hamta_con()]
#' @export
#'
#' @example inst/examples/func_gis_hamta_geoobjekt.R
func_gis_hamta_geoobjekt <- function(
    con        = func_gis_hamta_con(),  # DBI-anslutningsobjekt. Defaultar till func_gis_hamta_con() om inget anges.
    table_name = NULL,                  # Namn på tabellen att hämta. NULL returnerar lista med tillgängliga tabeller.
    schema     = NULL,                  # Schemanamn (t.ex. "public"). NULL söker i alla scheman.
    print_map  = FALSE                  # TRUE ritar upp geometrin i konsolen efter hämtning.
) {

  # Testa om con angavs av anroparen INNAN default-uttrycket evalueras. Om con saknas
  # skapar vi själva anslutningen via defaultvärdet och ansvarar då för att stänga den –
  # en anslutning som anroparen skickat in rör vi aldrig, den kan återanvändas efteråt.
  con_skapad_internt <- missing(con)
  if (con_skapad_internt) {
    force(con)                                     # Tvinga fram anslutningen från func_gis_hamta_con()
    on.exit(DBI::dbDisconnect(con), add = TRUE)     # Stäng garanterat vid retur, även vid fel
  }

  # Hämta alla tabeller från alla scheman, inklusive antal kolumner per tabell.
  # DBI::dbListTables() ser bara tabeller i search_path (vanligen "public") och missar
  # tabeller i andra scheman – därav potentiellt saknade kolumner om fel tabell matchas.
  tables_df <- DBI::dbGetQuery(con,
                               "SELECT t.table_schema, t.table_name, COUNT(c.column_name) AS antal_kolumner
     FROM information_schema.tables t
     LEFT JOIN information_schema.columns c
       ON t.table_schema = c.table_schema AND t.table_name = c.table_name
     WHERE t.table_type IN ('BASE TABLE', 'VIEW')
       AND t.table_schema NOT IN ('pg_catalog', 'information_schema')
     GROUP BY t.table_schema, t.table_name
     ORDER BY t.table_schema, t.table_name"
  )
  
  # Om inget tabellnamn anges – returnera listan med kolumnräkning
  if (is.null(table_name)) {
    message("Inget tabellnamn angivet. Returnerar lista med tillgängliga tabeller.")
    return(tables_df)
  }
  
  # Filtrera på schema om angivet, annars sök i alla scheman
  matches <- if (!is.null(schema)) {
    tables_df[tables_df$table_name == table_name & tables_df$table_schema == schema, ]
  } else {
    tables_df[tables_df$table_name == table_name, ]
  }
  
  if (nrow(matches) == 0) {
    stop(paste0(
      "Tabellen '", table_name, "' hittades inte.",
      "\nTillgängliga tabeller:\n",
      paste(paste0(tables_df$table_schema, ".", tables_df$table_name), collapse = "\n")
    ))
  }
  
  if (nrow(matches) > 1) {
    warning(paste0(
      "Tabellen '", table_name, "' finns i flera scheman: ",
      paste(matches$table_schema, collapse = ", "),
      ". Använder '", matches$table_schema[1], "'. Ange schema= för att välja specifikt."
    ))
  }
  
  # Använd schema-kvalificerat namn för att garantera rätt tabell och alla kolumner.
  # st_read med layer= söker utan schemakontext och kan matcha fel tabell.
  # En explicit SQL-fråga via PG-strängen säkerställer korrekt hämtning.
  resolved_schema <- matches$table_schema[1]
  qualified  <- paste0('"', resolved_schema, '"."', table_name, '"')

  if (con_skapad_internt) {
    # Vanliga fallet: con skapades internt av func_gis_hamta_con(), så vi vet exakt
    # vilka credentials som gäller och kan gå via den snabba, native PG-anslutningen
    # (samma källa till sanning som DBI-anslutningen ovan – se gis_inloggning() i
    # func_gis_hamta_con.R).
    spatial_data <- gis_st_read(paste("SELECT * FROM", qualified))
  } else {
    # Anroparen har skickat in en egen anslutning. Vi kan inte säkert läsa ut lösenordet
    # ur ett godtyckligt DBI-objekt (RPostgres::dbGetInfo() returnerar aldrig det), så vi
    # faller tillbaka på att låta st_read() gå via själva DBI-anslutningen. Detta rör sig
    # via GDAL:s generiska drivrutin, vilket trunkerar kolumnnamn till 10 tecken.
    warning("Extern con angiven: hämtar geometri via st_read(con, ...) vilket kan trunkera kolumnnamn till 10 tecken.")
    spatial_data <- sf::st_read(
      con,
      query = paste("SELECT * FROM", qualified),
      quiet = TRUE
    )
  }
  
  message("Hämtade spatial data från ", resolved_schema, ".", table_name,
          " (", nrow(spatial_data), " objekt, ", ncol(spatial_data), " kolumner)")
  
  if (print_map) plot(sf::st_geometry(spatial_data), main = table_name)
  
  return(spatial_data)
}
