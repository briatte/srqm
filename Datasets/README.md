# SRQM: Data sources

This file listing covers the datasets distributed as part of the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) course taught by François Briatte and Ivaylo Petev.

All datasets are provided in `dta` Stata format on an "as-is" basis. Please use these datasets for replication purposes only and do not redistribute them for any other reason.

Please also remember to **systematically cite the data source and authors**, after retrieving the bibliographic information from the source and formatting it as required by academic standards.

### Data sources:

| Filename		 | Data							         | Author/Year of release		 |
|:---------------|:--------------------------------------|:------------------------------|
| `ebm2009`		 | Eurobarometer Special Report			 | 2009							 |
| `ess2008`		 | European Social Survey				 | 2008							 |
| `gss2010`		 | General Social Survey				 | 2010							 |
| `lobbying2010` | 'Lobbying and Policy Change'		 	 | (Baumgartner *et al.* 2010)	 |
| `nhis2009`	 | National Health Interview Survey		 | 2009							 |
| `qog2011`		 | Quality of Government				 | 2011							 |
| `trust2012`	 | 'Bread and Peace'					 | (Hibbs 2012)					 |
| `wvs2000`		 | World Values Survey					 | 2000							 |

### Other sources:

A selection of other sources is shown at the end of this document. Please remember that other sources are allowed for research projects *iif* -- if and only if -- you can quickly show *skills in data management*.

### Usage commands:

