
library(tidytext)
data("stop_words")
library(ggthemes)

source("https://raw.githubusercontent.com/lukereding/random_scripts/master/plotting_functions.R")

require(feather)
df <- read_feather("~/Documents/nsf_nlp/out_cleaned.feather")

df %>% 
  group_by(directorate) %>%
  unnest_tokens(word, abstract) %>% 
  anti_join(stop_words) %>% 
  group_by(directorate) %>%
  count(word, sort = TRUE) %>%
  mutate(word = reorder(word, n)) %>%
  slice(1:5) %>%
  ggplot(aes(x = word, y = n)) +
  geom_col(aes(fill = directorate), position = "dodge") +
  theme_minimal() +
  facet_wrap(~directorate, scales = "free_x") +
  scale_fill_tableau() + 
  rotate_labels() 

# now exclude really common words
common_words <- df %>% 
  unnest_tokens(word, abstract) %>% # tokenize
  anti_join(stop_words) %>% # remove stop words
  filter(!word %in% c("research", "data", "project", "students", "science", "learning", "student", "study", "provide", "program", "university","based", "provide","studies", "provide", "understanding", "biology", "engineering", "education", "processes", "social")) %>% # remove common 'science' stop words
  group_by(directorate) %>% # group by directorite
  count(word, sort = TRUE) %>% # count in the number of each word in each directorate
  mutate(word = reorder(word, n), percent = n / n() * 100, number = n()) %>% # get the percent and reorder the words
  filter(!is.na(directorate)) # remove any NA directorates


common_words %>%
  top_n(5, percent) %>%
  ggplot(aes(x = word, y = percent)) +
  geom_col(aes(fill = directorate)) +
  facet_wrap(~directorate, scales = "free_x") +
  scale_fill_alpine(guide = F) + 
  theme_mod() +
  rotate_labels() +
  remove_ticks_x() +
  ylab("percent") +
  ggtitle("top 5 words from abstracts of each directorate")
file = "~/Documents/nsf_nlp/plots/fig1.pdf" 
ggsave(file, height = 8, width = 7)
system(paste0("open ", file))

# by year now
common_words_by_year <- df %>% 
  mutate(year = lubridate::year(date_start)) %>%
  unnest_tokens(word, abstract) %>% # tokenize
  anti_join(stop_words) %>% # remove stop words
  filter(!word %in% c("research", "data", "project", "students", "science", "learning", "student", "study", "provide", "program", "university","based", "provide","studies", "provide", "understanding")) %>% # remove common 'science' stop words
  group_by(directorate, year) %>% # regroup
  count(word, sort = TRUE) %>% # count in the number of each word in each directorate
  mutate(word = reorder(word, n), percent = n / n() * 100, number = n()) %>% # get the percent and reorder the words
  filter(!is.na(directorate)) %>% # remove any NA directorates
  filter(year <= 2015)

# choose some words, look at changes over time
common_words_by_year %>%
  filter(word %in% c("theory", "stem", "species", "climate", "novel", "model")) %>%
  ggplot(aes(x = year, y = percent, group = word, color = word)) +
  geom_line(size = 1.2) +
  facet_wrap(~ directorate) +
  scale_color_world() + 
  ylab("percent of abstracts containing the word") +
  theme_mod() +
  add_axes()
file= "~/Documents/nonstandard_deviations/images/post3/fig2.png"
ggsave(file, height = 6, width = 7)
system(paste0("open ", file))



## see how the top words change over time
## get the top 10 word used, overall, exlcuding stop and 'scientific' stop words
most_common <- common_words %>%
  ungroup %>%
  arrange(desc(n)) %>%
  slice(1:10) %>%
  pull(word)

common_words_by_year %>%
  filter(word %in% most_common) %>%
  ggplot(aes(x = year, y = percent, group = directorate, color = directorate)) +
  geom_line(size = 1) +
  scale_color_alpine() + 
  theme_mod() +
  facet_wrap(~ word) +
  scale_fill_continuous(guide = guide_legend()) +
  theme(legend.position="bottom") +
  theme(legend.text=element_text(size=8)) +
  add_axes() +
  ggtitle("percent of abstracts that contain some common words over time")

file= "~/Documents/nonstandard_deviations/images/post3/fig3.png"
ggsave(file, height = 8, width = 10)
system(paste0("open ", file))


