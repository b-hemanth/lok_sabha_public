# WORKFLOW Note----
# There is one main file that powers the app: `app.R` in `/lok_sabha/`.
# (github.com/b-hemanth/lok_sabha_public/lok_sabha/app.R) There are two other R
# script files in this same folder, namely: `helpers.R` and `static.R`.
# `helpers.R` contains much of the preprocessing for the app. It reads in the
# data, cleans it, does a lot of the text-mining, and does some preliminary
# sentiment analysis. It pushes out some `.Rds` files and dataframes that are
# then used in `static.R` to produce the static images. These are those plots
# that do not employ reactive variables and are not interactive on the final
# interface. Finally, `../lok_sabha/static/` is the folder that contains the
# static images produced in the R script files. These static images are then
# rendered in the Shiny App.


# A: PREPROCESSING----

# Load shiny packages
library(shiny)
library(shinythemes)
library(shinycssloaders)
library(shinyWidgets)

# Load packages 

library(tidyverse)
library(ggplot2)
library(viridis)
library(ggthemes)
library(gganimate)
library(lubridate)
library(janitor)

# Textmining and sentiment analysis packages for Tab 1

library(tidyr)
library(tidytext)
library(readr)
library(wordcloud)
library(syuzhet)

# Table package for 1.3

library(gt)

# Mapping & geospatial analysis (for tab 4)

library(leaflet)
library(tidycensus)
library(mapview)
library(sf)
library(tmap)
library(tmaptools)
library(tigris)

# I like to use this function

`%!in%` = Negate(`%in%`)

# Reading in data file
# This rds is cleaned, processed, and produced in helpers.R

data <- read_rds("x.rds") %>%
  select(created_at, is_retweet, is_quote, text, favourites_count, retweet_count) %>%
  arrange(desc(favourites_count)) %>%
  top_n(1000) %>%
  mutate(created_at = hour(created_at)) 


# UI-----

