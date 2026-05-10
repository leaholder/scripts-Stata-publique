********************************************************************************
* ÉVALUATION DE L'IMPACT DU RSA RÉNOVÉ
* Direction Régionale France Travail — Paris (REG75)
*
* Auteure : Léa Holder
* Objet   : Évaluation de l'effet de l'accompagnement intensif (XP RSA)
*           sur le retour à l'emploi des bénéficiaires du RSA (BRSA)
*
* Plan :
*   1. Chargement et nettoyage des données
*   2. Labélisation des variables
*   3. Équilibre des groupes traité / témoin
*   4. Statistiques descriptives
*   5. Effet du traitement sur l'accompagnement reçu
*   6. Effet du traitement sur le retour à l'emploi
*   7. Hétérogénéité des effets par action et par profil
*   8. Robustesse : test par période d'inscription
********************************************************************************


********************************************************************************
* 0. PARAMÈTRES GÉNÉRAUX
********************************************************************************

clear all
set more off

* Adapter le chemin selon l'environnement
* cd "CHEMIN_VERS_LE_DOSSIER"


********************************************************************************
* 1. CHARGEMENT ET NETTOYAGE DES DONNÉES
********************************************************************************

import excel "REG75_POP_XP_RSA_SERVICE.xlsx", sheet("QUERY_FOR_BASE") firstrow


* --- Vérification des appariements et doublons ---

tab pop_detail if pop == "XP_RSA"

duplicates report IDTUNQDMR
duplicates report DC_INDIVIDU_LOCAL

* Plusieurs observations par individu = réinscriptions multiples
* On conserve uniquement l'observation la plus récente par individu
bysort DC_INDIVIDU_LOCAL (date_ref): keep if _n == _N

duplicates report DC_INDIVIDU_LOCAL


* --- Gestion des valeurs manquantes sur les variables d'issue ---

