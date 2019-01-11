all: deploydata

.PHONY: all deploydata

deploydata:
	zip -j acs_cd116.dta.zip data/output/acs_cd116.dta
	rsync -avh --chmod=0444 acs_cd116.dta.zip /data/acs/
	rm acs_cd116.dta.zip
	/home/bzipperer/StatTransfer14_64/./st data/output/acs_cd116.dta acs_cd116.sas7bdat -sas
	zip acs_cd116.sas7bdat.zip acs_cd116.sas7bdat
	rm acs_cd116.sas7bdat
	rsync -avPzh acs_cd116.sas7bdat.zip /home/bzipperer/mount/epiextracts/acs/
	rm acs_cd116.sas7bdat.zip
