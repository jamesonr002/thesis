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

names(zhvi)
names(soi)

joined <- left_join(
	soi,
	zhvi,
	by = c("zipcode" = "region_name", "year")
) |>
	mutate(
	       # TODO: need to add distance from CBD - zip should be within 'inner third' of MSA
		gentrifiable = (zip_median <= cbsa_40pct) & (zhvi_rank <= 0.5)
	)
base_population <- joined |> filter(year == "2011")

write_csv(base_population, "0_data/1_clean/base_population.csv")
