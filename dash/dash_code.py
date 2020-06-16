# -*- coding: utf-8 -*-
"""
Created on Sun Jun 14 13:59:16 2020

@author: Peter
"""


# Taking a go at Plotly Dash - Prototype

# For the top 7 players (Rafa, Novak, Roger, Thiem, Zverev, Med), plot
# their yearly average serve statistics

# --> import libraries
import pandas as pd
import numpy as np
from plotly.offline import plot
import plotly.graph_objects as go

##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output


# --> Working directories
import os
print(os.getcwd())
path="C:/Users/Peter/Documents/zverev_analysis/"
os.chdir(path)
################################################

# --> read in data
dat = pd.read_csv('./data/atp_fulldata.csv', encoding='latin1')

# Fix time in data
dat['match_date'] = pd.to_datetime(dat['match_date'], format='%Y-%m-%d')
dat['year'] = pd.DatetimeIndex(dat['match_date']).year 


names_to_keep = ['Roger Federer', 'Novak Djokovic', 'Rafael Nadal', 
                 'Alexander Zverev', 'Dominic Thiem', 'Daniil Medvedev',
                 'Stefanos Tsitsipas', 'Milos Raonic', 'John Isner',
                 'Andy Murray', 'David Ferrer', 'Gilles Simon',
                 'Kei Nishikori']

dat_top_servers = dat[dat['server'].isin(names_to_keep)]


# --> Keep only matches against opponents in the top 104
dat_top_servers.shape

dat_top_servers = dat_top_servers[dat_top_servers.returner_rank <= 104]
# Reduces rows from 4634 --> 3752 


# --> For each (player, year), calculate average serve probabilities

top_servers_by_year = dat_top_servers.groupby(['server','year']).mean().reset_index()

# --> Add number of matches played each year by Zverev
match_counts = dat_top_servers.groupby(['server','year']).size().values
top_servers_by_year['num_matches'] = match_counts


# --> Only include years with at least 10 top 104 matches played
top_servers_by_year = top_servers_by_year[top_servers_by_year.num_matches >= 10]




##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
# This is where the plotly-dash fun starts...
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 
##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### ----- ##### 




### Dash Core component
# Ex: Dropdown menu

# The 'callback' connects the dash components with the plotly graphics

app = dash.Dash(__name__)

# ------------------------------------------------------------------------------
# App layout
app.layout = html.Div([
    #app.layout takes in your dash components & html codes

    html.H1("This is a title...", style={'text-align': 'center'}),

    dcc.Dropdown(id="slct_year",
                 options=[
                     {"label": "Djokovic", "value": 'Novak Djokovic'},
                     {"label": "Federer", "value": 'Roger Federer'},
                     {"label": "Nadal", "value": 'Rafael Nadal'},
                     {"label": "Zverev", "value": 'Alexander Zverev'},
                     {"label": "Thiem", "value": 'Dominic Thiem'},
                     {"label": "Medvedev", "value": 'Daniil Medvedev'},
                     {"label": "Tsitsipas", "value": 'Stefanos Tsitsipas'},
                     {"label": "Milos", "value": 'Milos Raonic'},
                     {"label": "Isner", "value": 'John Isner'},
                     {"label": "Murray", "value": 'Andy Murray'},
                     {"label": "Ferrer", "value": 'David Ferrer'},
                     {"label": "Simon", "value": 'Gilles Simon'},
                     {"label": "Nishikori", "value": 'Kei Nishikori'}
                     ],
                 multi=False,
                 value='Novak Djokovic',
                 #style={'width': "40%"}
                 ),

    html.Br(),
    html.Div(id='output_container', children=[]),
    html.Br(),

    dcc.Graph(id='my_bee_map', figure={})

])


