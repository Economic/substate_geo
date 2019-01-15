all: deploydata

.PHONY: all deploydata

deploydata:
	pigz -Kk data/output/acs_cd116.dta
	rsync -avh --chmod=0444 data/output/acs_cd116.dta.zip /data/acs/
	rm data/output/acs_cd116.dta.zip
	~/StatTransfer14_64/st data/output/acs_cd116.dta sas8 acs_cd116.sas7bdat
	pigz -Kk acs_cd116.sas7bdat
	rm acs_cd116.sas7bdat
	rsync -avPzh acs_cd116.sas7bdat.zip /home/bzipperer/mount/epiextracts/acs/
	rm acs_cd116.sas7bdat.zip
