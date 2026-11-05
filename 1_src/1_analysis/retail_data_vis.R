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
	filter(central) |>
	mutate(
		cbsa_code = as.character(cbsa_code),
		year = as.character(year)
	) |>
	select(
		count_totartsentertainment,
		count_coffeeshopscafes,
		count_delis,
		count_fastfood,
		count_dollarstores,
		cbsa_name,
		cbsa_code,
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
	) |>
	mutate(
		category_pretty = case_when(
			category == "coffeeshopscafes" ~ "Coffee Shops",
			category == "delis" ~ "Delis",
			category == "dollarstores" ~ "Dollar Stores",
			category == "fastfood" ~ "Fast Food",
			category == "totartsentertainment" ~ "Arts and Entertainment"
		)
	)


# TODO: control for cbsa-year population size or number of total businesses in cbsa-year to make this more accurate

grouped_lo <- pop |>
	filter(low_income) |>
	group_by(cbsa_name, year, category_pretty) |>
	summarize(count = mean(count)) |>
	ungroup()
summary(grouped_lo)

grouped_hi <- pop |>
	filter(high_income) |>
	group_by(cbsa_name, year, category_pretty) |>
	summarize(count = mean(count)) |>
	ungroup()
summary(grouped_hi)

grouped_med <- pop |>
	filter(zip_rank > 50, zip_rank < 75) |>
	group_by(cbsa_name, year, category_pretty) |>
	summarize(count = mean(count)) |>
	ungroup()

lo_chart <- ggplot(
	grouped_lo,
	aes(y = cbsa_name, x = count, fill = category_pretty)
) +
	geom_bar(stat = "identity", position = "fill", width = 0.5) +
	xlab("Retail Distribution") +
	ylab("CBSA") +
	labs(
		title = "Figure 2: Low-Income Retail Distribution by CBSA in 2011",
		caption = "Includes ZIP codes with a median income in the \n bottom fortieth percentile relative to the CBSA in 2011."
	) +
	theme(
		panel.background = element_rect(
			fill = "white",
		),
		axis.text.x = element_blank(),
		text = element_text(size = 11, family = "Times")
	) +
	scale_fill_brewer(palette = "Reds") +
	guides(fill = guide_legend(title = "Retail Category"))

hi_chart <- ggplot(
	grouped_hi,
	aes(y = cbsa_name, x = count, fill = category_pretty, width = 0.5)
) +
	geom_bar(stat = "identity", position = "fill") +
	xlab("Retail Distribution") +
	ylab("CBSA") +
	labs(
		title = "Figure 4: High-Income Retail Distribution by CBSA in 2011",
		caption = "Includes ZIP codes with a median income in the top \n twenty-fifth percentile relative to the CBSA in 2011."
	) +
	theme(
		panel.background = element_rect(
			fill = "white",
		),
		axis.text.x = element_blank(),
		text = element_text(size = 11, family = "Times")
	) +
	scale_fill_brewer(palette = "Reds") +
	guides(fill = guide_legend(title = "Retail Category"))

mod_chart <- ggplot(
	grouped_med,
	aes(y = cbsa_name, x = count, fill = category_pretty)
) +
	geom_bar(stat = "identity", position = "fill", width = 0.5) +
	xlab("Retail Distribution") +
	ylab("CBSA") +
	labs(
		title = "Figure 3: Moderate-Income Retail Distribution by CBSA in 2011",
		caption = "Includes ZIP codes with a median income below the top twenty-fifth \n percentile and above the fortieth percentile relative to the CBSA in 2011."
	) +
	theme(
		panel.background = element_rect(
			fill = "white",
		),
		axis.text.x = element_blank(),
		text = element_text(size = 11, family = "Times")
	) +
	scale_fill_brewer(palette = "Reds") +
	guides(fill = guide_legend(title = "Retail Category"))

# TODO: plot individual MSAs by low, med, hi

ggsave(
	"4_drafts/figures/retail_hi.png",
	hi_chart,
	width = 170,
	height = 100,
	units = "mm"
)
ggsave(
	"4_drafts/figures/retail_lo.png",
	lo_chart,
	width = 170,
	height = 100,
	units = "mm"
)
ggsave(
	"4_drafts/figures/retail_mod.png",
	mod_chart,
	width = 170,
	height = 100,
	units = "mm"
)
show(lo_chart)
show(mod_chart)
show(hi_chart)
