# ===============================================
# Program: 3_retail.R
# Author: Jameson Roth
# Date: 2026 10 27
# Description: Clean retail data from NaNDA
# ===============================================

library(janitor)
library(tidyverse)
library(rprojroot)
library(haven)

setwd(find_root(is_git_root))

zipped_files <- list.files(path = "0_data/0_raw/", pattern = ".zip$")
outDir <- "0_data/0_raw/"
for (i in zipped_files) {
	unzip(paste0("0_data/0_raw/", i), exdir = outDir)
}

cbsa_zip_zcta <- read_csv("0_data/1_clean/cbsa_zip.csv") |> drop_na()

f_names <- list(
	"ICPSR_209163-V4.0/nanda_artsentleisure_Zcta10_1990-2022_01.dta",
	"ICPSR_208751-V3.0/nanda_eatdrink_Zcta10_1990-2022_01.dta",
	"ICPSR_209324-V2.1/nanda_dollars_Zcta10_1990-2022_01.dta"
)

get_out_df <- function(in_df) {
	tmp <- read_dta(paste0("0_data/0_raw/", in_df)) |>
		filter(year >= 2011, year <= 2022)
	tmp <- left_join(cbsa_zip_zcta, tmp, by = c("zcta"="zcta10")) |>
		select(cbsa, geoid, zcta, year, starts_with("count_"))
}

out_df_list <- vector("list", 3)
p <- 1
for (f in f_names) {
	out_df_list[[p]] <- get_out_df(f)
	p <- p + 1
}

out <- out_df_list %>% reduce(left_join, by=c("cbsa","geoid","year","zcta"))
names(out)
write_csv(out, "0_data/1_clean/retail_counts.csv")
