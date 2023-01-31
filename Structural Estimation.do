// Structural Estimation // 

* Luvuyo, Nov 2

clear 

set more off 

global output "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/ Merged rural and urban analysis"
global path "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group"

* Load in data set
import delimited "$path/clean_merged_rural_urban_dataset.csv" , clear 


* Preparing the data for the structural estimation 
gen sid = 1000 + [_n] // generating an id for each subject 
expand 2 // changing the shape of the data, duplicated the data so we could use fixed effects 
sort sid

	* making matches line up for each child 
gen child = 0 
replace child = 1 if sid[_n+1]!=sid[_n]
label define child 0 "Anika" 1 "William"

gen sex_match = 0
replace sex_match = 1 if sex == 1 & child ==1
replace sex_match = 1 if sex == 0 & child ==0

gen country_match = 0
replace country_match = 1 if wcountry_match == 1 & child == 1
replace country_match = 1 if acountry_match == 1 & child ==0

gen religion_match = 0
replace religion_match = 1 if wreligion_match == 1 & child == 1
replace religion_match = 1 if areligion_match == 1 & child == 0

gen family_match = 0
replace family_match = 1 if wfamily_match == 1 & child == 1 
replace family_match = 1 if afamily_match == 1 & child == 0

gen hobby_match = 0
replace hobby_match = 1 if whobby_match == 1 & child == 1
replace hobby_match = 1 if ahobby_match == 1 & child == 0

gen affliction_match = 0
replace affliction_match = 1 if waffliction_match == 1 & child == 1
replace affliction_match = 1 if aaffliction_match == 1 & child == 0 

gen perct_hh_inc = 0
replace perct_hh_inc = william_y_perct if child == 1 
replace perct_hh_inc = anika_y_perct if child == 0

gen xfold = 0
replace xfold = william_xfold if child == 1 
replace xfold = anika_xfold if child == 0 

gen transfer = 0 
replace transfer = william if child == 1
replace transfer = anika if child == 0 

gen ln_transfer = ln(transfer)
replace ln_transfer = 0 if ln_transfer == .

	* creating income levels for each subject
gen subject_hh_inc = 0 

replace subject_hh_inc = 4900 if income_hh == "Less than R4,900"

replace subject_hh_inc = (5000 + 9999)/2  if income_hh ==  "R5,000 to R9,999"

replace subject_hh_inc = (10000 + 19999)/2 if income_hh == "R10,000 to R19,999"

replace subject_hh_inc = (20000 + 39999)/2 if income_hh == "R20,000 to R39,999"

replace subject_hh_inc = (40000 + 74999)/2 if income_hh == "R40,000 to R74,999"

replace subject_hh_inc = (75000 + 149999)/2 if income_hh == "R75,000 to R149,999"

replace subject_hh_inc = (150000 + 299999)/2 if income_hh == "R150,000 to R299,999"

replace subject_hh_inc = (300000 + 499999)/2 if income_hh == "R300,000 to R499,999"

replace subject_hh_inc = (500000 + 799999)/2 if income_hh == "R500,000 to R799,999"

replace subject_hh_inc = (800000 + 999999)/2 if income_hh == "R800,000 to R999,999" 

replace subject_hh_inc = 1000000 if income_hh == "R1,000,000 or more"

	* creating household income level for Anika and William 
gen a_hhinc = (607725.3) * (anika_y_perct/100)
gen w_hhinc = (607725.3) * (william_y_perct/100)

gen child_hh_inc = 0 
replace child_hh_inc = w_hhinc if child == 1
replace child_hh_inc = a_hhinc if child == 0


* Running the regressions 
xtset sid child

	* fixed effects regression
est clear
xtreg transfer sex_match hobby_match country_match family_match religion_match affliction_match perct_hh_inc xfold , fe i(sid) cluster(sid)
eststo: xtreg transfer sex_match hobby_match country_match family_match religion_match affliction_match perct_hh_inc xfold if urban == 0, fe i(sid) cluster(sid)
eststo: xtreg transfer sex_match hobby_match country_match family_match religion_match affliction_match perct_hh_inc xfold if urban == 1, fe i(sid) cluster(sid)
eststo: xtreg transfer sex_match hobby_match country_match family_match religion_match affliction_match perct_hh_inc xfold , fe i(sid) cluster(sid)

	* tobit regression
xttobit transfer sex_match hobby_match country_match family_match religion_match affliction_match xfold perct_hh_inc, ll(0) ul(1612) 

tobit transfer sex_match hobby_match country_match family_match religion_match affliction_match xfold perct_hh_inc , ll(0) ul(1612) vce(cluster sid) 

