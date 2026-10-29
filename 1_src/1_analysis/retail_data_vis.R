# ===============================================
# Program: retail_data_vis.R
# Author: Jameson Roth
# Date: 2026 10 27
# Description: Produce data visualization 2 - retail counts for different subsets of zips
# ===============================================
library(tidyverse)
library(ggplot2)
library(rprojroot)
library(RColorBrewer)

setwd(find_root(is_git_root))

pop <- read_csv("0_data/1_clean/base_population.csv") |>
	mutate(cbsa = as.character(cbsa), year = as.character(year)) |>
	select(
		count_totartsentertainment,
		count_coffeeshopscafes,
		count_delis,
		count_fastfood,
		count_dollarstores,
		cbsa_name,
		cbsa,
		year,
		low_income,
		high_income,
		zcta,
		zipcode,
		zip_rank
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
	group_by(cbsa_name, year, category) |>
	summarize(count = mean(count)) |>
	ungroup()
summary(grouped_lo)

grouped_hi <- pop |>
	filter(high_income) |>
	group_by(cbsa_name, year, category) |>
	summarize(count = mean(count)) |>
	ungroup()
summary(grouped_hi)

grouped_med <- pop |>
	filter(zip_rank > 50, zip_rank < 75) |>
	group_by(cbsa_name, year, category) |>
	summarize(count = mean(count)) |>
	ungroup()

ggplot(
	grouped_lo,
	aes(y = cbsa_name, x = count, fill = category)
) +
	geom_bar(stat = "identity", position = "fill") +
	xlab("Retail Distribution") +
	ylab("CBSA") +
	labs(
		title = "Low-Income Retail Distribution by CBSA in 2011",
		caption = "Zip codes with a median income in the \n bottom fiftieth percentile relative to the CBSA in 2011."
	) +
	theme(
		panel.background = element_rect(
			fill = "white",
			colour = "grey50"
		),
		axis.text.x = element_blank(),
	) +
	scale_fill_brewer(palette = "Spectral")
ggplot(
	grouped_hi,
	aes(y = cbsa_name, x = count, fill = category)
) +
	geom_bar(stat = "identity", position = "fill") +
	xlab("Retail Distribution") +
	ylab("CBSA") +
	labs(
		title = "High-Income Retail Distribution by CBSA in 2011",
		caption = "Zip codes with a median income in the top \n twenty-fifth percentile relative to the CBSA in 2011."
	) +
	theme(
		panel.background = element_rect(
			fill = "white",
			colour = "grey50"
		),
		axis.text.x = element_blank(),
	) +
	scale_fill_brewer(palette = "Spectral")

ggplot(
	grouped_med,
	aes(y = cbsa_name, x = count, fill = category)
) +
	geom_bar(stat = "identity", position = "fill") +
	xlab("Retail Distribution") +
	ylab("CBSA") +
	labs(
		title = "Moderate-Income Retail Distribution by CBSA in 2011",
		caption = "Zip codes with a median income below the top twenty-fifth \n percentile and above the fiftieth percentile relative to the CBSA in 2011."
	) +
	theme(
		panel.background = element_rect(
			fill = "white",
			colour = "grey50"
		),
		axis.text.x = element_blank(),
	) +
	scale_fill_brewer(palette = "Spectral")
