*EXAM ECONOMETRICS CAUSALITY
*LEA HOLDER MAGEVAL 2


cd "C:\Users\leaaa\OneDrive\Documents\MAGISTERE\MAGEVAL 2\ECONOMETRICS CAUSALITY\EXAM"

use "Exam_CC_2025_data.dta", clear

*1
*a. Yes, doing a simple regression would lead to biased estimates. Indeed, since treatment is not allocated randomly. Treated villages were selected based on criterias (>30% households classified as poor). So treated villages may already be different from untreated ones, even before the program. If we don't account for this, we might mix up the effect of the program with pre-existing differences. 

*b. To avoid such bias, we could use a regression discontinuty design, using the cutoff pov_municip_04 = 0. If the RDD assumption is verified (continuity assumption), the variation in the treatment near the threshold is as good as if it wad randomized. 
*We estimate: 
*drop_out = B0 + B1(CCT_municip)_i + B2(pov_municip_04)_i + f(pov_municip_04) epsilon_i
*with f() being a polynomial that captures an eventual non-linear relationship. 

*c
*For the RDD to be valid, the continuity assumption must be verified. This means that the indidivuals can not manipulate the score (level of poverty). We can test it whether by: 
*Checking the continuity of distribution of baseline covariates at the threshold. 
*checking the continuity of the distribution of the score X at the threshold. 
*an important element is also to check whether the eligible villages received the treatment. 



rdplot boy pov_municip_04, c(0) p(1) graph_options(title(distribution of characteristics (gender) around the threshold))

graph export "graph testing assumption1.png", width(1000) replace

rdplot class_size pov_municip_04, c(0) p(1) graph_options(title(distribution of characteristics (class size) around the threshold))

graph export "graph testing assumption2.png", width(1000) replace

rdplot electricite_04 pov_municip_04, c(0) p(1) graph_options(title(distribution of characteristics (electricity) around the threshold))

graph export "graph testing assumption3.png", width(1000) replace

*2.
*a.
gen eligibility = pov_municip_04 > 0
*We estimate the ITT
sum CCT_municip eligibility

tab  eligibility CCT_municip, row


rdplot eligibility CCT_municip,c(0) p(1)	

