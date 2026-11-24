# ===============================================
# Program: 03_map.R
# Author: Jameson Roth
# Date: 2026 11 19
# Description: Create chloropleth map for data visualization
# ===============================================

library(ggplot2)
library(tidyverse)
library(sf)
library(RColorBrewer)

geo_data <- read_sf("0_data/0_raw/ma_massachusetts_zip_codes_geo.min.json")
pop <- read_csv("0_data/1_clean/population.csv")

#TODO: why are there not measurements for each zip-year / check that all zip-years are counted (01434, etc.)

zips_ma <- pop[['zipcode']]

lvl <- c("gentrifying", "gentrifiable", "high_income", "moderate_income", "low_income")

geo_data_merged <- geo_data |>
	filter(ZCTA5CE10 %in% zips_ma) |>
	left_join(pop, by = c("ZCTA5CE10" = "zipcode")) |>
	mutate(
		income_cat = case_when(
			gentrifying ~ "gentrifying",
			(gentrifiable & !gentrifying) ~ "gentrifiable",
			high_income ~ "high_income",
			TRUE ~ "moderate_income"
		),
		income_cat = factor(income_cat, levels = lvl)
	)

pal <- setNames(brewer.pal(length(lvl), "Spectral"), lvl)
fill_scale <- scale_fill_manual(values = pal)

bos12 <- ggplot(geo_data_merged |> filter(year == "2012")) +
	geom_sf(aes(fill = income_cat), color = "black", linewidth = 0.3) +
	labs(
		title = "Boston ZIP code gentrifiablility 2012",
	) +
	fill_scale +
	theme_void()
bos15 <- ggplot(geo_data_merged |> filter(year == "2015")) +
	geom_sf(aes(fill = income_cat), color = "black", linewidth = 0.3) +
	fill_scale +
	labs(
		title = "Boston ZIP code gentrifiablility 2015",
	) +
	theme_void()
bos20 <- ggplot(geo_data_merged |> filter(year == "2020")) +
	geom_sf(aes(fill = income_cat), color = "black", linewidth = 0.3) +
	labs(
		title = "Boston ZIP code gentrifiablility 2020",
	) +
	fill_scale +
	theme_void()
bos22 <- ggplot(geo_data_merged |> filter(year == "2022")) +
	geom_sf(aes(fill = income_cat), color = "black", linewidth = 0.3) +
	labs(
		title = "Boston ZIP code gentrifiablility 2022",
	) +
	fill_scale +
	theme_void()

geo_data_merged |> filter(gentrifying) |> select(ZCTA5CE10, year)

ggsave(
	"4_drafts/figures/boston_map_12.png",
	bos12,
	width = 200,
	height = 150,
	units = "mm"
)
ggsave(
	"4_drafts/figures/boston_map_20.png",
	bos20,
	width = 200,
	height = 150,
	units = "mm"
)
ggsave(
	"4_drafts/figures/boston_map_15.png",
	bos15,
	width = 200,
	height = 150,
	units = "mm"
)
ggsave(
	"4_drafts/figures/boston_map_22.png",
	bos22,
	width = 200,
	height = 150,
	units = "mm"
)
