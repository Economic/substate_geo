gen adj_wkswork = .
replace adj_wkswork = 7 if wkswork2 == 1
replace adj_wkswork = 20 if wkswork2 == 2
replace adj_wkswork = 33 if wkswork2 == 3
replace adj_wkswork = 43.5 if wkswork2 == 4
replace adj_wkswork = 48.5 if wkswork2 == 5
replace adj_wkswork = 51 if wkswork2 == 6
