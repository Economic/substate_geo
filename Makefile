all: deploydata

.PHONY: all deploydata

deploydata:
	~/StatTransfer14_64/st data/output/acs_cd116.dta sas8 acs_cd116.sas7bdat
	~/StatTransfer14_64/st data/output/acs_state.dta sas8 acs_state.sas7bdat
	pigz -K acs_cd116.sas7bdat
	pigz -K acs_state.sas7bdat
	rsync -avh --chmod=0444 acs_cd116.sas7bdat.zip acs_state.sas7bdat.zip /data/acs/
	rsync -avPh acs_cd116.sas7bdat.zip acs_state.sas7bdat.zip ~/mount/epiextracts/acs/
	rm acs_cd116.sas7bdat.zip acs_state.sas7bdat.zip

	pigz -Kk data/output/acs_cd116.dta
	pigz -Kk data/output/acs_state.dta
	rsync -avh --chmod=0444 data/output/acs_state.dta.zip data/output/acs_cd116.dta.zip /data/acs/
	rm data/output/acs_cd116.dta.zip data/output/acs_state.dta.zip
