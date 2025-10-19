# Load required packages
library(shiny)
library(Biostrings)
library(pwalign)
library(bslib)

setwd("C:/Users/karap/Documents/Sequence_Shiny_App")

# Define UI
my_theme <- bs_theme(
  version = 5,
  bootswatch = "spacelab",
)

ui <- fluidPage(
  titlePanel("Sanger Sequence Alignment Checker"),
  theme = my_theme,
  sidebarLayout(
    sidebarPanel(
      fileInput("reference", "Upload Reference Sequence (FASTA)", accept = ".fasta"), #nolint
      fileInput("sanger", "Upload Sanger Sequence (FASTA)", accept = ".fasta"),
      numericInput("trim_start", "Trim 5' bases from Sanger", value = 20, min = 0), #nolint
      numericInput("trim_end", "Trim 3' bases from Sanger", value = 20, min = 0), #nolint
      actionButton("check", "Check Alignment"),
      br(), br(),
      textOutput("result")
    ),

    mainPanel(
      p("Upload your reference sequence and insert sequence using the panel on the left. Trim the beginning and end of the insert sequence to the point where the Sanger sequencing is a higher level of accuracy, around 20 bases. The mismatch output will display the number of bases aligned out of the total bases checked."), #nolint
      uiOutput("highlighted_sequences"),  # output for colored sequences
      tableOutput("mismatches")
    )
  )
)

# Server logic
server <- function(input, output) {

  observeEvent(input$check, {
    req(input$reference, input$sanger)

    # Read sequences
    reference_seq <- readDNAStringSet(input$reference$datapath)[[1]]
    sanger_seq <- readDNAStringSet(input$sanger$datapath)[[1]]

    # Trim Sanger ends if requested
    trim_start <- input$trim_start
    trim_end <- input$trim_end
    if (trim_end > 0) {
      sanger_seq_trim <- subseq(sanger_seq, start = trim_start + 1, end = length(sanger_seq) - trim_end) #nolint
    } else {
      sanger_seq_trim <- subseq(sanger_seq, start = trim_start + 1)
    }

    # Function to highlight bases with background colors
    highlight_sequence <- function(seq) {
      base_colors <- c(
        A = "#a8f0a8",  # light green
        T = "#f7a8a8",  # light red/pink
        G = "#ffd580",  # light orange/yellow
        C = "#a8c8f0",  # light blue
        N = "#e0e0e0"   # gray
      )

      bases <- strsplit(as.character(seq), "")[[1]]

      highlighted_bases <- sapply(bases, function(b) {
        color <- base_colors[b]
        if (is.na(color)) color <- "#ffffff"  # fallback to white
        paste0("<span style='background-color:", color, "; color:black'>", b, "</span>") #nolint
      })

      paste(highlighted_bases, collapse = "")
    }

    # Progress tracker to display while the app calculates alignment
    withProgress(message = "Aligning sequences...", {
      alignment <- tryCatch({
        pwalign::pairwiseAlignment(
          pattern = sanger_seq_trim,
          subject = reference_seq,
          type = "overlap"
        )
      }, error = function(e) {
        showNotification("Alignment failed: please check FASTA sequences or trimming values.", type = "error") #nolint
      })
    })

    # Calculate % identity
    matches <- nmatch(alignment)
    sanger_len <- length(sanger_seq_trim)
    identity <- matches / sanger_len

    # Determine if ligation was successful
    ligation_success <- ifelse(identity > 0.85, "YES ✅", "NO ❌")

    # Render results
    output$result <- renderText({
      paste0(
        "Matches: ", matches, "/", sanger_len, "\n",
        "Identity: ", round(identity, 3), "\n",
        "Ligation successful: ", ligation_success
      )
    })

    # Show alignment summary
    output$alignment_summary <- renderPrint({
      alignment
    })

    # Highlighted sequence output
    output$highlighted_sequences <- renderUI({
      tagList(
        tags$h4("Reference Sequence"),
        HTML(highlight_sequence(reference_seq)),
        HTML(highlight_sequence(sanger_seq_trim)),
        tags$h4("Trimmed Sanger Sequence")
      )
    })

  }) # end of ObserveEvent
} # end of server section

# Launch app
shinyApp(ui = ui, server = server)
