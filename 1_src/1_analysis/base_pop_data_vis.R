# ===============================================
# Program: base_pop_data_vis.R
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