# ------------------------------------------------------------------------------
# Connect the Plotly graphs with Dash Components
@app.callback(
    [Output(component_id='output_container', component_property='children'),
     Output(component_id='my_bee_map', component_property='figure')],
    [Input(component_id='slct_year', component_property='value')]
)
def update_graph(option_slctd):
    print(option_slctd)
    print(type(option_slctd))

    container = "The Player chosen by user was: {}".format(option_slctd)
    
    #dff = df.copy()
    dff = top_servers_by_year.copy()

    #dff = dff[dff["Year"] == option_slctd]
    dff = dff[dff.server == option_slctd]

    #dff = dff[dff["Affected by"] == "Varroa_mites"]

    # Plotly Express
    #fig = px.choropleth(
    #    data_frame=dff,
    #    locationmode='USA-states',
    #    locations='state_code',
    #    scope="usa",
    #    color='Pct of Colonies Impacted',
    #    hover_data=['State', 'Pct of Colonies Impacted'],
    #    color_continuous_scale=px.colors.sequential.YlOrRd,
    #    labels={'Pct of Colonies Impacted': '% of Bee Colonies'},
    #    template='plotly_dark'
    #)

    # Plotly Graph Objects (GO)
    # fig = go.Figure(
    #     data=[go.Choropleth(
    #         locationmode='USA-states',
    #         locations=dff['state_code'],
    #         z=dff["Pct of Colonies Impacted"].astype(float),
    #         colorscale='Reds',
    #     )]
    # )
    #
    # fig.update_layout(
    #     title_text="Bees Affected by Mites in the USA",
    #     title_xanchor="center",
    #     title_font=dict(size=24),
    #     title_x=0.5,
    #     geo=dict(scope='usa'),
    # )
    
    myplot = go.Figure()
    myplot.add_trace(go.Scatter(x=dff['year'],
                            y=dff['pr_2ndin'],
              marker_color = 'green',
              name = 'Prob(2nd Serve In)',
              line_shape = 'spline',
              mode = 'markers+lines',
              marker=dict(line=dict(width=1.5)),
              #name = 'Lower Bound',
              line = dict(width = 1)
              ))
    myplot.add_trace(go.Scatter(x=dff['year'],
                            y=dff['pr_win_on_2nd_serve'],
              marker_color = '#FFA500',
              name = 'Prob(Win on 2nd Serve)',
              line_shape = 'spline',
              mode = 'markers+lines',
              marker=dict(line=dict(width=1.5)),
              #name = 'Lower Bound',
              line = dict(width = 1),
              ))
    myplot.add_trace(go.Scatter(x=dff['year'],
                            y=dff['pr_w2_giv_2in'],
              marker_color = '#0f52ba',
              name = 'Prob(Win | 2nd Serve In)',
              line_shape = 'spline',
              mode = 'markers+lines',
              marker=dict(line=dict(width=1.5)),
              #name = 'Lower Bound',
              line = dict(width = 1),
              ))
    # --> Add 1st serve stats
    
    myplot.add_trace(go.Scatter(x=dff['year'],
                            y=dff['pr_1stin'],
              marker_color = 'purple',
              name = 'Prob(1st Serve In)',
              line_shape = 'spline',
              mode = 'markers+lines',
              marker=dict(line=dict(width=1.5)),
              #name = 'Lower Bound',
              line = dict(width = 1),
              ))
    myplot.add_trace(go.Scatter(x=dff['year'],
                            y=dff['pr_w1_giv_1in'],
              marker_color = 'red',
              name = 'Prob(Win | 1st Serve In)',
              line_shape = 'spline',
              mode = 'markers+lines',
              marker=dict(line=dict(width=1.5)),
              #name = 'Lower Bound',
              line = dict(width = 1),
              ))
    myplot.add_trace(go.Scatter(x=dff['year'],
                            y=dff['pr_win_on_1st_serve'],
              marker_color = 'blue',
              name = 'Prob(Win on 1st Serve)',
              line_shape = 'spline',
              mode = 'markers+lines',
              marker=dict(line=dict(width=1.5)),
              #name = 'Lower Bound',
              line = dict(width = 1),
              ))
    
    myplot.update_layout(
    showlegend = True,
    barmode = 'overlay',
    title = dict(text = "<b>Career <br> Serve Performance  </b>", # title of plot,
                    xanchor = 'center',
                    x = 0.5,
                    y = 0.95),
    legend = dict(font = dict(size=12)),
       xaxis_title_text="Year", # xaxis label
       yaxis_title_text='Probability', # yaxis label
       font = dict(size = 16),
       hovermode = 'closest',
       plot_bgcolor = "#FFF",
       xaxis_linecolor = "#BCCCDC",
       hoverlabel=dict(
               bgcolor="white", 
               bordercolor = 'black',
               font_size=14, 
               #font_family="Rockwell"
    )) 
    myplot.update_traces(opacity=0.95,
              text = dff[['num_matches']],
               hovertemplate =
                '<b>Year</b>: %{x}'+
                '<br><b>Probability</b>: %{y}<br>'+
                '<b>Matches Played: %{text} </b>'
)

    return container, myplot
    #return myplot


# ------------------------------------------------------------------------------
if __name__ == '__main__':
    app.run_server(debug=True)





