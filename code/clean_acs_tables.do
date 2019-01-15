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

foreach sex in male female {
	egen `sex'total = rowtotal(`sex'*)
	gen `sex'6599 = `sex'6569 + `sex'7074 + `sex'7599
	gen `sex'1664 = `sex'total - `sex'6599
}
gen emp = maletotal + femaletotal
gen emp1664 = male1664 + female1664
gen emp6599 = male6599 + female6599
foreach sex in male female {
	gen emp`sex'1624 = `sex'1619 + `sex'2021 + `sex'2224
	gen emp`sex'2544 = `sex'2529 + `sex'3034 + `sex'3544
	gen emp`sex'4564 = `sex'4554 + `sex'5559 + `sex'6061 + `sex'6264
	gen emp`sex'6599 = `sex'6569 + `sex'7074 + `sex'7599
}

keep cd115 emp emp1664 emp6599 emp*1624 emp*2544 emp*4564 emp*6599
tempfile overall
save `overall'

foreach race in hispanic white black {
	import delim ${acsdata}ACS_17_5YR_C23002_`race'_cd.csv, varnames(1) rowrange(3) clear
	destring hd01*, replace
	destring geoid2, replace
	rename geoid2 cd115
	rename hd01_vd07 `race'male1664
	rename hd01_vd13 `race'male6599
	rename hd01_vd21 `race'female1664
	rename hd01_vd27 `race'female6599

	gen `race'maletotal = `race'male1664 + `race'male6599
	gen `race'femaletotal = `race'female1664 + `race'female6599
	gen emp`race' = `race'maletotal + `race'femaletotal
	gen emp`race'1664 = `race'male1664 + `race'female1664
	gen emp`race'6599 = `race'male6599 + `race'female6599

	keep cd115 emp`race' emp`race'1664 emp`race'6599
	tempfile `race'
	save ``race''
}

use `overall', clear
foreach race in hispanic white black {
	merge 1:1 cd115 using ``race'', assert(3) nogenerate
}
gen empother = emp - (empwhite + empblack)
gen empother1664 = emp1664 - (empwhite1664 + empblack1664)
gen empother6599 = emp6599 - (empwhite6599 + empblack6599)

gen empnonhispanic = emp - emphispanic
gen empnonhispanic1664 = emp1664 - emphispanic1664
gen empnonhispanic6599 = emp6599 - emphispanic6599

* remove PR
drop if cd115 == 7298
