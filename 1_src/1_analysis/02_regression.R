# ===============================================
# Program: 02_regression.R
# Author: Jameson Roth
# Date: 2026 11 18
# Description: Run regression of gentrifying dummy on each retail category
# ===============================================

library(tidyverse)
library(ggplot2)
library(modelsummary)
library(fixest)
library(rprojroot)

setwd(find_root(is_git_root))

data <- read_csv("0_data/1_clean/population_by_cat.csv") |>
	mutate(
		year = as.character(year),
		cbsa_code = as.character(cbsa_code)
	) |>
	filter(gentrifiable)

arts_data <- data |> filter(category == "totartsentertainment")
cf_data <- data |> filter(category == "coffeeshopscafes")
ff_data <- data |> filter(category == "fastfood")
d_data <- data |> filter(category == "dollarstores")

m_a <- feols(count ~ gentrifying + year + cbsa_code, arts_data)
summary(m_a)

m_c <- feols(count ~ gentrifying + year + cbsa_code, cf_data)
summary(m_c)

m_ff <- feols(count ~ gentrifying + year + cbsa_code, ff_data)
summary(m_ff)

m_d <- feols(count ~ gentrifying + year + cbsa_code, d_data)
summary(m_d)

models <- list(
	"Dollar Stores" = m_d,
	"Fast Food" = m_ff,
	"Cafes" = m_c,
	"Arts/Ent" = m_a
)

msummary(
	models,
	output = "2_output/table.typ",
	stars = TRUE,
	fmt = fmt_significant(2),
	coef_map = c("gentrifyingTRUE" = "Gentrifying")
)