eststo: xttobit transfer sex_match hobby_match country_match family_match religion_match affliction_match perct_hh_inc xfold if urban == 0, ll(0) ul(1612)
eststo: xttobit transfer sex_match hobby_match country_match family_match religion_match affliction_match perct_hh_inc xfold if urban == 1, ll(0) ul(1612)
eststo: xttobit transfer sex_match hobby_match country_match family_match religion_match affliction_match perct_hh_inc xfold, ll(0) ul(1612)

eststo:tobit transfer sex_match hobby_match country_match family_match religion_match affliction_match xfold perct_hh_inc if urban == 0, ll(0) ul(1612) vce(cluster sid)
eststo:tobit transfer sex_match hobby_match country_match family_match religion_match affliction_match xfold perct_hh_inc if urban == 1, ll(0) ul(1612) vce(cluster sid)
eststo:tobit transfer sex_match hobby_match country_match family_match religion_match affliction_match xfold perct_hh_inc, ll(0) ul(1612) vce(cluster sid)

* creating latex table that compares rural and urban 
esttab using "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group/multiple regression anika william.tex", replace ///
b(2) se (3) ///
booktabs label            ///
mgroups(A B C, pattern(1 0 1 0 1 0)                   ///
prefix(\multicolumn{@span}{c}{) suffix(})   ///
span erepeat(\cmidrule(lr){@span}))         ///
alignment(D{.}{.}{-1}) page(dcolumn) nonumber

* creating latex table that compares the whole sample 
esttab using "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group/regression anika william.tex", replace   ///
 b(2) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label booktabs nomtitle noobs collabels(none) compress alignment(D{.}{.}{-1})

*Nonlinear estimation

nl (transfer = {b_0} + {beta_perct_hh_inc}*perct_hh_inc + {beta_country}*country_match + {beta_religion}*religion_match + {beta_family}*family_match + {beta_hobby}*hobby_match + {beta_affliction}*affliction_match + {beta_perct_hh_inc}*perct_hh_inc *xfold*(subject_hh_inc) - (child_hh_inc) / (xfold*(1 + {b_0}+ {beta_perct_hh_inc}*perct_hh_inc + {beta_country}*country_match + {beta_religion}*religion_match + {beta_family}*family_match + {beta_hobby}*hobby_match + {beta_affliction}*affliction_match + {beta_perct_hh_inc}*perct_hh_inc))), vce(cluster sid) // I think I just figured it out !!!!!!


	* nl for rural group
eststo: nl (transfer = {b_0} + {beta_perct_hh_inc}*perct_hh_inc + {beta_country}*country_match + {beta_religion}*religion_match + {beta_family}*family_match + {beta_hobby}*hobby_match + {beta_affliction}*affliction_match + {beta_perct_hh_inc}*perct_hh_inc *xfold*(subject_hh_inc) - (child_hh_inc) / (xfold*(1 + {b_0}+ {beta_perct_hh_inc}*perct_hh_inc + {beta_country}*country_match + {beta_religion}*religion_match + {beta_family}*family_match + {beta_hobby}*hobby_match + {beta_affliction}*affliction_match + {beta_perct_hh_inc}*perct_hh_inc ))) if urban == 0, vce(cluster sid) // 



	* nl for urban group 
eststo: nl (transfer = {b_0} + {beta_perct_hh_inc}*perct_hh_inc + {beta_country}*country_match + {beta_religion}*religion_match + {beta_family}*family_match + {beta_hobby}*hobby_match + {beta_affliction}*affliction_match + {beta_perct_hh_inc}*perct_hh_inc *xfold*(subject_hh_inc) - (child_hh_inc) / (xfold*(1 + {b_0} + {beta_perct_hh_inc}*perct_hh_inc + {beta_country}*country_match + {beta_religion}*religion_match + {beta_family}*family_match + {beta_hobby}*hobby_match + {beta_affliction}*affliction_match + {beta_perct_hh_inc}*perct_hh_inc ))) if urban == 1, vce(cluster sid) // if I log the incomes,  it makes sense. 
	
	* nl for everyone
eststo: nl (transfer = {b_0} + {beta_perct_hh_inc}*perct_hh_inc + {beta_country}*country_match + {beta_religion}*religion_match + {beta_family}*family_match + {beta_hobby}*hobby_match + {beta_affliction}*affliction_match + {beta_perct_hh_inc}*perct_hh_inc *xfold*(subject_hh_inc) - (child_hh_inc) / (xfold*(1 + {b_0} + {beta_perct_hh_inc}*perct_hh_inc + {beta_country}*country_match + {beta_religion}*religion_match + {beta_family}*family_match + {beta_hobby}*hobby_match + {beta_affliction}*affliction_match + {beta_perct_hh_inc}*perct_hh_inc ))), vce(cluster sid)


est clear
esttab using "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group/structural estimation anika william.tex", replace   ///
 b(2) se(3) ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label booktabs nomtitle noobs collabels(none) compress alignment(D{.}{.}{-1})
 

tab income_hh if urban == 1
 
 
