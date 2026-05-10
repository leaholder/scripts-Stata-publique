*td asd MC
cd "C:\Users\leaaa\OneDrive\Documents\MAGISTERE\MAGEVAL 3\TD ASD\"
*rev total = somme des 6 rev
*données sur la chine, couvre certaines provinces chinoises
tab province 
*7 provinces diff, chine = 30 provinces 
*données de panel, ménage, sur période très longue, données sur structure revenu. on peut evoluer comment structure des rev s'est modifiée, ouverture chine = 1980 (ici de 1989 --> 2015). comment réformes chinoises ont contribué à modifier la structure des revenus 
*cmt rev a évolué ds le temps
*évol de la structure du rev
*analyse de la distrib des revevenus (gini, anthropie, percentiles + décomposition)
*pad onnées rpz à l'échelle nationale, car provinces riches
*données chns: china health and nutrition survey
*fiabilité données chinoises ? pas collectées par institutions chinoises mais par univ us donc ok. 

*à la fin: exam --> rendre dofile esthetique + travail écrit 

label variable province "Province"
label variable urban "Urban vs. rural areas"
label variable hhsize "Household size"

label define urban_lbl 0 "Rural" 1 "Urban"
label define province_lbl 32 "Jiangsu" 37 "Shandoug" 41 "Henah" 42 "Hubei" 43 "Hunan" 45 "Guangxi" 52 "Guizhou"

label values province province_lbl
label values urban urban_lbl

tab urban
tab province 

save income, replace 

//ETAPE 1: REPRESENTER L'EVOLUTION DU REVENU MOYEN//

*revenu par tête car effet taille --> corriger effet taille
*corriger l'évolution des prix (rev année 89 exprimés en prix année 89)donc pas comparables ds temps. raisonner en monnaie constante, prendre prix d'une année comme ref. si données sur inflation, soit sur IPC --> 2eme fichier = cpi. 

merge 1:1 hhid wave using "C:\Users\leaaa\Downloads\cpi.dta" 

drop _merge 
*id indiv stat uniques 
*fusion verticale: append 

gen hhinc_pc_cpi = (hhinc/hhsize)/cpi2015
label variable hhinc_pc_cpi "Household annual income per capita (2015 price)"

bysort wave : sum hhinc_pc_cpi

*collapse: passer à une échelle supérieure + agregée

save income, replace 

collapse (mean) hhinc_pc_cpi, by(wave)

twoway line hhinc_pc_cpi wave, ytitle("Mean household income per capita (2015 prices)") xlabel(1989 1991 1993 1997 2000 2004 2006 2011) title("Change in mean household income") note("Source: CHNS data") color(pink%50)

*hausse continue qui s'accélère en fin de période 

use income, clear 
*on rappelle la base sans collapse 

collapse (mean) hhinc_pc_cpi, by (wave urban) //on agrege par 2
twoway (line hhinc_pc_cpi wave if urban==1, legend(label(1 "Urban"))) (line hhinc_pc_cpi wave if urban ==0, legend(label(2 "Rural")))

*augemnte plus vite ds les villes que campagne

//ETAPE 2: Analyse de l'évolution de la structure des revenus des ménages//

use income, clear 
gen nagr = hhinc - agr

label variable nagr "Household non-agricultural income"
*rev agricole vs non-agricole 

*aussi en terme de revenu absolu (montants monétaires) et relative (parts)

*recorriger cpi pour composantes du revenu 
order nagr, after(agr)
foreach var of varlist agr-wage {
	gen `var'_pc_cpi= (`var'/hhsize)/cpi2015
	local lab1: variable label `var'
	label variable `var'_pc_cpi `"`lab1' per capita income (2015 prices)"'
}

foreach var of varlist agr-wage{
	gen sh_`var'=`var'/hhinc
	local lab2: variable label `var'
	label variable sh_`var' `"Share of `lab2 in total income'"'
}

*représentation évolution structure revenu 

collapse (mean) agr_pc_cpi nagr_pc_cpi sh_agr sh_nagr, by(wave)

twoway (line agr_pc_cpi wave, legend(label(1 "Agricultural income"))) ///
       (line nagr_pc_cpi wave, legend(label(2 "Non-agricultural income")))

	   *forte augmentation rev nagr comparé à rev agricole

