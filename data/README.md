# SRQM: Data

This folder contains the teaching datasets required to follow the [Statistical Reasoning and Quantitative Methods][srqm] (SRQM) course taught by François Briatte and Ivaylo Petev.

[srqm]: http://f.briatte.org/teaching/quanti/

All datasets are provided in the Stata 9/10 `dta` format on an "as-is" basis. Please use the datasets for teaching purposes only, and do not redistribute them.

The teaching datasets were prepared with a [setup script][srqm-data] that runs as described in the [README][srqm-setup] file of the `setup` folder. Each dataset is bundled into a ZIP archive with its codebook and a list of available variables.

[srqm-setup]: https://github.com/briatte/srqm/blob/master/setup/README.md
[srqm-data]: https://github.com/briatte/srqm/blob/master/setup/srqm_data.ado

### Data sources:

| Filename       | Data                                  | Year(s)        |
|:---------------|:--------------------------------------|:---------------|
| `ess2008`      | European Social Survey                | Round 4 (2008) |
| `gss0012`      | General Social Survey                 | 2000-2012      |
| `nhis2009`     | National Health Interview Survey      | 2009           |
| `qog2013`      | Quality of Government                 | 2009 ± 3 years |
| `wvs2000`      | World Values Survey                   | Wave 4 (2000)  |

### Coursework:

Open each dataset with the `use` commands provided in this document. These require that the `SRQM` folder has been set as the working directory, as explained in its [README][srqm-readme] file. Then use the `lookfor` and `lookfor_all` commands to explore the variables. Finally, select one dataset and make a selection of variables relevant to your research project.

Bibliographic information and additional documentation is available from the online data sources. Once you have identified a dataset, retrieve that information to describe its sampling and weighting design. Include a full reference to the data in your paper, including author names, release year, version number and URL to the data website.

Indications on weighting the data with the `svyset` command are provided for point estimation. It is unlikely that you will need to do that yourself, but you should include the weighting scheme in your do-file for reference. Place it right after opening the data with the `use` command mentioned above.

Every single minute that you spend learning about your data by reading the documentation and exploring the variables is a minute well spent. It takes several hours to become sufficiently familiar with any complex data source. Finding and skim-reading a few papers that use the data is good practice.

* * *

## `ess2008`

The `ess2008` dataset holds "[Round 4][ess-round4]" (c. 2008) of the European Social Survey (ESS):

[ess-round4]: http://ess.nsd.uib.no/ess/round4/

> The European Social Survey (the ESS) is an academically-driven social survey designed to chart and explain the interaction between Europe's changing institutions and the attitudes, beliefs and behaviour patterns of its diverse populations.  
<http://www.europeansocialsurvey.org>

### Survey weights:

    use data/ess2008, clear
    svyset [pw = dweight]

See the [ESS weighting guide][ess-weights] for details.

[ess-weights]: http://ess.nsd.uib.no/ess/doc/weighting.pdf

### Production notes:

The dataset was downloaded from the [ESS data server][ess-dl]. In addition to the trimmed variables, a few more variables from the rotating module might also be missing. Check the [cumulative dataset][ess-cumulative] for other ESS survey waves.

[ess-dl]: http://nesstar.ess.nsd.uib.no/
[ess-cumulative]: http://ess.nsd.uib.no/downloadwizard/

* * *

## `gss0012`

The `gss0012` dataset holds data from the U.S. General Social Survey (GSS) for years 2000-2012:

> The GSS contains a standard 'core' of demographic, behavioral, and attitudinal questions, plus topics of special interest. Many of the core questions have remained unchanged since 1972 to facilitate time-trend studies as well as replication of earlier findings.  
<http://www3.norc.org/GSS+Website/>

### Survey weights:

    use data/gss0012, clear
    svyset vpsu [pw = wtssall], strata(vstrat)

See "[Calculating Design-Corrected Standard Errors for the General Social Survey, 1988-2010][gss-pedlow]" by Steven Pedlow and [Appendix A][gss-sampling] of the GSS codebook for details, especially if you plan to use older survey years for which the sampling and weighting design is different.

[gss-pedlow]: http://publicdata.norc.org:41000/gss/documents//OTHR/GSS%20design%20variables.pdf
[gss-sampling]: http://publicdata.norc.org:41000/gss/documents//BOOK/GSS_Codebook_AppendixA.pdf

### Production notes:

The data are extracted from the [GSS 1972-2012 cumulative cross-sectional dataset][gss-source] (Release 1, March 2013).

[gss-source]: http://www3.norc.org/GSS+Website/Download/STATA+v8.0+Format/

* * *

## `nhis2009`

