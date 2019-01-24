all: deploydata

.PHONY: all deploydata

deploydata:
	# convert data to SAS and transfer
	gunzip -k data/input_acs/usa_00035.dta.gz
	~/StatTransfer14_64/st data/input_acs/usa_00035.dta sas8 usa_00035.sas7bdat
	rm data/input_acs/usa_00035.dta
	~/StatTransfer14_64/st data/output/acs_cd116.dta sas8 acs_cd116.sas7bdat
	~/StatTransfer14_64/st data/output/acs_state.dta sas8 acs_state.sas7bdat
	pigz -K usa_00035.sas7bdat
	pigz -K acs_cd116.sas7bdat
	pigz -K acs_state.sas7bdat
	rsync -avh --chmod=0444 usa_00035.sas7bdat.zip acs_cd116.sas7bdat.zip acs_state.sas7bdat.zip /data/acs/
	rsync -avPh usa_00035.sas7bdat.zip acs_cd116.sas7bdat.zip acs_state.sas7bdat.zip ~/mount/epiextracts/acs/
	rm usa_00035.sas7bdat.zip acs_cd116.sas7bdat.zip acs_state.sas7bdat.zip

	# transfer Stata
	pigz -Kk data/output/acs_cd116.dta
	pigz -Kk data/output/acs_state.dta
	rsync -avh --chmod=0444 data/output/acs_state.dta.zip data/output/acs_cd116.dta.zip /data/acs/
	rm data/output/acs_cd116.dta.zip data/output/acs_state.dta.zip

	# transfer extra
	~/StatTransfer14_64/st data/output/acs_numkids.dta sas8 acs_numkids.sas7bdat
	pigz -K acs_numkids.sas7bdat
	rsync -avPh acs_numkids.sas7bdat.zip ~/mount/epiextracts/acs/
	rm acs_numkids.sas7bdat.zip
