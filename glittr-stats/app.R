library(shiny)
library(dplyr)
library(ggplot2)
library(jsonlite)

# parse glittr api at startup
parsed <- fromJSON("https://glittr.org/api/tags",
                   simplifyDataFrame = FALSE)

# create the dataframe with tags and categories
tag_dfs <- list()
for(i in seq_along(parsed)) {
  category <- parsed[[i]]$category
  name <- sapply(parsed[[i]]$tags, function(x) x$name)
  repositories <- sapply(parsed[[i]]$tags, function(x) x$repositories)
  tag_dfs[[category]] <- data.frame(name, category, repositories)
}

tag_df <- do.call(rbind, tag_dfs) |> arrange(repositories)

categories <- unique(tag_df$category)

# set the colors
glittr_cols <- c(
  "Scripting and languages" =             "#3a86ff",
  "Computational methods and pipelines" = "#fb5607",
  "Omics analysis" =                      "#ff006e",
  "Reproducibility and data management" = "#ffbe0b",
  "Statistics and machine learning" =     "#8338ec",
  "Others" =                              "#000000")




# UI ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Repos tagged per category"),
  sidebarLayout(
    
    sidebarPanel(width = 4,
                 checkboxGroupInput(inputId = "categories",
                                    label = "Select category",
                                    choices = categories,
                                    selected = categories),
                 
                 sliderInput(inputId = "min_repos",
                             label = "Minimum number of repos to show per tag",
                             min = 0,
                             max = 50,
                             value = 10),
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(width = 9,
              plotOutput(outputId = "barplot",
                         height = "400px")
              
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  
  
  output$barplot <- renderPlot({
    
    tag_df_filt <- tag_df |>
      filter(repositories > input$min_repos & category %in% input$categories)
    
    tag_freq_plot <- tag_df_filt |>
      ggplot(aes(x = reorder(name, repositories),
                 y = repositories, fill = category)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      scale_fill_manual(values = glittr_cols) +
      ggtitle(paste0("Tags with >", input$min_repos, " repositories")) +
      ylab("Number of repositories") +
      annotate(geom = "text", x = 2, y = 150,
               label = paste("Total number of tags: ",
                             nrow(tag_df_filt)),
               color="black") +
      theme_classic() +
      theme(legend.position = "none",
            axis.title.y = element_blank())
    
    print(tag_freq_plot)
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
