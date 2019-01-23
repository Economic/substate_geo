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

********************************************************************************
* create hourly wage in ACS data
* requires data: usa_XXXXX.dta.gz
* requires code: impute_weeksworked.do
* output data: acs_prep.dta
********************************************************************************
*do ${code}create_acs_prep.do

********************************************************************************
* create ACS state dataset
* requires data: acs_prep.dta
* requires code: impute_wages_cpsreg.do impute_wages_cpsloc.do
* output: acs_tables_state.dta acs_state.dta
*********************************************************************************
do ${code}create_acs_state.do

********************************************************************************
* create ACS CD dataset
* requires data: acs_prep.dta
* requires code: impute_wages_cpsreg.do impute_wages_cpsloc.do
* output: acs_tables_cd.dta acs_cd116.dta
********************************************************************************
*do ${code}create_acs_cd.do


* analyze weights
* requires: acs_tables.dta acs_cd116.dta
* output:
*do ${code}analyze_weights.do
*do ${code}analyze_wages.do
