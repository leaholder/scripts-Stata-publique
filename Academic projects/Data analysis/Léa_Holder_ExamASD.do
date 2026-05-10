*EXAMEN ANALYSE STATISTIQUE DES DONNEES
*Léa Holder

cd "C:\Users\leaaa\OneDrive\Documents\MAGISTERE\MAGEVAL 3\TD ASD\EXAM"

use "data.dta"

**************************************
**# VUE D'ENSEMBLE *******************
**************************************

*plusieurs observations (ménages) sur une période (2014) au Brésil. 

count 
*On dispose de 28,428 observations. 

describe 
*données sur les ménages urbains/ruraux, leur région de résidence, sur leur revenu  mensuel en reales et leur taille. 

tab urban 
*3,927 ménages ruraux soit 13.8% des observations, contre 24,501 ménages urbains, soit 86% des observations. 

tab region
*14% des ménages résident dans le Nord, 28% dans le Nord-Est, 30.5% dans le Sud-est, 16.8% dans le Sud et 10.6% dans le centre-ouest. 

*centre-ouest --> 12 millions habitants
*nord-est: 50 millions d'habitants
*nord: 14 millions d'habitants (région la plus étendue)
*sud-est: 77 millions d'habitants --> + peuplée et développée économiquement (pib et pib/hab plus important) et comporte les plus grandes villes
*sud: 26 millions d'habitants --> IDH + élevé
*source wikipedia 

tab hhsize 
* 99% des ménages ont au plus 7/8 enfants
*on va de 1 à 17 enfants

sum hhsize 
*moyenne d'enfants par ménage = 3

tab urban region, col
*nord et nord-est on la plus grande part de ruraux (environ 21% vs entre 7 et 12% pour le reste)

*********************************************
**# ANALYSE GENERALE DES INEGALITES**********
*********************************************

************1. par ménage***************
sum hhinc, detail

*revenu moyen par foyer: 3104 real, médian 1950 < moyenne --> moyenne tirée vers le haut pas très hauts revenus.
* écart-type très élevé (4700) = dispersion forte 
*variance pareil --> outliers extremes (tres hauts revenus)

*percentiles; 25% de la population gagnent moins de 1100 reals
*75% de la population gagnent moins de 3500 reals (donc les 25% les plus riches gagnent + de 3500)
*90% gagnent moins de 6300 reals (10% plus riches gagnent +6300), 95% gagnent moins de 9400 (5% gagnent + 9400) et 99% gagnent moins de 20,000 (1% gagnent + de 20000 reals)
*écarts inter-quartiles: écart entre P25 et P75 très élevé (3500-1100), P95:99 énormes par rapport à la médiane (qlq val extremes tandis que bcp de ménages ont revenus assez faibles). 
*skewness = 18, très élevé et positif --> distribution asymétrique à droite (majorité ds la moyenne, qlq très hauts revenus) 
*kurtosis extrement élevé = 935 --> distribution leptokurtique (en pointe) --> valeurs extremes , majorité concentré vers revenus faibles/moyens

sum hhinc, detail

*graphiques avec les percentiles 
preserve
clear
input str10 percentile float valeur
"P10" 700
"P25" 1100
"P50" 1950
"P75" 3500
"P90" 6300
"P95" 9400
"P99" 20000
end

graph hbar valeur, over(percentile)  ytitle("Revenu (reals)", size(medium)) title("Distribution des revenus des ménages par percentiles", size(medlarge)) blabel(bar, format(%5.0fc) size(small)) note("Source: Données enquête ménages brésiliens (2014)", size(vsmall))
    
graph export "percentiles_revenus.png", replace
restore

*graphique noyau de densité 

kdensity hhinc

*on ne visualise pas trop --> restreindre au 99e percentile

kdensity hhinc if hhinc<20000, xtitle("Revenu par ménages") ytitle("Densité") title("Noyau de densité des revenus par ménages", color(black)) note("Source: données enquête ménages brésiliens (2014)", size(vsmall)) 

graph export "kdensity_hhincome.png", replace 
*le graph confirme ce qu'on a vu sur les stats précédemment : distribution très en pointe (leptokurtique) et asymétique vers la droite, indiquant que la plus part des valeurs se situent atour de la moyenne, avec qlq valeurs extrêmes, indiquant que qlq personne détiennent de très hauts revenus tandis que la majeure partie de la popu ont des revenus faibles/moyens. 

*on regarde la courbe de Lorenz

*ssc install glcurve 
glcurve hhinc, lorenz plot (function equality=x) title("Courbe de Lorenz", color(black)) ytitle ("Revenu cumulé L(p)") xtitle("Population cumulée (p)") note("Source: Données enquête ménages brésiliens (2014)", size(vsmall))