foreach var in ACCESM6 ACCESDURM6 PRESDURM6 ACCESM12 ACCESDURM12 PRESDURM12 {
    count if missing(`var')
}

* Suppression des observations avec outcomes manquants (n=309)
drop if missing(ACCESM6, ACCESDURM6, PRESDURM6, ACCESM12, ACCESDURM12, PRESDURM12)


* --- Recodage de la qualification ---
* La modalité 4 correspond à "aucune information" → recodée en manquant

encode qualif, gen(qualif_num)
recode qualif_num (4 = .)
drop qualif

* Suppression des observations avec qualification manquante (n=108, soit 3.45%)
drop if missing(qualif_num)


* --- Variable de traitement ---

gen treated = (pop == "XP_RSA")
label define treated_lbl 0 "Témoin" 1 "Traitement"
label values treated treated_lbl


* --- Recodage de Top_GLO (variable binaire avec valeur aberrante) ---

recode Top_GLO (2 = .)
drop if missing(Top_GLO)


* --- Déstring des variables numériques stockées en string ---

destring age26 sexe anc BOE DPTRES, replace


* --- Variables indicatrices d'accès aux services ---

gen a_immersion = Nb_PMSMP > 0
label variable a_immersion "A eu au moins une immersion (PMSMP)"

gen a_entretien = Nb_entretiens_tous > 0
label variable a_entretien "A eu au moins un entretien"


* --- Recodage de la mobilité géographique (string → numérique) ---

gen mobilite_num = .
replace mobilite_num = 0 if strpos(mobilite, "0_aucune mobilité") > 0
replace mobilite_num = 1 if strpos(mobilite, "1_moins de 15 km ou 30 mn ou moins") > 0
replace mobilite_num = 2 if strpos(mobilite, "2_15 à 39 km ou 31 à 59 mn") > 0
replace mobilite_num = 3 if strpos(mobilite, "3_plus de 39 km ou au moins 1 heure") > 0
drop mobilite


* --- Recodage de l'expérience professionnelle (string → numérique) ---

gen exper_num = .
replace exper_num = 1 if strpos(exper, "1") > 0
replace exper_num = 2 if strpos(exper, "2") > 0
replace exper_num = 3 if strpos(exper, "3") > 0
drop exper


********************************************************************************
* 2. LABÉLISATION DES VARIABLES
********************************************************************************

* Domaine professionnel
encode dom_prof, gen(dom_prof_num)
label define domprof_lbl                                                       ///
    1  "Agriculture, Pêche, Espaces verts"                                     ///
    2  "Arts et Façonnage"                                                      ///
    3  "Banque, Assurance, Immobilier"                                          ///
    4  "Commerce, Vente, Grande distribution"                                   ///
    5  "Communication, Média, Multimédia"                                       ///
    6  "Construction, BTP"                                                      ///
    7  "Hôtellerie, Tourisme, Loisirs"                                          ///
    8  "Industrie"                                                               ///
    9  "Installation et Maintenance"                                             ///
    10 "Santé"                                                                   ///
    11 "Services à la personne et à la collectivité"                            ///
    12 "Spectacle"                                                               ///
    13 "Support à l'entreprise"                                                  ///
    14 "Transport et Logistique"
label values dom_prof_num domprof_lbl

* Âge
label define age_lbl 1 "Moins de 26 ans" 2 "26–49 ans" 3 "50 ans et plus"
label values age26 age_lbl

* Qualification
label define qualif_lbl 1 "Non qualifié" 2 "Qualifié" 3 "AMT/Cadres"
label values qualif_num qualif_lbl

* Sexe
label define sexe_lbl 1 "Homme" 2 "Femme"
label values sexe sexe_lbl

* Ancienneté d'inscription
label define anc_lbl 1 "<12 mois" 2 "12–23 mois" 3 "24 mois+"
label values anc anc_lbl

* Statut BOE (bénéficiaire de l'obligation d'emploi)
label define boe_lbl 0 "Non BOE" 1 "BOE"
label values BOE boe_lbl

* Mobilité géographique
label define mob_lbl                                                           ///
    0 "Aucune mobilité"                                                        ///
    1 "<15 km / 30 min"                                                        ///
    2 "15–39 km / 31–59 min"                                                   ///
    3 ">39 km / 1h+"
label values mobilite_num mob_lbl

* Expérience professionnelle
label define exper_lbl 1 "<1 an" 2 "1–5 ans" 3 "6 ans et plus"
label values exper_num exper_lbl


********************************************************************************
* 3. ÉQUILIBRE DES GROUPES TRAITÉ / TÉMOIN
********************************************************************************

* Tests du Chi2 sur les variables de contrôle

tab sexe        treated, chi2   // p=0.624 → pas de différence significative
tab qualif_num  treated, chi2   // p=0.062 → pas de différence significative
tab age26       treated, chi2   // p=0.239 → pas de différence significative
tab anc         treated, chi2   // p=0.043 → différence significative (contrôler)
tab mobilite_num treated, chi2  // p=0.424 → pas de différence significative
tab BOE         treated, chi2   // p=0.031 → différence significative (contrôler)
tab exper_num   treated, chi2   // p=0.375 → pas de différence significative

* Note : ancienneté et statut BOE diffèrent entre groupes → inclus comme contrôles


* Graphiques de répartition par groupe
graph bar (percent), over(qualif_num) over(treated)                            ///
    title("Répartition par qualification")                                     ///
    legend(off) ytitle("Proportion (%)")
graph export "graph_repartition_qualif.png", replace

graph bar (percent), over(anc) over(treated)                                   ///
    title("Répartition par ancienneté d'inscription")                          ///
    legend(off) ytitle("Proportion (%)")
graph export "graph_repartition_anc.png", replace

graph bar (percent), over(exper_num) over(treated)                             ///
    title("Répartition par expérience professionnelle")                        ///
    legend(off) ytitle("Proportion (%)")
graph export "graph_repartition_exper.png", replace


********************************************************************************
* 4. STATISTIQUES DESCRIPTIVES
********************************************************************************

* Statistiques sur les variables de services reçus
summarize NB_PdP Nb_entretiens_tous Nb_entretiens_EDP Nb_entretiens_BILAN     ///
          Top_CEJ Top_AIJ Top_GLO Nb_AES Nb_Activ_Projet Nb_Activ_Crea Nb_PES ///
          Nb_VSI Nb_MRS Nb_PMSMP Nb_MEC Nb_MER, detail

* Part des individus ayant bénéficié d'au moins un service
local vars NB_PdP Nb_entretiens_tous Nb_entretiens_EDP Nb_entretiens_BILAN    ///
           Nb_AES Nb_Activ_Projet Nb_Activ_Crea Nb_PES Nb_VSI Nb_MRS         ///
           Nb_PMSMP Nb_MEC Nb_MER

foreach v of local vars {
    count if `v' > 0
}


********************************************************************************
* 5. EFFET DU TRAITEMENT SUR L'ACCOMPAGNEMENT REÇU
********************************************************************************

* --- Accès aux immersions ---

reg a_immersion i.treated sexe i.age26 i.qualif_num i.anc                     ///
    i.exper_num i.mobilite_num i.dom_prof_num BOE

margins treated
marginsplot,                                                                   ///
    recastci(rarea)                                                            ///
    plotopts(msymbol(O) msize(large) mcolor("140 25 55") lwidth(thick) lcolor("140 25 55")) ///
    ciopts(color("251 113 133%20") lwidth(none))                               ///
    ytitle("Part de BRSA avec au moins une immersion (%)", size(small))        ///
    title("Effet du RSA rénové sur l'accès aux immersions", size(medlarge))    ///
    xlabel(0 "Témoins" 1 "Traités", labsize(medlarge))                        ///
    xtitle("") legend(off)                                                     ///
    graphregion(color(white))                                                  ///
    note("Source : Données France Travail", size(small))                       ///
    scheme(s1mono)
graph export "graphique_immersion.png", replace width(1200) height(800)


* --- Outils de recrutement (MRS, PMSMP) ---

reg Nb_MRS   treated sexe i.age26 i.qualif_num i.anc i.exper_num i.mobilite_num i.dom_prof_num BOE
reg Nb_PMSMP treated sexe i.age26 i.qualif_num i.anc i.exper_num i.mobilite_num i.dom_prof_num BOE

esttab using "actions_outils_recrutement.rtf", replace                         ///
    keep(treated) se label b(3)                                                ///
    title("Effet du RSA rénové sur les outils de recrutement")


********************************************************************************
* 6. EFFET DU TRAITEMENT SUR LE RETOUR À L'EMPLOI
********************************************************************************

* Variables de contrôle communes
local controles sexe i.age26 i.qualif_num i.anc i.exper_num i.mobilite_num i.dom_prof_num BOE

* Outcomes : accès à l'emploi, emploi durable, présence en emploi durable
local outcomes ACCESM6 ACCESM12 ACCESDURM6 ACCESDURM12 PRESDURM6 PRESDURM12


* --- Sans contrôles (effet brut) ---

eststo clear
foreach y of local outcomes {
    eststo: reg `y' treated
}
esttab using "resultats_effet_brut.rtf", replace                               ///
    keep(treated) se label b(3) star(* 0.1 ** 0.05 *** 0.01)                  ///
    title("Effet brut du RSA rénové sur le retour à l'emploi")


* --- Avec contrôles socio-démographiques ---

eststo clear
foreach y of local outcomes {
    eststo: reg `y' treated `controles'
}
esttab using "resultats_effet_controle.rtf", replace                           ///
    keep(treated) se label b(3) star(* 0.1 ** 0.05 *** 0.01)                  ///
    title("Effet du RSA rénové sur le retour à l'emploi (avec contrôles)")


* --- Effets marginaux (marges ajustées) ---

reg ACCESDURM12 i.treated `controles'
margins treated, atmeans post

* Reconstruction du dataset pour le graphique
matrix M = r(b)'
clear
set obs 2
gen treated = _n - 1
gen yhat = .
replace yhat = M[1,1] if treated == 0
replace yhat = M[2,1] if treated == 1

label define treatlbl 0 "Groupe témoin" 1 "Groupe traité"
label values treated treatlbl

graph bar yhat, over(treated, label(angle(0)))                                 ///
    bar(1, color("blue*0.3")) bar(2, color("purple*0.7"))                      ///
    blabel(bar, format(%4.3f))                                                 ///
    ylabel(, grid)                                                             ///
    title("Accès à un emploi durable à 12 mois (ajusté)")                     ///
    subtitle("Effet du RSA rénové")                                            ///
    ytitle("Probabilité moyenne") legend(off)
graph export "graphique_ACCESDURM12_ajuste.png", replace


********************************************************************************
* 7. HÉTÉROGÉNÉITÉ DES EFFETS PAR ACTION ET PAR PROFIL
********************************************************************************

* --- Impact de chaque action sur les outcomes d'emploi ---

local actions Nb_entretiens_tous Nb_entretiens_EDP Nb_entretiens_BILAN        ///
              Nb_AES Nb_Activ_Projet Nb_Activ_Crea                             ///
              Nb_PES Nb_VSI Nb_MRS Nb_PMSMP Nb_MEC Nb_MER NB_PdP

local outcomes ACCESM6 ACCESDURM6 PRESDURM6 ACCESM12 ACCESDURM12 PRESDURM12

foreach act of local actions {
    eststo clear
    foreach y of local outcomes {
        eststo: reg `y' `act' sexe i.age26 i.qualif_num i.anc                 ///
            i.exper_num i.mobilite_num i.dom_prof_num BOE, vce(robust)
    }
    esttab using "resultats_`act'.rtf", replace                                ///
        keep(`act') b(3) se(3) star(* 0.1 ** 0.05 *** 0.01)                   ///
        stats(N r2, labels("N" "R²")) label                                    ///
        title("Effet de `act' sur les variables d'emploi")
}


