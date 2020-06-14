#################################
library(dplyr)

collect_match_stats <- function(server_match_id, year, tournament, server_name){
  # Given a match ID, carefully re-state player1 and player2 as simply server and returner
  # collect: serve speed, score prior to serve, set number, game number
  # outcome of serve (win/loss), 1st/2nd serve flag,
  
  
  wd = "/Users/petertea/Documents/Sports-Analytics/Sackmann/tennis_slam_pointbypoint"
  # Set to appropriate working directory
  setwd(wd)
  
  points_file_name <- paste(as.character(year), "-", as.character(tournament), "-points.csv", sep="")
  matches_file_name <- paste(as.character(year), "-", as.character(tournament), "-matches.csv", sep=""  )
  
  points_data <- read.csv(points_file_name)
  matches_data <- read.csv(matches_file_name)
  
  # Get info on who opponent is, and whether server is coded as player1 or player2
  server_matches_data <- matches_data %>%
    dplyr::filter(match_id == server_match_id)
  
  player_1_or_2 = ifelse(server_matches_data$player1 == server_name, 1, 2)
  
  opponent_name = ifelse(server_matches_data$player1 == server_name,
                         as.character(server_matches_data$player2), 
                         as.character(server_matches_data$player1))
  
  # Mould the data...
  # Keep only interesting variables
  player_points_data <- points_data %>%
    dplyr::filter(match_id %in% server_match_id) %>%
    dplyr::select(match_id, PointWinner, SetNo, GameNo, PointNumber,
                  PointServer, Speed_KMH, Speed_MPH,
                  P1DoubleFault, P2DoubleFault, 
                  ServeNumber, P1Score, P2Score)
  
  # Get scores (score prior to serve) relative to the server
  if(player_1_or_2 == 1){
    current_score <- paste(player_points_data$P1Score, '-', player_points_data$P2Score, sep = ' ')
    current_score <- current_score[c(length(current_score), 1:( length(current_score) -1 ) )]
  } else{
    current_score <- paste(player_points_data$P2Score, '-', player_points_data$P1Score, sep = ' ')
    current_score <- current_score[c(length(current_score), 1:( length(current_score) -1 ) )]
  }
  
  # Add score column
  player_points_data$serve_score = current_score
  
  
  if(player_1_or_2 == 1){
    server_points_data <- player_points_data %>%
      dplyr::select(-P2DoubleFault, -P1Score, -P2Score) %>%
      dplyr::filter(PointServer == 1) %>%
      dplyr::mutate(won_point = ifelse(PointWinner == 1, 1, 0),
                    returner = opponent_name) %>%
      rename(server_df = P1DoubleFault)
  } else{
    server_points_data <- player_points_data %>%
      dplyr::select(-P1DoubleFault, -P1Score, -P2Score) %>%
      dplyr::filter(PointServer == 2) %>%
      dplyr::mutate(won_point = ifelse(PointWinner == 2, 1, 0),
                    returner = opponent_name)%>%
      rename(server_df = P2DoubleFault)
  }
  
  return(server_points_data)
  
}
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# End function
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 


##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# Test out function
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
zverev_match1_dat = collect_match_stats(server_match_id = "2018-ausopen-1148",
                                        year = 2018,
                                        tournament = 'ausopen',
                                        server_name = 'A. Zverev')
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# End test function
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 


##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# Collect data for ENTIRE tournament
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- #####

get_slam_serve <- function(Player, year, tournament){
  
  # Read match data based on year and grand-slam tourney
  matches_file_name <- paste("/Users/petertea/Documents/Sports-Analytics/Sackmann/tennis_slam_pointbypoint/",
                             as.character(year),
                             "-",
                             as.character(tournament),
                             "-matches.csv", sep=""  )
  
  matches_data <- read.csv(matches_file_name)
  
  #Select matches with the Player involved
  which_match_id <- which(matches_data$player1 == Player | matches_data$player2 == Player)
  
  #Sometimes data coded as N. Djokovic
  if ( length(which_match_id) == 0) {
    last_name <- strsplit(Player, " ")[[1]][2]
    which_match_id <- which( grepl(x=matches_data$player1, pattern = last_name) | grepl(x=matches_data$player2, pattern = last_name))
  }
  
  match_ids <- as.character(matches_data[which_match_id,1])
  
  complete_dat = list()
  for(i in 1:length(match_ids)){
    complete_dat[[i]] =  collect_match_stats(server_match_id = match_ids[i],
                        year=year,
                        tournament=tournament,
                        server_name=Player)
  }
  
  all_data = do.call(rbind, complete_dat)
  
  # Add year of match...
  all_data$year = as.numeric(substr(all_data$match_id,1,4))
  
  return(all_data)
  
}


##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# End Data collection
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- #####


### 
#Calculate proportion of success (wins) in 1st service games vs 2nd service games
serve_success_rates <- function(mydata){
  library(dplyr)
  total <- mydata %>%
    group_by(ServeNumber) %>%
    tally()
  
  wins <- mydata %>%
    group_by(ServeNumber) %>%
    summarise(num_wins =sum(PointWinner==PointServer))
  
  result <- total %>%
    left_join(wins, by = "ServeNumber") %>%
    mutate(win_percentage = num_wins / n)
  
  colnames(result) = c("Serve Number", "Service Games", "Service Wins", "Win Percentage")
  
  return(result)
}