The Stata commands included at the end of each dataset description require that the `SRQM` folder has been set as the working directory, as explained in a separate [README](https://github.com/briatte/srqm/blob/master/README.md) file.

* * *

## ebm2009

The `ebm2009` dataset holds data from the Special Eurobarometer, [Ref. 311](http://ec.europa.eu/public_opinion/archives/eb_special_320_300_en.htm), Wave 71.1 (2009), on "Europeans and the Economic crisis":

> Special Eurobarometer reports are based on in-depth thematical studies carried out for various services of the European Commission or other EU Institutions and integrated in Standard Eurobarometer's polling waves. Reproduction is authorized, except for commercial purposes, provided the source is acknowledged.  
<http://ec.europa.eu/public_opinion/archives/eb_special_en.htm>

### Selected documentation:

- [Survey analysis][ebm2009_analysis] by the European Commission (2009)
- [Sample factsheet (descriptive results) for Greece][ebm2009_greece] (2009)

[ebm2009_analysis]: http://ec.europa.eu/public_opinion/archives/ebs/ebs_311_summary.zip "ZIP"
[ebm2009_greece]: http://ec.europa.eu/public_opinion/archives/ebs/ebs_311_factsheets_en.zip "ZIP"

### Usage in Stata:

	use "Datasets/ebm2009.dta", clear

* * *

## ess2008

The `ess2008` dataset holds Round 4 (2008) of the European Social Survey (ESS):

> The European Social Survey (the ESS) is an academically-driven social survey designed to chart and explain the interaction between Europe's changing institutions and the attitudes, beliefs and behaviour patterns of its diverse populations.  
<http://www.europeansocialsurvey.org>

### Selected documentation:

- [ESS description brochure][ess2008_brochure]
- [ESS4 questionnaire][ess2008_questionnaire] (2008)
- [ESS4 documentation (survey design) report][ess2008_survey] (2011)
- [ESS1--4 variable list][ess2008_variables]
- [ESS guide to survey weights][ess2008_weights]

[ess2008_brochure]: http://www.europeansocialsurvey.org/index.php?option=com_docman&task=doc_download&gid=118&itemid=80 "PDF"
[ess2008_questionnaire]: http://ess.nsd.uib.no/streamer/?module=main&year=2009&country=&download=%5CFieldwork+documents%5C2009%5C01%23ESS4+-+Main+questionnaire+%28including+interviewer%27s+form%29%5C.%5CESS4Source_Mainquestionnaire.pdf "PDF"
[ess2008_survey]: http://ess.nsd.uib.no/streamer/?module=main&year=2009&country=null&download=%5CSurvey+documentation%5C2009%5C01%23ESS4+-+ESS4-2008+Documentation+Report%2C+ed.+4.0%5CLanguages%5CEnglish%5CESS4DataDocReport_4.0.pdf "PDF"
[ess2008_variables]: http://ess.nsd.uib.no/streamer/?module=main&year=2009&country=null&download=%5CSurvey+documentation%5C2009%5C05%23ESS4+-+Appendix4%2C+Variable+lists%2C+ed.+4.0%5CLanguages%5CEnglish%5CESS4AppendixA4e04_0.pdf "PDF"
[ess2008_weights]: http://ess.nsd.uib.no/streamer/?module=main&year=2009&country=null&download=%5CSurvey+documentation%5C2009%5C07%23ESS4+-+Weighting+ESS+Data%5CLanguages%5CEnglish%5CWeightingESS.pdf "PDF"

### Usage in Stata:

	use "Datasets/ess2008.dta", clear

The dataset was created by subsetting the ESS cumulative dataset to Round 4, and then by removing variables with no observations. The code follows:

	drop if essround != 4

	foreach v of varlist * {
		qui count if !mi(`v')
		if r(N)==0 {
			di "Dropping: " "`v'"
			drop `v'
		}
	}
	
	save ess2008.dta, replace

* * *

## gss2010

The `gss2010` dataset holds data from the U.S. General Social Survey (GSS) for year 2010:

> The GSS contains a standard 'core' of demographic, behavioral, and attitudinal questions, plus topics of special interest. Many of the core questions have remained unchanged since 1972 to facilitate time-trend studies as well as replication of earlier findings.  
<http://www3.norc.org/GSS+Website/>

### Selected documentation:

- [GSS variable lists](http://sda.berkeley.edu/D3/GSS10/Docyr/gs10.htm) (online)
- [Guide to weighting GSS data][gss2010_weights] (GSS Codebook, Appendix A)
- Stata codebook (for quicker access to variable codings; see "Usage" below)

[gss2010_weights]: http://publicdata.norc.org:41000/gss/Documents/Codebook/A.pdf "PDF"

### Usage in Stata:

	use "Datasets/gss2010.dta", clear

The dataset is a subset from the [GSS 1972-2010 cross-sectional cumulative dataset](http://www3.norc.org/GSS+Website/Download/STATA+v8.0+Format/) (Release 1.1, Feb. 2011). The code used to trim the data and to export the Stata codebook follows:

	// Subset.
	keep if year==2010
	
	// Remove empty variables.
	foreach v of varlist * {
		qui su `v'
		if r(N)==0 {
		di "Removing " "`v'"
		drop `v'
		}
	}
	save gss2010.dta, replace

	// Export codebook.
	log using gss2010_codebook.log, name(gss2010) replace
	d
	codebook
	log close gss2010
	
* * *

## lobbying2010

The `lobbying2010` dataset contains the variables required to replicate part of the analysis published in Frank R. Baumgartner, Jeffrey M. Berry, Marie Hojnacki, David C. Kimball and Beth L. Leech, *[Lobbying and Policy Change. Who Wins, Who Loses, and Why](http://www.unc.edu/~fbaum/books/lobby/lobbying.htm)* (University of Chicago Press, 20009).

### Selected documentation:

- [Advocacy and Public Policymaking](http://lobby.la.psu.edu/) (online)
- [Issue-level codebook][lobbying2010_codebook] (2010)

[lobbying2010_codebook]: http://www.unc.edu/~fbaum/books/lobby/_documentation/data/Issue_level_codebook_24_August_2010.pdf "PDF"

The issue-level dataset is used in Chapter 5 of the book.

* * *

## nhis2009

The `nhis2009` dataset holds data for years 2000--2009 of the U.S. National Health Interview Survey (NHIS):

> The National Health Interview Survey (NHIS) has monitored the health of the nation since 1957. NHIS data on a broad range of health topics are collected through personal household interviews. For over 50 years, the U.S. Census Bureau has been the data collection agent for the National Health Interview Survey. Survey results have been instrumental in providing data to track health status, health care access, and progress toward achieving national health objectives.  
<http://www.cdc.gov/nchs/nhis.htm>

### Selected documentation:

- [Description brochure][nhis2009_brochure] (2010)
- [Description of NHIS 2009][nhis2009_description] (2010)

[nhis2009_brochure]: http://www.cdc.gov/nchs/data/nhis/brochure2010January.pdf "PDF"
[nhis2009_description]: ftp://ftp.cdc.gov/pub/health.../nchs/dataset.../nhis/2009/srvydesc.pdf "PDF"

### Usage in Stata:

	use "Datasets/nhis2009.dta", clear

If you want to use the data with individual weights, the code should probably look like this:

	svyset psu [pweight=perweight], strata(strata) vce(linearized) singleunit(missing)

* * *

## qog2011

The `qog2011` dataset holds the Quality of Government (QOG) Standard dataset in its most recent revision of April 6, 2011:

> Our research addresses the questions of how to create and maintain high quality government institutions and how the quality of such institutions influences public policy in a broader sense.  
<http://www.qog.pol.gu.se/>

### Selected documentation:

- [QOG Annual report][qog2011_annualreport] (2011)
- [QOG Standard codebook][qog2011_codebook] (2011)

[qog2011_annualreport]: http://www.qog.pol.gu.se/digitalAssets/1372/1372076_qog_annualreport_2011.pdf "PDF"
[qog2011_codebook]: http://www.qog.pol.gu.se/digitalAssets/1358/1358062_qog_codebook_v6apr11.pdf "PDF"

### Usage in Stata:

	use "Datasets/qog2011.dta", clear

A simpler version of the dataset, [QOG Basic](http://www.qog.pol.gu.se/data/qogbasicdataset/), is also available for students who prefer to work on a more accessible and less extensive version of the data.

* * *

## trust2012

The `trust2012` dataset contains the variables required to replicate Douglas Hibbs' 'Bread and Peace' model of the U.S. presidential election:

> Aggregate votes for president in postwar elections are well explained by just two fundamental determinants: (1) weighted-average growth of per capita real disposable personal income over the term, and (2) cumulative US military fatalities owing to unprovoked, hostile deployments of American armed forces in foreign conflicts.  No other objectively measured, exogenous factor systematically affects postwar aggregate votes for president.  
<http://www.douglas-hibbs.com/Election2012/2012Election-MainPage.htm>

<!-- The following figure summarizes the main relationship explored by the model:

![Main figure from John Sides' blog post](http://www.themonkeycage.org/trusteconomy-thumb.png) -->

### Selected documentation:

- Douglas Hibbs, "[The 2012 US Presidential Election: Implications of the ‘Bread and Peace’ Model For Obama’s Re-election Prospects as of 2011:q4][trust2012_paper]", 29 February 2012 (with [slides][trust2012_slides] material).

[trust2012_paper]: http://www.douglas-hibbs.com/Election2012/2012Election-MainPage.htm "HTML"
[trust2012_slides]: http://www.douglas-hibbs.com/Election2012/HIBBS-SLIDES-PCS-2012-02-29.pdf "PDF"

### Usage in Stata:

	use "Datasets/trust2012.dta", clear

The data were kindly provided by John Sides, following his blog post "[What Will Make People Trust Goverment Again?](http://themonkeycage.org/blog/2010/02/14/what_will_make_people_love_gov/)" published at *The Monkey Cage* on February 14, 2010.

* * *

## wvs2000

The `wvs2000` dataset holds data from the 1999-2004 wave of the World Values Survey (WVS):

> The World Values Survey (WVS) is a worldwide network of social scientists studying changing values and their impact on social and political life. The WVS in collaboration with EVS (European Values Study) carried out representative national surveys in 97 societies containing almost 90 percent of the world's population. These surveys show pervasive changes in what people want out of life and what they believe. In order to monitor these changes, the EVS/WVS has executed five waves of surveys, from 1981 to 2007.  
<http://www.worldvaluessurvey.org/>

### Selected documentation:

- [Full questionnaire of all WVS waves][wvs2000_questionnaire] (1981-2008)
- [Questionnaire for Egypt][wvs2000_egypt] (2000)

[wvs2000_questionnaire]: http://www.asep-sa.org/wvs/wvs_1981-2008/WVS_1981-2008_IntegratedQuestionnaire.pdf "PDF"
[wvs2000_egypt]: http://www.wvsevsdb.com/wvs/WVSDocumentation.jsp?Idioma=I

### Usage in Stata:

	use "Datasets/wvs2000.dta", clear

The data were extracted from the WVS cumulative dataset. The code to capitalize country names was kindly provided at [StackOverflow](http://stats.stackexchange.com/questions/8234/capitalizing-value-labels-in-stata) by William A. Huber.

* * *

## Sources

The following list was inspired by Robert J. Franzese, Jr., “[Empirical Strategies for Various Manifestations of Multilevel Data](http://pan.oxfordjournals.org/cgi/content/short/13/4/430),” *Political Analysis* 13:430–446, 2005; Paul Pennings *et al.*, *Doing Research in Political Science: An Introduction to Comparative Methods and Statistics*, Sage, 2005; Berenica Vejvoda, “[Selected Data Resources for Political Science Research](http://libraries.ucsd.edu/ssds/polhon.pdf),” UC San Diego [Social Science Data Services](http://libraries.ucsd.edu/ssds/); [Emiliano Grossman and Nicolas Sauger](http://emiliano-grossman.webou.net/hoprubrique.php?id_rub=26); friends, students, colleagues, etc.

More sources can be identified using websites like CKAN, the [Council of European Social Science Data Archives](http://www.cessda.org/), [DataMarket](http://datamarket.com/), [IPSAportal](http://ipsaportal.unina.it/?cat=16), the [Macro Data Guide](http://www.nsd.uib.no/macrodataguide/) and data libraries from your home universities (see e.g. the [Data Libary](http://www.ed.ac.uk/schools-departments/information-services/services/research-support/data-library) at the University of Edinburgh).

### Intergovernmental organizations

- [Eurostat](http://epp.eurostat.ec.europa.eu/portal/page/portal/eurostat/home/)
- [International Monetary Fund](http://www.imf.org/external/data.htm) (IMF)
- [World Bank](http://data.worldbank.org/) ([World Development Indicators](http://data.worldbank.org/indicator))
- [OECD](http://www.oecd.org/) ([OECD Health](http://www.oecd.org/health/healthdata), [OECD Social Expenditure](http://www.oecd.org/els/social/expenditure))
- [ILO](http://www.ilo.org/dyn/lfsurvey/lfsurvey.home) (labour force surveys)
- [United Nations](http://data.un.org/) ([Statistics Division](http://unstats.un.org/unsd/databases.htm), [Millennium Development Goals](http://mdgs.un.org/))
-  [World Health Organization](http://data.euro.who.int/) (WHO) ([Global Health Observatory](http://www.who.int/gho/en/), [WHO Health for All Database](http://data.euro.who.int/hfadb/)); [Gapminder](http://www.gapminder.org/) (excellent graphing)

### Nongovermental organizations

- [Freedom House](http://www.freedomhouse.org/template.cfm?page=274) (freedom of the press)
- [Reporters Without Borders](http://en.rsf.org/) (Press Freedom Index)
- [Transparency International](http://www.transparency.org/policy_research/surveys_indices) (corruption perception indexes)

### National providers

- United Kingdom:
	- [Office of National Statistics](http://www.statistics.gov.uk/hub/index.html) (ONS)
	- [UK Data Archive](http://www.data-archive.ac.uk/), browsable at [ESDS](http://www.esds.ac.uk/); see e.g. [British Social Attitudes](http://www.britsocat.com/) (BSA) or [British Household Panel Survey](http://www.iser.essex.ac.uk/survey/bhps) (BHPS)
	- [Survey Question Bank](http://www.surveynet.ac.uk/) (ESRC Survey Resources Network)
- United States:
	- [Census Bureau](http://www.census.gov/)
	- [General Social Survey](http://www.norc.org/GSS/GSS+Resources.htm) (GSS)
	- [American National Election Studies](http://www.electionstudies.org/) (ANES)
	- [Federal Reserve](http://research.stlouisfed.org/fred2/) (U.S. economic time series)
	- [Pew Research Center for the People & the Press](http://people-press.org/)
	- [Pew Research Center's Social & Demographic Trends](http://pewsocialtrends.org/)
	- [Cultural Policy & the Arts National Data Archive](http://www.cpanda.org/) (CPANDA)
- France:
	- [INSEE](http://www.insee.fr/) (very large and detailed data)
	- [Réseau Quételet](http://www.reseau-quetelet.cnrs.fr/spip/) (strict access conditions)

### Comparative politics

- [Parties and elections](http://www.parties-and-elections.de/) (elections and political parties in Europe since 1945)
- [Comparative political data sets](http://www.ipw.unibe.ch/mitarbeiter/ru_armingeon/CPD_Set_en.asp) (politics and expenditures in OECD and European countries)
- [ICPSR](http://www.icpsr.umich.edu/) (includes comparative datasets used by American political scientists)
- [IPU](http://www.ipu.org/) (parliaments and electoral systems)
- [Worldwide Elections](http://sshl.ucsd.edu/election/world.html) (electoral competition and outcomes)
- [Comparative Study of Electoral Systems](http://www.umich.edu/~cses/)
- [Comparative Manifestos](http://www.wzb.eu/zkd/dsl/pdf/manifesto-project.pdf) (pools parties’ election manifestos by election across several democracies)
- [Quality of Government](http://www.qog.pol.gu.se/) (used in course)
- [Polity IV](http://www.systemicpeace.org/polity/polity4.htm) (regime characteristics and transitions)
- [Comparative Policy Agendas](http://www.comparativeagendas.org/) (initially an [American project](http://www.policyagendas.org/))

### Comparative public opinion

- [Afrobarometers](http://www.afrobarometer.org/)
- [Eurobarometers](http://ec.europa.eu/public_opinion/index_en.htm) (EB)
- [European Social Survey](http://www.europeansocialsurvey.org/) (ESS) (used in course)
- [European Values Surveys](http://www.europeanvaluesstudy.eu/) (EVS) -- see [download guide](http://www.europeanvaluesstudy.eu/evs/data-and-downloads/manual_EVS_Zacat.pdf)
- [International Social Survey Program](http://www.issp.org/) (ISSP)
- [World Values Surveys](http://www.worldvaluessurvey.org/) (WVS)

### International relations

- [SIPRI](http://databases.sipri.se/) (Stockholm International Peace Research Institute; world armament and disarmament)
- [Correlates of War](http://www.correlatesofwar.org/) (includes Militarized Interstate Disputes)
