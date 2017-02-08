# Downloaded from Statistics New Zealand Infoshare
nzbirths <- read.csv(system.file("extdata/births.csv", package = "nzbabynames"))

use_data(nzbirths, overwrite = TRUE)