* --- Effets hétérogènes des PMSMP par profil ---

local variables ACCESM6 ACCESM12 ACCESDURM6 ACCESDURM12 PRESDURM6 PRESDURM12

* Par qualification
foreach var of local variables {
    reg `var' c.Nb_PMSMP##i.qualif_num i.mobilite_num sexe                    ///
        i.exper_num i.age26 i.dom_prof_num BOE i.anc
    margins, dydx(Nb_PMSMP) over(qualif_num)
    eststo `var'_pmsmp_qualif
}

* Par mobilité
foreach var of local variables {
    reg `var' c.Nb_PMSMP##i.mobilite_num i.qualif_num sexe                    ///
        i.exper_num i.age26 i.dom_prof_num BOE i.anc
    margins, dydx(Nb_PMSMP) over(mobilite_num)
}


* --- Effets hétérogènes des MRS par profil ---

local variables ACCESM6 ACCESM12 ACCESDURM6 ACCESDURM12 PRESDURM6 PRESDURM12

* Par qualification
foreach var of local variables {
    reg `var' c.Nb_MRS##i.qualif_num i.mobilite_num sexe                      ///
        i.exper_num i.age26 i.dom_prof_num BOE i.anc
    margins, dydx(Nb_MRS) over(qualif_num)
    eststo `var'_mrs_qualif
}

* Graphique des effets marginaux par profil
local all_qualif ""
foreach var of local variables {
    local all_qualif "`all_qualif' `var'_mrs_qualif"
}

