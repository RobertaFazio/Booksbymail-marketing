
*************************
** DESCRIZIONE DATASET **
*************************

*Vediamo se ci sono missing values:

codebook scelta
codebook multi
codebook emails
codebook catalogs
codebook resi_euro
codebook qta
codebook Mtot
codebook PVtot
codebook Itot
codebook agenti
codebook age
codebook genere
codebook recency
codebook tot



*Mettiamo le etichette alle modalità della nostra variabile dipendente "scelta", in modo tale da rendere più leggibili i risultati:

label define scelta_nome 1 "mobile" 2 "internet" 3 "ptovendita"
label value scelta scelta_nome



*Analizziamo la variabile dipendente:

tab scelta



*Analizziamo nel particolare le variabili indipendenti che rappresentano il numero di volte che è stato acquistato utilizzando, rispettivamente, il canale telefonico, il canale internet e il punto vendita, nel periodo di osservazione:

sum Mtot, d
sum Itot,d
sum PVtot, d



*Analizziamo la variabile dummy che indica se il cliente è multicanale (1=sì, 0=no):

tab multi



*Analizziamo la variabile dell'età:

sum age, d

*Abbiamo riscontrato un problema: la variabile "age" parte da 1. Poiché è alquanto improbabile che individui di 1 anno possano aver effettuato il fenomeno oggetto di studio (acquisto di libri attraverso un certo canale), li possiamo considerare come dati anomali. Per questo motivo, abbiamo deciso di modificarli inserendo la media dell'età (calcolata trasformando i valori 1 in 0) al posto di questi dati anomali, che sono 205 in totale:

replace age=0 if age==1
sum age 

*Essendo la media (calcolata trasformando i valori 1 in 0) pari a circa 43,34 modifichiamo i dati anomali (ora indicati con valore 0) con il valore 43:

replace age=43 if age==0
sum age 



*Analizziamo le altre variabili indipendenti:

tab genere
sum emails,d 
sum catalogs,d
tab agent



*Abbiamo deciso di generare e analizzare una nuova variabile dummy che indica in quante e quali occasioni di acquisto sono stati effettuati dei resi (1=reso sì, 0=reso no):

gen reso=0
replace reso=1 if resi_euro!=0
tab reso



*Analizziamo la variabile che indica il valore dei prodotti restituiti all'impresa (considerando solo le occasioni di acquisto in cui sono stati effettuati resi, che sono in totale 335 su 14719):

sum resi_euro if reso==1





***********************
** MULTINOMIAL LOGIT **
***********************

*Poiché la variabile dipendente ("scelta") è una variabile qualitativa multinomiale, scegliamo di utilizzare un modello multinomial logit. Tra le variabili indipendenti abbiamo deciso di inserire "reso" anziché "resi_euro", e di eliminare "tot" in quanto collineare con le tre variabili "Mtot", "PVtot", "Itot":

mlogit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere, base(3)

*Come baseline abbiamo scelto il canale punto vendita, in quanto è la modalità più frequente (54.29%) rispetto ai canali mobile (39.96%) e internet (5.75%). 

*scelta "mobile" vs "ptovendita" --> variabili non significative al 5%: multi, catalogs, agenti, age, genere
*scelta "internet" vs "ptovendita" --> variabili non significative al 5%: catalogs, age, genere





*************************
** LIFT CHART ANALYSIS **
*************************

*Per creare in-sample e out-sample, generiamo una nuova variabile che ci permette di dividere casualmente le osservazioni in 75% (per in-sample) e 25% (per out-sample):

gen random=uniform()
sum random,d



*Salviamo il 75 percentile, poi richiamiamo e visualizziamo il valore in output:

scalar cutoff=r(p75)
scalar list cutoff



*A questo punto, generiamo una nuova variabile e assegniamo valore 0 alle osservazioni appartenenti al campione di calibrazione e valore 1 alle osservazioni appartenenti al campione di validazione:

gen out_sample=0
replace out_sample=1 if random>cutoff



*Eliminiamo la variabile "random" che non ci serve più:

drop random



