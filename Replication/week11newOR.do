* ===============
* = ODDS RATIOS =
* ===============


* Odds ratios are common in biostatistics, where analysts are often interested
* in calculating the risk ratio of exposure to a given pathological factor. We
* used the odds ratios here to change our initial perspective on the variable:
* instead of measuring opposition to torture, the odds ratios above relate to
* supporters of torture among those exposed to TV news, as compared to support
* among unexposed respondents.


* Simple example
* --------------

tab torture media

* Handiest way to get odds:
tabodds torture media // shows the odds of being a 'case' instead of a 'control'
tabodds torture media, ciplot ///
	name(tabodds1, replace)
	
* Odds ratios:
tabodds torture media, or base(1) // odds ratio against lo media exposure
tabodds torture media, or base(2) // odds ratio against hi media exposure

* Save the crosstabulated frequencies to a matrix.
tab torture media, col nof exact matcell(odds)

* Build an odds-ratios statement.
di as txt _n "Respondents with low political TV news exposure were about " ///
	round((odds[2,1]*odds[1,2])/(odds[1,1]*odds[2,2]),.01) " times " ///
	_n "less likely to systematically support torture than other respondents."

* Simple logistic regression provides the same result, except it uses log-odds
* to simplify interpretation: negative log-odds are odds under 1, i.e. lesser
* likelihood, while positive log-odds indicvate higher likelihood.
logit torture media
logit torture media, or     // odds ratio against lo media exposure
logit torture ib1.media, or // odds ratio against hi media exposure


* Complex example
* ---------------

tab torture income4

* Odds across income deciles.
tabodds torture income, ciplot ///
	yti("Odds of opposing torture") xti("HH income deciles") ///
	xlab(1 "Lowest" 10 "Highest") ///
	name(tabodds2, replace)

* Smoother results with less income granularity.
tabodds torture income4, ciplot ///
	yti("Odds of opposing torture") xti("HH income quartiles") ///
	xlab(1 "Lowest" 4 "Highest") ///
	name(tabodds3, replace)
