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
levelsof cd116, local(cd116levels)

foreach i of numlist `cd116levels' {
	use if cd116 == `i' using ${output}acs_tables.dta, clear

	mkmat empwhite1664 empwhite6599 empblack1664 empblack6599 empother1664 empother6599, matrix(raceage)
	* CD 4903 tables contain some BH6599; but ACS micro contain zero
	* adjustment: move table BH6599 pop to BH1664
	matrix rownames raceage = raceagegroup
	matrix colnames raceage = _one:11 _one:12 _one:21 _one:22 _one:31 _one:32
	if cd116 == 4903 {
		replace empblack1664 = empblack1664 + empblack6599
		replace empblack6599 = 0
		mkmat empwhite1664 empwhite6599 empblack1664 empother1664 empother6599, matrix(raceage)
		matrix rownames raceage = raceagegroup
		matrix colnames raceage = _one:11 _one:12 _one:21 _one:31 _one:32
	}
	mat li raceage
	mkmat emphispanic1664 emphispanic6599 empnonhispanic1664 empnonhispanic6599, matrix(hispage)
	matrix rownames hispage = hispagegroup
	matrix colnames hispage = _one:11 _one:12 _one:21 _one:22
	mat li hispage

	use if cd116 == `i' using `acsmicrodata', clear
	ipfraking [pw=perwt1], ctotal(raceage hispage) generate(perwt2)
	tempfile cd`i'
	save `cd`i''
}

local counter = 0
foreach i of numlist `cd116levels' {
	local counter = `counter' + 1
	if `i' == 1 use `cd`i'', clear
	append using `cd`i''
}
