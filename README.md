# lok_sabha_public
## Analysis of Twitter Data on the 2019 Indian Parliamentary Elections by Hemanth Bharatha Chakravarthy 
_This project aims to investigate scraped twitter data on the ongoing 2019 Indian Lok Sabha Elections and perform sentiment analysis, forecasting, and analysis on bot tweets based on this data._ 

### Note on the Project
#### The App
Link: 

#### 1: Sentiment Analysis
#### 2: Geospatial Analysis for Forecasting
#### 3: Bots & IT Cells -- Analysis of Fake Tweets

#### Technical Details
This project is written in R and it's UI is built with R`Shiny` to be interactive and reactive. I use `rtweet` to scrape twitter data (more on `rtweet` here: https://rtweet.info/) and use the `nrc` dictionary to perform sentiment analysis (more on `nrc` here: https://www.rdocumentation.org/packages/syuzhet/versions/1.0.4/topics/get_nrc_sentiment). Aside of some geospatial analysis and mapping tools, a large part of the core functionality of this project is built in `dplyr` and `ggplot2`.  

### Note on the Data
There are two data files:

#### 1: The #Chowkidar Campaign
The csv file: https://drive.google.com/file/d/1cSUnWV-dQK0XgBfJGkhHJNX_6uc1JDgK/view?usp=sharing

This data is a mixed sample of the most popular and most recent one hundred and eight thousand tweets made in English from the last three days (as of 20 March, 2019, 10:07 pm EST) on the Bharatiya Janata Party's #MainBhiChowkidar campaign. 

#### 2: The Forecasting Data
The csv file: 