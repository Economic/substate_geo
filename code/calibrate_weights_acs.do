* 0th stage adjustment:
* scale to single year (divide by 5 years)
gen perwt0 = perwt / 5

* 1st stage adjustment:
* proportion according to population allocation factor
gen perwt1 = perwt0 * afact

* 2nd stage adjustment
* rake to match ACS tables
* things to match: race X age group X gender

* prep for ipfraking
* variable to total for ipfraking
gen byte _one = 1

tempfile acsmicrodata
save `acsmicrodata'



use ${output}acs_tables.dta, clear


stop 




* create in-sample diagnostics


* create out-of-sample diagnostics
