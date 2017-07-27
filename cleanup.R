library(magrittr)
library(tidyverse)
library(feather)

# df <- read_csv("~/Documents/nsf_nlp/out.csv")
df <- read_feather("~/Documents/nsf_nlp/out.feather")
# write_feather(df, "~/Documents/nsf_nlp/out.feather")


# cleanup 

# get the directorates correct
df$directorate %<>% factor
df %<>%
  mutate(directorate = forcats::fct_recode(directorate,
    "Directorate for Engineering" = "Directorate For Engineering",
    "Direct For Biological Sciences" = "Directorate for Biological Sciences",
    "Office Of The Director" = "OFFICE OF THE DIRECTOR",
    "Direct For Social, Behav & Economic Scie" = "Directorate for Social, Behavioral & Economic Sciences",
    "Directorate for Geosciences" = "Directorate For Geosciences",
    "Direct For Mathematical & Physical Scien" = "Directorate for Mathematical & Physical Sciences",
    "Direct For Computer & Info Scie & Enginr" = "Directorate for Computer & Information Science & Engineering",
    "Direct For Education and Human Resources" = "Directorate for Education & Human Resources"))
    
# parse dates
df$date_start %<>% lubridate::mdy(.)
df$date_end %<>% lubridate::mdy(.)
df$duration <- df$date_end - df$date_start

df$`grant type` %<>% factor

# get rid of newlines in program officer
df %<>%
  mutate(program_officer = gsub("\n", "", program_officer))

df$program_officer %<>% factor

# remove 'br' from abstracts
df %<>%
  mutate(abstract = gsub("br", " ", abstract))


#######
## getting only the grants we want

df %<>%
  filter(directorate %in% c(
    "Direct For Biological Sciences",
    "Direct For Computer & Info Scie & Enginr",
    "Direct For Education and Human Resources",
    "Direct For Mathematical & Physical Scien",
    "Direct For Social, Behav & Economic Scie",
    "Directorate for Engineering",
    "Directorate for Geosciences"
  )) %>%
  filter(amount > 10000) %>%
  filter(`grant type` == "Standard Grant")
df %>%
  write_feather("out_cleaned.feather")
  