*Visualizziamo la tabella di frequenza di "out_sample" che ci permette di vedere quante osservazioni sono in in-sample e quante in out-sample:

tab out_sample



*Stimiamo il modello sull'in-sample (campione di calibrazione):

mlogit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere if out_sample==0



*Generiamo tre variabili che rappresentano la predizione dei tre canali di scelta possibili per l'acquisto:

predict mobile_hat, outcome(1)
predict internet_hat, outcome(2)
predict ptovendita_hat, outcome(3)





*********************************
** LIFT CHART ANALYSIS: MOBILE **
*********************************

gen mobile=0
replace mobile=1 if  scelta==1



*Cominciamo con la lift chart in-sample.
*Dividiamo in decili i valori della variabile "mobile_hat" del campione di calibrazione:

xtile decileM_in=mobile_hat if out_sample==0, n(10)



*Controlliamo di aver creato bene i decili:

tabstat mobile_hat, by(decileM_in)



*Invertiamo la tabella in modo da avere i valori medi più alti nei primi decili:

replace decileM_in=11-decileM_in if out_sample==0
tabstat mobile_hat, by(decileM_in)



*Visualizziamo ora la tabella dei valori medi per decile riferita alla variabile "mobile" dei valori osservati e ne facciamo il grafico:

tabstat mobile, by(decileM_in)
graph bar mobile if out_sample==0, over(decileM_in)



*Eseguiamo lo stesso procedimento ma per l'out-sample (validazione):

xtile decileM_out=mobile_hat if out_sample==1, n(10)
tabstat mobile_hat, by(decileM_out)
replace decileM_out=11-decileM_out if out_sample==1
tabstat mobile_hat, by(decileM_out)
tabstat mobile, by(decileM_out)
graph bar mobile if out_sample==1, over(decileM_out)





***********************************
** LIFT CHART ANALYSIS: INTERNET **
***********************************

gen internet=0
replace internet=1 if scelta==2



*Cominciamo con la lift chart in-sample.
*Dividiamo in decili i valori della variabile "internet_hat" del campione di calibrazione:

xtile decileI_in=internet_hat if out_sample==0, n(10)



*Controlliamo di aver creato bene i decili:

tabstat internet_hat, by(decileI_in)



*Invertiamo la tabella in modo da avere i valori medi più alti nei primi decili:

replace decileI_in=11-decileI_in if out_sample==0
tabstat internet_hat, by(decileI_in)



*Visualizziamo ora la tabella dei valori medi per decile riferita alla variabile "internet" dei valori osservati e ne facciamo il grafico:

tabstat internet, by(decileI_in)
graph bar internet if out_sample==0, over(decileI_in)



*Eseguiamo lo stesso procedimento ma per l'out-sample (validazione):

xtile decileI_out=internet_hat if out_sample==1, n(10)
tabstat internet_hat, by(decileI_out)
replace decileI_out=11-decileI_out if out_sample==1
tabstat internet_hat, by(decileI_out)
tabstat internet, by(decileI_out)
graph bar internet if out_sample==1, over(decileI_out)





****************************************
** LIFT CHART ANALYSIS: PUNTO VENDITA **
****************************************

gen ptovendita=0
replace ptovendita=1 if scelta==3



*Cominciamo con la lift chart in-sample.
*Dividiamo in decili i valori della variabile "ptovendita_hat" del campione di calibrazione:

xtile decileP_in=ptovendita_hat if out_sample==0, n(10)



*Controlliamo di aver creato bene i decili:

tabstat ptovendita_hat, by(decileP_in)



*Invertiamo la tabella in modo da avere i valori medi più alti nei primi decili:

replace decileP_in=11-decileP_in if out_sample==0
tabstat ptovendita_hat, by(decileP_in)



*Visualizziamo ora la tabella dei valori medi per decile riferita alla variabile "ptovendita" dei valori osservati e ne facciamo il grafico:

tabstat ptovendita, by(decileP_in)
graph bar ptovendita if out_sample==0, over(decileP_in)



*Eseguiamo lo stesso procedimento ma per l'out-sample (validazione):

