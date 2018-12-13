*clean up acs tables
*B23001 tables by sex and age
*read in metatdata to get the description of each table row
import delim ${acs_tables}ACS_16_5YR_B23001_metadata.csv, clear
*remove secondary header rows
drop in 1/3
gen table_id = lower(v1)
drop v1
rename v2 description
*remove MOE observations
keep if regexm(description,"Estimate")
tempfile B23001_labels
save `B23001_labels'

*read in sex and age data
foreach place in "cd" "county"{
  import delim ${acs_tables}ACS_16_5YR_B23001_sex_age_`place'.csv, varnames(1) clear
  *remove secondary hearder row
  drop in 1
  *reshape to long
  reshape long hd, i(geoid geoid2) j(table_id) string
  rename geoid2 countyfips
  rename geodisplaylabel countyname
  split table_id, p(_)
  *drop margin of error
  drop if table_id1 == "02"
  rename hd value
  *add "hd" back in to ids so the merge with descriptions works
  replace table_id = "hd"+table_id
  li in 1/5
  drop table_id1 table_id2
  destring value, replace
  merge m:1 table_id using `B23001_labels'
  *Keep estimates for totals and employed by sex
  keep if regexm(description,"Estimate")
  keep if regexm(description,"(Total|Employed|Male:$|Female:$|years:$)")
  drop _merge
  *create variables for age and sex
  gen sex = ""
  replace sex = "Female" if regexm(description, "Female")
  replace sex = "Male" if regexm(description, "Male")
  replace sex = "All" if regexm(description, "Total")
  gen age_group = ""
  replace age_group = "16-19" if regexm(description, "16 to 19 years")
  replace age_group = "20-21" if regexm(description, "20 and 21 years")
  replace age_group = "22-24" if regexm(description, "22 to 24 years")
  replace age_group = "25-29" if regexm(description, "25 to 29 years")
  replace age_group = "30-34" if regexm(description, "30 to 34 years")
  replace age_group = "35-44" if regexm(description, "35 to 44 years")
  replace age_group = "45-54" if regexm(description, "45 to 54 years")
  replace age_group = "55-59" if regexm(description, "55 to 59 years")
  replace age_group = "60-61" if regexm(description, "60 and 61 years")
  replace age_group = "62-64" if regexm(description, "62 to 64 years")
  replace age_group = "65-69" if regexm(description, "65 to 69 years")
  replace age_group = "70-74" if regexm(description, "70 to 74 years")
  replace age_group = "75+" if regexm(description, "75 years and over")
  replace age_group = "All" if regexm(description,"(Total|Male:$|Female:$)")
  gen employed = ""
  replace employed = "Employed" if regexm(description,"Employed")
  tempfile B23001_`place'
  save `B23001_`place''
}

*C23002 ACS tables by race
import delim ${acs_tables}ACS_16_5YR_C23002_metadata.csv, clear
drop in 1/3
gen table_id = lower(v1)
drop v1
rename v2 description
keep if regexm(description,"Estimate")
tempfile C23002_labels
save `C23002_labels'

*read in all tables by race and place
foreach race in "white" "black" "asian" "hispanic" {
  foreach place in "cd" "county"{
    import delim ${acs_tables}ACS_16_5YR_C23002_`race'_`place'.csv, varnames(1) clear
    drop in 1
    reshape long hd, i(geoid geoid2) j(table_id) string
    rename geoid2 countyfips
    rename geodisplaylabel countyname
    split table_id, p(_)
    *drop margin of error
    drop if table_id1 == "02"
    rename hd value
    replace table_id = "hd"+table_id
    li in 1/5
    drop table_id1 table_id2
    destring value, replace
    merge m:1 table_id using `C23002_labels'
    keep if regexm(description,"Estimate")
    keep if regexm(description,"(Total|Employed|Male:$|Female:$)")
    *remove MOE observations
    drop _merge
    gen sex = ""
    replace sex = "Female" if regexm(description, "Female")
    replace sex = "Male" if regexm(description, "Male")
    replace sex = "All" if regexm(description, "Total")
    gen age_group = ""
    replace age_group = "16-64" if regexm(description, "16 to 64 years")
    replace age_group = "65+" if regexm(description, "65 years and over:")
    gen employed = ""
    replace employed = "Employed" if regexm(description, "Employed")
    gen wbha = "`race'"
    tempfile C23002_`race'_`place'
    save `C23002_`race'_`place''
  }
}

*export reshaped tables to csv
use `B23001_county', clear
export delim ${output}sex_age_county.csv

use `B23001_cd', clear
export delim ${output}sex_age_cd.csv

use `C23002_white_county', clear
append using `C23002_black_county'
append using `C23002_asian_county'
append using `C23002_hispanic_county'
export delim ${output}race_county.csv, replace

use `C23002_white_cd', clear
append using `C23002_black_cd'
append using `C23002_asian_cd'
append using `C23002_hispanic_cd'
export delim ${output}race_cd.csv, replace
