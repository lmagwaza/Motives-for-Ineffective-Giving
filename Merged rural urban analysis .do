// T-tests and Regressions, Thesis// 

* Luvuyo, Nov 2

clear 

set more off 

global output "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/ Merged rural and urban analysis"
global path "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group"

* Load in data set
import delimited "$path/clean_merged_rural_urban_dataset.csv" , clear 



* Summary stats for both groups 
tab income_hh  urban  


tabstat age sex education , by(urban) stat(mean sd min max) nototal  listwise col(stat)
eststo demographics : qui estpost tabstat age sex education , by(urban) stat(mean sd min max) nototal listwise col(stat) 
esttab demographics using "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group/demographics table.tex", replace ///
 cells("mean sd min max")  nomtitle nonumber noobs 
 
 
* T-tests 
	* Summary stats 
est clear
global summary_stats age sex 	

estpost ttest $summary_stats, by (urban) 
esttab, wide
	
esttab using "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group/sum_stats ttest table.tex", replace ///
  cells("mu_1(fmt(1)) mu_2  b(star) se(par)") ///
  collabels("Rural" "Urban" "Diff. (Rural - Urban)" "s.e.") ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  label booktabs nonum gaps noobs compress
  
	* Giving tasks 

foreach giving_task  in community country ideology religion generation species cause_affliction cause_passion {
	estpost ttest `giving_task', by (urban)  
	
}

est clear
global g_tasks community country ideology religion generation species cause_affliction cause_passion
estpost ttest $g_tasks, by (urban) 
esttab, wide

esttab using "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group/ttest table.tex", replace ///
  cells("mu_1(fmt(1)) mu_2  b(star) se(par)") ///
  collabels("Rural" "Urban" "Diff. (Rural - Urban)" "s.e.") ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  label booktabs nonum gaps noobs compress
/*
The ttest subtracts the mean of the urban group from that of the rural group (mean(0) - mean(1)).

community: t = -3.9980, p = 0.0001; rural group gives less to effective charity B than urban if 
ingroup is based on community. 

country: t = 3.8097, p = 0.0002; urban group gives less than rural to effective charity B if ingroup 
is based on country. 

ideology: t = -4.2148, p = 0.0000; rural group gives less to effective charity B than urban if 
ingroup is based on ideology. 

religion: t = -4.1199, p = 0.0000; rural group gives less to effective charity B than urban if 
ingroup is based on religion. 

generation: t = 2.7102, p = 0.0069; urban group gives less than rural to effective charity B if ingroup 
is based on generation. 

species: t = 5.1627, p = 0.0000; urban group gives less than rural to effective charity B if ingroup 
is based on generation. 

cause_affliction: t = -1.9501, p = 0.0516; rural group gives less to effective charity B than urban if 
ingroup is based on cause_affliction. 

cause_passion: t = -1.6160, p = 0.1066; rural group gives less to effective charity B than urban if 
ingroup is based on cause_passion. However, the difference is statistically insignificant

*/


* Regressions

global controls urban sex age  
est clear
reg country $controls , vce (cluster urban)
foreach giving_task  in community country ideology religion generation species cause_affliction cause_passion{
	eststo:reg `giving_task' $controls, vce(urban) 
}



esttab using "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group/regression table.tex", replace   ///
 b(3) se(3) ///
 keep($controls) ///
 mgroups("Community" "Country" "Ideology" "Religion" "Generation" "Species" "Cause Affliction" "Cause Passion") ///
 star(* 0.10 ** 0.05 *** 0.01) ///
 label booktabs nomtitle noobs collabels() compress alignment(D{.}{.}{-1}) 

/*
community: there are no significant variables. However, the coefficient for urban is economically large, 
urban group gives 6.11pp more to effective charity compared to rural group. 

country: coefficient on urban is significant at the 5% level. Urban group gives 9.46pp less than the 
rural group when country characteristic is made salient. 

ideology: coefficient on urban is significant at the 1% level. Urban group gives 11.05pp more to effective
charity compared to the rural group. 

religion: coefficients on urban and sex are significant at the 5% level. Urban group gives 6.81pp more to 
effective charity and men give 4.49pp more to effective charity compared to women. 

generation: none of the coefficients are statistically significant. However urban coefficient shows that urban
group gives 4.61pp less than rural group. 

species: education coefficient is significant at the 10% level showing that people who have at least a 
bachelors degree give 6.05pp less to the effective charity than those with less education. 

cause_affliction: no statistically significant coefficients. 

cause_passion: no statistically significant coefficients.

*/



* T-test for personal donation choice 
est clear
estpost ttest personal_generosity, by(urban) 
esttab, wide

esttab using "/Users/lmagwaza/Google Drive/USF Semesters /Semesters/2022 Fall/Urban Group/ttest personal donation.tex", replace ///
  cells("mu_1(fmt(1)) mu_2  b(star) se(par)") ///
  collabels("Rural" "Urban" "Diff. (Rural - Urban)" "s.e.") ///
  star(* 0.10 ** 0.05 *** 0.01) ///
  label booktabs nonum gaps noobs compress




* Cheking if my R CI's are correct
foreach giving_task  in community country ideology religion generation species cause_affliction cause_passion {
	 ci means `giving_task' if urban == 1
	
}

ttest age, by(urban)



