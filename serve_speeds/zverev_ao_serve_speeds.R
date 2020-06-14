### How fast is Zverev serving given the current score?
library(dplyr)
library(ggplot2)
library(reshape2)

source("~/Documents/kovalchik_post_speed/gather_data_v2.R")


##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# AUSTRALIAN OPEN
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# --> 2018 AO
az_ao_18 = get_slam_serve(Player = "A. Zverev", 
                          year = 2018, tournament = "ausopen")
# --> 2019 AO
az_ao_19 = get_slam_serve(Player = "A. Zverev", 
                          year = 2019, tournament = "ausopen")
# --> 2020 AO
az_ao_20 = get_slam_serve(Player = "A. Zverev", 
                          year = 2020, tournament = "ausopen")

# Combine all datasets into one
#entire_data_list = list(az_ao_18, az_ao_19, az_ao_20)
entire_data_list = list(az_ao_18, az_ao_19)
entire_to_plot_prelim = do.call(rbind, entire_data_list)



get_score <- function(score){
  # Function to convert scores to 4 categories
  
  # Note this doesn't write out all possible scenarios.
  # I just coded the serve scores observed for Zverev's service games
  
  game_point = c('40 - 0', '40 - 15', '40 - 30', 'AD - 40')
  break_point = c('0 - 40', '15 - 40', '30 - 40', '40 - AD',
                  '1 - 5', '1 - 6', '3 - 5', '2 - 5')
  setup_point = c('40 - 40', '30 - 30', '30 - 15', '15 - 30',
                  '30 - 0', '0 - 30')
  neutral_point = c('0 - 0', '15 - 0', '0 - 15', '15 - 15',
                    '2 - 0', '1 - 1', '0 - 1')
  
  res <-  ifelse(score %in% game_point, 'Game',
                 ifelse(score %in% break_point, 'Break',
                        ifelse(score %in% setup_point, 'Setup',
                               'Neutral')))
  
  return(res)
}
az_ao_18$grouped_score = get_score(az_ao_18$serve_score)
az_ao_19$grouped_score = get_score(az_ao_19$serve_score)
az_ao_20$grouped_score = get_score(az_ao_20$serve_score)

entire_to_plot_prelim <- entire_to_plot_prelim %>%
  mutate(grouped_score = get_score(serve_score)) %>%
  filter(Speed_KMH != 0)


# Counts of each point situation
entire_to_plot_prelim %>%
  group_by(grouped_score, year) %>%
  summarise(count = n(),
            win_percentage = sum(won_point) / n(),
            num_df = sum(server_df))

# average speeds
entire_to_plot_prelim %>%
  group_by(ServeNumber,year) %>%
  summarise(avg_second_speed = mean(Speed_KMH))

  

tiff("zverev_ao_speeds.tiff", units="in", width=4, height=5.5, res=150)
ggplot(entire_to_plot_prelim, aes(x = as.factor(year), y = Speed_KMH)) + 
  geom_boxplot(aes(fill = as.factor(ServeNumber)),
              position = position_dodge(0.9),
              alpha = 0.9,
              color = '#6c7a86')+
  #color = '#C0C0C0') +
  
  facet_grid(rows = vars(grouped_score)) +
  geom_jitter(data = az_ao_18[az_ao_18$server_df==1 & az_ao_18$grouped_score == 'Break',], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.25
  ) +
  
  geom_jitter(data = az_ao_18[az_ao_18$server_df==1 & az_ao_18$grouped_score == 'Game',], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.25
  ) + 
  
  geom_jitter(data = az_ao_18[az_ao_18$server_df==1 & az_ao_18$grouped_score == 'Neutral',], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.25
  ) + 
  geom_jitter(data = az_ao_18[az_ao_18$server_df==1 & az_ao_18$grouped_score == 'Setup',], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.25
  ) + 
  
  geom_jitter(data = az_ao_19[az_ao_19$server_df==1 & az_ao_19$grouped_score == 'Break',], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.25
  ) +
  
  geom_jitter(data = az_ao_19[az_ao_19$server_df==1 & az_ao_19$grouped_score == 'Game',], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.25
  ) + 
  
  geom_jitter(data = az_ao_19[az_ao_19$server_df==1 & az_ao_19$grouped_score == 'Neutral',], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.25
  ) + 
  geom_jitter(data = az_ao_19[az_ao_19$server_df==1 & az_ao_19$grouped_score == 'Setup',], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.25
  )   + 
  
  geom_hline(yintercept = 166.7519,
             linetype = 'dashed',
             size = 0.5,
             color = '#6c7a86',
             alpha = 0.7) + 
  ggtitle('Zverev Australian Open Serve \nSpeed Distributions (2018 - 2019)') + 
  ylab("Serve Speed (KM/H)") + xlab("Year") + labs(fill = "Serve Number:" ) +
  theme_bw() +
  scale_fill_manual(values=c("#FA8072", "#AFEEEE"), labels = c("1st", "2nd") ) +  
  theme(panel.background = element_rect(fill = 'white', # background colour
                                        colour = "black", # border colour
                                        size = 0.5, linetype = "solid"),
        plot.title=element_text(size = rel(1.1),
                                face = "bold", hjust = 0.5),
        legend.position = "bottom",
        legend.title =  element_text(face = "bold", size = 9),
        legend.background = element_rect(colour = "gray"),
        legend.key = element_rect(fill = "gray90"),
        axis.title = element_text(face = "bold", size = 9))
dev.off()
