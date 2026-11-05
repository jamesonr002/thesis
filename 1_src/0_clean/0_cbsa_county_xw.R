# ===============================================
# Program: 0_cbsa_county_xw.R
# Author: Jameson Roth
# Date: 2026 11 01
# Description: Connect CBSAs of interest to county FIPS codes, in order to then connect these to ZIP codes
# ===============================================

library(tidyverse)
library(readxl)
library(janitor)
library(rprojroot)

setwd(find_root(is_git_root))
cbsa_codes <- list("14460", "47900", "31080", "41860", "35620", "16980")

cbsa <- read_excel("0_data/0_raw/list1_2023.xlsx", skip = 2) |> clean_names()
names(cbsa)

cbsa <- cbsa |>
	filter(cbsa_code %in% cbsa_codes) |>
	mutate(central = (central_outlying_county == "Central"),
			  full_code = paste0(fips_state_code, fips_county_code)) |>
	select(cbsa_code, full_code, central)
write_csv(cbsa, "0_data/1_clean/cbsa_fips.csv")

glimpse(cbsa)