graph export "lorenzcurve.png", replace 

*ssc install ineqdecgini

*formules d'approximation de l'indice de gini

ineqdecgini hhinc
*indice de gini général de 0.5 indiquant niv élevé d'inégalités de revenu 

ineqdeco hhinc
*décomposition générale

***********2. par tete*************

gen inc_hab = hhinc/hhsize 
label variable inc_hab "Income per capita"

sum inc_hab, detail 

*moyenne: 1234 reals/mediane 724
*valeurs plus faibles comme on a divisé par la taille du ménage
**écart-type= 2809 reals, forte dispersion
*variance extreme
*percentiles: 
*25% de la pop gagne moins de 405 reals par habitant
*75: les 25% les plus riches gagnent +1300
*90%: les 10% les plus riches gagnent +2485
*95: les 5% les plus riches gagnent +3800
*99: les 1% les plus riches gagnent +9000

*P75-P25 = 1300 - 405 = 895, important 
*percentiles 99/95 élevés par rapport à la médiane, indiquant de fortes inégalités 

*sk: 61.9, distribution très asymétrique à droite
*kurtosis; 6810, distrib extrememnt leptokurtique 

*graph noyau de densité 
kdensity inc_hab if inc_hab<9000, xtitle("Revenu par habitant") ytitle("Densité") title("Densité de noyau des revenus par habitants") note("Source: Données enquête ménages brésiliens (2014)", size(vsmall))

graph export "kdensity_incomepc.png", replace 

***************************************
**# ANALYSE PAR GROUPES****************
***************************************

*************1. urbain/rural***********

tabstat hhinc, by(urban) stats(mean median sd skewness kurtosis)
*mean rural: 1745 vs 3322 urbain, mediane 1350 vs 2067, écart-type très elevé pr les 2 cas mais + élevé en milieu urbain
*rural: sk = 4.8 // urbain = 17
*kurtosis rural = 45 vs 861 en ville
*inégalités ds deux mais bcp plus marquées en ville: courbe + leptokurtique 

twoway(kdensity hhinc if urban==1 & hhinc<20000, lcolor(pink) lpattern(dash)) (kdensity hhinc if urban==0 & hhinc<20000, lcolor(emerald) lpattern(solid)), legend(label(1 "Urbain") label(2 "Rural")) xtitle("Revenu par ménages") ytitle("Densité") title("Noyau de densité des revenus par ménages urbains/ruraux") note("Source: Données enquête ménages brésiliens (2014)", size(vsmall))

graph export "kdensity_hhincomeurbanrural.png", replace 

*courbe de Lorenz par urbain/rural:
	
glcurve hhinc, by(urban) split plot(function equality = x) clcolor( emerald pink) clpattern(solid dash) lorenz title("Courbe de Lorenz : urbain vs rural", color(black)) ytitle("Revenu cumulé L(p)") xtitle("Population cumulée (p)") legend(label(1 "Urbain") label(2 "Rural")) note("Source: Données enquête ménages brésiliens (2014)", size(vsmall))

graph export "lorenzcurveurbanrural.png", replace 

*la courbe de rural se rapproche plus de la ligne d'égalité, confirme inégalités + prononcées en rural

ineqdecgini hhinc, by(urban)
*gini en rural = 0.44 // en urban = 0.5
*gini within = 0.4, between = 0.06
* décompo du coef de gini montre que lessentiel des inégalités = différences au sein des zones, mais différences entre urban et rural expliquent peu les inégalités totales
*niveau d'inégalités supérieur ds les villes

*décomposistion plus générale

ineqdeco hhinc, by(urban)

***************2. par régions*************

tabstat hhinc, by(region) stats(mean median sd skewness kurtosis)

*courbes de lorenz par region
glcurve hhinc, by(region) split plot(function equality = x) lorenz title("Courbes de Lorenz par région") ytitle("Revenu cumulé L(p)") xtitle("Population cumulée (p)") legend(label(1 "Nord") label(2 "Nord-est") label(3 "Sud-est") label(4 "Sud") label(5 "Centre-ouest"))
graph export "lorenzcurve_region.png", replace

*pas très lisible pour le mettre sur le rapport

*Gini
ineqdecgini hhinc, by(region)

*décomposition complète des inégalités 
ineqdeco hhinc, by(region)

*part du revenu total par région
bysort region: egen total_region = total(hhinc)
egen total_national = total(hhinc)
gen pct_revenu =(total_region / total_national)*100

preserve
collapse (mean) pct_revenu, by(region)

*graphique part du revenu total par region
graph bar pct_revenu, over(region) ytitle("Part du revenu total (%)") title("Concentration des revenus par région") note("Source: Données enquête ménages brésiliens (2014)")
    
graph export "revenus_region.png", replace
restore
