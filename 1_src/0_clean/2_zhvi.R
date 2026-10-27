# ===============================================
# Program: 2_zhvi.R
# Author: Jameson Roth
# Date: 2026 10 26
# Description: Clean and export home value data from the ZHVI
# ===============================================

library(tidyverse)
library(rprojroot)
library(janitor)
library(binsmooth)

setwd(find_root(is_git_root))

cbsa_zip <- read_csv("0_data/1_clean/cbsa_zip.csv") |>
	select("geoid", "cbsa")
zips_keep <- cbsa_zip[["geoid"]]
# TODO: make zips_keep a dataset so you don't have to keep extracting it

data <- read_csv(
	"0_data/0_raw/Zip_zhvi_uc_sfrcondo_tier_0.33_0.67_sm_sa_month.csv"
) |>
	clean_names() |>
	filter(region_name %in% zips_keep)

zhvi_clean <- data |>
	pivot_longer(
		starts_with("x2"),
		names_to = "date",
		values_to = "zhvi"
	) |>
	mutate(year = substr(date, 2, 5)) |>
	filter(
		year %in%
			list(
				"2011",
				"2012",
				"2013",
				"2014",
				"2015",
				"2016",
				"2017",
				"2018",
				"2019",
				"2020",
				"2021",
				"2022"
			)
	)

zhvi_zip <- zhvi_clean |>
	group_by(region_name, year) |>
	summarize(
		annual_avg_zhvi = mean(zhvi),
	) |>
	ungroup()

zhvi_zip_cbsa <- left_join(
	zhvi_zip,
	cbsa_zip,
	by = c("region_name" = "geoid")
)
glimpse(zhvi_zip_cbsa)

zhvi_out <- zhvi_zip_cbsa |>
	group_by(cbsa, year) |>
	mutate(
		zhvi_rank = rank(annual_avg_zhvi) / length(annual_avg_zhvi),
		median_zhvi_cbsa = median(annual_avg_zhvi, na.rm = TRUE)
	) |>
	ungroup() |>
	select(
		region_name,
		year,
		annual_avg_zhvi,
		median_zhvi_cbsa,
		zhvi_rank
	)
glimpse(zhvi_out)

write_csv(zhvi_out, "0_data/1_clean/zhvi.csv")
