# Substate geographic ACS data
This code create CD-level and county-level ACS data, useful for analyzing wage distributions at those geographic levels.

Stata and SAS versions of the data are available on

* maynard: `/data/acs/acs_cd116.dta.zip`
* epi06: `\fdata0\epiextracts\acs\acs_cd116.sas7bdat.zip`

## Sample weight calibration
When analyzing these data, it is important that you use the appropriate sample weight described below, probably perwt2. The weights are created in three stages:

1. perwt0: the original person-level sample weight on file, divided by 5 to reflect 5 years of data
2. perwt1: a scaled version of perwt0, scaled proportionally to the Census 2010 population allocation factor of PUMAs to CDs or counties
3. perwt2: a calibrated version of perwt1, adjusted using iterative proportional fitting (raking) to match certain CD or county race, ethnicity, and age-specific employment counts from ACS 5-year tables.

Using perwt0 on the CD-level or county-level datasets will duplicate observations and is probably inappropriate for most analyses.

## Hourly wages
The data contain multiple hourly wage variables. The "best", hrwage2, is created in three stages:

1. hrwage0: annual income divided by the product of (imputed) weeks worked and usual hours worked per week
2. hrwage1: the average of hrwage0 and a predicted hourly wage variable based on an OLS log(wage) prediction using CPS-ORG data.
3. hrwage2: a state-specific distribution location adjustment of hrwage1 to match CPS-ORG derived state hourly wage distributions
