*clean up acs tables





/* just do manuall downloading
*eventually try to do download acs data using API
*sex by age group
!curl -o ${data}sex_age.json "https://api.census.gov/data/2016/acs/acs5?get=NAME,group(B23001)&for=county:*"
tempfile f0 f1 f2 f3
copy ${data}sex_age.json `f0'
hexdump `f0', analyze
filefilter `f0' `f1', replace from(",\n") to("\n")
filefilter `f1' `f2', replace from("[") to("")
filefilter `f2' `f3', replace from("]") to("")
import delimited `f3', clear
drop *m *ea *ma v*
d
local N = _N
drop in 2/`N'
di
*variable names
drop state county
reshape long b, i(name) j(var) string
tostring b, replace
replace b = ""
reshape wide
drop name
d
rename b23001_001e B23001_001E

!curl -o ${data}b23001_metadata.json "https://api.census.gov/data/2016/acs/acs5/groups/B23001.json"
clear

insheetjson variable using ${data}b23001_metadata.json, showresponse

li name state b23001_008e b23001_167 county in 1/4
