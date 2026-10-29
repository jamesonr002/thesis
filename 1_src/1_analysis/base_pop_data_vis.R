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
	group_by(cbsa) |>
	mutate(
		count_gentrifiable = sum(gentrifiable, na.rm = TRUE),
		total_zips = n(),
		share_gentrifiable = count_gentrifiable / total_zips,
		cbsa = as.character(cbsa),
		cbsa_name = case_when(
			cbsa == "14460" ~ "Boston",
			cbsa == "47900" ~ "Washington D.C.",
			cbsa == "31080" ~ "Los Angeles",
			cbsa == "41860" ~ "San Francisco",
			cbsa == "35620" ~ "New York",
			cbsa == "16980" ~ "Chicago",
		)
	) |>
	ungroup() |>
	select(cbsa, count_gentrifiable, share_gentrifiable, cbsa_name) |>
	unique()
glimpse(pop)

# Share gentrifiable by CBSA
chart <- ggplot(
	pop,
	aes(
		x = reorder(cbsa_name, -share_gentrifiable),
		y = share_gentrifiable,
		fill = cbsa_name,
	)
) +
	geom_text(aes(label = count_gentrifiable), vjust=-1) +
	geom_bar(stat = "identity") +
	xlab("CBSA") +
	ylab("Share of Gentrifiable Zips") +
	scale_y_continuous(breaks = seq(0, 0.5, 0.01)) +
	scale_fill_discrete(name = "CBSA") +
	scale_fill_brewer(palette = "Spectral") +
	ggtitle("Share of Gentrifiable Zips by CBSA in 2011") +
	theme(
		panel.background = element_rect(
			fill = "white",
			colour = "grey50"
		),
		axis.text.x = element_blank(),
	)
show(chart)