###############
### $$$$
# 
# money <- df %>% 
#   mutate(year = lubridate::year(date_start)) %>%
#   unnest_tokens(word, abstract) %>% 
#   anti_join(stop_words) %>%
#   filter(!word %in% c("research", "data", "project", "students", "science", "learning", "student", "study", "provide", "program", "university","based", "provide","studies", "provide", "understanding", "biology", "engineering", "education", "processes", "social")) %>% # remove common 'science' stop words
#   group_by(directorate, year, word) %>%
#   summarize(avg_amount = mean(amount, na.rm = TRUE)) %>%
#   top_n(5, avg_amount) %>%
#   filter(!is.na(directorate))
# 
# money %>%
#   ungroup %>%
#   group_by(directorate) %>%
#   top_n(5, avg_amount) %>%
#   ggplot(aes(x = word, y = avg_amount)) +
#   geom_col(aes(fill = directorate)) +
#   scale_color_alpine() + 
#   theme_mod() +
#   facet_wrap(~ directorate, scales = "free_x")
# file= "~/Documents/nonstandard_deviations/images/post3/fig4.png"
# ggsave(file, height = 10, width = 10)
# system(paste0("open ", file))
# save(money, file = "money.Rda")

##############

#cool!
df %>%
  mutate(year = lubridate::year(date_start)) %>%
  group_by(year, directorate) %>%
  summarise(avg_pis = mean(number_pis, na.rm = T)) %>%
  filter(year > 1975) %>%
  ggplot(aes(x = year, y = avg_pis)) +
  geom_line(aes(color = directorate)) +
  scale_color_alpine() +
  ggtitle("average number of PIs on a grant over time") +
  ylab("average # PIs") +
  theme_mod() +
  add_axes() + 
  theme(legend.position="bottom")
ggsave("~/Documents/nsf_nlp/plots/fig4.pdf", height = 7.5, width = 7.5)


require(ggjoy)
df %>%
  mutate(year = lubridate::year(date_start)) %>%
  filter(year > 1975) %>%
  ggplot(aes(x = amount, y = year, group = year, height = ..density..)) +
  geom_joy(scale = 5, color = "white") +
  scale_y_reverse() +
  scale_x_log10(breaks = c(50000, 100000, 1000000, 5000000),
                label = c("$50k", "$100k", "$1mil", "$5mil")) +
  theme_mod() +
  rotate_labels(35)
file= "~/Documents/nonstandard_deviations/images/post4/fig1.png"
ggsave(file, height = 4, width = 7)
system(paste0("open ", file))


df %>%
  mutate(year = lubridate::year(date_start)) %>%
  filter(year > 1975) %>%
  ggplot(aes(x = amount, y = year, group = year, height = ..density..)) +
  geom_joy(scale = 5, color = "white") +
  scale_y_reverse() +
  scale_x_log10(breaks = c(50000, 100000, 1000000, 5000000),
                label = c("$50k", "$100k", "$1mil", "$5mil")) +
  theme_mod() +
  rotate_labels(35) +
  facet_wrap(~directorate)
file= "~/Documents/nonstandard_deviations/images/post4/fig2.png"
ggsave(file, height = 6, width = 7)
system(paste0("open ", file))


df %>%
  mutate(year = lubridate::year(date_start)) %>%
  filter(year > 1975) %>%
  filter(amount > 20000) %>%
  ggplot(aes(x = amount, y = year, group = year, height = ..density..)) +
  geom_joy(scale = 5, color = "white") +
  scale_y_reverse() +
  scale_x_log10(breaks = c(50000, 100000, 1000000, 5000000),
                label = c("$50k", "$100k", "$1mil", "$5mil")) +
  theme_mod() +
  rotate_labels(35) +
  facet_wrap(~ directorate)

# adjust for inflation
getSymbols("CPIAUCSL", src='FRED') 
cpi <- CPIAUCSL %>%
  as.data.frame %>%
  tibble::rownames_to_column() %>%
  mutate(year = lubridate::year(rowname)) %>%
  group_by(year) %>% 
  summarise(avg_cpi = mean(CPIAUCSL, na.rm = T))
cpi[cpi$year == 1975,]
cpi <- cpi %>%
  mutate(dollars_1975 = avg_cpi / 53.825)
df %>%
  mutate(year = lubridate::year(date_start)) %>%
  filter(year > 1975) %>%
  filter(amount > 20000) %>%
  left_join(., cpi) %>%
  mutate(amount_adjusted = amount / dollars_1975) %>% 
  ggplot(aes(x = amount_adjusted, y = year, group = year, height = ..density..)) +
  geom_joy(scale = 5, color = "white") +
  scale_y_reverse() +
  scale_x_log10(breaks = c(50000, 100000, 1000000, 5000000),
                label = c("$50k", "$100k", "$1mil", "$5mil")) +
  theme_mod() +
  rotate_labels(35) +
  xlab("amount, adjusted for inflation")
