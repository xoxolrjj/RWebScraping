# Load the required libraries
library(rvest)
library(httr)
library(dplyr) 
library(polite)
library(kableExtra)

polite::use_manners(save_as = 'polite_scrape.R')

url <- 'https://m.imdb.com/chart/toptv/?ref_=nv_tvv_250'

session <- bow(url, user_agent = "Educational")
session

title_show <- character(0)
list_year_ep <-character(0)
 
title_show <- scrape(session) %>%
  html_nodes('h3.ipc-title__text') %>% 
  html_text
 
title_show_only <- as.data.frame(title_show[2:51])
title_show_only
colnames(title_show_only) <- "Rank"

#split the string(rank  title)
show_df <- strsplit(as.character(title_show_only$Rank),".",fixed = TRUE)
show_df <- data.frame(do.call(rbind,show_df))

#rename and delete columns
# deleting columns 3 and 4 since it duplicated the columns
show_df <- show_df[-c(4:3)] 

#renaming column 1 and 2
colnames(show_df) <- c("Rank","Title") 
show_df
 

list_year_ep <- scrape(session) %>%
  html_nodes('span.sc-479faa3c-8.bNrEFi.cli-title-metadata-item
') %>% 
  html_text

 
years_only <- c()
for (i in seq(1, length(list_year_ep), by = 3)) {
  years_only <- c(years_only, list_year_ep[i])
}
Year <- years_only[1:50]
Year

ep_only <- c()
for (i in seq(2, length(list_year_ep), by = 3)) {
  ep_only <- c(ep_only, list_year_ep[i])
}
Episode <- ep_only[1:50]
Episode

df_title_ep <- data.frame(Episode,Year)
colnames(df_title_ep) <- c("Number Of Episodes","Year Released") 

df_title_ep

 
list_rating <- scrape(session) %>%
  html_nodes('span.ipc-rating-star.ipc-rating-star--base.ipc-rating-star--imdb.ratingGroup--imdb-rating') %>% 
  html_text()

wholeRATING <- as.data.frame(list_rating[1:50])
colnames(wholeRATING) <- "Rating"

# Extracting Rating and Vote_Count using regular expressions
wholeRATING$Rating <- gsub("\\s*\\([^)]+\\)\\s*", "", wholeRATING$Rating)
wholeRATING$Vote_Count <- gsub(".*\\(([^)]+)\\)", "\\1", list_rating[1:50])


df_rating_vote <- wholeRATING
colnames(df_rating_vote) <- c("Rating","Vote Count") 
df_rating_vote


 
final_df <- cbind(show_df, df_rating_vote,df_title_ep )

final_df
 
# Print the final dataframe
print(final_df)

  

 