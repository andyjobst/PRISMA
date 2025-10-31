Preferred Reporting Items for Systematic Reviews and Meta-Analyses (PRISMA)

The R scripts in this package implement the Preferred Reporting Items for Systematic Reviews and Meta-Analyses (PRISMA) methodology using a thematic query of research titles and abstracts via API access to Elsevier-SCOPUS and Web of Science with various selection criteria. More specifically, it uses a search query structure with the complex Boolean logic for the relevant scope of coverage to implement to implement API pagination and data retrieval with auto-screening variables. For easy data handing and further analysis creates a comprehensive dataframe with all metadata and supports the generation of common PRIMA-related visualization, including a flow diagram for the screening process of eligible papers and a Sankey diagram of thematic association of papers over time. The specification has been formulated consistent with the relevant literature (Page and others, 2021; Pickering and Byrne, 2013; Moher and others, 2009; Petticrew and Roberts, 2006; Tranfield and others, 2003). 

Generating the results requires the sequential execution of three scripts (Part 1 for each SCOPUS and Web of Science as well as Part 2) using R Version 4.4.3 or higher:
1.	Generate the thematic literature search using SCOPUS: run the script “2025_10_26_Part1_SCOPUS_add_key.R”, which generates output file “scopus_results_raw.csv”
2.	Generate the thematic literature search using Web of Science: run the script “2025_10_26_Part1_WoS_add_key.R”, which generates output file “wos_results_raw.csv”
3.	Consolidate (manually) both output files into a new file “total_results_raw.csv”
4.	Generate the typical PRISMA representation (flow chart and Sankey diagram) by running the script “2025_10_26_Part2_Visualization.R,” which uses the output file (“total_results_raw.csv”) above as input file 

Search Specification and Visualization of Results

The current version of these scripts is work-in-progress and reflects the implementation of a PRISMA analysis for scanning relevant literature in support of a research project on infrastructure investment. The specification of the thematic search query was inspired by the PRISMA implementation on sustainable infrastructure in Meng and others (2024).
Specification of Search Query and Thematic Auto-Screening
•	Initial thematic query: (infrastructure*) AND (financ* OR invest* OR capital OR lend*) AND (insur* OR insurance OR pension) AND (regulat* OR prudential OR capital* OR risk)) AND PUBYEAR > 1980 AND PUBYEAR < 2026"  
•	Auto-screening: "infrastructure", "financ", "invest", "insur", “regulat”, “prudential, “capital”

Visualization of PRISMA Results

The PRISMA flow chart comprises four major steps (see below):
•	Identification: number of relevant articles/papers from keyword search – before and after removing duplicates based on the same DOI/URL (use total paper count)
•	Screening: number of articles/papers based on title/abstract relevance (“auto_include”=1)
•	Eligibility: number of articles/papers based on relevance assess their eligibility (i.e., papers with relevant issues to the topic search are excluded) (“relevance_score”>0)
•	Inclusion: number of papers that most relevant for data extraction and analysis (“inclusion” =1)

The Sankey diagram traces the continuity and emergence of various topics, highlighting shifts in scholarly focus. It illustrates the evolution of key research themes over three distinct time periods: before 2009, 2009–2018, 2019–2022, and most recently (2023-2025). The time periods are populated based on the number of eligible papers in each time period.
•	Theme 1 (“Infrastructure”): “infrastructure”
•	Theme 2 (“Finance”): (“finance” OR “investment” OR “invest”) 
•	Theme 3 (“Insurance”): (“insurance” OR “insurer”) 
•	Theme 4 (“Regulation”): (“regulation” OR “regulatory” OR “prudential”) 
•	Theme 5 (“Sustainability”): (“green” OR “sustainable” OR “sustainability”) 
Figure 1. PRISMA Flow Chart and Sankey Diagram
  
Generating a Personalized API Key

Implementing the search query in SCOPUS and Web of Science requires adding an API Key to each of the R scripts – “2025_10_26_Part1_SCOPUS_add_key.R” and “2025_10_26_Part1_WoS_add_key.R”, which can be obtained by following the instructions below.