twoway (line sh_agr wave, legend(label(1 "Share of agricultural income"))) (line sh_nagr wave, legend(label(2 "Share of non-agricultural income")))

*début de période: 40% ds rev tot, baisse progressive pr se situer à 25% environ, rev nagr: 60% --> 80%. 
*montée en puissance rev nagr et diminution sources nagr du revenu. 

//// ANALYSE DE LA DISTRIBUTION //// -----
*regarder écart-type --> appréhender distribution de manière très rapide. 

use income, clear 

sum hhinc_pc_cpi if wave == 1989, detail 
sum hhinc_pc_cpi if wave == 2015, detail 
*1989: 2782 w par tete au prix de 2015/2015: 35000 w par tete au prix de 2015. explosion de l'écart type. inégalités ont fortement augmentés. 

*histogramme/ kernel (pref à histogramme, fct de densité à noyau) --> premier regard graphique sur distrib des revenus

twoway (kdensity hhinc_pc_cpi if wave == 1989 & hhinc_pc_cpi < 50000, legend(label(1 "1989"))) (kdensity hhinc_pc_cpi if wave == 2000 & hhinc_pc_cpi < 50000, legend(label(2 "2000"))) (kdensity hhinc_pc_cpi if wave == 2015 & hhinc_pc_cpi < 50000, legend(label(3 "2015"))), ytitle("Kernel density") xtitle("Household per capita income")

*pas visible, il faut tronquer la distrib pr enlever qlq ménages en 2015 (très riches) qui font que graph est illisible
*aplatissement de la distrib des revenus et étalement à droite: distrib devient de moins en moins leptokurtique (mode très pointu, ex 89); cb de 2015 platikurtique --> mode de plus en plus bas (concentration de ménages de plus en plus faible autour du mode). distrib s'étale au cours du temps vers la droite (échelle des revenus s'élargit, traduit montée des inégalités). le mode reste quasimment le même (autour de 3000/4000w par an?) --> avec enrichissement et dvpmt chine mode ne se décale pas vers la droite.
*étalement à droite --> gens s'enrichissent, montée des inégalités. 
*mode ne se décale pas vers droite + aplatissement --> traduit pauvreté qui a fortement diminué monétaire. (de moins en moins de pers ds les tranches les plus basses). 
*pauvres de 2015 ont niv de vie comparable au niv de vie "courant" en 89. même si pauvreté s'est réduite, ceux qui sont pauvres le sont environ comme en 1989. 
*étalement vers la droite: montée des inégalités (si mode se décale vers droite ne trad pas nécessairement inég), montre que tous les gens qui se situent ds milieu distrib rev ont vu leur poids augmenter. a la pauvreté s'est substitué classes moyennes qui sont montées en puissance entre 89/2015. 


twoway (kdensity hhinc_pc_cpi if wave == 2015 & urban == 1 & hhinc_pc_cpi < 100000, legend(label(1 "Urban"))) (kdensity hhinc_pc_cpi if wave == 2015 & urban == 0 & hhinc_pc_cpi < 100000, legend(label(2 "Rural"))), ytitle("Kernel density") xtitle("Household per capita income")

*urbna: courbe plus étalée que rural, ds le bleu , pls d'inégalités ? ne suffit pas. 
*mode est bien plus à droite pr zones urbaines, dc échelle des revenus est  pas si importante. si on reg rural, mode très leptokurtique + étalement pas tant moins important quen zone urbaine , moins de classe moy mais autnt de riches
*résultat contreintuitifs: ineg + pronconcée en rural qu urbain
*ineg semblerait plus elevee en zone rurale qu'urbaine en 2015. 

ssc install glcurve 
glcurve hhinc_pc_cpi, lorenz plot (function equality=x)
*les 40% les plus pauvres détiennent environ 10% du revenu total. années empliées ici n'a pas de sensn on va plutot regarder revenu ds le temps. 

glcurve hhinc_pc_cpi if wave == 1989 | wave == 2000 | wave == 2015, by(wave) split plot(function equality = x) lorenz title("Lorenz Curves") ytitle ("L(p)") xtitle("Household per capita income")

