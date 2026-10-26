# ===============================================
# Program: 0_soi.R
# Author: Jameson Roth
# Date: 2026 10 20
# Description: Clean SOI data
# ===============================================

library(tidyverse)
library(janitor)
library(rprojroot)

setwd(find_root(is_git_root))

clean_csv <- function(yr) {
	tmp <- read_csv(paste0("0_data/0_raw/", yr, "zpallagi.csv")) |>
		clean_names() |>
		select(statefips, zipcode, agi_stub, n1, a00100) |>
		filter(zipcode != "00000") |>
		mutate(year = paste0("20",yr))
}

soi <- data.frame(
	statefips = character(),
	zipcode = character(),
	agi_stub = integer(),
	n1 = integer(),
	a00100 = double(),
	year = character()
)

for (i in 11:22) {
	soi <- rbind(soi, clean_csv(i))
}
