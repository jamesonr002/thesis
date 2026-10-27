# ===============================================
# Program: 0_zipcodes.R
# Author: Jameson Roth
# Date: 2026 10 21
# Description: Get zipcodes in CBSAs of interest
# ===============================================

library(tidyverse)
library(rprojroot)
library(httr)
library(jsonlite)

setwd(find_root(is_git_root))

# Boston, Washington D.C., LA, SF, NYC, Chicago
cbsa_codes <- list("14460", "47900", "31080", "41860", "35620", "16980")
con <- file("0_data/0_raw/api.txt", "r") 
token <- con |> readLines(n=1)
close(con)
url <- "https://www.huduser.gov/hudapi/public/usps"

# initialize dataframe
out <- data.frame(
		  "cbsa" = character(),
		  "geoid" = character(),
		  "city" = character(),
		  "state" = character(),
		  "res_ratio" = numeric(),
		  "bus_ratio" = numeric(),
		  "oth_ratio" = numeric(),
		  "tot_ratio" = numeric()
)

for (code in cbsa_codes) {
	res <- GET(url, query = list(type = 8, query = code),
	add_headers(Authorization = paste("Bearer", token)))
	tmp <- fromJSON(content(res, type = 'text'))
	out <- rbind(out, tmp$data$results)
}

write_csv(out, "0_data/1_clean/cbsa_zip.csv")
