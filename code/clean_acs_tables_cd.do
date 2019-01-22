import delim ${acsdata}ACS_17_5YR_B23001_sex_age_cd.csv, varnames(1) rowrange(3) clear
destring hd01*, replace
destring geoid2, replace
rename geoid2 cd115
rename hd01_vd07 male1619
rename hd01_vd14 male2021
rename hd01_vd21 male2224
rename hd01_vd28 male2529
rename hd01_vd35 male3034
rename hd01_vd42 male3544
rename hd01_vd49 male4554
rename hd01_vd56 male5559
rename hd01_vd63 male6061
rename hd01_vd70 male6264
rename hd01_vd76 male6569
rename hd01_vd82 male7074
rename hd01_vd88 male7599
rename hd01_vd96 female1619
rename hd01_vd103 female2021
rename hd01_vd110 female2224
rename hd01_vd117 female2529
rename hd01_vd124 female3034
rename hd01_vd131 female3544
rename hd01_vd138 female4554
rename hd01_vd145 female5559
rename hd01_vd152 female6061
rename hd01_vd159 female6264
rename hd01_vd165 female6569
rename hd01_vd171 female7074
rename hd01_vd177 female7599

gen emp1619 = male1619 + female1619
gen emp2024 = male2021 + male2224 + female2021 + female2224
gen emp2534 = male2529 + male3034 + female2529 + female3034
gen emp3544 = male3544 + female3544
gen emp4554 = male4554 + female4554
gen emp5564 = male5559 + male6061 + male6264 + female5559 + female6061 + female6264
gen emp6599 = male6569 + male7074 + male7599 + female6569 + female7074 + female7599
egen empmale = rowtotal(male*)
egen empfemale = rowtotal(female*)
gen emp = empmale + empfemale
gen empmale1664 = male1619 + male2021 + male2224 + male2529 + male3034 + male3544 + male4554 + male5559 + male6061 + male6264
gen empfemale1664 = female1619 + female2021 + female2224 + female2529 + female3034 + female3544 + female4554 + female5559 + female6061 + female6264
gen empmale6599 = empmale - empmale1664
gen empfemale6599 = empfemale - empfemale1664

keep cd115 emp*
tempfile age
save `age'

foreach race in hispanic white black {
	import delim ${acsdata}ACS_17_5YR_C23002_`race'_cd.csv, varnames(1) rowrange(3) clear
	destring hd01*, replace
	destring geoid2, replace
	rename geoid2 cd115
	rename hd01_vd07 emp`race'male1664
	rename hd01_vd13 emp`race'male6599
	rename hd01_vd21 emp`race'female1664
	rename hd01_vd27 emp`race'female6599
	gen emp`race'1664 = emp`race'male1664 + emp`race'female1664
	gen emp`race'6599 = emp`race'male6599 + emp`race'female6599

	keep cd115 emp*
	tempfile `race'
	save ``race''
}

import delim ${acsdata}ACS_17_5YR_B23006_educ_cd.csv, varnames(1) rowrange(3) clear
destring hd01*, replace
destring geoid2, replace
rename geoid2 cd115
rename hd01_vd06 emplths
rename hd01_vd13 emphs
rename hd01_vd20 empscol
rename hd01_vd27 empcol

keep cd115 emp*
tempfile educ
save `educ'

use `age', clear
foreach race in hispanic white black {
	merge 1:1 cd115 using ``race'', assert(3) nogenerate
}
merge 1:1 cd115 using `educ', assert(3) nogenerate

gen empothermale1664 = empmale1664 - (empwhitemale1664 + empblackmale1664)
gen empotherfemale1664 = empfemale1664 - (empwhitefemale1664 + empblackfemale1664)
gen empothermale6599 = empmale6599 - (empwhitemale6599 + empblackmale6599)
gen empotherfemale6599 = empfemale6599 - (empwhitefemale6599 + empblackfemale6599)
gen empother1664 = empothermale1664 + empotherfemale1664
gen empother6599 = empothermale6599 + empotherfemale6599

gen empnonhispanicmale1664 = empmale1664 - emphispanicmale1664
gen empnonhispanicfemale1664 = empfemale1664 - emphispanicfemale1664
gen empnonhispanicmale6599 = empmale6599 - emphispanicmale6599
gen empnonhispanicfemale6599 = empfemale6599 - emphispanicfemale6599
gen empnonhispanic1664 = empnonhispanicmale1664 + empnonhispanicfemale1664
gen empnonhispanic6599 = empnonhispanicmale6599 + empnonhispanicfemale6599

gen empedother = empmale + empfemale - (emplths + emphs + empscol + empcol)

* remove PR
drop if cd115 == 7298
