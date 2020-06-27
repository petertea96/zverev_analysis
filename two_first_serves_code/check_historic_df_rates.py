# -*- coding: utf-8 -*-
"""
Created on Sun Jun 21 16:55:31 2020

@author: Peter
"""


import pandas as pd
import numpy as np

################################################
# --> Working directories
import os
print(os.getcwd())
path="C:/Users/Peter/Documents/zverev_analysis/"
os.chdir(path)
################################################

# --> read in data
dat = pd.read_csv('./data/atp_fulldata.csv', encoding='latin1')

# --> Data processing steps:
# --> Some player names include parantheses...let's remove the
# parantheses and only have characers in the names
tosee=dat[dat.server.str.find('(') != -1]
dat.server = dat.server.str.replace(r"\(.*\)","")
dat.returner = dat.returner.str.replace(r"\(.*\)","")

# Fix time in data
dat['match_date'] = pd.to_datetime(dat['match_date'], format='%Y-%m-%d')
dat['year'] = pd.DatetimeIndex(dat['match_date']).year 


dat['df_per_ss'] = dat.s_df / (dat.s_2ndIn + dat.s_df)

rank_100_dat = dat[dat.server_rank <= 100]

average_df_rates = rank_100_dat.groupby(['server', 'year'])['df_per_ss'].agg('mean')

df_rates = average_df_rates.reset_index()

df_rates.sort_values('df_per_ss', ascending= False)
# Only one above Zverev:
# Irakli Labadze  2004   0.245925

# Count how many matches were played by 
dat_2004_num_matches = dat[dat.year == 2004].groupby(['server']).count()
# 4 matche recorded...