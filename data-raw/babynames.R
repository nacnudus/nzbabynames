library(tidyverse)
library(tidyxl)
library(unpivotr)
library(here)

path <- here("data-raw", "Top-100-girls-and-boys-names-since-1954.xlsx")

download.file("https://smartstart.services.govt.nz/assets/files/Top-100-girls-and-boys-names-since-1954.xlsx",
              destfile = path, mode = "wb")

sheets <- xlsx_cells(path)

nzbabynames <-
  sheets %>%
  dplyr::filter(between(row, 5, 107), !is_blank) %>%
  select(sheet, row, col, data_type, character, numeric) %>%
  nest(-sheet) %>%
  mutate(data = map(data,
                    ~ .x %>%
                      behead("NNW", "year") %>%
                      behead("NNW", "header") %>%
                      behead("W", "rank") %>%
                      select(-col) %>%
                      spatter(header))) %>%
  unnest() %>%
  mutate(n = if_else(is.na(No), No., No)) %>%
  select(-row, -No., -No) %>%
  rename(sex = sheet, name = Name) %>%
  mutate(sex = fct_recode(sex, female = "Girls' Names", male = "Boys' Names"),
         sex = as.character(sex),
         year = as.integer(year),
         n = as.integer(n)) %>%
  select(year, sex, name, n)  %>%
  arrange(sex, year, desc(n), name)

usethis::use_data(nzbabynames, overwrite = TRUE)
