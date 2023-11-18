# Sentiment analysis of messages (Dictionary based)
require(devtools)
require(readr)
require(stringr)
require(stopwords)
# Get SentiWS from Gist
devtools::source_gist("https://gist.github.com/Studentenfutter/b03a5f03bcee00f721287f627eb95c2c")
sentiWS <- get_sentiws()

# Data cleaning for message
csv <- read_csv("scraper/scraped_data/sample.csv")

messages <- trimws(csv$message[!is.na(csv$message)])

df <- data.frame(number = character(length = nrow(csv)),
                 message = character(length = nrow(csv)))
for (i in vector) {
  
}


stop_de <- stopwords::stopwords(language = "de", source = "snowball")
stop_de <- paste(stop_de, collapse = "|")




stringr::str_remove_all(messages, stop_de)
