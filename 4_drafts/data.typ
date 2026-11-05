#set text(font: "New Computer Modern")
#set par(spacing: 1em, first-line-indent: 1em)

= Data

The data used cover three domains: income, home values, and retail
environments. Income and home value data is used to characterize a
neighborhood's gentrification status, following a method developed by Bunten et
al. (2023). Retail environment data is then used to characterize changes in the
establishments present in a ZIP code over time. The consistent unit of
measurement across all datasets is a ZIP code-year.

The baseline population for this study consists of all ZIP codes in each of six
core-based statistical areas (CBSAs): Chicago, New York City, Boston, Los
Angeles, Washington D.C., and San Francisco. These areas were chosen based on a
combination of population size and reports of extensive gentrification in these
areas. While all ZIP codes in each CBSA are used when computing the CBSA's
distribution of home values and income, only ZIP codes in central counties are
considered eligible to undergo gentrification in this study.

== Income

Income data come from the Statistics of Income files provided by the IRS. These
files list ZIP code level totals for the number of returns filed in each of
six income brackets, as well as the total dollar amount of income falling
into each bracket. These files are provided in a standardized format from 2011
to 2022. Earlier years use varying delineations of the income brackets, and
for this reason, the years 2011 to 2022 were chosen for this study.

ZIP codes are matched to each CBSA using the HUD CBSA-ZIP crosswalk, accessed
through the HUD User API. Median incomes for each ZIP code are computed using
interpolation assuming a uniform distribution within each income bin.
CBSA-level distributions are computed using R's "splinebins" package, which
specifically handles calculations for binned datasets. The CBSA-level
distribution for each year is then used to find each ZIP code's income
percentile ranking within its CBSA.

== Home value

Home value data is sourced from the Zillow Home Value Index (ZHVI), which provides an
estimate of the value of single-family homes in the 35th to 65th percentile of
each ZIP code tablulation area (ZCTA). ZCTAs differ slightly from ZIP codes, so
a crosswalk was used to match ZIP codes to their associated ZCTA in order for
the income and retail data to be merged with the home value data. The ZHVI is
provided on a monthly basis, and annual averages per ZIP code were computed for
the purpose of this study. Similarly to the income data, the home value data
for each ZIP code-year was assigned a percentile ranking based on the distribution
of the CBSA that the ZIP code belongs to in that year.

== Retail distribution

The retail environment of each ZIP code was assessed using data from
the National Neighborhood Data Archive, which collects and publishes data on
counts of businesses in different categories based on NAICS codes. The
categories of interest in this study thus far are: dollar stores, coffee shops
and cafés, delis, and the total number of arts, entertainment and leisure
establishments. In the future, more categories will be added to give a more
comprehensive picture of a ZIP code's retail environment.

Figures 2 through 4 show the shares of different types of retail establishments
in high-income, moderate-income, and low-income ZIP codes in 2011. Here,
high-income ZIP codes are defined as those in the top twenty-fifth percentile,
low-income as those within the bottom fortieth percentile, and moderate-income
as those in between.

From these figures, some clear preliminary differences can be seen in the
retail distributions of low, moderate, and high-income areas. High-income
areas have more coffee shops and entertainment-related establishments, while
low-income areas have more dollar stores and fast-food restaurants.

== Identification of gentrification

From among the ZIP codes in each CBSA, those designated as gentrifiable in any
given year are those which satisfy the following two conditions: (1) the
median income of the ZIP code is below the fortieth percentile relative to the
CBSA, and (2) the ZIP code lies in one of the central counties of the CBSA.
Those ZIP codes identified as gentrifying in any given year are those which
were in a previous year identified as gentrifiable, and exhibit a twenty-five
percentile point gap between their average home value and their median income.

Figure 1 shows the share of ZIP codes in each CBSA in 2011 that are considered
eligible for gentrification according to the two conditions outlined above.

#figure(
  image("figures/base_pop_chart.png", width: 80%),
)

#figure(
  image("figures/retail_lo.png", width: 92%),
)
#figure(
  image("figures/retail_mod.png", width: 92%),
)
#figure(
  image("figures/retail_hi.png", width: 92%),
)
#pagebreak()
= References
#set par(first-line-indent: 0em)

Housing Data. Zillow. (n.d.). https://www.zillow.com/research/data/ 

SOI tax stats - individual income tax statistics - ZIP code data (SOI).
Internal Revenue Service. (n.d.).
https://www.irs.gov/statistics/soi-tax-stats-individual-income-tax-statistics-zip-code-data-soi 

University of Michigan. (n.d.). Data. NaNDA - National Neighborhood Data
Archive. https://nanda.isr.umich.edu/data/ 
 
 
 
 
 
 
