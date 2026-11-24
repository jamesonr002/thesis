# ===============================================
# Program: 01_base_pop_data_vis.R
# Author: Jameson Roth
# Date: 2026 10 27
# Description: Data visualisations and summary stats of base population (2011 zips)
# ===============================================

library(tidyverse)
library(ggplot2)
library(rprojroot)
library(RColorBrewer)

setwd(find_root(is_git_root))

pop <- read_csv("0_data/1_clean/base_population.csv") |>
	group_by(cbsa_code) |>
	mutate(
		count_gentrifiable = sum(gentrifiable, na.rm = TRUE),
		total_zips = n(),
		share_gentrifiable = count_gentrifiable / total_zips,
		cbsa_code = as.character(cbsa_code),
	) |>
	ungroup() |>
	select(cbsa_code, count_gentrifiable, share_gentrifiable, cbsa_name) |>
	unique()
glimpse(pop)

# Share gentrifiable by CBSA
base_pop_chart <- ggplot(
	pop,
	aes(
		x = reorder(cbsa_name, -share_gentrifiable),
		y = share_gentrifiable,
		# fill = cbsa_name,
	)
) +
	geom_bar(stat = "identity", fill = "cadetblue4") +
	xlab("CBSA") +
	ylab("Share of Gentrifiable ZIP Codes") +
	scale_y_continuous(
		breaks = seq(0, 0.15, 0.01),
		limits = c(0, 0.15),
		expand = c(0, 0)
	) +
	# ylim(0, 0.15) +
	scale_fill_brewer(palette = "Set3") +
	# guides(fill = guide_legend(title = "CBSA")) +
	ggtitle("Figure 1: Share of Gentrifiable ZIP Codes in 2011") +
	theme(
		panel.background = element_rect(
			fill = "white",
			# colour = "grey50"
		),
		axis.text.x = element_text(size = 10),
		# axis.text.x = element_blank(),
		text = element_text(size = 12, family = "Times")
	)

ggsave(
	"4_drafts/figures/base_pop_chart.png",
	base_pop_chart,
	width = 170,
	height = 125,
	units = "mm"
)
show(base_pop_chart)

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
