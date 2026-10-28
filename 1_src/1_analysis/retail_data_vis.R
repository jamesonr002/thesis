# ===============================================
# Program: retail_data_vis.R
# Author: Jameson Roth
# Date: 2026 10 27
# Description: Produce data visualization 2 - retail counts for different subsets of zips
# ===============================================
library(tidyverse)
library(ggplot2)
library(rprojroot)

setwd(find_root(is_git_root))

pop <- read_csv("0_data/1_clean/base_population.csv") |>
	mutate(cbsa = as.character(cbsa), year = as.character(year)) |>
	select(
	       count_totartsentertainment,
	       count_coffeeshopscafes,
	       count_delis,
	       count_fastfood,
	       count_dollarstores,
	       cbsa,
	       year,
	       low_income,
	       high_income,
	       zcta,
	       zipcode

	) |>
	# TODO: move this to retail cleaning code
	pivot_longer(
		starts_with("count"),
		values_to = "count",
		names_to = "category",
		names_prefix = "count_"
	)


# TODO: control for cbsa-year population size or number of total businesses in cbsa-year to make this more accurate

grouped_lo <- pop |>
	filter(low_income) |>
	group_by(cbsa, year, category) |>
	summarize(count = mean(count)) |>
	ungroup()
summary(grouped_lo)

grouped_hi <- pop |>
	filter(high_income) |>
	group_by(cbsa, year, category) |>
	summarize(count = mean(count)) |>
	ungroup()
summary(grouped_hi)

ggplot(
	grouped_lo,
	aes(y = cbsa, x = count, fill = category)
) +
	geom_bar(stat = "identity", position = "fill")
ggplot(
	grouped_hi,
	aes(y = cbsa, x = count, fill = category)
) +
	geom_bar(stat = "identity", position = "fill")