*pas d'intersection, augmentation inégalités sans ambiguité. montée évidente des inégalités. si se croisent on ne peut pas ccl (ps de relation de dominance d'une distrib sur l'autre --> forme des inégalités ont changés)

*gl = generalize lorenz, plusieurs courbes 

glcurve hhinc_pc_cpi  if wave == 1989 | wave == 2015, by(wave) by(urban) split plot(function equality = x) lorenz 

*montée générale observé pr ensemble éhantillon se confirme distinctement pr zones rurales et urbaines

glcurve hhinc_pc_cpi if wave == 2015, by(urban) split plot(function equality = x) lorenz 
*inégalités plus pronconcées en rural qu'en urbain (rare)

// INDICATEURS D'INEGALITE -----

*percentiles
pctile decile = hhinc_pc_cpi, nq(10)

xtile decile1 = hhinc_pc_cpi, nq(10)

_pctile hhinc_pc_cpi, percentiles(10 34 76 90)
return list 

*val des percentiles remarquables (niv de revenu qui va séparer en diff tranches pop)

ssc install ineqdecgini

*formules d'approximation de l'indice de gini

ineqdecgini hhinc_pc_cpi if wave == 2015

*gini à 0.54, relativement fort niveau d'inégalité. généralement se situe entre 0.25-0.65 (sur le revenu). au dessus de 0.4-45: élevé. 

*indice de gini caluclé pr l'ensemble des observations 
ineqdecgini hhinc_pc_cpi

ineqdecgini hhinc_pc_cpi, by(wave)

*ici groupes = années. inégalités intra-groupes (pour chacune des années) et inter-groupes (différence =s de revenu moyen entre les années).  n'a aucun sens 

*évolution dans le temps de l'indice de gini: tendance globale à la hausse. période de baisse entre 2006 et 2011 puis repart à la hausse. du début de la période à la fin, on a pris 16 points d'indice. 

ineqdecgini hhinc_pc_cpi if urban == 1, by(wave) 

ineqdecgini hhinc_pc_cpi if urban == 0, by(wave) 

*niveau supérieur d'inégalités dans els villes, meme tendance (hausse). en réalité, a l'échelle nationale, la baisse s'est poursuivie: effet propre à certaines provinces qui tirent vers le haut inégalités. 

*commande qui va permettre de sauvegarder en mémoire résultats de l'indice de gini: 

gen gini = .
egen group= group(urban wave)
sum group, meanonly 

forval i = 1/`r(max)' {
	ineqdecgini hhinc_pc_cpi if group == `i'
	replace gini = r(gini) if group == `i'
}

*jeu de données d'enquête sur revenu, et énoncé très général (explorer distrib des revenus), comprendr stat des, kernel, gini, lorenz... diagnostic sur les inégalités. document texte où on reporte principaux résultats et commentaires + dofile. 10/15/20 pages. données un peu plus simples. beaux tableau et graph. date: un peu avant noel. lundi 22 dec/. 

* Indices d'inégalité complémentaires

ssc install ineqdeco

*calcule tous les grands indicateurs d'inégalité (gini, indices d'enthropie (ge0, ge1, ge2) et indices d'Atkinson A(.) qui ont mm propriétés qu'indices d'enthropie. 
*décomposition intra et inter groupes. 

ineqdeco hhinc_pc_cpi, by(wave)

*ratio inter-percentiles (p90/p10 = 16, bcp), indices d'enthropie, d'atkinson, de gini. enthropie: plus paramètre d'aversion aux ineg est élevé, pls indice accorde poids aux diff ds le haut de la distrib. G2 surréagit si bcp d'inégalités chez les riches. GE1 surréagit si diff de revenu ds milieu de la distrib, GE0 et GE-1 régissent sur diff de rev chez les plus pauvres. GE2: 0.35 - 1.36. chez les pauvres aussi, choses se sont distendues, et ds milieu distrib moin smarqué. inég ont fortement augemntés, plus marquées ds les queues de la distrib où écarts de revenus ont exposés. 
*indice de gini pas parfaitement décomposé en var intra inter 

ineqdeco hhinc_pc_cpi if wave == 2015, by(urban)

*ineg plus fortes ds zones rurales qu'urbaines. indices d'enthropie; haut, ineg mesurée par GE2 supérieure ds villes que campagnes. 

ssc install descogini

*pr décompo revenus 
