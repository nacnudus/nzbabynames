library(tidyverse)
library(tidyxl)
library(unpivotr)

download.file("https://smartstart.services.govt.nz/assets/files/Top-100-girls-and-boys-names-since-1954.xlsx",
              destfile = "inst/extdata/nzbabynames.xlsx", mode = "wb")

sheets <- xlsx_cells("./inst/extdata/nzbabynames.xlsx")

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
  mutate(sex = fct_recode(sex, F = "Girls' Names", M = "Boys' Names"),
         sex = as.character(sex),
         year = as.integer(year),
         n = as.integer(n)) %>%
  select(year, sex, name, n)  %>%
  arrange(sex, year, desc(n), name)

write.csv(nzbabynames, row.names = FALSE, quote = FALSE,
          file=gzfile("./inst/extdata/babynames.csv.gz"))

usethis::use_data(nzbabynames, overwrite = TRUE)
