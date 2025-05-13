The R code implements the Preferred Reporting Items for Systematic reviews and Meta-Analyses (PRISMA) methodology using a thematic query of paper titles and abstracts via API access to Elsevier-SCOPUS with various selection criteria. The specification has been formulated consistent with the relevant literature (see below).

Elsevier-SCOPUS
•	URL: https://api.elsevier.com/content/search/scopus
•	API: 2cd48ad4c32d99e6c9fbfd57251b8a96
o	Obtain your own API key:
	You must have an Elsevier account. Register here for a free account.
	You must use your student email address
	You may already have an account if you have registered with Scopus/ScienceDirect 
	Access the Elsevier Developer Portal. Select the 'I want an API Key' button
	Select 'Create API key' 
	Add a Label for the API
	For Website URL add - (*insert URL here*)

Generating the results requires the sequential execution of two scripts (Part 1 and Part 2) using R Version 4.4.3 or higher:
•	2025_05_13_Part1_SCOPUS.R: generates output file “scopus_results_raw.csv”
•	2025_05_13_Part2_Visual.R: uses the output file above as input file for generating the typical PRISMA representation (flow chart and Sankey diagram)

The current version of these scripts is work-in-progress and reflects the implementation of a PRISMA analysis for scanning relevant literature in support of a research project on infrastructure investment at the Department of Land Economy, University of Cambridge.
Current Search Specification
•	Initial thematic query: (infrastructure*) AND (financ* OR invest* OR capital OR lend*) AND (insurance OR insurer OR pension) AND (regulat* OR prudential OR restrict*)) AND PUBYEAR > 1980 AND PUBYEAR < 2026"  
•	Auto-screening: "infrastructure", "finance", "investment", "insurance"

Use at your own risk. Citation for use of the code would be appreciated. For any questions, get in touch with Andy Jobst (aaj22@cam.ac.uk or Tel. +971-543439374). 

References
D. Moher, A. Liberati, J. Tetzlaff, D.G. Altman, P. Group, Preferred reporting items for systematic reviews and meta-analyses: the PRISMA statement, Ann. Intern. Med. 151 (7) (2009) 264–269, https://doi.org/10.7326/0003-4819-151-4- 200908180-00135.
M.J. Page, J. E. McKenzie, P.M. Bossuyt, I. Boutron, T.C. Hoffmann, C.D. Mulrow, L. Shamseer, J.M. Tetzlaff, E.A. Akl, S.E. Brennan, R. Chou, J. Glanville, J. M. Grimshaw, A. Hróbjartsson, M.M. Lalu, T. Li, E.W. Loder, E. Mayo-Wilson, S. McDonald, D. Moher, The PRISMA 2020 statement: an updated guideline for reporting systematic reviews, BMJ 372 (2021) n71, https://doi.org/10.1136/bmj.n71.   
D. Tranfield, D. Denyer, P. Smart, Towards a methodology for developing evidence-informed management knowledge by means of systematic review, Br. J. Manage. 14 (3) (2003) 207–222, https://doi.org/10.1111/1467-8551.00375.
M. Petticrew, H. Roberts, Systematic Reviews in the Social Sciences: A Practical Guide, John Wiley & Sons, 2008.
C. Pickering, J. Byrne, The benefits of publishing systematic quantitative literature reviews for PhD candidates and other early-career researchers, High. Educ. Res. Dev. 33 (3) (2014) 534–548, https://doi.org/10.1080/07294360.2013.841651. 



# PRISMA
