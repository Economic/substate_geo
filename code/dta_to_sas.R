# convert sas to dta
args = commandArgs(trailingOnly=TRUE)
library(haven)
write_sas(read_dta(args[1]),args[2])
