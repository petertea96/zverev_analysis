##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- #####
# SERVE SPEED VIOLIN PLOTS
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
source("~/Documents/tennis/zverev_analysis/serve_speeds/run.R")
library(dplyr)
library(ggplot2)
library(reshape2)


##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
#### Plot all 4 using FACET_GRID() ####
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
az_ao_18$tournament = 'AO'
az_ao_19$tournament = 'AO'
az_rg_18$tournament = 'RG'
az_rg_19$tournament = 'RG'
az_us_18$tournament = 'US'
az_us_19$tournament = 'US'
az_wim_18$tournament = 'WIM'
az_wim_19$tournament = 'WIM'

entire_data_list = list(az_ao_18, az_ao_19, az_rg_18,az_rg_19,
                        az_us_18, az_us_19,az_wim_18,
                        az_wim_19)
entire_to_plot_prelim = do.call(rbind, entire_data_list)

#sanity checks
# Remove speeds of 0
entire_to_plot <- entire_to_plot_prelim %>%
  filter(Speed_KMH != 0)




##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
#### DOUBLE FAULTING ANALYSIS                                ####
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
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
  
  res <-  ifelse(score %in% game_point, 'Game Point',
                 ifelse(score %in% break_point, 'Break Point',
                        ifelse(score %in% setup_point, 'Setup Point',
                               'Neutral Point')))
  
  return(res)
}

# -->Add grouped score column
entire_to_plot_prelim <- entire_to_plot_prelim %>%
  mutate(grouped_score = get_score(serve_score))

#Zverev's 2018 szn
zverev_entire_2018 <- entire_to_plot_prelim %>%
  filter(year ==2018)

#Zverev's 2019 szn
zverev_entire_2019 <- entire_to_plot_prelim %>%
  filter(year ==2019)

#Zverev's 2018 double faults
zverev_df_2018 <- zverev_entire_2018 %>%
  filter(server_df == 1)

#Zverev's 2019 double faults
zverev_df_2019 <- zverev_entire_2019 %>%
  filter(server_df == 1)

##### ----- ##### ----- #####
#### 2018 analysis       ####
##### ----- ##### ----- #####

# --> What scores did he serve mostly?
table(zverev_entire_2018$grouped_score) %>% sort()

# --> What scores did he double fault mostly?
table(zverev_df_2018$grouped_score) %>% sort()  

context_2018 <- (table(zverev_df_2018$grouped_score)) / (table(zverev_entire_2018$grouped_score)) 

#-->proportion of points won on each situation
entire_to_plot_prelim %>%
  group_by(grouped_score,year, tournament) %>%
  summarize(pts_played = n(),
            pts_won = sum(won_point),
            win_perc = sum(won_point) / n(),
            df = sum(server_df),
            df_perc_of_losses = sum(server_df) / (n() - sum(won_point)))

##### ----- ##### ----- #####
# 2019 analysis          ####
##### ----- ##### ----- #####

# --> What scores did he serve mostly?
table(zverev_entire_2019$grouped_score) 

# --> What scores did he double fault mostly?
table(zverev_df_2019$grouped_score) 

#-->proportion of points won on each situation
zverev_entire_2019 %>%
  group_by(grouped_score) %>%
  summarize(pts_played = n(),
            pts_won = sum(won_point),
            win_perc = sum(won_point) / n(),
            df = sum(server_df),
            df_perc_of_losses = sum(server_df) / (n() - sum(won_point)))

context_2019 <- (table(zverev_df_2019$grouped_score)) / (table(zverev_entire_2019$grouped_score)) 


# --> Plots
context_to_plot <- cbind(context_2018, context_2019) %>% as.data.frame()
context_to_plot <- context_to_plot %>% 
  tibble::rownames_to_column("Situation") 
context_to_plot <- reshape2::melt(context_to_plot)

