require('RCurl', quietly = TRUE, warn.conflicts = FALSE)
require('dplyr', quietly = TRUE, warn.conflicts = FALSE)
require('futile.logger', quietly = TRUE, warn.conflicts = FALSE)


################################################################################
# Kimonolabs Data URL
################################################################################

csv.url <- "https://www.kimonolabs.com/api/csv/6m6p7z5y?apikey=JgN4UsyEGSZ0ogyTSDnJPCCObZ7lEbHa"


################################################################################
# Retrieves data from given URL
################################################################################

get.data.from.url <- function(url, on.success = NULL, on.error = NULL) {
  rval <- ""
  tryCatch({
    rval <- RCurl::getURL(url, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
  if (is.function(on.success))
    on.success()
  }, error = function(e) {
    if (is.function(on.error))
      on.error(e)
  })
  return(rval)
}

on.success.get.data.from.url <- function() {
  flog.debug("Retrieved data from given url.")
}

on.error.get.data.from.url <- function(e) {
  flog.error("Error retrieving data from url: %s", e$message)
}


################################################################################
# Converts text into data.frame 
# Logs error message, if any.
################################################################################

csv.text.to.data.frame <- function(csv.text, on.success = NULL, on.error = NULL) {
  rval <- data.frame()
  tryCatch({
    rval  <- read.csv(text = csv.text, skip = 1, header = TRUE, as.is = TRUE, stringsAsFactors = FALSE)
    if (is.function(on.success))
      on.success()
  }, error = function(e) {
    if (is.function(on.error))
      on.error(e)
  })
  return(rval)
}

on.success.csv.text.to.data.frame <- function() {
  flog.debug("Parsed data retrieved from url")
}

on.error.csv.text.to.data.frame <- function(e) {
  flog.error("Error parsing data retrieved from url: %s. Data: %s", e$message, csv.text)
}


################################################################################
# Data
################################################################################

earthquakes <- csv.url %>% 
  get.data.from.url(on.success.get.data.from.url, on.error.get.data.from.url) %>% 
  csv.text.to.data.frame(on.success.csv.text.to.data.frame, on.error.csv.text.to.data.frame) %>% 
  mutate(date_time = sprintf("%s %s", date, time)) %>%
  transform(date_time_posixlt = as.POSIXlt.character(date_time)) %>% 
  filter(date_time_posixlt >= as.POSIXlt.character(x = "2015/04/25 11:56"))