ui <-
  shinyUI(
    navbarPage(
      "Twitter in the Biggest Election in the World",
      collapsible = TRUE,
      theme = shinytheme("darkly"),
      inverse = TRUE,
      windowTitle = "Indian Elections Analysis",
      setBackgroundImage(src = "https://images.assettype.com/thequint%2F2019-01%2Fee2f9fbc-b781-4a0f-8ede-ff7234db38c0%2Fsc2.jpg?q=35&auto=format%2Ccompress&w=960"),
      
      # TAB 1: About--------------------------
      
      tabPanel("About",
               mainPanel(
                 h1("2019 Indian Parliamentary Elections: Twitter Data Analysis"),
                 htmlOutput("about")
               )),
      
      # TAB 2: Sentiment Analysis--------------------------
      
      navbarMenu(
        "The Public Sentiment",
        
        tabPanel(
          "The #Chowkidar Campaign",
          mainPanel(tabsetPanel(
            tabPanel("About the #Chowkidar Campaign",
            htmlOutput("chowkidar"))
          ))
          ),
        
        tabPanel(
          "Wordcloud",
          sidebarPanel(
            helpText(
              "This analyzes a mixed sample of 108,000 most popular
              and most recent tweets collected from Twitter on 20 March, 2019,
              that tweeted about the BJP's #MainBhiChowkidar ('I am a guard
              of the nation') campaign. This wordcloud shows the hundred most
              tweeted meaningful words and phrases with greater font
              size indicating greater frequency of being tweeted."
            )
            ),
          mainPanel(tabsetPanel(
            tabPanel("The Most Tweeted Words",
                     withSpinner(imageOutput("wordcloud"), type = 4))
          ))
            ),
        
        tabPanel(
          "Popular Words",
          sidebarPanel(
            helpText(
              "This analyzes a mixed sample of 108,000 most popular
              and most recent tweets collected from Twitter on 20 March, 2019,
              that tweeted about the BJP's #MainBhiChowkidar ('I am a guard
              of the nation') campaign. This plot measures words that
              expressed positive and negative sentiments about the Modi-led
              BJP's #Chowkidar Campaign that achieved the most retweets
              and favourites."
            )
            ),
          mainPanel(tabsetPanel(
            tabPanel(
              "Popular Positive and Negative Words",
              withSpinner(imageOutput("popular_words"), type = 4)
            )
          ))
            ),
        tabPanel(
          "Sentiments: Summary",
          sidebarPanel(
            helpText(
              "This analyzes a mixed sample of 108,000 most popular
              and most recent tweets collected from Twitter on 20 March, 2019,
              that tweeted about the BJP's #MainBhiChowkidar ('I am a guard
              of the nation') campaign. This measures the positive and negative sentiments about the Modi-led BJP's #Chowkidar Campaign."
            )
          ),
          mainPanel(tabsetPanel(
            tabPanel("Sentiments: Summary",
                     withSpinner(gt_output("senti_summary"), type = 4))
          ))
        ),
        tabPanel("Sentiments as the Day Unravelled",
                 sidebarPanel(
                   helpText(
                     "As I expected, sentiments have been pretty stable though they seem to have 
                     been more positive on the 19th. What's interesting about this plot is the 
                     increased negativity and backlash against the campaign starting around
                     6 am on the 20th in American time. This is interesting because this roughly
                     coincides with when the news about white collar criminal Nirav Modi's arrest in London was released. 
                     As you can see from the above wordcloud, words like Nirav Modi and arrest 
                     immediately become some of the most tweeted words. Now, I expected a generally
                     positive reaction to Nirav Modi's arrest. However, the data shows that Nirav 
                     Modi's arrest actually caused an increase in negative tweets
                     about the #Chowkidar aka #MainBhiChowkidar campaign. A lot of tweeters seemed 
                     to believe that this is an election stunt and suspected the convenient timing 
                     of the arrest for the BJP. "
                   )
                 ),
                 mainPanel(tabsetPanel(
                   tabPanel("Sentiments as the Day Unravelled",
                            withSpinner(plotOutput("hourly"), type = 4))
                 ))
        )
      ),
      
      # TAB 3: Fake Tweets-----
      
      tabPanel("Fake? Tweets",
               sidebarLayout(
                 sidebarPanel(
                   helpText(
                     "Some tweets had the exact same message pasted in them and tweeted again
                     and again, thousands of times. This is an analysis of a few of these top (suspected) fake tweets.
                     Fake tweets are used to both spread misinformation and artificially trend
                     chosen hashtags. You can notice that some of these, even more suspiciously,
                     had identical retweet and favorite counts at all times in the day."
                   ),
                   radioButtons("text",
                                "Fake Tweet:", unique(data$text))
                   ),
                
                  # Show a plot of the generated distribution
                 
                 mainPanel(tabsetPanel(
                   tabPanel("Retweets",
                            plotOutput("rtPlot")),
                   tabPanel("Favourites",
                            plotOutput("favtPlot"))
                 ))
               )),
     
       # TAB 4: Forecast-----
      
      tabPanel("The Twitter Forecast",
               sidebarLayout(
                 sidebarPanel(
                   helpText(
                     "Mapping pro- and anti-Modi tweets on a map of India. 
                     Unfortunately, Twitter India has a weak geo-coding system. 
                     Hence, only a limited, small sample of tweets could be mapped.
                     However, this can be expanded once better data becomes available."
                   )),
                
                 # Show a plot of the generated distribution
                 
                 mainPanel(tabsetPanel(
                   tabPanel("The Twitter Forecast",
                            withSpinner(leafletOutput("mymap",height = 1000), type=4))
                 )))
               ))
    )



# SERVER-------------

