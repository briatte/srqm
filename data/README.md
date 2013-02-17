# SRQM: Data sources

This file listing covers the datasets distributed as part of the [Statistical Reasoning and Quantitative Methods](http://f.briatte.org/teaching/quanti/) course taught by François Briatte and Ivaylo Petev.

All files are provided in Stata 9/10 `dta` format on an "as-is" basis: please use them for teaching purposes only, and do not redistribute them. Modifications to the original files are listed in [`setup/dataprep.do`](https://github.com/briatte/srqm/blob/master/setup/dataprep.do).

### Data sources:

| Filename       | Data                                  | Year of release               |
|:---------------|:--------------------------------------|:------------------------------|
| `ess2008`      | European Social Survey                | 2008                          |
| `gss2010`      | General Social Survey                 | 2010                          |
| `nhis2009`     | National Health Interview Survey      | 2009                          |
| `qog2011`      | Quality of Government                 | 2011                          |
| `wvs2000`      | World Values Survey                   | 2000                          |

### Coursework:

You are expected to use the `lookfor` and `lookfor_all` commands to explore the course datasets, in order to select a set of variables for analysis in your research project.

Bibliographic information and additional documentation is available from the online data sources. Once you have identified a dataset, retrieve that information to describe and reference the data in your paper.

The Stata `use` commands mentioned in this document require that the `SRQM` folder has been set as the working directory, as explained in its [README](https://github.com/briatte/srqm/blob/master/README.md) file.

Indications on weighting the data with the `svyset` command are provided for point estimation.

* * *

## `ess2008`

The `ess2008` dataset holds [Round 4](http://ess.nsd.uib.no/ess/round4/) (2008) of the European Social Survey (ESS):

> The European Social Survey (the ESS) is an academically-driven social survey designed to chart and explain the interaction between Europe's changing institutions and the attitudes, beliefs and behaviour patterns of its diverse populations.  
<http://www.europeansocialsurvey.org>

### Survey weights:

    use datasets/ess2008, clear
    svyset [aw=dweight]

See the [ESS weighting guide](http://ess.nsd.uib.no/ess/doc/weighting.pdf) for instructions.

### Production notes:

The dataset was created by subsetting the [ESS cumulative dataset](http://ess.nsd.uib.no/downloadwizard/) to Round 4, and then by removing variables with no observations. The codebook was downloaded from the [ESS data](http://ess.nsd.uib.no/) website. A few variables from the ESS 4 rotating module on welfare attitudes are missing.

* * *

## `gss2010`

The `gss2010` dataset holds data from the U.S. General Social Survey (GSS) for years 2000-2010:

> The GSS contains a standard 'core' of demographic, behavioral, and attitudinal questions, plus topics of special interest. Many of the core questions have remained unchanged since 1972 to facilitate time-trend studies as well as replication of earlier findings.  
<http://www3.norc.org/GSS+Website/>

### Survey weights:

    use datasets/gss2010, clear
    svyset vpsu [pw=wtssall], strata(vstrata)

See "[Calculating Design-Corrected Standard Errors for the General Social Survey, 1988-2010](http://publicdata.norc.org:41000/gss/documents//OTHR/GSS%20design%20variables.pdf)" by Steven Pedlow and [Appendix A](http://publicdata.norc.org:41000/gss/.%5CDocuments%5CCodebook%5CA.pdf) of the GSS codebook for other options.

### Production notes:

The dataset is a trimmed-down version of the [GSS 1972-2010 cumulative cross-sectional dataset](http://www3.norc.org/GSS+Website/Download/STATA+v8.0+Format/) (Release 2, Feb. 2012). A mock codebook is bundled with the data extract.

* * *

## `nhis2009`

The `nhis2009` dataset holds sample adult data for years 2000--2009 of the U.S. National Health Interview Survey (NHIS):

> The National Health Interview Survey (NHIS) has monitored the health of the nation since 1957. NHIS data on a broad range of health topics are collected through personal household interviews. For over 50 years, the U.S. Census Bureau has been the data collection agent for the National Health Interview Survey. Survey results have been instrumental in providing data to track health status, health care access, and progress toward achieving national health objectives.  
<http://www.cdc.gov/nchs/nhis.htm>

### Survey weights:

    use "Datasets/nhis2009.dta", clear
    svyset psu [pweight=perweight], strata(strata)

See the [IHIS/NHIS user notes](http://www.ihis.us/ihis/userNotes_variance.shtml) on variance estimation for more details.

### Production notes:

The data come from the [Integrated Health Interview Series](http://www.ihis.us/) website. A mock codebook is bundled with the data extract.

* * *

## `qog2011`

The `qog2011` dataset holds the Quality of Government (QOG) Standard dataset in its most recent revision of April 6, 2011:

> Our research addresses the questions of how to create and maintain high quality government institutions and how the quality of such institutions influences public policy in a broader sense.  
<http://www.qog.pol.gu.se/>

### Production notes:

The data and codebook come from the [QOG Standard download page](http://www.qog.pol.gu.se/data/qogstandarddataset/). A simpler version of the dataset, [QOG Basic](http://www.qog.pol.gu.se/data/qogbasicdataset/), is also available for students who prefer to work on a more accessible and less extensive version of the data.

* * *

## `wvs2000`

The `wvs2000` dataset holds data from Wave 4 (1999-2004) of the World Values Survey (WVS):

> The World Values Survey (WVS) is a worldwide network of social scientists studying changing values and their impact on social and political life. The WVS in collaboration with EVS (European Values Study) carried out representative national surveys in 97 societies containing almost 90 percent of the world's population. These surveys show pervasive changes in what people want out of life and what they believe. In order to monitor these changes, the EVS/WVS has executed five waves of surveys, from 1981 to 2007.  
<http://www.worldvaluessurvey.org/>

### Survey weights:

    use datasets/wvs2000, clear
    svyset [aw=s017]

See the [WVS weighting guide](http://www.jdsurvey.net/jds/jdsurveyActualidad.jsp?Idioma=I&SeccionTexto=0405) for other options.

### Production notes:

The data come from the [WVS 2000 official file](http://www.asep-sa.org/wvs/wvs2000/wvs2000_v20090914_stata.zip) found at the [WVS website](http://www.wvsevsdb.com/wvs/WVSData.jsp). This version had encoding issues that are used as examples in class for recode commands. The [cumulative dataset](http://www.asep-sa.org/wvs/wvs_1981-2008/wvs1981_2008_v20090914_stata.zip) has different variable names and proper variable encoding. More recent data is also available up to [Wave 6](http://www.wvs-online.com/) (2010-2013). A mock codebook is bundled with the data.

* * *

[Additional data sources](https://github.com/briatte/srqm/wiki/Data) are listed on the course wiki; note that many sources are less suitable for cross-national than for longitudinal or pooled time series analysis.