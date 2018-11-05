/* substate geography master do file.
FILE: master.do
DESC: this file and the do files called on below are set up to examine
data at substate geographic levels using the ACS PUMS. Specifically, we
want to look at PUMAs, CDs, and Counties.

This file will be designed to be run from the project root containing this do-file in the future.
For now, since the data is stored in Zane's project folder on maynard, us the ${base}
global macro to point to the correct Directory
*/
set more off
clear all
*Directory Structure
global base /home/zmokhiber/projects/substate_geo/
global code ${base}code/
global data ${base}data/
global acs_extracts ${data}acs_extracts/
