# -----------------------------  
# Automated literature search for Elsevier-SCOPUS and World of Science, PRISMA Part 2
# (c) Andreas (Andy) Jobst, aaj22@cam.ac.uk
# Uses the results from the thematic search to produce a flow chart and Sankey diagram
# -----------------------------  

# -----------------------------  
# Install and load required packages  
# -----------------------------  
required_packages <- c("networkD3", "dplyr", "stringr", "htmlwidgets", "DiagrammeR")  
for(pkg in required_packages){  
  if (!require(pkg, character.only = TRUE)){  
    install.packages(pkg)  
    library(pkg, character.only = TRUE)  
  }  
}  
library(networkD3)  
library(dplyr)  
library(stringr)  
library(htmlwidgets)  
library(DiagrammeR)  
  
# -----------------------------  
# Load data
# -----------------------------  
df <- read.csv("total_results_raw.csv", encoding = "UTF-8")  
  
# -----------------------------  
# PRISMA Flow Diagram Calculations  
# -----------------------------  
total_papers <- nrow(df)  
after_dup <- nrow(df[!duplicated(df$DOI_URL), ])  
dedup_df <- df[!duplicated(df$DOI_URL), ]  
auto_screened <- nrow(subset(dedup_df, auto_include == 1))  
eligible <- nrow(subset(dedup_df, auto_include == 1 & relevance_score > 0))  
# For demonstration we assume that inclusion means eligible papers are included.  
# Adjust this if you have a different "included" definition:  
included <- eligible   
  
# Create PRISMA flow diagram 
prisma_code <- sprintf('  
digraph G {  
    rankdir=TB;  
    node [shape=box, style="rounded, filled", fillcolor="#ACE0F9", fontname="Helvetica", fontsize=10];  
      
    A [label="Records identified through\ndatabase searching\n(n = %d)"];  
    B [label="Records after\nduplicates removed\n(n = %d)"];  
    C [label="Records after\nauto-screening\n(n = %d)"];  
    D [label="Records eligible\n(n = %d)"];  
    E [label="Studies included\n(n = %d)"];  
      
    A -> B -> C -> D -> E;  
}', total_papers, after_dup, auto_screened, eligible, included)  
  
prisma_flow <- DiagrammeR::grViz(prisma_code)  
htmlwidgets::saveWidget(prisma_flow, "prisma_flow_diagram.html", selfcontained = FALSE)  
print(prisma_flow)  
  
# -----------------------------  
# Create Sankey diagram  
# -----------------------------  
# Filter eligible papers (auto_include == 1 & relevance_score > 0)  
eligible_df <- subset(df, auto_include == 1 & relevance_score > 0)  
  
# Define ordered time periods  
time_periods <- c("Previous Years", "2009-18", "2019-2022", "2023-2025")  
# Define themes, including "Other"  
themes <- c("Infrastructure", "Finance", "Insurance", "Regulation", "Sustainability", "Other")  
  
# Create theme classifications based on Title content  
eligible_df <- eligible_df %>%  
  mutate(theme = case_when(  
    str_detect(tolower(Title), "infrastructure") ~ "Infrastructure",  
    str_detect(tolower(Title), "finance|investment|invest") ~ "Finance",  
    str_detect(tolower(Title), "insurance|insurer") ~ "Insurance",  
    str_detect(tolower(Title), "regulation|regulatory|prudential") ~ "Regulation",  
    str_detect(tolower(Title), "green|sustainable|climate|sustainability") ~ "Sustainability",  
    TRUE ~ "Other"  
  ))  
  
# Create time periods using the Year column  
eligible_df <- eligible_df %>%  
  mutate(time_period = case_when(  
    Year < 2009 ~ "Previous Years",  
    Year >= 2009 & Year <= 2018 ~ "2009-18",  
    Year >= 2019 & Year <= 2022 ~ "2019-2022",  
    Year >= 2023 ~ "2023-2025"  
  ))  
  
# Ensure time_period is a factor with the specified order  
eligible_df$time_period <- factor(eligible_df$time_period, levels = time_periods)  
  
# Create nodes for Sankey diagram: first the time_periods (left), then themes (right)  
nodes <- data.frame(  
  name = c(time_periods, themes)  
)  
  
# Aggregate counts to create links: from time period to theme.  
links <- eligible_df %>%  
  group_by(time_period, theme) %>%  
  summarise(value = n(), .groups = 'drop') %>%  
  mutate(  
    source = as.numeric(factor(time_period, levels = time_periods)) - 1,  # 0-indexing  
    target = match(theme, themes) - 1 + length(time_periods)              # shift theme indices  
  ) %>%  
  select(source, target, value)  
  
links <- as.data.frame(links)  
nodes <- as.data.frame(nodes)  
  
# Create node colors:  
# Time periods: red gradient; Themes: fixed colors.  
time_colors <- colorRampPalette(c("#ffcccc", "#ff3333"))(length(time_periods))  
theme_colors <- c("#8B4513", "#ADD8E6", "#0000FF", "#00008B", "#008000", "#999999")  
node_colors <- c(time_colors, theme_colors)  
color_scale_str <- paste0('d3.scaleOrdinal().range(["', paste(node_colors, collapse = '","'), '"])')  
  
# Create the Sankey diagram using networkD3  
sankey_diagram <- sankeyNetwork(  
  Links = links,  
  Nodes = nodes,  
  Source = "source",  
  Target = "target",  
  Value = "value",  
  NodeID = "name",  
  fontSize = 12,  
  nodeWidth = 30,  
  height = 500,  
  width = 800,  
  colourScale = color_scale_str  
)  
  
# Display the Sankey diagram  
print(sankey_diagram)  
htmlwidgets::saveWidget(sankey_diagram, "sankey_all_papers.html", selfcontained = FALSE)  
  
# -----------------------------  
# Final Diagnostic Output  
# -----------------------------  
cat("\nFinal Diagnostic Information:\n")  
cat("PRISMA Flow counts:\n")  
cat(sprintf("Total papers: %d\n", total_papers))  
cat(sprintf("After duplicates removed: %d\n", after_dup))  
cat(sprintf("After auto-screening: %d\n", auto_screened))  
cat(sprintf("Eligible papers: %d\n", eligible))  
cat(sprintf("Included papers: %d\n", included))  
  
cat("\nSankey Diagram Data:\n")  
cat("Nodes (", nrow(nodes), "):\n")  
print(nodes)  
cat("Links (", nrow(links), "):\n")  
print(head(links))  