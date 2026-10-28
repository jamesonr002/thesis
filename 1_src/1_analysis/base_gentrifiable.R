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
) |> filter(!is.na(annual_avg_zhvi))

all_joined <- left_join(
	soi_zhvi_joined,
	retail,
	by = c("zipcode" = "geoid", "year", "cbsa")
) |>
	mutate(
		# TODO: need to add distance from CBD - zip should be within 'inner third' of MSA
		gentrifiable = (zip_median <= 40) & (zhvi_rank <= 50),
		low_income = zip_rank <= 50,
		high_income = zip_rank >= 75,
		pct_diff = abs(zip_rank - zhvi_rank),
		# TODO: add condition: gentrifiable in previous year
		gentrifying = pct_diff >= 25
	)
summary(all_joined)
base_population <- all_joined |> filter(year == "2011")

write_csv(base_population, "0_data/1_clean/base_population.csv")
write_csv(all_joined, "0_data/1_clean/population.csv")