Elsevier-SCOPUS
•	URL: https://api.elsevier.com/content/search/scopus
•	Obtain your own API key by following the steps below:
o	You must have an Elsevier account. Register here for a free account.
o	You must use your student email address
o	You may already have an account if you have registered with Scopus/ScienceDirect 
o	Access the Elsevier Developer Portal. Select the “I want an API Key” button
o	Select “Create API Key”
o	Add the API Key in “2025_10_26_Part1_SCOPUS_add_key.R”: api_key <- "[add key]"  

Web of Science
•	URL: https://api.clarivate.com/apis/wos-starter/v1/documents (https://api.clarivate.com/apis/wos-starter/v1) 
•	Obtain your own API key by following the steps below:
o	You must have a Clarivate account. Register here for a free account.
o	You must use your student email address
o	Access the Clarivate Developer Portal. Click on “Applications” in the header menu and select “Register new application”
o	Fill in the form and click on “Register Application”
o	Go to API in the header menu and choose “Web of Science Starter API” and click on it
o	Scroll down to “Applications” and click on “Subscribe”; also click on “Subscribe” in the next dialogue.
o	It will take some time for Clarivate to approve the request. Once approved, the assigned API key appears on the same screen. Click on the little eye you can see the API key. 
o	Add the API Key in “2025_10_26_Part1_WoS_add_key.R”: api_key <- "[add key]"  

Use at your own risk. Citation when using/adapting the code for your own purposes would be appreciated. For any questions, contact Andreas (Andy) Jobst (aaj22@cam.ac.uk, Tel. +971-543439374; https://papers.ssrn.com/sol3/cf_dev/AbsByAuth.cfm?per_id=337763 and https://www.linkedin.com/in/andyjobst/). 

References

Meng, Jiayin, Zhen Ye and Ying Wang, 2024, “Financing and Investing in Sustainable Infrastructure: A Review and Research Agenda,” Sustainable Futures, Vol. 8, 100312, available at https://doi.org/10.1016/j.sftr.2024.100312

Moher, David, Alessandro Liberati, Jennifer Tetzlaff, and Douglas G. Altman, 2009, “Preferred Reporting Items for Systematic Reviews and Meta-Analyses: The PRISMA Statement,” Annals of Internal Medicine, Vol. 151, No. 4, pp. 264-69, available at https://www.bmj.com/content/bmj/339/bmj.b2535.full.pdf

Page, Matthew J., Joanne E. McKenzie, Patrick M. Bossuyt, Isabelle Boutron, Tammy C. Hoffmann, Cynthia D. Mulrow, Larissa Shamseer, Jennifer M. Tetzlaff, Elie A. Akl, Sue E. Brennan, Roger Chou, Julie Glanville, Jeremy M. Grimshaw, Asbjørn Hróbjartsson, Manoj M. Lalu, Tianjing Li, Elizabeth W. Loder, Evan Mayo-Wilson, Steve McDonald, Luke A. McGuinness, Lesley A. Stewart, James Thomas, Andrea C. Tricco, Vivian A. Welch, Penny Whiting, David Moher, 2021, “The PRISMA 2020 Statement: An Updated Guideline for Reporting Systematic Reviews,” International Journal of Surgery, Vol. 88, 105906, available at https://doi.org/10.1016/j.ijsu.2021.105906

Petticrew, Mark and Helen Roberts, 2006. Systematic Reviews in the Social Sciences: A Practical Guide (Oxford: Blackwell Publishing)

Pickering, Catherine and Jason Byrne, 2013, “The benefits of publishing systematic quantitative literature reviews for PhD candidates and other early-career researchers, Higher Education Research and Development, Vol. 33, No. 3, pp. 534-48, available at https://www.tandfonline.com/doi/abs/10.1080/07294360.2013.841651

Tranfield, David, David Denyer and Palminder Smart, 2003, “Towards a Methodology for Developing Evidence-Informed Management Knowledge by Means of Systematic Review,” British Journal of Management, Vol. 14, No. 3, pp. 207-22, https://onlinelibrary.wiley.com/doi/10.1111/1467-8551.00375. 


# PRISMA
