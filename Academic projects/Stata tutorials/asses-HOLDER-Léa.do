
*****************************************************
* FINAL ASSESSMENT ECONOMETRIC SOFTWARES LEA HOLDER *
*****************************************************

*1
capture log close
log using asses-HOLDER-lea.log, replace

*2
clear all

*3
cd "C:\Users\leaaa\OneDrive\Documents\MAGISTERE\MAGEVAL 2\STATA\FINAL EXAM"

*********************************************************************
*                      DATA PREPARATION                             *
*********************************************************************

*4)
*a)
use "DATA1_.dta", clear

*b)
browse
* All the variables are numeric (year, x1-X9, dry, prcp, dd89 are float; fland and corn_planted are long; fips is double), except one string variable (corn_prod)

*c)
label variable fips "US county"
label variable dd89 "Degree days between 46.4F and 89.6F"
label variable prcp "Total precipitation"
label variable dry "Irrigation dummy"
label variable corn_prod "Corn Production"
label variable corn_planted "Corn acres planted"
label variable year "Year"
label variable fland "Farmland area"

*d)
count
*There is 9,074 observations.

*e)
describe 
*There is 17 variables. It is a panel data, as it includes multiple observations of counties over different years.

*f)
misstable summarize
*There is 2,193 missing values.

*g)
codebook
*All the missing values are in the variable corn_planted (2,193/9,074). The other variables don't have any missing values.

*h)
duplicates report
duplicates list
duplicates drop 
*This deletes 26 observations. 

*i)
drop if missing(corn_prod)
drop if missing(corn_planted)
drop if missing(dd89)

*j)
drop if dd89 == 0

