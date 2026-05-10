****************************************
*      EXAM BLANC ECONOMETRICS         *
****************************************
*1. Yes, doing a simple regression could cause biased estimates. This is because the villages were not chosen randomly, they were selected based on a score, which depends on things like how many school-age children (especially girls) they had.
*So treated villages may already be different from untreated ones, even before the program. If we don't account for this, we mix up the effect of the program with pre-existing differences. 

*2. A better approach is to use a regression discontinuity design using the cutoff at rel_score = 0. If the RDD assumption is verified (continuity assumption), the variation in the treatment near the threshold is as good as if it wad randomized. 
*We estimate: 
*attending = B0 + B1(rel_score)_i + f(rel_score)_i + epsilon_i

*3. assumptions: continuity assumption (indiv are unable to precisely manipulate the level of the variable) --> tests 
*2 tests:
*continuity of distribution of X at the threshold
*coninuity of distribution of baseline covariates at the threshold. 
*an important element is also to check whether the eligible villages received the treatment. 

cd "C:\Users\leaaa\OneDrive\Documents\MAGISTERE\MAGEVAL 2\ECONOMETRICS CAUSALITY\TD ECONOMETRICS CAUSALITY"
use "Exam2_data.dta", clear



* Tester la continuité des covariables autour du seuil
* Définir les variables clés pour lesquelles nous voulons tester la continuité
local keyvars Ch_Age Ch_Girl Hh_HeadAge Hh_HeadSchool Hh_NumKids Hh_Animist Hh_Bike Hh_Cart Hh_Motorbike Hh_Radio

* Tester la continuité pour chaque variable autour du seuil (rel_score = 0)
foreach var of local keyvars {
    rdplot `var' rel_score, c(0) p(1) graph_options(title("Continuity of `var' around the threshold"))
    pause
}

pause off


rdplot Ch_Age rel_score, c(0) p(1)


* Régression de base (RDD) avec variables pertinentes
reg attending rel_score, robust

esttab using "resultats.csv", replace se
outreg2 using "regression_results.doc", append

* Graphique de régression localisée (RD plot) pour voir l'effet sur l'assiduité scolaire
rdplot attending rel_score, c(0) p(1) graph_options(title("Effect of New Schools on Attendance"))

graph export "graphique regression.png", width(1000) replace

*4
reg total_norm rel_score, robust
rdplot total_norm rel_score, c(0) p(1) graph_options(title("Effect of New Schools on Knowledge Test Score"))

* Run the regression with the interaction term
reg total_norm rel_score Ch_Girl c.rel_score#c.Ch_Girl, robust

* Display results for interpretation









