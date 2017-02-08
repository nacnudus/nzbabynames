library(tidyxl)
library(unpivotr)
library(tidyverse)
library(forcats)

download.file("https://smartstart.services.govt.nz/assets/files/Top-baby-names-1954-2016.xlsx",
              destfile = "nzbabynames.xlsx", mode = "wb")

sheets <- tidy_xlsx("nzbabynames.xlsx")

get_data <- function(.sheet) {
  .years <- # 5th row
    .sheet %>%
    filter(row == 5, is.na(character), !is.na(numeric)) %>%
    group_by(`row`, numeric) %>% # Eliminate a duplicate 1985 in the boys' sheet
    summarise(col = first(col)) %>%
    ungroup %>%
    select(row, col, year = numeric) %>%
    mutate(year = as.integer(year)) %>%
    split(.$col)
  .names <- # Columns of cells with text in them
    .sheet %>%
    filter(row >= 8, row <= 107, col >= 3, !is.na(character)) %>%
    select(row, col, name = character) %>%
    split(.$col)
  .counts <- # Columns of cells with numbers in them
    .sheet %>%
    filter(row >= 8, row <= 107, col >= 3, !is.na(numeric)) %>%
    select(row, col, n = numeric) %>%
    mutate(n = as.integer(n)) %>%
    split(.$col)
  # Treat as small multiples, and map over them
  .all <- list(.years, .names, .counts)
  pmap_df(.all,
          function(.year, .names, .counts) {
            .counts %>%
              E(.names) %>%
              ABOVE(.year)
          }) %>%
  select(-row, -col)
}

nzbabynames <-
  sheets$data %>%
  map_df(get_data, .id = "sex") %>%
  mutate(sex = fct_recode(sex,
                          F = "Girls' Names",
                          M = "Boys' Names"),
         sex = as.character(sex)) %>%
  select(year, sex, name, n)

write.csv(nzbabynames, row.names = FALSE, quote = FALSE,
          file=gzfile("./inst/extdata/babynames.csv.gz"))

use_data(nzbabynames, overwrite = TRUE)
