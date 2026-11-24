# ===============================================
# Program: 2_soi.R
# Author: Jameson Roth
# Date: 2026 10 20
# Description: Clean SOI data
# ===============================================

library(tidyverse)
library(janitor)
library(dplyr)
library(rprojroot)
library(binsmooth)

setwd(find_root(is_git_root))

zip_data <- read_csv("0_data/1_clean/zips.csv")
zips_keep <- zip_data[["geoid"]]

clean_csv <- function(yr) {
	tmp <- read_csv(
		paste0("0_data/0_raw/", yr, "zpallagi.csv"),
		show_col_types = FALSE
	) |>
		clean_names() |>
		select(zipcode, agi_stub, n1, a00100) |>
		filter(zipcode %in% zips_keep) |>
		mutate(
			year = paste0("20", yr),
			bin_min = case_when(
				agi_stub == 1 ~ 1,
				agi_stub == 2 ~ 25000,
				agi_stub == 3 ~ 50000,
				agi_stub == 4 ~ 75000,
				agi_stub == 5 ~ 100000,
				agi_stub == 6 ~ 200000
			),
			bin_max = case_when(
				agi_stub == 1 ~ 24999,
				agi_stub == 2 ~ 49999,
				agi_stub == 3 ~ 74999,
				agi_stub == 4 ~ 99999,
				agi_stub == 5 ~ 199999,
				agi_stub == 6 ~ NA,
			),
			a00100 = a00100 * 1000
		)
}

soi <- data.frame(
	zipcode = character(),
	agi_stub = numeric(),
	n1 = numeric(),
	a00100 = numeric(),
	year = character()
)

for (i in 11:22) {
	soi <- rbind(soi, clean_csv(i))
}

joined <- left_join(soi, zip_data, by = c("zipcode" = "geoid"))

# TODO: how to handle zip codes with very low number of returns in certain brackets (n1 = 0.0001)
joined <- joined |>
	mutate(a00100 = case_when(n1 < 1 ~ 0, TRUE ~ a00100), n1 = case_when(a00100 < 1 ~ 0, TRUE ~ n1))

cbsa_means <- joined |>
	group_by(cbsa_code, year, agi_stub) |>
	summarize(
		n1 = sum(n1),
		a00100 = sum(a00100),
		bin_min = first(bin_min),
		bin_max = first(bin_max)
	) |>
	ungroup() |>
	group_by(cbsa_code, year) |>
	mutate(cbsa_mean = sum(a00100) / sum(n1)) |>
	ungroup() |>
	select(
		"cbsa_code",
		"year",
		"cbsa_mean",
		"bin_min",
		"bin_max",
		"n1",
		"a00100",
		"agi_stub",
	)

zip_medians <- joined |>
	group_by(zipcode, year) |>
	arrange(agi_stub, .by_group = TRUE) |>
	group_nest() |>
	mutate(
		zip_median = map_dbl(data, function(df) {
			n <- sum(df$n1)
			csum <- cumsum(df$n1)
			i <- which(csum >= n / 2)[1]
			if (is.na(df$bin_max[i])) {
				# TODO: how to handle zips where over 50% of the returns are in the top income bracket
				return(NA)
			}
			csum_prev <- if (i == 1) 0 else csum[i - 1]
			lb <- df$bin_min[i]
			ub <- df$bin_max[i] + 1

			lb + (n / 2 - csum_prev) / df$n1[i] * (ub - lb)
		})
	) |>
	ungroup() |>
	select(zipcode, year, zip_median) |>
	drop_na()
joined <- left_join(joined, zip_medians, by = c("zipcode", "year"))

cbsa_distributions <- cbsa_means |>
	group_by(cbsa_code, year) |>
	arrange(agi_stub, .by_group = TRUE) |>
	group_nest() |>
	mutate(
		cbsa_fit = map(data, function(df) {
			bin_edges <- df$bin_max
			bin_counts <- df$n1
			cbsa_mean <- unique(df$cbsa_mean)
			return(splinebins(bin_edges, bin_counts, cbsa_mean))
		})
	) |>
	ungroup() |>
	select(cbsa_code, year, cbsa_fit)

joined <- left_join(joined, cbsa_distributions, by = c("cbsa_code", "year")) |>
	select(
		zipcode,
		year,
		cbsa_code,
		cbsa_fit,
		zip_median,
		central
	) |>
	unique()

joined <- joined %>%
	rowwise() %>%
	mutate(
		zip_rank = (cbsa_fit$splineCDF(zip_median) * 100),
	) |>
	select(-cbsa_fit) |>
	filter(!is.na(zip_median))

write_csv(joined, "0_data/1_clean/soi_fitted.csv")
