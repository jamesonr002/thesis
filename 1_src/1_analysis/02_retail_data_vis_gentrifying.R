# ===============================================
# Program: 02_retail_data_vis.R
# Author: Jameson Roth
# Date: 2026 10 27
# Description: Produce data visualization 2 - retail counts for different subsets of zips
# ===============================================
library(tidyverse)
library(ggplot2)
library(rprojroot)
library(RColorBrewer)

setwd(find_root(is_git_root))

pop <- read_csv("0_data/1_clean/population.csv") |>
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
		zip_rank,
		gentrifying,
		gentrifiable
	) |>
	mutate(
		category_pretty = case_when(
			category == "coffeeshopscafes" ~ "Coffee Shops",
			category == "delis" ~ "Delis",
			category == "dollarstores" ~ "Dollar Stores",
			category == "fastfood" ~ "Fast Food",
			category ==
				"totartsentertainment" ~ "Arts and Entertainment"
		)
	)


# TODO: control for cbsa-year population size or number of total businesses in cbsa-year to make this more accurate?
counter <- 7
cbsa_income_counts_graph <- function(cbsa) {
	tmp <- pop |>
		filter(cbsa_name == cbsa)
	tmplo <- ggplot(
		tmp |>
			filter(low_income & !gentrifying) |>
			group_by(category_pretty, year) |>
			summarize(count = mean(count)) |>
			ungroup(),
		aes(
			x = year,
			y = count,
			group = category_pretty,
			color = category_pretty
		)
	) +
		geom_line() +
		ylab("Retail Distribution") +
		xlab("Year") +
		labs(
			title = paste0(
				"Figure ",
				counter,
				": Retail Distribution Low Income, ",
				cbsa,
				", 2011-2022"
			),
			caption = paste0(
				"Includes all low-income ZIP codes in ",
				cbsa,
				" that are not gentrifying."
			)
		) +
		theme(
			text = element_text(size = 11, family = "Times")
		) +
		scale_fill_brewer(palette = "Reds") +
		guides(fill = guide_legend(title = "Retail Category"))
	ggsave(
		paste0("4_drafts/figures/income_lo_counts_", cbsa, ".png"),
		tmplo,
		width = 170,
		height = 100,
		units = "mm"
	)
	counter <- counter+1

	tmphi <- ggplot(
		tmp |>
			filter(high_income & !gentrifying) |>
			group_by(category_pretty, year) |>
			summarize(count = mean(count)) |>
			ungroup(),
		aes(
			x = year,
			y = count,
			group = category_pretty,
			color = category_pretty
		)
	) +
		geom_line() +
		ylab("Retail Distribution") +
		xlab("Year") +
		labs(
			title = paste0(
				"Figure ",
				counter,
				": Retail Distribution High Income, ",
				cbsa,
				", 2011-2022"
			),
			caption = paste0(
				"Includes all high-income ZIP codes in ",
				cbsa,
				" that are not gentrifying."
			)
		) +
		theme(
			text = element_text(size = 11, family = "Times")
		) +
		scale_fill_brewer(palette = "Reds") +
		guides(fill = guide_legend(title = "Retail Category"))
	ggsave(
		paste0("4_drafts/figures/income_hi_counts_", cbsa, ".png"),
		tmphi,
		width = 170,
		height = 100,
		units = "mm"
	)
	counter <- counter+1
	tmpgen <- ggplot(
		tmp |>
			filter(gentrifying) |>
			group_by(category_pretty, year) |>
			summarize(count = mean(count)) |>
			ungroup(),
		aes(
			x = year,
			y = count,
			group = category_pretty,
			color = category_pretty
		)
	) +
		geom_line() +
		ylab("Retail Distribution") +
		xlab("Year") +
		labs(
			title = paste0(
				"Figure ",
				counter,
				": Retail Distribution Gentrifying, ",
				cbsa,
				", 2011-2022"
			),
			caption = paste0(
				"Includes all ZIP codes in ",
				cbsa,
				" that are gentrifying."
			)
		) +
		theme(
			text = element_text(size = 11, family = "Times")
		) +
		scale_fill_brewer(palette = "Reds") +
		guides(fill = guide_legend(title = "Retail Category"))
	ggsave(
		paste0("4_drafts/figures/income_gen_counts_", cbsa, ".png"),
		tmpgen,
		width = 170,
		height = 100,
		units = "mm"
	)
}

