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
ggplot(
	pop,
	aes(
		x = reorder(cbsa_name, -share_gentrifiable),
		y = share_gentrifiable,
		fill = cbsa_name,
	)
) +
	geom_text(aes(label = count_gentrifiable), vjust=-1, size = 2.5) +
	geom_bar(stat = "identity") +
	xlab("CBSA") +
	ylab("Share of Gentrifiable Zips") +
	scale_y_continuous(breaks = seq(0, 0.2, 0.01)) +
	scale_fill_brewer(palette = "Spectral") +
	ggtitle("Share of Gentrifiable Zips by CBSA in 2011") +
	theme(
		panel.background = element_rect(
			fill = "white",
			colour = "grey50"
		),
		axis.text.x = element_blank(),
		text = element_text(size = 10)
	)
