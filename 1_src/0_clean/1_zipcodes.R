# ===============================================
# Program: 1_zipcodes.R
# Author: Jameson Roth
# Date: 2026 10 21
# Description: Get zipcodes in counties of interest
# ===============================================

# TODO: take out non-central
# TODO: visualizations: stacked bar chart showing hi-mod-low-gentrifiable distribution in 2011 by CBSA
# TODO: aggregate hi-mod-low retail distribution stacked bar chart to all CBSAs, hi-mod-low

library(tidyverse)
library(rprojroot)
library(httr)
library(jsonlite)

setwd(find_root(is_git_root))

# Boston, Washington D.C., LA, SF, NYC, Chicago
cbsa_codes <- list("14460", "47900", "31080", "41860", "35620", "16980")
cbsa_county_xw <- read_csv("0_data/1_clean/cbsa_county_xw.csv")
fips_codes <- cbsa_county_xw[['full_code']]
zcta_xw <- read_csv("0_data/0_raw/zip_zcta_xref.csv") |> select(-source)

con <- file("0_data/0_raw/api.txt", "r")
token <- con |> readLines(n = 1)
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
	res <- GET(
		url,
		query = list(type = 7, query = code),
		add_headers(Authorization = paste("Bearer", token))
	)
	tmp <- fromJSON(content(res, type = 'text'))
	out <- rbind(out, tmp$data$results)
}

data <- out |> select(county, geoid)

data <- left_join(data, zcta_xw, by = c("geoid" = "zip_code"))
data <- data |> filter(geoid == zcta)

joined <- left_join(data, cbsa_county_xw, by = c("county" = "full_code")) |>
	select(geoid, cbsa_code, central) |>
	group_by(geoid, cbsa_code) |>
	summarize(central = prod(central)) |>
	ungroup()

write_csv(joined, "0_data/1_clean/zips.csv")