cbsa_gen_counts_graph <- function(cbsa) {
	tmp <- ggplot(
		gentrifying |> filter(cbsa_name == cbsa),
		aes(
			x = year,
			y = count,
			group = category_pretty,
			color = category_pretty
		)
	) +
		geom_line() +
		ylab("Retail Distribution") +
		xlab("Year") +
		labs(
			title = paste0(
				"Figure 6: Retail Distribution in Gentrifying Areas, ",
				cbsa,
				", 2012-2022"
			),
			caption = paste0(
				"Includes all gentrifiable ZIP codes in ",
				cbsa,
				"."
			)
		) +
		theme(
			text = element_text(size = 11, family = "Times")
		) +
		scale_fill_brewer(palette = "Reds") +
		guides(fill = guide_legend(title = "Retail Category"))
	ggsave(
		paste0("4_drafts/figures/gentrifying_counts_", cbsa, ".png"),
		tmp,
		width = 170,
		height = 100,
		units = "mm"
	)
	return(tmp)
}

# TODO: these graphs need fixing - display category counts for each CBSA over time
## one graph per CBSA showing change in counts by category, or one graph per category
## showing change in counts by CBSA. four vars: year, category, count, CBSA

# TODO: for income graphs: one chart per CBSA showing 2011 differences between
## each income group + gentrifiable

## TODO: chart showing change in category counts over time for gentrifying ZIPs
## do this by CBSA

grouped_lo <- pop |>
	filter(low_income) |>
	group_by(cbsa_name, year, category_pretty) |>
	summarize(count = mean(count)) |>
	ungroup()
grouped_hi <- pop |>
	filter(high_income) |>
	group_by(cbsa_name, year, category_pretty) |>
	summarize(count = mean(count)) |>
	ungroup()
grouped_med <- pop |>
	filter(zip_rank > 40, zip_rank < 75) |>
	group_by(cbsa_name, year, category_pretty) |>
	summarize(count = mean(count)) |>
	ungroup()
gentrifiable <- pop |>
	filter(gentrifiable) |>
	group_by(cbsa_name, year, category_pretty) |>
	summarize(count = mean(count)) |>
	ungroup()
gentrifying <- pop |>
	filter(gentrifying) |>
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


gentrifiable_chart <- ggplot(
	gentrifiable,
	aes(y = cbsa_name, x = count, fill = category_pretty)
) +
	geom_bar(stat = "identity", position = "fill", width = 0.5) +
	xlab("Retail Distribution") +
	ylab("CBSA") +
	labs(
		title = "Figure 4: Retail Distribution in Gentrifiable Areas, 2012-2022",
		caption = "Includes gentrifiable ZIP codes across all CBSAs."
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

gentrifying_chart <- ggplot(
	gentrifying,
	aes(y = cbsa_name, x = count, fill = category_pretty)
) +
	geom_bar(stat = "identity", position = "fill", width = 0.5) +
	xlab("Retail Distribution") +
	ylab("CBSA") +
	labs(
		title = "Figure 5: Retail Distribution in Gentrifying Areas, 2012-2022",
		caption = "Includes gentrifying ZIP codes across all CBSAs."
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

gentrifying_counts_graph_bos <- cbsa_gen_counts_graph("Boston")
gentrifying_counts_graph_chi <- cbsa_gen_counts_graph("Chicago")
gentrifying_counts_graph_ls <- cbsa_gen_counts_graph("Los Angeles")
gentrifying_counts_graph_sf <- cbsa_gen_counts_graph("San Francisco")
gentrifying_counts_graph_nyc <- cbsa_gen_counts_graph("New York")
gentrifying_counts_graph_dc <- cbsa_gen_counts_graph("Washington D.C.")

cbsa_income_counts_graph("Boston")

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
ggsave(
	"4_drafts/figures/gentrifiable_chart.png",
	gentrifiable_chart,
	width = 170,
	height = 100,
	units = "mm"
)
ggsave(
	"4_drafts/figures/gentrifying_chart.png",
	gentrifying_chart,
	width = 170,
	height = 100,
	units = "mm"
)
