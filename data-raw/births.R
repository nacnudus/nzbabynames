# Downloaded from Statistics New Zealand Infoshare
# Group: Births - VSB
# Table: Table: Live births (by sex), stillbirths (Maori and total population) (Annual-Dec)
# Variables:
# * Live births, male
# * Live births, female
# * Live births
# Ethnicity: Total
# All years
# Table reference VSB038AA

library(tidyverse)
library(here)

path <- here("data-raw", "VSB357005_20190109_100559_70.csv")

first_line_number <- 4L

final_line_number <-
  melt_csv(path) %>%
  dplyr::filter(value == "Table information:") %>%
  pull(row) %>%
  `-`(1L)

nzbirths <-
  read_csv(path,
           skip = first_line_number,
           n_max = final_line_number - first_line_number,
           col_names = c("year", "male", "female", "total"),
           col_types = "iiii",
           na = "..")

usethis::use_data(nzbirths, overwrite = TRUE)