context_to_plot <- context_to_plot%>%
  rename(Year = variable, proportion = value) %>%
  mutate(Year = ifelse(Year == 'context_2018',
                       '2018', 
                       '2019'),
         Situation = factor(Situation, 
                            levels =rev(c('Break Point', 'Game Point', 'Setup Point', 'Neutral Point' )) ))

#teal: #9ED9CCFF
tiff("zverev_sdf_situation.tiff", units="in", width=4.75, height=3.25, res=150)
ggplot(data = context_to_plot,
       aes(x = Situation, y = proportion, fill = Year)) +
  geom_bar(stat = "identity", 
           color="#6c7a86", 
           width = 0.8,
           position=position_dodge(0.9)) +
  geom_label(data = context_to_plot %>% filter(Year == '2018'),
            aes(x = Situation,
                y = proportion + 0.015, 
                label = paste(round(proportion,3), sep = "")),
            position= position_nudge(x = -0.225),
            size = 2,
            show.legend = FALSE
            ) +
  geom_label(data = context_to_plot %>% filter(Year == '2019'),
            aes(x = Situation,
                y = proportion + 0.015, 
                label = paste(round(proportion,3), sep = "")),
            position= position_nudge(x = 0.225),
            size = 2,
            show.legend = FALSE
  ) +
  
  ylim(0, 0.155) +
  coord_flip() + 
  xlab("") +
  theme_bw() + 
  ylab(" Proportion of Double Faults") + 
  ggtitle('Zverev Grand Slam Situational \nDouble Faults')+ 
  scale_fill_manual(values=c("#FCFAF1", "#FACCAD"))+
  theme(panel.background = element_rect(#fill = "#DBF5F0", # background colour
                                        #light green: ##DBF5E8
                                        # light yellow: #F8FCCB
                                        colour = "black", # border colour
                                        size = 0.2, linetype = "solid"),
        plot.title=element_text(size = rel(1.1),
                                face = "bold", hjust = 0.5),
        axis.text.y = element_text(face="bold", color="black", 
                                   size=10),
        axis.text.x = element_text(face="bold", color="black", 
                                   size=9),
        axis.line = element_line(colour = "black", 
                                 size = 0.3, linetype = "solid"),
        #axis.title.y=element_text(colour = "black", face = "bold",
        #                          size = 12),
        axis.title.x = element_text(colour = "black", face = "bold",
                                   size = 10) ,
        plot.background = element_rect(fill = "#DBF5F0",
                                       colour = "black",size = 1),
        panel.grid.major = element_line(size = 0.025, linetype = 'solid',
                                        colour = "#6c7a86"), 
        panel.grid.minor = element_line(size = 0.1, linetype = 'solid',
                                        colour = "#6c7a86"),
        legend.background = element_rect(#fill = "#DBF5F0",
                                         colour = "black",size = 0.1),
        legend.title =  element_text(colour = "black", face = "bold",
                                     size = 10)
        
        
  )

dev.off()







###### ----- ##### ----- ####
#### How does Zverev's serve distribution as match progresses? ####
##### ----- ##### ----- #####
# !!! Zverev is slowing much slower on second serve as he reaches the 5th set???
# Facet_GRID by set number

ggplot(entire_to_plot, aes(x = as.factor(year), y = Speed_KMH)) + 
  geom_boxplot(aes(fill = as.factor(ServeNumber)),
              position = position_dodge(0.9),
              alpha = 0.9,
              color = '#6c7a86')+
  #color = '#C0C0C0') +
  
  geom_jitter(data = az_ao_18[az_ao_18$server_df==1,], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.15
  ) +
  
  geom_jitter(data = az_ao_19[az_ao_19$server_df==1,], 
              aes(x = as.factor(year), y = Speed_KMH),
              position= position_nudge(x = 0.225),
              color = 'red',
              alpha = 0.15)  + 
  facet_grid(rows = vars(SetNo)) 


##### ----- ##### ----- #####
# End set number facet
##### ----- ##### ----- #####
