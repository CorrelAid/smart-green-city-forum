
# Import necessary library
library(tidyverse)
library(dplyr)

df <- read.csv("scraper/scraped_data/results.csv")

# Exclude all missing values in category
df <- df[!is.na(df$category),]

# Convert to integer
df$bms_number <- as.integer(df$bms_number)

# Strip date
df$date <- trimws(df$date)
# Extract only date
df$date <- gsub(".*?([0-9]+(\\.[0-9]+)+).*", "\\1", df$date)


# Strip empty spaces
df$responsibility <- trimws(df$responsibility)
df$message <- trimws(df$message)


# Extract location adress
func <- function(x) {
  result <- tryCatch({
    sub(".*: ", "", x)
  }, error = function(e) {
    x
  })
  return(result)
}

df$searched_adress <- sapply(df$searched_adress, func)



# Dropping empty strings in category
df <- df %>% filter(category != "")



# Grouping by 'date' and counting occurrences, creating a new dataframe
no_occ <- df %>%
  group_by(date) %>%
  summarise(count = n()) %>%
  ungroup()


# Renaming the dataframe column
names(no_occ)[1] <- "date"


# Exporting dfs to csv file
#write.csv(no_occ, "cleaned_data/numer_occ.csv", row.names = FALSE)
#write.csv(df, "cleaned_data/cleaned.csv", row.names = FALSE)