The `nhis2009` dataset holds sample adult data for years 2000--2009 of the U.S. National Health Interview Survey (NHIS):

> The National Health Interview Survey (NHIS) has monitored the health of the nation since 1957. NHIS data on a broad range of health topics are collected through personal household interviews. For over 50 years, the U.S. Census Bureau has been the data collection agent for the National Health Interview Survey. Survey results have been instrumental in providing data to track health status, health care access, and progress toward achieving national health objectives.  
<http://www.cdc.gov/nchs/nhis.htm>

### Survey weights:

    use data/nhis2009.dta, clear
    svyset psu [pw = perweight], strata(strata)

See the [IHIS/NHIS user notes][ihis-var] on variance estimation for more details.

[ihis-var]: http://www.ihis.us/ihis/userNotes_variance.shtml

### Production notes:

The data come from the [Integrated Health Interview Series][ihis] website.

[ihis]: http://www.ihis.us/

* * *

## `qog2013`

The `qog2013` dataset holds the Quality of Government (QOG) Standard dataset in its most recent revision of May 15, 2013 (aggregate data centered around 2009 ± 3 years):

> Our research addresses the questions of how to create and maintain high quality government institutions and how the quality of such institutions influences public policy in a broader sense.  
<http://www.qog.pol.gu.se/>

### Production notes:

The data and codebook come from the [QOG Standard download page][qog-source]. A simpler version of the dataset, [QOG Basic][qog-basic], is also available for students who prefer to work on a more accessible and less extensive version of the data (my own experience is however that QOG Basic is usually too basic).

[qog-source]: http://www.qog.pol.gu.se/data/qogstandarddataset/
[qog-basic]: http://www.qog.pol.gu.se/data/qogbasicdataset/

* * *

## `trust2012`

The `trust2012` dataset holds data provided by John Sides in a personal communication (thanks!). See his post "[What Will Make People Trust Goverment Again?][js]" (_The Monkey Cage_, 14 February 2010).

[js]: http://www.themonkeycage.org/2010/02/what_will_make_people_love_gov.html

The data for change in per capita income come from [Douglas Hibbs][dh]. The data for presidential trust come from the [American National Election Study][anes]. The survey question is:

> How much of the time do you think you can trust the government in Washington to do what is right, just about always, most of the time, or only some of the time?

Trust is measured as the sum of "just about always" and "most of the time" response items.

[dh]: http://douglas-hibbs.com/
[anes]: http://www.electionstudies.org/

### Production notes:

The dataset was not modified.

* * *

## `wvs2000`

The `wvs2000` dataset holds data from "Wave 4" (1999-2004) of the World Values Survey (WVS):

> The World Values Survey (WVS) is a worldwide network of social scientists studying changing values and their impact on social and political life. The WVS in collaboration with EVS (European Values Study) carried out representative national surveys in 97 societies containing almost 90 percent of the world's population. These surveys show pervasive changes in what people want out of life and what they believe. In order to monitor these changes, the EVS/WVS has executed five waves of surveys, from 1981 to 2007.  
<http://www.worldvaluessurvey.org/>

More recent data is currently getting assembled in [Wave 6][wvs-wave6] (2010-2013).

[wvs-wave6]: http://www.wvs-online.com/

### Survey weights:

    use data/wvs2000, clear
    svyset [pw = s017]

See the [WVS weighting guide][wvs-weights] for details.

[wvs-weights]: http://www.jdsurvey.net/jds/jdsurveyActualidad.jsp?Idioma=I&SeccionTexto=0405

### Production notes:

The data come from the [WVS 2000 official file][wvs-file] found at the [WVS website][wvs-source]. This version has encoding issues that are used as examples in class to teach recoding. The [cumulative dataset][wvs-cumulative] has different variable names and proper variable encoding.

[wvs-file]: http://www.asep-sa.org/wvs/wvs2000/wvs2000_v20090914_stata.zip
[wvs-source]: http://www.wvsevsdb.com/wvs/WVSData.jsp
[wvs-cumulative]: http://www.asep-sa.org/wvs/wvs_1981-2008/wvs1981_2008_v20090914_stata.zip

Thanks to William A. Huber for the [code][so] that capitalizes country names.

[so]: http://stackoverflow.com/q/12591056/635806

* * *

Additional data sources are listed on the [course wiki][srqm-wiki]. Many of the sources are less suitable for cross-national than for longitudinal or pooled time series analysis. It is _very highly_ recommended to stick with the teaching datasets if you want to avoid bleeding out hours of data preparation at the very beginning of the course (experience speaks).

[srqm-wiki]: https://github.com/briatte/srqm/wiki/data
