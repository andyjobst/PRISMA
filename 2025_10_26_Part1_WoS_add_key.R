# -----------------------------  
# Automated literature search for Web of Science, PRISMA Part 1
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
# Access to Web of Science: base URL and API key 
# Replace the current API key with your own
# -----------------------------  
api_key <- "[add key]"  
base_url <- "https://api.clarivate.com/apis/wos-starter/v1/documents"  
  
# -----------------------------    
# Define initial thematic query  
query_string <- "TS=((infrastructure*) AND (financ* OR invest*) AND (insur* OR insurance OR pension) AND (regulat* OR prudential OR capital* OR risk)) AND PY=(1980-2025)"  
# -----------------------------  

# -----------------------------  
# Define terms for auto-screening based on relevance  
auto_screen_terms <- c("infrastructure", "financ", "invest", "insur", "regulat", "prudential", "capital")   
# -----------------------------  

# -----------------------------  
# Function to process a single record with additional fields  
# -----------------------------   
process_record <- function(record) {  
  # Extract DOI/URL from 'links' field  
  doi_url <- if (!is.null(record$links$record)) record$links$record else NA  
    
  data.frame(  
    Title = record$title,  
    Year = record$source$publishYear,  
    Citations = record$citations[[1]]$count,  
    Authors = paste(sapply(record$names$authors, function(x) x$displayName), collapse = "; "),  
    Source = record$source$sourceTitle,  
    DOI_URL = doi_url,  
    stringsAsFactors = FALSE  
  )  
}  
  
# -----------------------------  
# Specification of function for rate-limited API requests using exponential back-off
# -----------------------------  
get_page_data <- function(page, limit = 50) {  
  cat(sprintf("Requesting page %d with limit %d\n", page, limit))  
    
  req <- request(base_url) %>%  
    req_headers(  
      "X-ApiKey" = api_key,  
      Accept = "application/json"  
    ) %>%  
    req_url_query(  
      q = query_string,  
      limit = limit,  
      page = page  
    )  
    
  result <- tryCatch({  
    resp <- req %>% req_perform()  
    data <- resp %>% resp_body_json()  
    return(data)  
  }, error = function(e) {  
    cat("Error in get_page_data:", e$message, "\n")  
    return(NULL)  
  })  
    
  return(result)  
}  
  
# -----------------------------    
# Get initial data
# ----------------------------- 
initial_data <- get_page_data(1)  
if (is.null(initial_data)) {  
  stop("Error retrieving initial data. Please check your API credentials and query parameters.")  
}  
  
# -----------------------------   
# Get total records and calculate pages  
# -----------------------------    
total_records <- initial_data$metadata$total  
records_per_page <- initial_data$metadata$limit  
total_pages <- ceiling(total_records / records_per_page)  
  
cat(sprintf("Found %d total records across %d pages\n", total_records, total_pages))  
  
# -----------------------------    
# Process all pages  
# -----------------------------  
all_results <- list()  
for (p in 1:total_pages) {  
  page_data <- get_page_data(p)  
  if (!is.null(page_data)) {  
    # Process each record in the page  
    page_results <- do.call(rbind, lapply(page_data$hits, process_record))  
    all_results[[p]] <- page_results  
    cat(sprintf("Processed page %d of %d\n", p, total_pages))  
  }  
}  
  
# -----------------------------    
# Combine all page results into one dataframe  
# -----------------------------   
results_df <- do.call(rbind, all_results)  
  
# Function to count term occurrences  
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
# Calculate relevance score based on Title only (or Title plus further text if desired)    
results_df$relevance_score <- sapply(results_df$Title, count_terms, terms = auto_screen_terms)  
  
# Calculate auto_include: flag set to 1 if at least one auto-screen term is present in the Title, else 0.  
results_df$auto_include <- ifelse(sapply(results_df$Title, count_terms, terms = auto_screen_terms) > 0, 1, 0)  
  
# Create binary inclusion variable; for now, set it to be the same as auto_include.  
results_df$inclusion <- results_df$auto_include  
  
# -----------------------------    
# Order columns for further use and write the results to output file
# -----------------------------   
col_order <- c(  
  "Title", "Year", "Citations", "Authors", "Source", "DOI_URL",   
  "auto_include", "relevance_score", "inclusion"  
)  
results_df <- results_df[, col_order]  
  
# Write results to CSV  
write.csv(results_df, "wos_results_raw.csv", row.names = FALSE)  
cat("\nFile written: wos_results_raw.csv\n")  
  
# Print summary statistics  
cat("\nSummary Statistics:\n")  
print(summary(results_df[c("Year", "Citations")]))  
cat(sprintf("\nTotal papers retrieved: %d\n", nrow(results_df)))  
cat(sprintf("Auto-included papers: %d\n", sum(results_df$auto_include)))  
  
# Print year distribution  
cat("\nDistribution by Year:\n")  
print(table(results_df$Year))  
  
# Show sample of results  
cat("\nSample of retrieved papers:\n")  
print(head(results_df[, c("Title", "Year", "Citations", "auto_include", "relevance_score", "inclusion")], 10))  