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
	mutate(
		category_pretty = case_when(
			category == "coffeeshopscafes" ~ "Coffee Shops",
			category == "delis" ~ "Delis",
			category == "dollarstores" ~ "Dollar Stores",
			category == "fastfood" ~ "Fast Food",
			category == "totartsentertainment" ~ "Arts and Entertainment"
		)
	)

bos <- pop |> filter(cbsa_name = "Boston")
