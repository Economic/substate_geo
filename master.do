********************************************************************************
* FILE: master.do
* DESC: create ACS microdata with hourly wages & substate geographic identifiers
*
* Run this file with the project root as your working directory.
********************************************************************************
set more off
clear all

global code code/
global acsdata data/input_acs/
global miscdata data/input_misc/
global output data/output/

* create hourly wage in ACS data
* requires: impute_weeksworked.do impute_wages_cpsreg.do impute_wages_cpsloc.do
* output: acs_wages_imputed.dta
*do ${code}create_acs_wages.do

* create ACS CD dataset
* requires: acs_wages_imputed.dta
* output: acs_tables.dta acs_cd116.dta
*do ${code}create_acs_cd.do

* analyze weights
* requires: acs_tables.dta acs_cd116.dta
* output:
*do ${code}analyze_weights.do
