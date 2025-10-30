# -----------------------------  
# Automated literature search for Elsevier-SCOPUS, PRISMA Part 1
# (c) Andreas (Andy) Jobst, aaj22@cam.ac.uk
# Output comprises results of a thematic search together with auto-screening, relevance scoring and manual selection for inclusion
# ----------------------------- 

# -----------------------------  
# Load required packages  
# -----------------------------  
library(httr2)  
library(dplyr)  
library(stringr)  
library(data.table)  
  
# -----------------------------  
# Access to Elsevier-SCOPUS: base URL and API key 
# Replace the current API key with your own
# -----------------------------  
api_key <- "[add key]"  
base_url <- "https://api.elsevier.com/content/search/scopus"  

# -----------------------------    
# Define initial thematic query  
query_string <- "TITLE-ABS-KEY((infrastructure*) AND (financ* OR invest* capital OR lend*) AND (insur* OR insurance OR pension) AND (regulat* OR prudential OR capital* OR risk)) AND PUBYEAR > 1980 AND PUBYEAR < 2026"  
# -----------------------------  

# -----------------------------  
# Define terms for auto-screening based on relevance  
auto_screen_terms <- c("infrastructure", "financ", "invest", "insur", "regulat", "prudential", "capital")   
# -----------------------------  
  
# -----------------------------  
# Function to process a single record with additional fields  
# -----------------------------  
process_record <- function(record) {  
  # Safely extract each field  
  title <- if (!is.null(record$`dc:title`)) record$`dc:title` else NA  
  year <- if (!is.null(record$`prism:coverDate`)) as.numeric(substr(record$`prism:coverDate`, 1, 4)) else NA  
  citations <- if (!is.null(record$`citedby-count`)) as.numeric(record$`citedby-count`) else 0  
  authors <- if (!is.null(record$`dc:creator`)) record$`dc:creator` else NA  
  source <- if (!is.null(record$`prism:publicationName`)) record$`prism:publicationName` else NA  
  doi_url <- if (!is.null(record$`prism:doi`)) record$`prism:doi` else NA  
  abstract <- if (!is.null(record$`dc:description`)) record$`dc:description` else NA  
    
  # Return a dataframe with one row  
  data.frame(  
    Title = title,  
    Year = year,  
    Citations = citations,  
    Authors = authors,  
    Source = source,  
    DOI_URL = doi_url,  
    Abstract = abstract,  
    stringsAsFactors = FALSE  
  )  
}  
  
# -----------------------------  
# Specification of function for rate-limited API requests using exponential back-off
# -----------------------------  
get_page_data <- function(start, count = 25, max_retries = 5) {  
  cat(sprintf("Requesting records starting at %d with count %d\n", start, count))  
  attempt <- 1  
  delay <- 1   # initial delay in seconds  
  repeat {  
    req <- request(base_url) %>%  
      req_headers(  
        "X-ELS-APIKey" = api_key,  
        Accept = "application/json"  
      ) %>%  
      req_url_query(  
        query = query_string,  
        start = start,  
        count = count  
      )  
      
    resp <- req %>% req_perform()  
      
    # If we get a 429 error, use exponential back-off  
    if (resp$status_code == 429) {  
      if (attempt > max_retries) {  
        stop("Maximum re-tries exceeded due to API rate limits.")  
      }  
      cat(sprintf("Rate limit exceeded. Retrying in %d seconds (attempt %d)...\n", delay, attempt))  
      Sys.sleep(delay)  
      attempt <- attempt + 1  
      delay <- delay * 2  
    } else {  
      # If the response is OK, return the JSON content.  
      return(resp %>% resp_body_json())  
    }  
  }  
}  

# -----------------------------    
# Get initial data
# -----------------------------    
initial_data <- get_page_data(0)  
if (is.null(initial_data)) {  
  stop("Error retrieving initial data. Please check your API credentials and query parameters.")  
}  
 
# -----------------------------   
# Get total records and calculate pages  
# -----------------------------  
total_records <- as.numeric(initial_data$`search-results`$`opensearch:totalResults`)  
records_per_page <- 25  
total_pages <- ceiling(total_records / records_per_page)  
  
cat(sprintf("\nFound %d total records across %d pages\n", total_records, total_pages))  

# -----------------------------    
# Process all pages  
# -----------------------------  
all_results <- list()  
for (p in 0:(total_pages - 1)) {  
  start_val <- p * records_per_page  
  page_data <- get_page_data(start_val)  
  if (!is.null(page_data)) {  
    records <- page_data$`search-results`$entry  
    if (!is.null(records)) {  
      page_results <- do.call(rbind, lapply(records, process_record))  
      all_results[[p + 1]] <- page_results  
      cat(sprintf("Processed page %d of %d\n", p + 1, total_pages))  
    }  
  }  
}  

# -----------------------------    
# Combine all page results into one dataframe  
# -----------------------------  
scopus_results <- do.call(rbind, all_results)  
 
# -----------------------------   
# Function to count occurrences of key terms in a text  
# -----------------------------  
count_terms <- function(text, terms) {  
  if (is.na(text) || text == "") return(0)  
  text_lower <- tolower(text)  
  counts <- sapply(terms, function(term) {  
    str_count(text_lower, fixed(term))  
  })  
  sum(counts)  
}  

# -----------------------------  
# Create relevance, auto_screen and inclusion variables   
# -----------------------------  

# Calculate relevance_score - uses the key words from auto screening(title and abstract) for a combined score
scopus_results$relevance_score <- mapply(function(title, abstract) {  
  title_count <- count_terms(title, auto_screen_terms)  
  abstract_count <- count_terms(abstract, auto_screen_terms)  
  title_count + abstract_count  
}, scopus_results$Title, scopus_results$Abstract)  

# Create auto_include variable: 1 if relevance_score > 0, otherwise 0  
scopus_results$auto_include <- ifelse(scopus_results$relevance_score > 0, 1, 0)  
  
# Create inclusion variable: set equal to the auto_include variable subject to manual selection (override)
scopus_results$inclusion <- ifelse(scopus_results$relevance_score > 0, 1, 0)  

# -----------------------------    
# Order columns for further use and write the results to output file
# -----------------------------   
desired_order <- c("Title", "Year", "Citations", "Authors", "Source", "DOI_URL", "Abstract", "auto_include", "relevance_score", "inclusion")  
scopus_results <- scopus_results[, desired_order]  
write.csv(scopus_results, "scopus_results_raw.csv", row.names = FALSE)  
cat("\nFile written: scopus_results_raw.csv\n")  