server <- function(input, output) {
  
  # 1 OUTPUT About
  
  output$about <- renderText({
    "<span style='background-color: black'><font size='5.2' face = 'Georgia'>The 2019 Indian general election is currently being held in seven phases
    from 11 April to 19 May 2019 to constitute the 17th Lok Sabha. The
    counting of votes will be conducted on 23 May, and on the same day
    the results will be declared. About <b>900 million</b> Indian citizens are
    eligible to vote in one of the seven phases depending on the region in what is the world's biggest exercise in democracy. <br><br>Find
    my code at <a href='https://github.com/b-hemanth/lok_sabha_public'>
    https://github.com/b-hemanth/lok_sabha_public</a>.<br><br><b>What is the data?</b><br>A mixed sample of the 
    most popular and most recent one hundred and eight thousand tweets in English from the last 
    three days (as of 20 March, 2019, 10:07 pm EST) on the Bharatiya Janata Party's 
    #MainBhiChowkidar campaign.<br><br><b>A Final Developer's Note:</b><br> 
    Unfortunately, there seem to be no existing machine learning based APIs or CRAN packages to
    deal with Hindi Tweets, so I'm ignoring them. I considered translating and then analyzing, 
    but this seems to have too broad a confidence interval and Google Translate API is too expensive 
    for me. This obviously makes this analysis biased to some extent. Furthermore, even for English 
    sentiment analysis, there is a non-zero margin of error. However, given my rather large sample size, 
    this margin should be adjusted for. My analysis also does not account for paid tweets. So, 
    the positive skew might be caused in some part by the BJP tech cell's tweeting. However, 
    given that I scraped a mixed sample of popular and recent tweets and given that paid tweets 
    are unlikely to be the most popular ones, this skew should be mitigated. Read more about the skew
    <a href='https://www.theatlantic.com/international/archive/2019/04/india-misinformation-election-fake-news/586123/'>
    here</a>.</font></span>"
  })
  
  # 2.1 OUTPUT about chowkidar
  
  output$chowkidar <- renderText({
    "<span style='background-color: black'><font size='5.2' face = 'Georgia'>The incumbent BJP party through the use of the slogan, 'Main bhi Chowkidar' (translated: 'I too am a guard'), began a campaign for the 2019 elections wherein the leaders of the party posited that they were guards of the nation. The BJP campaign created a movement wherein lakhs of citizens pledged their support towards prime minister Modi's integrity by implying that if the prime minister is an honest guardian, so are all of them. This was primarily a twitter campaigns with party leaders inserting 'Guard' in front of their twitter names, tweeting #MainBhiChowkidar, and pushing supporters to do so as well.<br><br> This led to both an increase in public support and mockery of the BJP. In response, the Congress, the opposition party, started a Twitter campaign, 'Chowkidar Chor Hai,' i.e., 'the guard is the thief.'</font></span>"
  })
  
  # 2.2 OUTPUT wordcloud
  
  output$wordcloud <- renderImage({
    list(
      src = "static/wordcloud.png",
      contentType = 'image/png',
      width = 550,
      height = 650
    )
  })
  
  # 2.3 OUTPUT popular words
  
  output$popular_words <- renderImage({
    list(
      src = "static/popular_words.png",
      contentType = 'image/png',
      width = 600,
      height = 900
    )
  })
  
  # 2.4 OUTPUT Sentiment analysis
  
  output$senti_summary <- render_gt({
    tbl <- read_rds("tbl.rds")
    tbl %>%
      select(Sentiment, Percentage) %>%
      gt() %>%
      fmt_percent(columns = vars("Percentage")) %>%
      tab_header(title = "Sentiment Analysis of Tweets About the #Chowkidar Campaign",
                 subtitle = "Analyzing a Mixed Sample of 108,000 of the Most Popular and Most Recent Tweets") %>%
      
      # Cite the data source
      
      tab_source_note(source_note = "Data from Twitter")
  })
  
  # 2.5 OUTPUT Hourly Sentiments
  
  output$hourly <- renderPlot({
    plot <- read_rds("plot_1.4.rds")
    plot %>% 
      ggplot(aes(x = Hour, y = Percentage, fill = Sentiment)) +
      geom_bar(stat = "identity", alpha = 0.6, color = "black") +
      labs(
        title = "Positive and Negative Tweets by Hour",
        subtitle = "From 6 pm on 19 March to 10 pm on 20 March",
        x = "Day and Hour of Day in Eastern Standard Time"
      ) +
      theme_solarized_2(light = FALSE) +
      scale_x_discrete(labels = c("19th-6pm", "", "",  "9pm", "", "", "20th-12am", "", "", "3am", "", "", "6am", "", "", "9am", "",  "", "12pm", "", "", "3pm", "", "", "6pm", "", "",  "9pm", ""))
  })
  
  # 3 OUTPUT: Fake tweets
  # How do we know these are fake tweets? Some tweets had the exact same message
  # pasted in them and tweeted again and again, thousands of times. This is an
  # analysis of a few of the top (suspected) fake tweets. Fake tweets are used
  # to both spread misinformation and artificially trend chosen hashtags. You
  # can notice that some of these, even more suspiciously, had identical retweet
  # and favorite counts at all times in the day.
  
  # 3.1 Retweets
  
  output$rtPlot <- renderPlot({
    
    # Using is_retweet and is_quote to judge if fake tweet: By ensuring that a
    # tweet wasn't a quote of another tweet or a RT we ensure that it's the same
    # text that's being copy-pasted by different users
    
    region_subset <- data %>% filter(!is.na(text), text == input$text)
    ggplot(region_subset, aes(x = created_at, y = retweet_count)) +
      geom_col() +
      geom_point() +
      theme_wsj() + 
      theme_solarized_2(light = FALSE) +
      labs(
        title = "When the IT Cells Strike Twitter* —
        Retweet Count Across the Hours",
        subtitle = "The Indian elections see bot tweeting as a tool to 
        make messages popular: when in the day were these bots deadliest?",
        source = "Data scraped from Twitter; 
        *represents a particular sample, 
        details @https://github.com/b-hemanth/lok_sabha_campaigns",
        x = "Hour of the Day",
        y = "Retweets"
      )
  })
  
  # 3.2 Favourites
  
  output$favtPlot <- renderPlot({
    region_subset <- data %>% filter(!is.na(text), text == input$text)
    ggplot(region_subset, aes(x = created_at, y = favourites_count)) +
      geom_col() +
      geom_point() +
      theme_solarized_2(light = FALSE) +
      labs(
        title = "When the IT Cells Strike Twitter* —
         Favourites Count Across the Hours",
        subtitle = "The Indian elections see bot tweeting as a tool to 
         make messages popular: when in the day were these bots deadliest?",
        source = "Data scraped from Twitter; 
         *represents a particular sample, 
         details @https://github.com/b-hemanth/lok_sabha_campaigns",
        x = "Hour of the Day",
        y = "Favourites"
      )
  })
  
  # 4 Forecast Geospatial
  
  output$mymap <- renderLeaflet({
    
    temp <- read_rds("temp.rds") 
    x <- temp %>% 
      select(text, favourites_count, geo_coords, senti) 
    x <- separate(x, geo_coords, into = c("lat", "lang"), sep = " ")
    x <- as_tibble(as.data.frame(x))
    x <- x %>% 
      mutate(lat = as.double(lat), lang = as.double(lang))
    x <- x %>% 
      filter(!is.na(lat), !is.na(lang))
    leaflet(data = x) %>%
      addTiles() %>% 
      addMarkers(lng = ~lang,
                 lat = ~lat,
                 popup = paste("Positive for Modi:", x$senti$positive, "<br>",
                               "Negative for Modi:", x$senti$negative, "<br>",
                               "Favorites Count", x$favourites_count, "<br>",
                               "Text", x$text, "<br>"))
  })
}

# Run the application--------

shinyApp(ui = ui, server = server)
