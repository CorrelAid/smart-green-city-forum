require(leaflet)
require(leaflet.extras)
require(leaflet.extras2)
require(mapview)
require(tidyverse)
require(webshot) # for map preview generation
require(rgdal)
require(data.table)
require(htmltools)
require(htmlwidgets)
require(readr)
require(tidyr)


# Import cleaned data
results <- read_csv(file = "data_cleaning/cleaned_data/cleaned.csv")


# Drop missing values
results <- results %>% drop_na(coordinates)

# Divide category into upper and subcategory
results <- results %>% tidyr::separate(col = category, c("cat", "subcategory"), sep = ">")
results$cat <- trimws(results$cat)
results$subcategory <- trimws(results$subcategory)


# Split coordinates and convert to numeric
results <- results %>% tidyr::separate(col = coordinates, c("lat", "lng"), sep = ",")
results$lng <- as.numeric(trimws(results$lng))
results$lat <- as.numeric(trimws(results$lat))


# Compute counts per category
counts <- results %>% group_by(subcategory) %>% summarise(count = n())


# Filter two most popular categories
laternen <- results %>%  filter(subcategory == "Straßenlaternen defekt")
müll <- results %>%  filter(subcategory == "Illegaler Müll")



# Information Box for our visualization
rr <- tags$div(
  HTML('<b>Hotspots of reported city issues in Konstanz 04/2020 - 03/2022</b><p>
       Data aggregated from <a href="https://konstanz-mitgestalten.de/#portal-bms">Konstanz mitgestalten</a> (CC BY-SA) on 2022-03-05</p>
       <p>Click on a point to learn more!</p>'))  


# Compute basic map with broken lamps and illegal garbage

map_basic <- leaflet() %>% 
  addProviderTiles(provider = "CartoDB.Voyager") %>% 
  enableTileCaching() %>% 
  setView(lat = 47.67304974982142, lng = 9.183714827775331, zoom = 14) %>% 
  #addMarkers(data=laternen, lat = ~lat, lng = ~lng)
  addHeatmap(data=laternen, lat = ~lat, lng = ~lng, radius = 8, group ="Broken lamps") %>% 
  addHeatmap(data=müll, lat = ~lat, lng = ~lng, radius = 8, group ="Illegal garbage") %>%
  addControl(rr, position = "topright") %>% 
  addLayersControl(
      overlayGroups =  c("Broken lamps", "Illegal garbage"),
      options = layersControlOptions(collapsed = FALSE)
    ) 

htmlwidgets::saveWidget(map_basic, file="map/map_konstanz.html", selfcontained = TRUE)
  

# Detailed map with pop-up information

map_detailed <- leaflet() %>% 
  addProviderTiles(provider = "CartoDB.Voyager") %>% 
  enableTileCaching() %>% 
  setView(lat = 47.67304974982142, lng = 9.183714827775331, zoom = 14) %>% 
  #addMarkers(data=laternen, lat = ~lat, lng = ~lng)
  addHeatmap(data=laternen, lat = ~lat, lng = ~lng, radius = 8, group =paste0("Broken lamps ", "(n=", nrow(laternen), ")")) %>% 
  addCircleMarkers(data=laternen, lng = ~lng, lat = ~lat, 
                   fillOpacity = 0, weight = 0,
                   popup = paste("<b>", laternen$subcategory ,"</b><br>",
                                 "Date:", laternen$date, "<br>",
                                 "Status:<b>", laternen$status, "</b><br>",
                                 "URL", paste0('<a href="https://konstanz-mitgestalten.de/bms/', laternen$bms_number, '">https://konstanz-mitgestalten.de/bms/', laternen$bms_number, "</a>"),
                                 "<br>Searched adress:", laternen$searched_adress,
                                 "<br>Message:", laternen$message),
                   labelOptions = labelOptions(noHide = TRUE)) %>% 
  addHeatmap(data=müll, lat = ~lat, lng = ~lng, radius = 8, group =paste0("Illegal garbage ", "(n=", nrow(müll), ")")) %>%
  addCircleMarkers(data=müll, lng = ~lng, lat = ~lat, 
                   fillOpacity = 0, weight = 0,
                   popup = paste("<b>", müll$subcategory ,"</b><br>",
                                 "Date:", müll$date, "<br>",
                                 "Status:<b>", müll$status, "</b><br>",
                                 "URL", paste0('<a href="https://konstanz-mitgestalten.de/bms/', müll$bms_number, '">https://konstanz-mitgestalten.de/bms/', müll$bms_number, "</a>"),
                                 "<br>Searched adress:", müll$searched_adress,
                                 "<br>Message:", müll$message),
                   labelOptions = labelOptions(noHide = TRUE)) %>% 
  addControl(rr, position = "topright") %>% 
  addLayersControl(
    overlayGroups =  c(paste0("Broken lamps ", "(n=", nrow(laternen), ")"), paste0("Illegal garbage ", "(n=", nrow(müll), ")")),
    options = layersControlOptions(collapsed = FALSE)
  ) 


htmlwidgets::saveWidget(map_detailed, file="map/map_konstanz_popups.html", selfcontained = TRUE)


