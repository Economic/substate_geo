all: deploydata

.PHONY: all deploydata

deploydata:
	~/StatTransfer14_64/st data/output/acs_cd116.dta sas8 acs_cd116.sas7bdat
	~/StatTransfer14_64/st data/output/acs_wages_imputed.dta sas8 acs_wages_imputed.sas7bdat
	pigz -Kk acs_cd116.sas7bdat
	pigz -Kk acs_wages_imputed.sas7bdat
	rsync -avh --chmod=0444 acs_cd116.sas7bdat.zip acs_wages_imputed.sas7bdat.zip /data/acs/
	rsync -avPzh acs_cd116.sas7bdat.zip acs_wages_imputed.sas7bdat.zip ~/mount/epiextracts/acs/
	rm acs_cd116.sas7bdat.zip acs_cd116.sas7bdat acs_wages_imputed.sas7bdat acs_wages_imputed.sas7bdat.zip

	pigz -Kk data/output/acs_cd116.dta
	pigz -Kk data/output/acs_wages_imputed.dta
	rsync -avh --chmod=0444 data/output/acs_wages_imputed.dta.zip data/output/acs_cd116.dta.zip /data/acs/
	rm data/output/acs_cd116.dta.zip 	rm data/output/acs_wages_imputed.dta.zip
