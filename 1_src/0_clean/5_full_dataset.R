# ===============================================
# Program: 5_full_dataset.R
# Author: Jameson Roth
# Date: 2026 11 10
# Description: Pull all three datasets and merge based on zipcode-year
# ===============================================

library(tidyverse)

soi <- read_csv("0_data/1_clean/soi_fitted.csv")
zhvi <- read_csv("0_data/1_clean/zhvi.csv")
retail <- read_csv("0_data/1_clean/retail_counts.csv")

prev_year_gen <- function(year, zipcode) {
	if (year == 2011) {
		return(FALSE)
	} else {
		tmp <- all_joined[
			all_joined$year == year &
				all_joined$region_name == zipcode,
		]
		return(isTRUE(tmp$gentrifiable))
	}
}

soi_zhvi_joined <- inner_join(
	zhvi,
	soi,
	by = c("region_name" = "zipcode", "year")
)

all_joined <- left_join(
	soi_zhvi_joined,
	retail,
	by = c("region_name" = "geoid", "year", "cbsa_code")
) |>
	#TODO: add shares of each retail category by cbsa-year
	mutate(
		gentrifiable = (zip_rank <= 40),
		low_income = zip_rank <= 40,
		high_income = zip_rank >= 75,
		pct_diff = zhvi_rank - zip_rank,
		cbsa_name = case_when(
			cbsa_code == "14460" ~ "Boston",
			cbsa_code == "47900" ~ "Washington D.C.",
			cbsa_code == "31080" ~ "Los Angeles",
			cbsa_code == "41860" ~ "San Francisco",
			cbsa_code == "35620" ~ "New York",
			cbsa_code == "16980" ~ "Chicago",
		)
	)

all_joined <- all_joined |>
	rowwise() |>
	mutate(
		gentrifying = (pct_diff >= 25) &
			prev_year_gen(year, region_name)
	) |>
	rename(zipcode = region_name)

categories_pop <- all_joined |>
	pivot_longer(
		starts_with("count"),
		values_to = "count",
		names_to = "category",
		names_prefix = "count_"
	)
base_population <- all_joined |> filter(year == "2011")

write_csv(base_population, "0_data/1_clean/base_population.csv")
write_csv(all_joined, "0_data/1_clean/population.csv")
write_csv(categories_pop, "0_data/1_clean/population_by_cat.csv")