tempfile all_margins_mrs
local first_run = 1

* Boucle de collecte des marges par caractéristique (qualification, âge, expérience, ancienneté, mobilité, BOE)
local chars qualif_num age26 exper_num anc mobilite_num BOE
local char_labels "Qualification" "Âge" "Expérience" "Ancienneté chômage" "Mobilité" "Statut BOE"

forvalues i = 1/6 {
    local char   : word `i' of `chars'
    local clabel : word `i' of `char_labels'

    reg ACCESM12 c.Nb_MRS##i.`char' i.qualif_num i.mobilite_num sexe          ///
        i.exper_num i.age26 i.dom_prof_num BOE i.anc
    margins, dydx(Nb_MRS) over(`char') post

    preserve
    parmest, norestore
    gen characteristic = "`clabel'"
    gen level = real(regexs(1)) if regexm(parm, "([0-9]+)\.`char'")

    if `first_run' == 1 {
        save `all_margins_mrs', replace
        local first_run = 0
    }
    else {
        append using `all_margins_mrs'
        save `all_margins_mrs', replace
    }
    restore
}

* Graphique synthétique des effets hétérogènes des MRS
use `all_margins_mrs', clear
drop if missing(estimate)

gen stars = ""
replace stars = "***" if p < 0.01
replace stars = "**"  if p < 0.05 & p >= 0.01
replace stars = "*"   if p < 0.1  & p >= 0.05

graph bar estimate, over(characteristic, label(angle(45) labsize(vsmall)))     ///
    blabel(bar, size(tiny) format(%9.3f) position(outside))                    ///
    title("Effet marginal d'une MRS supplémentaire selon le profil", size(medium)) ///
    subtitle("Accès à l'emploi à 12 mois", size(small))                        ///
    ytitle("Effet marginal (points de pourcentage)")                           ///
    yline(0, lcolor(black) lpattern(dash))                                     ///
    graphregion(color(white)) scheme(s1mono)                                   ///
    note("Note : *** p<0.01, ** p<0.05, * p<0.1" "Source : Données France Travail", size(vsmall))
graph export "mrs_effets_heterogenes.png", replace width(1600) height(900)


********************************************************************************
* 8. ROBUSTESSE : TEST PAR PÉRIODE D'INSCRIPTION
********************************************************************************

* Hypothèse : l'effet du traitement a pu varier selon la période d'inscription
* (montée en charge du dispositif potentiellement plus tardive)

gen periode_inscription = .
replace periode_inscription = 0 if date_ref >= td(01mar2023) & date_ref < td(01jun2023)
replace periode_inscription = 1 if date_ref >= td(01jun2023)
label define periode_lbl 0 "Mars–Mai 2023" 1 "Juin 2023 et après"
label values periode_inscription periode_lbl

local outcomes ACCESM6 ACCESM12 ACCESDURM6 ACCESDURM12 PRESDURM6 PRESDURM12 Nb_entretiens_tous

foreach y of local outcomes {
    reg `y' i.treated##i.periode_inscription sexe i.age26 i.qualif_num        ///
        i.anc i.exper_num i.mobilite_num i.dom_prof_num BOE
    test 1.treated#1.periode_inscription
}

* Résultat : pas de différence significative d'effet selon la période pour les
* outcomes d'emploi (p>0.05). En revanche, l'effet sur le nombre d'entretiens
* diminue significativement après juin 2023 (interaction négative, p<0.001).

********************************************************************************
* FIN DU DO-FILE
********************************************************************************