xtile decileP_out=ptovendita_hat if out_sample==1, n(10)
tabstat ptovendita_hat, by(decileP_out)
replace decileP_out=11-decileP_out if out_sample==1
tabstat ptovendita_hat, by(decileP_out)
tabstat ptovendita, by(decileP_out)
graph bar ptovendita if out_sample==1, over(decileP_out)





*********************************************************
** INTERPRETAZIONE DEL MODELLO con RELATIVE RISK RATIO **
*********************************************************

mlogit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere, base(3) rrr





*****************************
** TEST PER CONDIZIONE IIA **
*****************************

mlogit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere, base(3)
est store all

mlogit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere if scelta!=1
est store partial

hausman partial all, alleqs constant

*Il p-value è minore di 0.05: si rifiuta l'ipotesi nulla. Dunque si riscontrano differenze sistematiche nei coefficienti: l'esclusione di una delle scelte (in questo caso l'esclusione di "mobile") viola la condizione IIA.
*Pertanto, poiché la condizione non è verificata, è meglio fare il multinomial probit anziché il multinomial logit.





******************************************************
** VERIFICA DELLA CORRELAZIONE TRA MLOGIT E MPROBIT **
******************************************************

*Verifichiamo se le stime di mlogit e mprobit sono correlate per la modalità "mobile":

mlogit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere
predict pr_mlogit1, outcome(1)

mprobit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere
predict pr_mprobit1, outcome(1)

corr pr_mlogit1 pr_mprobit1
scatter pr_mlogit1 pr_mprobit1



*Verifichiamo se le stime di mlogit e mprobit sono correlate per la modalità "internet":

mlogit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere
predict pr_mlogit2, outcome(2)

mprobit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere
predict pr_mprobit2, outcome(2)

corr pr_mlogit2 pr_mprobit2
scatter pr_mlogit2 pr_mprobit2



*Verifichiamo se le stime di mlogit e mprobit sono correlate per la modalità "punto vendita":

mlogit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere
predict pr_mlogit3, outcome(3)

mprobit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere
predict pr_mprobit3, outcome(3)

corr pr_mlogit3 pr_mprobit3
scatter pr_mlogit3 pr_mprobit3





************************
** MULTINOMIAL PROBIT **
************************

*Eseguiamo il multinomial probit con baseline "ptovendita", modalità più frequente:

mprobit scelta multi emails catalogs reso qta recency Mtot PVtot Itot agenti age genere, base(3)

*Anche qui come baseline abbiamo scelto il canale punto vendita, in quanto è la modalità più frequente. 

*scelta "mobile" vs "ptovendita" --> variabili non significative al 5%: multi, emails, catalogs, agenti, age, genere
*scelta "internet" vs "ptovendita" --> variabili non significative al 5%: catalogs, age, genere





***********************
** EFFETTI MARGINALI **
***********************


*Tabella di "internet" per la variabile emails:

margins, at(emails=(0.072 (2) 8.019))predict(outcome(2))
marginsplot

*All'aumentare del numero medio di emails aumenta la probabilità di scegliere internet, a conferma di quanto osservato nel multinomial probit.



*Tabella di "punto vendita" per la variabile emails:

margins, at(emails=(0.072 (2) 8.019))predict(outcome(3))
marginsplot

*All'aumentare del numero medio di emails non viene influenzata la probabilità di acquistare nei punti vendita.



*Tabella di "internet" per la variabile agenti:

margins, at(agenti=(0 (1) 1))predict(outcome(2))
marginsplot

*Se il cliente viene reclutato da un agente di vendita, la probabilità di acquistare tramite internet è di circa il 6%. Mentre, se il cliente non viene reclutato da un agente di vendita, la probabilità di acquistare tramite internet è di circa il 4%.



*Tabella di "punto vendita" per la variabile agenti:

margins, at(agenti=(0 (1) 1))predict(outcome(3))
marginsplot

*Se il cliente viene reclutato da un agente di vendita, la probabilità di acquistare nei punti vendita è di circa il 54%. Mentre, se il cliente non viene reclutato da un agente di vendita, la probabilità di acquistare nei punti vendita è di circa il 55%. Sostanzialmente, la differenza non è rilevante.


