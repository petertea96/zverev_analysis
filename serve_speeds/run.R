# ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# Collect Zverev serve speed
# ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# --> run gather_data_v2.R
source("~/Documents/tennis/zverev_analysis/serve_speeds/collect_speed_data_functions.R")

# ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# AUSTRALIAN OPEN
# ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# --> 2018 AO
az_ao_18 = get_slam_serve(Player = "A. Zverev", 
               year = 2018, tournament = "ausopen")
#write.csv(az_ao_18, file = 'zverev_ao2018.csv', row.names = FALSE)

# --> 2019 AO
az_ao_19 = get_slam_serve(Player = "A. Zverev", 
                          year = 2019, tournament = "ausopen")
#write.csv(az_ao_19, file = 'zverev_ao2019.csv', row.names = FALSE)

# --> 2020 AO
az_ao_20 = get_slam_serve(Player = "A. Zverev", 
                          year = 2020, tournament = "ausopen")
#write.csv(az_ao_20, file = 'zverev_ao2020.csv', row.names = FALSE)


# Check how many service points were played for each match
az_ao_19$match_id = as.character(az_ao_19$match_id)
table(az_ao_19$match_id)

az_ao_20$match_id = as.character(az_ao_20$match_id)
table(az_ao_20$match_id)



##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# US OPEN
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
### **** NOTE ***
# ---> US Open will code double fault speeds as 0...

# --> 2018 US
az_us_18 = get_slam_serve(Player = "Alexander Zverev", 
                          year = 2018, tournament = "usopen")
# --> 2019 US
az_us_19 = get_slam_serve(Player = "Alexander Zverev", 
                          year = 2019, tournament = "usopen")


##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# Rolland Garros
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
### **** NOTE ***
# ---> rolland garros will code double fault speeds as 0...
# --> also speed only available in mph

az_rg_18 = get_slam_serve(Player = "A. Zverev", 
                          year = 2018, tournament = "frenchopen")
az_rg_18$Speed_KMH <- az_rg_18$Speed_MPH*1.60934

# --> 2019 US
az_rg_19 = get_slam_serve(Player = "Alexander Zverev", 
                          year = 2019, tournament = "frenchopen")
az_rg_19$Speed_KMH <- az_rg_19$Speed_MPH*1.60934



##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# Wimbledon
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
### **** NOTE ***
# ---> Wimbledon will code double fault speeds as 0...
az_wim_18 = get_slam_serve(Player = "Alexander Zverev", 
                          year = 2018, tournament = "wimbledon")
# --> 2019 Wimbledon
az_wim_19 = get_slam_serve(Player = "Alexander Zverev", 
                          year = 2019, tournament = "wimbledon")



