# Downloaded from Statistics New Zealand Infoshare
# Group: Births - VSB
# Table: Live births, New Zealand residents, overseas visitors and total registrations (Annual-Dec)
# Total
# Table reference VSB040AA

nzbirths <- readr::read_csv(system.file("extdata/births.csv", package = "nzbabynames"))

use_data(nzbirths, overwrite = TRUE)
