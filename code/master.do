/* substate geography master do file.
FILE: master.do
DESC: this file and the do files called on below are set up to examine
data at substate geographic levels using the ACS PUMS. Specifically, we
want to look at PUMAs, CDs, and Counties.

This file is designed to be run from the project root containing this do-file.
*/

*Directory Structure

global code code/
global data data/
global acs_extracts ${data}acs_extracts/
