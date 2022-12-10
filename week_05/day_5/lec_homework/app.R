library(shiny)
library(shinydashboard)
library(tidyverse)
library(bslib)

lec_data <- read_csv("data/lec_data.csv")

### Functions

get_roster <- function(x_team){
  
  lec_data %>% 
    filter(!is.na(player_name), team_name == x_team) %>% 
    select(position, player_name, game_id) %>% 
    group_by(player_name) %>% 
    summarise(position, games = n_distinct(game_id)) %>% 
    distinct() %>% 
    ungroup() %>% 
    select(position, player_name, games) %>% 
    arrange(factor(position, levels = c("top", "mid", "bot", "sup", "jng")), player_name)
}

get_matches <- function(x_team){
  
  lec_data %>% 
    select(game_id, team_name) %>% 
    group_by(game_id) %>%
    filter(team_name == x_team) %>% 
    select(game_id) %>% 
    distinct() %>% 
    pull()
}

get_game_history <- function(x_team){
  
  team_games <- get_matches(x_team)
  
  lec_data %>% 
    select(game_id, date, split, playoffs, game, side, team_name, winner) %>% 
    filter(game_id %in% team_games, team_name != x_team) %>%
    distinct() %>% 
    mutate(winner = !winner) %>% 
    arrange(date, game)
}

get_match_history <- function(x_team, match_data){
  
  get_game_history(x_team) %>% 
    select(date, split, playoffs, game, team_name, winner) %>% 
    mutate(date = as.Date(date)) %>% 
    group_by(date) %>%
    count(team_name, playoffs, split, winner) %>% 
    pivot_wider(names_from = winner, values_from = n) %>% 
    rename(wins = `TRUE`, losses = `FALSE`) %>% 
    mutate(wins = coalesce(wins, 0), losses = coalesce(losses, 0),
           winner = if_else(wins > losses, TRUE, FALSE))
}

### UI

ui <- dashboardPage(
  
  dashboardHeader(),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Team Data", tabName = "team_data", icon = icon("th"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard"
      ),
      
      tabItem(tabName = "team_data",
              fluidRow(
                column(width = 2,
                       selectInput(
                         inputId = "team_select",
                         label = tags$b("Select Team"),
                         choices = sort(unique(lec_data$team_name)))
                       ),
                
                column(width = 3,
                       conditionalPanel(
                         condition = "input.team_tabs == 'Game History'
                                    | input.team_tabs == 'Match History'",
                         radioButtons(inline = TRUE,
                                      inputId = "split_select",
                                      label = tags$b("Split"),
                                      choices = c("Both", "Spring", "Summer")))
                       ),
                
                column(width = 4,
                       conditionalPanel(
                         condition = "input.team_tabs == 'Game History'
                                    | input.team_tabs == 'Match History'",
                         radioButtons(inline = TRUE,
                                      inputId = "playoff_select",
                                      label = tags$b("Playoffs"),
                                      choices = c("Both", "Yes", "No")))
                       )
                
              ),
              
              fluidRow(
                tabBox(id = "team_tabs",
                       width = 12,
                            tabPanel("Roster",
                                     dataTableOutput("roster")),
                            
                            tabPanel("Game History",
                                     dataTableOutput("game_history")),
                            
                            tabPanel("Match History",
                                     dataTableOutput("match_history")))
              )
      )
    )
  )
)

### Server

# Define server logic required to return team data
server <- function(input, output) {
  
  output$roster <- renderDataTable(
    (get_roster(input$team_select)),
    options = list(dom = "t",
                   columnDefs = list(list(targets = "_all", searchable = FALSE))
    )
  )
  
  output$match_history <- renderDataTable(
    (get_match_history(input$team_select) %>% 
       filter(
         split == case_when(
           input$split_select == "Spring" ~ "Spring",
           input$split_select == "Summer" ~ "Summer",
           TRUE ~ split),
         playoffs ==
           case_when(
             input$playoff_select == "Yes" ~ TRUE,
             input$playoff_select == "No" ~ FALSE,
             TRUE ~ playoffs))
    ),
    options = list(pageLength = 10,
                   dom = "ltipr",
                   columnDefs = list(list(targets = "_all", searchable = FALSE))
    )
  )
  
  output$game_history <- renderDataTable(
    (get_game_history(input$team_select) %>% 
       filter(
         split == case_when(
           input$split_select == "Spring" ~ "Spring",
           input$split_select == "Summer" ~ "Summer",
           TRUE ~ split),
         playoffs ==
           case_when(
             input$playoff_select == "Yes" ~ TRUE,
             input$playoff_select == "No" ~ FALSE,
             TRUE ~ playoffs))
    ),
    options = list(pageLength = 10,
                   dom = "ltipr",
                   columnDefs = list(list(targets = "_all", searchable = FALSE))
    )
  )
}

# Run the application 
shinyApp(ui = ui, server = server)