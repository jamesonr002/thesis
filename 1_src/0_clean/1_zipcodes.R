# ===============================================
# Program: 1_zipcodes.R
# Author: Jameson Roth
# Date: 2026 10 21
# Description: Get zipcodes in counties of interest
# ===============================================

library(tidyverse)
library(rprojroot)
library(httr)
library(jsonlite)

setwd(find_root(is_git_root))

# Boston, Washington D.C., LA, SF, NYC, Chicago
cbsa_codes <- list("14460", "47900", "31080", "41860", "35620", "16980")
fips_data <- read_csv("0_data/1_clean/cbsa_fips.csv")
fips_codes <- fips_data[["full_code"]]

con <- file("0_data/0_raw/api.txt", "r") 
token <- con |> readLines(n=1)
close(con)
url <- "https://www.huduser.gov/hudapi/public/usps"

# initialize dataframe
out <- data.frame(
		  "county" = character(),
		  "geoid" = character(),
		  "city" = character(),
		  "state" = character(),
		  "res_ratio" = numeric(),
		  "bus_ratio" = numeric(),
		  "oth_ratio" = numeric(),
		  "tot_ratio" = numeric()
)

for (code in fips_codes) {
	res <- GET(url, query = list(type = 7, query = code),
	add_headers(Authorization = paste("Bearer", token)))
	tmp <- fromJSON(content(res, type = 'text'))
	out <- rbind(out, tmp$data$results)
}

zcta_xw <- read_csv("0_data/0_raw/zip_zcta_xref.csv")
out <- left_join(out, zcta_xw, by=c("geoid"="zip_code"))
out <- left_join(out, fips_data, by=c("county"="full_code"))
write_csv(out, "0_data/1_clean/county_zip.csv")
write_csv(out |> select("geoid"), "0_data/1_clean/zips_keep.csv")
