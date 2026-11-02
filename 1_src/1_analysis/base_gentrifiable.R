# ===============================================
# Program: base_gentrifying.R
# Author: Jameson Roth
# Date: 2026 10 26
# Description: Get population of gentrifiable zip codes in 2011
# ===============================================

library(tidyverse)
library(rprojroot)
library(binsmooth)

setwd(find_root(is_git_root))

zhvi <- read_csv("0_data/1_clean/zhvi.csv")
soi <- read_csv("0_data/1_clean/soi_fitted.csv")
retail <- read_csv("0_data/1_clean/retail_counts.csv")

names(zhvi)
summary(soi)
names(retail)

soi_zhvi_joined <- left_join(
	soi,
	zhvi,
	by = c("zipcode" = "region_name", "year")
) |>
	filter(!is.na(annual_avg_zhvi))

all_joined <- left_join(
	soi_zhvi_joined,
	retail,
	by = c("zipcode" = "geoid", "year", "cbsa_code")
) |>
	mutate(
		gentrifiable = (zip_rank <= 40) & (central),
		low_income = zip_rank <= 50,
		high_income = zip_rank >= 75,
		pct_diff = abs(zip_rank - zhvi_rank),
		# TODO: add condition: gentrifiable in previous year
		gentrifying = (pct_diff >= 25),
		cbsa_name = case_when(
			cbsa_code == "14460" ~ "Boston",
			cbsa_code == "47900" ~ "Washington D.C.",
			cbsa_code == "31080" ~ "Los Angeles",
			cbsa_code == "41860" ~ "San Francisco",
			cbsa_code == "35620" ~ "New York",
			cbsa_code == "16980" ~ "Chicago",
		)
	)
summary(all_joined)
base_population <- all_joined |> filter(year == "2011")

write_csv(base_population, "0_data/1_clean/base_population.csv")
write_csv(all_joined, "0_data/1_clean/population.csv")
