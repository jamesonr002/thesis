# ===============================================
# Program: 0_soi.R
# Author: Jameson Roth
# Date: 2026 10 20
# Description: Clean SOI data
# ===============================================

library(tidyverse)
library(janitor)
library(dplyr)
library(rprojroot)
library(binsmooth)

#====================
# Fixing some code in the splinebins() function that leads to an error when the median is in the top bin
#===================

src <- deparse(binsmooth::splinebins)
src <- sub("if (fitWarn)", "if (isTRUE(fitWarn))", src, fixed = TRUE)
splinebins_fix <- eval(parse(text = src), envir = asNamespace("binsmooth"))

src <- deparse(binsmooth::sb_percentiles)
src <- sub(
	"if (splinebinFit$fitWarn)",
	"if (isTRUE(splinebinFit$fitWarn))",
	src,
	fixed = TRUE
)
sb_percentiles_fix <- eval(parse(text = src), envir = asNamespace("binsmooth"))

#===================

setwd(find_root(is_git_root))

cbsa_zip <- read_csv("0_data/1_clean/cbsa_zip.csv") |>
	select("geoid", "cbsa", "city", "state")
zips_keep <- cbsa_zip[["geoid"]]

clean_csv <- function(yr) {
	tmp <- read_csv(
		paste0("0_data/0_raw/", yr, "zpallagi.csv"),
		show_col_types = FALSE
	) |>
		clean_names() |>
		select(statefips, zipcode, agi_stub, n1, a00100) |>
		mutate(statefips = as.numeric(statefips)) |>
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
	statefips = character(),
	zipcode = character(),
	agi_stub = integer(),
	n1 = integer(),
	a00100 = double(),
	year = character()
)

for (i in 11:22) {
	soi <- rbind(soi, clean_csv(i))
}

joined <- left_join(soi, cbsa_zip, by = c("zipcode" = "geoid"))

zip_means <- joined |>
	group_by(zipcode, year) |>
	summarize(
		sum_n1 = sum(n1, na.rm = TRUE),
		sum_a00100 = sum(a00100),
		zip_mean = sum_a00100 / sum_n1
	) |>
	ungroup() |>
	select("zipcode", "year", "zip_mean")
joined <- left_join(joined, zip_means, by = c("zipcode", "year"))

cbsa_means <- joined |>
	group_by(cbsa, year, agi_stub) |>
	summarize(
		n1 = sum(n1, na.rm = TRUE),
		a00100 = sum(a00100),
		bin_min = first(bin_min),
		bin_max = first(bin_max)
	) |>
	ungroup() |>
	group_by(cbsa, year) |>
	mutate(cbsa_mean = sum(a00100) / sum(n1)) |>
	ungroup() |>
	select(
		"cbsa",
		"year",
		"cbsa_mean",
		"bin_min",
		"bin_max",
		"n1",
		"a00100",
		"agi_stub"
	)
glimpse(cbsa_means)

zip_distributions <- joined |>
	group_by(zipcode, year) |>
	arrange(agi_stub, .by_group = TRUE) |>
	group_nest() |>
	mutate(
		zip_fit = map(data, function(df) {
			be <- df$bin_max
			bc <- df$n1
			mean <- unique(df$zip_mean)
			return(splinebins_fix(
				be,
				bc,
				mean
			))
		}),
		# gini_zip = map_dbl(data$zip_fit, gini()),
		zip_median = map_dbl(data, function(df) {
			n <- sum(df$n1)
			csum <- cumsum(df$n1)
			i <- which(csum >= n / 2)[1]
			if (is.na(df$bin_max[i])) {
				return(NA)
			}
			csum_prev <- if (i == 1) 0 else csum[i - 1]
			lb <- df$bin_min[i]
			ub <- df$bin_max[i] + 1

			lb + (n / 2 - csum_prev) / df$n1[i] * (ub - lb)
		})
	) |>
	ungroup() |>
	select(zipcode, year, zip_fit, zip_median)
glimpse(zip_distributions)

joined <- left_join(joined, zip_distributions, by = c("zipcode", "year"))

cbsa_distributions <- cbsa_means |>
	group_by(cbsa, year) |>
	arrange(agi_stub, .by_group = TRUE) |>
	group_nest() |>
	mutate(
		cbsa_fit = map(data, function(df) {
			bin_edges <- df$bin_max
			bin_counts <- df$n1
			cbsa_mean <- unique(df$cbsa_mean)
			return(splinebins_fix(bin_edges, bin_counts, cbsa_mean))
		})
	) |>
	ungroup() |>
	select(cbsa, year, cbsa_fit)

cbsa_distributions <- cbsa_distributions %>%
	rowwise() %>%
	mutate(cbsa_40pct = sb_percentiles_fix(get("cbsa_fit"), 40))

joined <- left_join(joined, cbsa_distributions, by = c("cbsa", "year")) |>
	select(statefips, zipcode, year, cbsa, zip_median, cbsa_40pct) |>
	unique()

write_csv(joined, "0_data/1_clean/soi_fitted.csv")
