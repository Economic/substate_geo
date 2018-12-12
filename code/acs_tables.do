*clean up acs tables
*B23001 tables by sex and age

*read in metatdata
import delim ${acs_tables}ACS_16_5YR_B23001_metadata.csv, clear
drop in 1/3
gen table_id = lower(v1)
drop v1
rename v2 description
tempfile B23001_labels
save `B23001_labels'

*read in sex and age data
foreach place in "cd" "county"{
  import delim ${acs_tables}ACS_16_5YR_B23001_sex_age_`place'.csv, varnames(1) clear
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
  merge m:1 table_id using `B23001_labels'
  *remove MOE ids from metadata
  drop if _merge == 2
  drop _merge
  tempfile B23001_`place'
  save `B23001_`place''
}
*C23002 ACS tables by race
import delim ${acs_tables}ACS_16_5YR_C23002_metadata.csv, clear
drop in 1/3
gen table_id = lower(v1)
drop v1
rename v2 description
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
    *remove MOE ids from metadata
    drop if _merge == 2
    drop _merge
    tempfile C23002_`race'_`place'
    save `C23002_`race'_`place''
  }
}

li in 1/6
