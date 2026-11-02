#set text(font: "New Computer Modern")
#set par(spacing: 1em, first-line-indent: 1em)

= Data

The data used for this project cover three domains: income, home values, and
retail environments.

Income data come from the Statistics of Income files provided by the IRS. These
files provide ZIP code level totals for the number of returns filed in each of
six income brackets, as well as for the total dollar amount of income falling
into each bracket. These files are provided in a standardized format from 2011
to 2022, with earlier years using varying delineations of the income brackets.
For this reason, the years 2011 to 2022 were chose for this study.

Home value data is sourced from the Zillow Home Value Index, which provides an
estimate of the value of single-family homes in the 35th to 65th percentile of
each ZIP code.

Finally, the retail environment of each ZIP code was assessed using data from
the National Neighborhood Data Archive, which collects and publishes data on
counts of businesses in different categories based on NAICS codes. The
categories of interest in this study thus far are: dollar stores, coffee shops
and cafés, delis, and the total number of arts, entertainment and leisure
establishments.

The baseline population consists of all ZIP codes in 2011 in each of six
core-based statistical areas (CBSAs): Chicago, New York City, Boston, Los
Angeles, Washington D.C., and San Francisco. From among these ZIP codes, those
designated as gentrifyiable in any given year are those with a median income
below the fortiethe percentile relative to the CBSA. Those identified as
gentrifying in any given year are those which were previously identified as
gentrifiable in 2011, and exhibit a twenty-five percentile point gap between
their median home value and their median income.

Figure 1 shows the share of gentrifiable ZIP codes in each CBSA in 2011.

Figure 2 shows the shares of different types of retail establishments in
high-income, moderate-income, and low-income ZIP codes in 2011. Here,
high-income ZIP codes are defined as those in the top twenty-fifth percentile,
low-income as those within the bottom fortieth percentile, and moderate-income
as those in between.