ggsave("~/Desktop/Rploy.png", height = 6, width = 7)



df %>%
  mutate(year = lubridate::year(date_start)) %>%
  group_by(year, directorate) %>%
  summarise(avg_pis = mean(number_pis, na.rm = T)) %>%
  filter(year > 1975) %>%
  ungroup %>%
  mutate(directorate = reorder(directorate, avg_pis, FUN=which.max)) %>%
  arrange(directorate) %>%
  mutate(directorate.f = reorder(as.character(directorate), desc(directorate))) %>%
  {
    dirs = levels(.$directorate.f)
    dirs <- dirs[1:7]
    
    ggplot(., aes(x = year, y = as.numeric(directorate.f), group = directorate.f)) +
      geom_ribbon(aes(ymin = as.numeric(directorate), ymax = as.numeric(directorate) + (avg_pis-1)*1.5, fill = directorate.f), color='white', size=0.4) +
      scale_fill_alpine(guide = F) +
      # scale_y_continuous(breaks = 1:length(dirs), labels = function(y) {dirs[y]}) +
      theme_mod() +
      theme(axis.ticks.y = element_blank())
  }



# average grant award by year
df %>%
  mutate(year = lubridate::year(date_start)) %>%
  group_by(year, directorate) %>%
  summarise(money = mean(amount, na.rm = T)) %>%
  filter(year > 1975) %>%
  ggplot(aes(x = year, y = money)) +
  geom_line(aes(color = directorate)) +
  scale_color_alpine() +
  ggtitle("award money per year") +
  ylab("cash $$") +
  theme_mod() +
  add_axes() + 
  theme(legend.position="bottom")
ggsave("~/Documents/nsf_nlp/plots/fig5.pdf", height = 7.5, width = 7.5)


# number of grant awards per directorate
df %>%
  mutate(year = lubridate::year(date_start)) %>%
  group_by(year, directorate) %>%
  count %>%
  filter(year > 1975 & year < 2015) %>%
  ggplot(aes(x = year, y = n, color = directorate)) +
  geom_line(aes(color = directorate)) +
  scale_color_tableau() +
  theme_mod() +
  add_axes()

# top $ institutions
df %>%
  group_by(institution) %>%
  summarise(money = sum(amount, na.rm = T)) %>%
  arrange(desc(money)) %>%
  slice(1:20) %>% 
  ggplot(aes(reorder(institution, money), money)) +
  geom_point() +
  coord_flip()

# get top instituions
top_institutions <- df %>%
  group_by(institution) %>%
  summarise(money = sum(amount, na.rm = T)) %>%
  arrange(desc(money)) %>%
  slice(1:20) %>%
  ungroup %>%
  select(institution) %>%
  unlist

df %>% 
  filter(institution %in% top_institutions) %>%
  mutate(year = lubridate::year(date_start)) %>%
  group_by(institution, year) %>%
  summarise(money = mean(amount, na.rm= T)) %>%
  filter(year < 2015 & year > 1975) %>%
  ggplot(aes(year, money)) + 
  geom_line() +
  ylab("$") +
  facet_wrap(~ institution) +
  theme_mod() +
  add_axes() +
  ggtitle("top 20 institutions for raking in NSF money", subtitle = "check out that stimulus bump in 2009")
ggsave("~/Documents/nsf_nlp/plots/fig6.pdf", height = 7.5, width = 7.5)



### what words are associated with the most $$$


####################
## do to: gender analysis
# male names: http://www.cs.cmu.edu/afs/cs/project/ai-repository/ai/areas/nlp/corpora/names/male.txt
# female names: http://www.cs.cmu.edu/afs/cs/project/ai-repository/ai/areas/nlp/corpora/names/female.txt



### create corpus

# create corpus of each directorate
nested <- df %>%
  group_by(directorate) %>% 
  nest

## function to write all abstracts to a text file
write_corpus <- function(x, name){
  x$abstract %>%
    unlist %>%
    write(., file = paste0("~/Documents/nsf_nlp/corpus/", name, ".txt"))
}

for(i in 1:nrow(nested)){
  write_corpus(nested$data[[i]], as.character(nested$directorate[[i]]))
}