*k)
foreach var of varlist fips dd89 prcp dry corn_prod corn_planted year fland {
    destring `var', replace 
}
*This replaced corn_prod, which was a string variable as long (numeric)

*5
*a)
gen corn_yield = corn_prod / corn_planted

*b)
gen dry_dd89 = dd89
replace dry_dd89 = 0 if dry != 1

*internet(chatgpt, I asked "Simplify this (the last code) in one line") 
gen dry_dd89 = cond(dry == 1, dd89, 0)


*c)
gen dry_dd89_sq = 0
replace dry_dd89_sq = dd89*dd89 if dry == 1

*d)
gen dry_prcp = 0
replace dry_prcp = prcp if dry == 1

*e)
gen dry_prcp_sq = 0
replace dry_prcp_sq = prcp*prcp if dry == 1

*f)
generate irr_dd89 = 0
replace irr_dd89 = dd89 if dry == 0

*g)
generate irr_dd89_sq = 0
replace irr_dd89_sq = dd89*dd89 if dry == 0

*h)
generate irr_prcp = 0
replace irr_prcp = prcp if dry == 0

*i)
generate irr_prcp_sq = 0
replace irr_prcp_sq = prcp*prcp if dry == 0

*j)
ssc install estout

sort year
by year: outreg2 using t1_HOLDER.xls, sum(detail) keep(corn_yield dd89 prcp dry) eqkeep(mean sd min max) label replace excel

*k)
preserve
collapse (mean) corn_yield, by(year dry)
twoway (line corn_yield year if dry == 0, lcolor(pink%50)) (line corn_yield year if dry == 1, lcolor(emerald)), title("Corn Yield Over Time by Irrigation Status") xtitle("Year") ytitle("Corn Yield") legend(label(1 "Non-Irrigated") label(2 "Irrigated"))

graph export plot1_HOLDER.jpg, replace
restore
*We can see that in the irrigated areas (pink line), the corn yield is higher compared to the non-irrigated areas, which indicates that irrigation has a positive impact on corn yields. For the tendency of the curves, the corn yield with irrigation shows a sharp increase between 1985 and around 1992, followed by a slower increase from 1992 to 1997. After 1997, the yield decrease. The trend without irrigation remains about the same, except for a slight decline between 1992 and 1997.

*l)

graph box dd89, over(year) title("Boxplot of Degree Days by Year") ylabel(,angle(0)) box(1, bcolor(pink%50))

graph export plot2_HOLDER.jpg, replace

*****************************************************************
*          REGRESSION ANALYSIS                                  *
*****************************************************************

*6)
*a) Basic model with fixed effects
ssc install reghdfe
ssc install ftools

reghdfe corn_yield dry_dd89 dry_prcp irr_dd89 irr_prcp i.year [pw=fland], absorb(fips) cluster(fips)
outreg2 using "table2_HOLDER.rtf", replace nolabel ctitle("First regression") keep(corn_yield dry_dd89 dry_prcp irr_dd89 irr_prcp) addtext("Fixed Effects", "Yes", "Quadratic Variables", "No", "Control Variables", "No")

*b) Model adding quadratic variables 
reghdfe corn_yield dry_dd89 dry_dd89_sq dry_prcp dry_prcp_sq irr_dd89 irr_dd89_sq i.year [pw=fland], absorb(fips) cluster(fips)
outreg2 using "table2_HOLDER.rtf", append nolabel ctitle("Second regression") keep(corn_yield dry_dd89 dry_dd89_sq dry_prcp dry_prcp_sq irr_dd89 irr_dd89_sq irr_prcp irr_prcp_sq) addtext("Fixed Effects", "Yes", "Quadratic Variables", "Yes", "Control Variables", "No")

*c) Model adding control variables x1 - x6
reghdfe corn_yield dry_dd89 dry_dd89_sq dry_prcp dry_prcp_sq irr_dd89 irr_dd89_sq x1 x2 x3 x4 x5 x6 i.year [pw=fland], absorb(fips) cluster(fips)
outreg2 using "table2_HOLDER.rtf", append nolabel ctitle("Third regression") keep(corn_yield dry_dd89 dry_dd89_sq dry_prcp dry_prcp_sq irr_dd89 irr_dd89_sq irr_prcp irr_prcp_sq) addtext("Fixed Effects", "Yes", "Quadratic Variables", "Yes", "Control Variables", "Yes")

*d) I put all my results in one table by using the outreg2 command after every regression in a) b) c), which created a Word document with all 3 regressions. with the command "addtext", i added the specificities for each regression (if they contain quadratic variables or not etc...)

*********************************************************************
*                   PRESENTING RESULTS                              *
*********************************************************************

*7)
*b) The first graph (lineplot, which I interpretated further in 5.k) represents the evolution of corn yields across time for the irrigated and non-irrigated counties. We observed that the corn yields are higher in the irrigated counties, which indicates that irrigation has a positive effect on yields. The boxplot shows the median, dispersion and outliers. We can observe that the median of the degree days variates from on year to another, which may indicate climatic fluctuations, its highest being in 2002. The bigger lenght of the box in 2002 also indicates more variation in the temperatures during this year.

*We can now delve into the results of the 3rd regression:
*Ceteris paribus, an increase of one unit in dregree days below 89.6°F in non-irrigated areas is associated with a 0.007 unit increase of corn yield. This result is statistically signficant (pvalue = 0.025<0.05). The coefficient associated with the square root of the variable is negative, which indicates that beyond a certain threshold, heat reduces yield. This result is also statistically significant (pvalue=0.01<0.05). 
*In irrigated areas, an increase of one unit in degree days is associated with a 0.018 unit increase of corn yield. This result is statistically significant (pvalue=0.001). It has a stronger positive effect compared to non-irrigated areas. As in non-irrigated areas, when we look at the square root of the coefficient we observe that temperature effects are also non-linear, where excessive heat is negatively affecting yield. This result is also statistically significant (pvalue = 0.004). 
*Furthermore, we can observe that the coefficients associated with the control variables are not statistically significant. 
*When we look at the time variables, we observe that, ceteris paribus, in 1992, corn yield was 5.14 units higher compared to the baseline year. In 1997, the yield increased even more, reaching 8.99 units higher than the baselin eyear. However, in 2002, there was a decline of 2.86 units relative to the baseline. All these results are statistically significant. 
*By looking further into the coefficients in the regression, we observe that the effect of irrigation on corn yields appears to be less pronounced than what the graph showed, which may be counterintuitive. This may imply that other factors may contribute in determining productivity than irrigation alone, for example extreme weather or soil quality.
*The R-squared of the third regression is equal to 0.8386, which means that 83.86% of the variation in corn yields is explained by the independant variables in the model. The model fits the data  well. 













