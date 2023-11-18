
# Import necessary packages
library(rvest)
library(RCurl)

# Define incidents to retreive and base url
page_number <- 3250:5952 # till beginning of march 2022

base_url <- "https://konstanz-mitgestalten.de/bms/"


# Initialize Data Frame to store the result
scraping_results <- data.frame(bms_number = character(length = length(page_number)),
                               category = character(length = length(page_number)),
                               coordinates = character(length = length(page_number)),
                               responsibility = character(length = length(page_number)),
                               status = character(length = length(page_number)),
                               date = character(length = length(page_number)),
                               searched_adress = character(length = length(page_number)),
                               message = character(length = length(page_number)),
                               message_links = character(length = length(page_number))
                               )


for (i in rev(page_number)) # iterate over incidents, from latest to older ones
  {message("Scraping bms ", i, " / ", tail(page_number, 1)) # print message, iteration step
  
  row_number <- i - (head(page_number, 1) - 1) # row number from 1 to max.
  
  # Combine URL
  url <- paste0(base_url, i)
  
  
  # Could include checks if url exists
  # if elements exist
  # or if elements are private 
  
  
  page <- read_html(url)
  
  
  
  # Incident number
  bms_number <- i
  
  # Category 
  category <- page %>% 
    html_nodes(xpath = "/html/body/div[2]/div[3]/div/div[1]/div/div[2]/div[2]/div/div[1]/dl/div[1]/dd") %>%
    head() %>% 
    html_text()
  
  # Coordinates
  coordinates <- page %>% 
    html_nodes(xpath = "/html/body/div[2]/div[3]/div/div[1]/div/div[2]/div[2]/div/div[2]/dl/div[1]/dd") %>%
    head() %>% 
    html_text()
  
  # Responsibility
  responsibility <- page %>% 
    html_nodes(xpath = "/html/body/div[2]/div[3]/div/div[1]/div/div[2]/div[2]/div/div[1]/dl/div[2]/dd") %>%
    head() %>% 
    html_text()
  
  # Status
  status <- page %>% 
    html_nodes(xpath = "/html/body/div[2]/div[3]/div/div[1]/div/div[2]/div[2]/div/div[2]/dl/div[3]/dd") %>%
    head() %>% 
    html_text()
  
  # Date
  date <- page %>% 
    html_nodes(xpath = "/html/body/div[2]/div[3]/div/div[1]/div/div[1]/div[1]/div/div[2]/div/div[2]/p/span") %>%
    head() %>% 
    html_text()
  
  # Searched Adress
  searched_adress <- page %>% 
    html_nodes(xpath = "/html/body/div[2]/div[3]/div/div[1]/div/div[2]/div[2]/div/div[2]/dl/div[2]/dd") %>%
    head() %>% 
    html_text() 
  
  # Message Detail (CSS)
    message <- page %>% 
    html_nodes(".messagetext-detail") %>% 
    head() %>% 
    html_text()
    
  # Message Links (CSS)
    message_links <- page %>% 
      html_nodes(".messagetext-link") %>% 
      head() %>% 
      html_text()
  
  # Check if values exist, otherwise fill NA
  for (coln in colnames(scraping_results)) {
    
    if (length(get(coln)) == 0) { 
      scraping_results[row_number, coln] <- "NA"
      } 
    else {
      scraping_results[row_number, coln] <- get(coln)
      }
    }

  
  message("Categorie:", category)
  message("Geo:", coordinates)
  
  
  # Wait before scraping next page
  Sys.sleep(0.5)
  
}

# Export to csv
#write.csv(scraping_results, "scraped_data/results.csv")





# Test polite
# session <- bow("https://konstanz-mitgestalten.de/bms/", force = TRUE)
# result <- scrape(session, query=list(bms=page_number[1])) %>%
#   html_nodes(xpath = "/html/body/div[2]/div[3]/div/div[1]/div/div[2]/div[2]/div/div[1]/dl/div[1]/dd") %>%
#   head() %>% 
#   html_text()
# head(result)
