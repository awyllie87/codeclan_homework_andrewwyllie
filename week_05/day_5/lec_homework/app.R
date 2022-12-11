library(shiny)
library(shinydashboard)
library(tidyverse)
library(bslib)

lec_data <- read_csv("data/lec_data.csv")

lec_data_teams <- lec_data %>% 
  filter(is.na(player_name))

lec_data_players <- lec_data %>% 
  filter(!is.na(player_name))

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

### Variables

no_players <- length(unique(na.omit(lec_data$player_name)))

no_games <- length(unique(na.omit(lec_data$game_id)))

no_teams <- length(unique(na.omit(lec_data$team_name)))

total_champs <- length(unique(na.omit(lec_data$champion)))

total_kills <- lec_data_teams %>% 
  summarise(total_kills = sum(kills)) %>% 
  pull()

total_deaths <- lec_data_teams %>% 
  summarise(total_deaths = sum(deaths)) %>% 
  pull()

top5_picks <- lec_data_players %>% 
  select(champion) %>% 
  group_by(champion) %>% 
  summarise(times_picked = n()) %>% 
  slice_max(times_picked, n = 5)

most_picked <- top5_picks %>% 
  slice_max(times_picked) %>% 
  pull(var = champion)

top5_bans <- lec_data %>% 
  filter(is.na(player_name)) %>% 
  select(ban_1:ban_5) %>%
  pivot_longer(1:5, names_to = "ban_no", values_to = "champion") %>% 
  group_by(champion) %>% 
  summarise(times_banned = n()) %>% 
  slice_max(times_banned, n = 5)

most_banned <- top5_bans %>% 
  slice_max(times_banned) %>% 
  pull(var = champion)


### UI

ui <- dashboardPage(
  
  dashboardHeader(),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Headlines", tabName = "headlines", icon = icon("dashboard")),
      menuItem("Team Data", tabName = "team_data", icon = icon("th")),
      menuItem("Player Analysis", tabName = "player_analysis", icon = icon("th"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "headlines",
              fluidRow(valueBoxOutput("dash_total_players"),
                       valueBoxOutput("dash_total_teams"),
                       valueBoxOutput("dash_total_games")),
              
              fluidRow(valueBoxOutput("dash_total_kills"),
                       valueBoxOutput("dash_total_deaths")),
              
              fluidRow(valueBoxOutput("dash_total_champs"),
                       valueBoxOutput("dash_most_picked"),
                       valueBoxOutput("dash_most_banned"))
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
  
  output$dash_total_players <- renderValueBox({
    valueBox(no_players, "Players", color = "blue")})
  
  output$dash_total_teams <- renderValueBox({
    valueBox(no_teams, "Teams", color = "navy")})
  
  output$dash_total_games <- renderValueBox({
    valueBox(no_games, "Games", color = "olive")})
  
  output$dash_total_kills <- renderValueBox({
    valueBox(total_kills, "Kills", color = "maroon")})
  
  output$dash_total_deaths <- renderValueBox({
    valueBox(total_kills, "Deaths", color = "black")})
  
  output$dash_total_champs <- renderValueBox({
    valueBox(total_champs, "Champions Picked", color = "orange")})
  
  output$dash_most_picked <- renderValueBox({
    valueBox(paste(most_picked, collapse = " & "), "Most Picked", color = "black")})
  
  output$dash_most_banned <- renderValueBox({
    valueBox(paste(most_banned, collapse = " & "), "Most Banned", color = "black")})
  
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