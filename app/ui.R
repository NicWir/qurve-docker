library(shiny, quietly = T)
library(QurvE, quietly = T)
library(shinyBS, quietly = T)
library(shinycssloaders, quietly = T)
library(shinyFiles, quietly = T)
library(shinyjs, quietly = T)
library(shinythemes, quietly = T)
library(ggplot2, quietly = T)

jscode <- "
shinyjs.disableTab = function(name) {
var tab = $('.nav li a[data-value=' + name + ']');
tab.bind('click.tab', function(e) {
e.preventDefault();
return false;
});
tab.addClass('disabled');
}

shinyjs.enableTab = function(name) {
var tab = $('.nav li a[data-value=' + name + ']');
tab.unbind('click.tab');
tab.removeClass('disabled');
}
"
css <- "
.nav li a.disabled {
background-color: #65675F !important;
color: #333 !important;
cursor: not-allowed !important;
border-color: #aaa !important;
}"

load_data <- function() {
  Sys.sleep(2)
  hide("loading_page")
  show("main_content")
}

widePopover <-
  '<div class="popover popover-lg" role="tooltip"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'

ui <- fluidPage(theme = shinythemes::shinytheme(theme = "spacelab"),
                tags$head(
                  tags$style(HTML(".popover.popover-lg {width: 600px; max-width: 600px;}"))
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.gcFitLinear { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.rdm.data { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.gcFitSpline { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.gcFitModel { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.flFitLinear { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.flFitSpline { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.flworkflow { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.fldr { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.growthworkflow { width: fit-content !important; }'
                ),
                tags$style(
                  type = 'text/css',
                  '.modal-dialog.growthdr { width: fit-content !important; }'
                ),
                tagList(
                  # tags$style(type = 'text/css', '.navbar {
                  #          font-size: 200px;
                  #          }',
                  #
                  #            '.navbar-dropdown { background-color: #262626;
                  #          font-family: Arial;
                  #          font-size: 50px;
                  #          color: #FF0000; }',
                  #
                  #            '.navbar-default .navbar-brand {
                  #            ;
                  #          }',
                  #            '.navbar li a {
                  #            font-size: 50px;
                  #          }'
                  #
                  # ),

                  # # Create object input$dimension as c(width, height) with the app window size
                  # tags$head(tags$script('
                  #               var dimension = [0, 0];
                  #               $(document).on("shiny:connected", function(e) {
                  #                   dimension[0] = window.innerWidth;
                  #                   dimension[1] = window.innerHeight;
                  #                   Shiny.onInputChange("dimension", dimension);
                  #               });
                  #               $(window).resize(function(e) {
                  #                   dimension[0] = window.innerWidth;
                  #                   dimension[1] = window.innerHeight;
                  #                   Shiny.onInputChange("dimension", dimension);
                  #               });
                  #           ')),
                  useShinyjs(),
                  shinyjs::extendShinyjs(text = jscode, functions = c("disableTab","enableTab")),
                  shinyjs::inlineCSS(css),
                  div(
                    id = "loading_page",
                    HTML("<br>"),
                    HTML("<br>"),
                    HTML('<center><img src="QurvE_logo.png" width="500" vertical-align="middle"></center>'),
                    HTML("<br>"),
                    HTML("<br>"),
                    h1("Initializing...", align = "center")
                  ),
                  hidden(
                    div(
                      id = "main_content",
                      navbarPage(
                        'QurvE',
                        id = "navbar",

                        # load input file
                        #____DATA____####
                        tabPanel(span("Data", title = "Upload custom formatted data or parse results from plate readers and similar devices."),
                                 icon = icon("file-lines"),
                                 value = "tabPanel",
                                 tabsetPanel(type = "tabs", id = "tabs_data",
                                             ##____CUSTOM____####
                                             tabPanel(value = "Custom", span("Custom", title="Upload manually formatted data. Data from different experiments can be added. In column format, the first three table rows contain (see figure):\n1. sample description\n2. replicate number (optional: followed by a letter to indicate technical replicates)\n3. concentration value (optional, for dose-response analysis)"),
                                                      sidebarPanel(
                                                        style='border-color: #ADADAD',
                                                        # Growth data
                                                        wellPanel(
                                                          h4(strong("Growth data"), style = "line-height: 0.4;font-size: 150%; margin-bottom: 15px;"),
                                                          style='padding: 0.1; border-color: #ADADAD; padding: 1; padding-bottom: 0',

                                                          fileInput(inputId = 'custom_file_growth',
                                                                    label = 'Choose growth data file',
                                                                    accept = c('.xlsx', '.xls', '.csv', '.txt', '.tsv')
                                                          ),

                                                          conditionalPanel(
                                                            condition = "output.growthfileUploaded && output.custom_growth_format == 'xlsx'",
                                                            div(style = "margin-bottom: -20px"),
                                                            selectInput(inputId = "custom_growth_sheets",
                                                                        label = "Select Sheet",
                                                                        choices = "Sheet1")

                                                          ), # select sheet: conditional
                                                          conditionalPanel(
                                                            condition = "output.growthfileUploaded && output.custom_growth_format == 'csv'",

                                                            selectInput(inputId = "separator_custom_growth",
                                                                        label = "Select separator",
                                                                        choices = c("," = ",",
                                                                                    ";" = ";")
                                                            ),

                                                            selectInput(inputId = "decimal_separator_custom_growth",
                                                                        label = "Select Decimal separator",
                                                                        choices = c("." = ".",
                                                                                    "," = ",")
                                                            )
                                                          ),
                                                          conditionalPanel(
                                                            condition = "output.growthfileUploaded && (output.custom_growth_format == 'tsv' || output.custom_growth_format == 'txt')",

                                                            selectInput(inputId = "decimal_separator_custom_growth",
                                                                        label = "Select Decimal separator",
                                                                        choices = c("." = ".",
                                                                                    "," = ",")
                                                            )
                                                          ),
                                                          div(style = "margin-bottom: -15px"),
                                                          tags$div(title="Provide an equation in the form 'y = function(x)' (for example: 'y = x^2 * 0.3 - 0.5') to convert growth values. This can be used to, e.g., convert plate reader absorbance values into OD600.",
                                                                   checkboxInput(inputId = 'calibration_growth_custom',
                                                                                 label = 'Apply calibration')
                                                          ),
                                                          conditionalPanel(
                                                            condition = 'input.calibration_growth_custom',
                                                            div(style = "margin-bottom: -10px"),
                                                            textInput(inputId = "calibration_equation_growth_custom",
                                                                      label = "Type equation in the form 'y = function(x)'",
                                                                      placeholder = 'y = x * 0.5 - 1'
                                                            )
                                                          ),
                                                        ),
                                                        #____Fluorescence___________
                                                        wellPanel(
                                                          h4(strong("Fluorescence data"), style = "line-height: 1;font-size: 150%; margin-bottom: 15px;"),
                                                          style='padding: 0.1; border-color: #ADADAD; padding: 1; padding-bottom: 0',

                                                          fileInput(inputId = 'custom_file_fluorescence',
                                                                    label = 'Choose fluorescence data file',
                                                                    accept = c('.xlsx', '.xls', '.csv', '.txt', '.tsv')
                                                          ),

                                                          conditionalPanel(
                                                            condition = "output.fluorescencefileUploaded && output.custom_fluorescence_format == 'xlsx'",
                                                            div(style = "margin-bottom: -20px"),
                                                            selectInput(inputId = "custom_fluorescence_sheets",
                                                                        label = "Select Sheet",
                                                                        choices = "Sheet1")
                                                          ), # select sheet: conditional
                                                          conditionalPanel(
                                                            condition = "output.fluorescencefileUploaded && output.custom_fluorescence_format == 'csv'",

                                                            selectInput(inputId = "separator_custom_fluorescence",
                                                                        label = "Select separator",
                                                                        choices = c("," = ",",
                                                                                    ";" = ";")
                                                            ),

                                                            selectInput(inputId = "decimal_separator_custom_fluorescence",
                                                                        label = "Select Decimal separator",
                                                                        choices = c("." = ".",
                                                                                    "," = ",")
                                                            )
                                                          ),
                                                          conditionalPanel(
                                                            condition = "output.fluorescencefileUploaded && (output.custom_fluorescence_format == 'tsv' || output.custom_fluorescence_format == 'txt')",

                                                            selectInput(inputId = "decimal_separator_custom_fluorescence",
                                                                        label = "Select Decimal separator",
                                                                        choices = c("." = ".",
                                                                                    "," = ",")
                                                            )
                                                          ),
                                                          div(style = "margin-top: -15px"),
                                                          tags$div(title="Provide an equation in the form 'y = function(x)' (for example: 'y = x^2 * 0.3 - 0.5') to convert fluorescence values. This can be used to, e.g., convert fluorescence intensities into molecule concentrations.",
                                                                   checkboxInput(inputId = 'calibration_fluorescence_custom',
                                                                                 label = 'Apply calibration')
                                                          ),
                                                          conditionalPanel(
                                                            condition = 'input.calibration_fluorescence_custom',
                                                            div(style = "margin-bottom: -10px"),
                                                            textInput(inputId = "calibration_equation_fluorescence_custom",
                                                                      label = "Type equation in the form 'y = function(x)'",
                                                                      placeholder = 'y = x * 0.5 - 1'
                                                            )
                                                          ),
                                                        ), # wellpanel

                                                        conditionalPanel(
                                                          condition = "output.fluorescencefileUploaded",
                                                          checkboxInput(inputId = 'load_fl2_data_custom',
                                                                        label = 'Use second fluorescence to normalize fluorescence.',
                                                                        value = FALSE),
                                                          bsPopover("load_fl2_data_custom", title = "Provide a table file with fluorescence 2 data",
                                                                    content = "Table layout must mimic that of growth data. Fluorescence 2 data is only used to normalize of fluorescence!")
                                                        ),
                                                        # #_____Fluorescence 2___________
                                                        conditionalPanel(
                                                          condition = "input.load_fl2_data_custom",
                                                          wellPanel(
                                                            h4(strong("Fluorescence 2 data"), style = "line-height: 1;font-size: 150%; margin-bottom: 15px;"),
                                                            style='padding: 0.1; border-color: #ADADAD; padding: 1; padding-bottom: 0',


                                                            fileInput(inputId = 'custom_file_fluorescence2',
                                                                      label = 'Choose fluorescence2 data file',
                                                                      accept = c('.xlsx', '.xls', '.csv', '.txt', '.tsv')
                                                            ),


                                                            conditionalPanel(
                                                              condition = "output.fluorescence2fileUploaded && output.custom_fluorescence2_format == 'xlsx'",
                                                              wellPanel(
                                                                style='padding: 1; border-color: #ADADAD; padding-bottom: 0',
                                                                div(style = "margin-bottom: -20px"),
                                                                selectInput(inputId = "custom_fluorescence2_sheets",
                                                                            label = "Select Sheet",
                                                                            choices = "Sheet1")
                                                              )
                                                            ), # select sheet: conditional
                                                            conditionalPanel(
                                                              condition = "output.fluorescence2fileUploaded && output.custom_fluorescence2_format == 'csv'",
                                                              wellPanel(
                                                                style='padding: 1; border-color: #ADADAD; padding-bottom: 0',
                                                                selectInput(inputId = "separator_custom_fluorescence2",
                                                                            label = "Select separator",
                                                                            choices = c("," = ",",
                                                                                        ";" = ";")
                                                                ),

                                                                selectInput(inputId = "decimal_separator_custom_fluorescence2",
                                                                            label = "Select Decimal separator",
                                                                            choices = c("." = ".",
                                                                                        "," = ",")
                                                                )
                                                              )
                                                            ),
                                                            conditionalPanel(
                                                              condition = "output.fluorescence2fileUploaded && (output.custom_fluorescence2_format == 'tsv' || output.custom_fluorescence2_format == 'txt')",
                                                              wellPanel(
                                                                style='padding: 1; border-color: #ADADAD; padding-bottom: 0',
                                                                selectInput(inputId = "decimal_separator_custom_fluorescence2",
                                                                            label = "Select Decimal separator",
                                                                            choices = c("." = ".",
                                                                                        "," = ",")
                                                                )
                                                              )
                                                            ),
                                                            div(style = "margin-top: -15px"),
                                                            tags$div(title="Provide an equation in the form 'y = function(x)' (for example: 'y = x^2 * 0.3 - 0.5') to convert fluorescence2 values. This can be used to, e.g., convert fluorescence intensities into molecule concentrations.",
                                                                     checkboxInput(inputId = 'calibration_fluorescence2_custom',
                                                                                   label = 'Apply calibration')
                                                            ),
                                                            conditionalPanel(
                                                              condition = 'input.calibration_fluorescence2_custom',
                                                              div(style = "margin-bottom: -10px"),
                                                              textInput(inputId = "calibration_equation_fluorescence2_custom",
                                                                        label = "Type equation in the form 'y = function(x)'",
                                                                        placeholder = 'y = x * 0.5 - 1'
                                                              )
                                                            ),
                                                          ) # wellPanel
                                                        ),

                                                        selectInput(inputId = 'norm_type_custom',
                                                                    label = 'Select data type for fluorescence normalization',
                                                                    choices = ""),

                                                        tags$div(title="Shall blank values (the mean of samples identified by 'Blank' IDs) be subtracted from values within the same experiment?",
                                                                 checkboxInput(inputId = 'subtract_blank_custom',
                                                                               label = 'Subtract blank',
                                                                               value = TRUE)
                                                        ),

                                                        tags$div(title=HTML(paste("Provide an equation in the form 'y = function(x)' to convert time values. For example, type 'y = x / 60' to convert minutes to hours.\n", "Note: the time unit will affect calculated parameters (e.g., the growth rate in 1/h, 1/min, or 1/s) as well as the time displayed in all plots.")),
                                                                 checkboxInput(inputId = 'convert_time_values_custom',
                                                                               label = 'Convert time values',
                                                                               value = FALSE)
                                                        ),

                                                        conditionalPanel(
                                                          condition = 'input.convert_time_values_custom',
                                                          tags$div(title=HTML(paste("Provide an equation in the form 'y = function(x)' to convert time values. For example, type 'y = x / 60' to convert minutes to hours.\n", "Note: the time unit will affect calculated parameters (e.g., the growth rate in 1/h, 1/min, or 1/s) as well as the time displayed in all plots.")),
                                                                   div(style = "margin-bottom: -10px"),
                                                                   textInput(inputId = "convert_time_equation_custom",
                                                                             label = "Type equation in the form 'y = function(x)'",
                                                                             placeholder = 'y = x / 24')
                                                          )
                                                        ),

                                                        conditionalPanel(
                                                          condition = 'output.growthfileUploaded || output.fluorescencefileUploaded',
                                                          fluidRow(
                                                            column(12,
                                                                   div(
                                                                     actionButton(inputId = "read_custom",
                                                                                  label = "Read data",
                                                                                  icon=icon("file-lines"),
                                                                                  style="padding:5px; font-size:120%"),
                                                                     style="float:right")
                                                            )
                                                          )
                                                        ),
                                                        HTML("<br>"),
                                                        HTML("<br>"),
                                                        tags$div(title="Simulate growth curves to generate a random demo dataset.",
                                                                 actionButton(inputId = "random_data_growth",
                                                                              label = "Create random growth dataset",
                                                                              icon=icon("shuffle"),
                                                                              style="padding:4px; font-size:80%; color: white; background-color: #35e51d")
                                                        ),
                                                      ),# sidebar panel
                                             ), # Custom tabPanel

                                             ##____PLATE READER____####

                                             tabPanel(value = "Parse Raw Data", span("Parse Raw Data", title="Upload a results table file generated with the default export function of a plate reader (or similar device) software. Sample information need to be provided in a separate table."),
                                                      sidebarPanel(
                                                        style='border-color: #ADADAD',
                                                        wellPanel(
                                                          div(style = "margin-top: -10px"),
                                                          h3(strong("1. Load data"), style = "line-height: 0.4;font-size: 150%; margin-bottom: 15px;"),
                                                          style='padding: 5px; border-color: #ADADAD;',
                                                          # select file type
                                                          fileInput(inputId = 'parse_file',
                                                                    label = 'Choose raw export file',
                                                                    accept = c('.xlsx', '.xls', '.csv', '.tsv', '.txt')),
                                                          div(style = "margin-top: -10px"),
                                                          conditionalPanel(
                                                            condition = "output.parsefileUploaded && (output.parse_file_format == 'xlsx' | output.parse_file_format == 'xls')",
                                                            selectInput(inputId = "parse_data_sheets",
                                                                        label = "Select sheet with read data",
                                                                        choices = "Sheet1")
                                                          ), # select sheet: conditional
                                                          conditionalPanel(
                                                            condition = "output.parsefileUploaded && output.parse_file_format == 'csv'",
                                                            selectInput(inputId = "separator_parse",
                                                                        label = "Select separator",
                                                                        choices = c("," = ",",
                                                                                    ";" = ";")
                                                            ),

                                                            selectInput(inputId = "decimal_separator_parse",
                                                                        label = "Select Decimal separator",
                                                                        choices = c("." = ".",
                                                                                    "," = ",")
                                                            )
                                                          ),
                                                          conditionalPanel(
                                                            condition = "output.parsefileUploaded && (output.parse_file_format == 'tsv' || output.parse_file_format == 'txt')",
                                                            selectInput(inputId = "decimal_separator_parse",
                                                                        label = "Select Decimal separator",
                                                                        choices = c("." = ".",
                                                                                    "," = ",")
                                                            )
                                                          )
                                                        ),
                                                        div(style = "margin-top: -15px"),
                                                        conditionalPanel(
                                                          condition = "output.parsefileUploaded",
                                                          wellPanel(
                                                            style='padding: 5px; border-color: #ADADAD; padding-bottom: 0',
                                                            div(style = "margin-top: -10px"),
                                                            h3(strong("2. Format"), style = "line-height: 0.4;font-size: 150%; margin-bottom: 15px;"),
                                                            selectizeInput(inputId = "platereader_software",
                                                                           label = "Platereader software",
                                                                           choices = c("Biotek - Gen5/Gen6" = "Gen5",
                                                                                       "Biolector" = "Biolector",
                                                                                       "Chi.Bio" = "Chi.Bio",
                                                                                       "Growth Profiler 960" = "GrowthProfiler",
                                                                                       "Tecan i-control" = "Tecan",
                                                                                       "PerkinElmer - Victor Nivo" = "VictorNivo",
                                                                                       "PerkinElmer - Victor X3" = "VictorX3"
                                                                           ),
                                                                           multiple = TRUE,
                                                                           options = list(maxItems = 1)
                                                            )
                                                          )
                                                        ),
                                                        div(style = "margin-top: -15px"),
                                                        conditionalPanel(
                                                          condition = "output.parsefileUploaded",
                                                          wellPanel(
                                                            style='padding: 5px; border-color: #ADADAD; padding-bottom: 0',
                                                            div(style = "margin-top: -10px"),
                                                            h3(strong("3. Assign data type"), style = "line-height: 0.4; font-size: 150%; margin-bottom: 15px;"),
                                                            conditionalPanel(
                                                              condition = "input.platereader_software != 'GrowthProfiler'",

                                                              # Growth Read
                                                              selectInput(inputId = "parsed_reads_growth",
                                                                          label = "Growth data",
                                                                          choices = ""
                                                              ),
                                                              conditionalPanel(
                                                                condition = "input.parsed_reads_growth.length > 0 && input.parsed_reads_growth != 'Ignore'",
                                                                div(style = "margin-top: -15px"),
                                                                tags$div(title="Provide an equation in the form 'y = function(x)' (for example: 'y = x^2 * 0.3 - 0.5') to convert growth values. This can be used to, e.g., convert plate reader absorbance values into OD600.",
                                                                         checkboxInput(inputId = 'calibration_growth_plate_reader',
                                                                                       label = 'Apply calibration'),
                                                                ),
                                                                conditionalPanel(
                                                                  condition = "input.calibration_growth_plate_reader",
                                                                  div(style = "margin-bottom: -10px"),
                                                                  textInput(inputId = "calibration_equation_growth_plate_reader",
                                                                            label = NULL,
                                                                            placeholder = 'y = x * 0.5 - 1',
                                                                            width = "85%")

                                                                )
                                                              ),

                                                              # Fluorescence Read
                                                              selectInput(inputId = "parsed_reads_fluorescence",
                                                                          label = "Fluorescence data",
                                                                          choices = ""
                                                              ),
                                                              conditionalPanel(
                                                                condition = "input.parsed_reads_fluorescence.length > 0 && input.parsed_reads_fluorescence != 'Ignore'",
                                                                div(style = "margin-top: -15px"),
                                                                tags$div(title="Provide an equation in the form 'y = function(x)' (for example: 'y = x^2 * 0.3 - 0.5') to convert fluorescence values. This can be used to, e.g., convert fluorescence intensities into molecule concentrations.",
                                                                         checkboxInput(inputId = 'calibration_fluorescence_plate_reader',
                                                                                       label = 'Apply calibration')
                                                                ),
                                                                conditionalPanel(
                                                                  condition = "input.calibration_fluorescence_plate_reader",
                                                                  div(style = "margin-bottom: -10px"),
                                                                  textInput(inputId = "calibration_equation_fluorescence_plate_reader",
                                                                            label = NULL,
                                                                            placeholder = 'y = x * 0.5 - 1',
                                                                            width = "85%"),
                                                                )
                                                              ),

                                                              # Fluorescence2 Read
                                                              selectInput(inputId = "parsed_reads_fluorescence2",
                                                                          label = "Fluorescence data 2 (used only for normalization)",
                                                                          choices = ""
                                                              ),
                                                              conditionalPanel(
                                                                condition = "input.parsed_reads_fluorescence2.length > 0 && input.parsed_reads_fluorescence2 != 'Ignore'",
                                                                div(style = "margin-top: -15px"),
                                                                tags$div(title="Provide an equation in the form 'y = function(x)' (for example: 'y = x^2 * 0.3 - 0.5') to convert fluorescence values. This can be used to, e.g., convert fluorescence intensities into molecule concentrations.",
                                                                         checkboxInput(inputId = 'calibration_fluorescence2_plate_reader',
                                                                                       label = 'Apply calibration')
                                                                ),
                                                                conditionalPanel(
                                                                  condition = "input.calibration_fluorescence2_plate_reader",
                                                                  div(style = "margin-bottom: -10px"),
                                                                  textInput(inputId = "calibration_equation_fluorescence2_plate_reader",
                                                                            label = NULL,
                                                                            placeholder = 'y = x * 0.5 - 1',
                                                                            width = "85%")

                                                                )
                                                              ),
                                                            ), # conditionalPanel
                                                          ) # wellPanel
                                                        ),
                                                        div(style = "margin-top: -15px"),
                                                        conditionalPanel(
                                                          condition = "output.parsefileUploaded",
                                                          wellPanel(
                                                            style='padding: 5px; border-color: #ADADAD; padding-bottom: 0',
                                                            div(style = "margin-top: -10px"),
                                                            h3(strong("4. Load mapping"), style = "line-height: 0.4; font-size: 150%; margin-bottom: 15px;"),
                                                            conditionalPanel(
                                                              condition = "output.parse_file_format == 'xlsx' | output.parse_file_format == 'xls'",
                                                              tags$div(title="A table with mapping information is stored within the same Excel file that contains experimental data as separate sheet.",
                                                                       checkboxInput(inputId = 'mapping_included_in_parse',
                                                                                     label = 'Included in data file (xlsx/xls)',
                                                                                     value = FALSE)
                                                              )
                                                            ),
                                                            tags$div(title = "Table with four columns: Well | Description | Replicate | Concentration",
                                                                     fileInput(inputId = 'map_file',
                                                                               label = 'Choose mapping file',
                                                                               accept = c('.xlsx', '.xls', '.csv', '.tsv', '.txt'),
                                                                               placeholder = "map file",
                                                                     )
                                                            ),
                                                            conditionalPanel(
                                                              condition = "(input.mapping_included_in_parse && (output.parse_file_format == 'xlsx' | output.parse_file_format == 'xls')) || (!input.mapping_included_in_parse && output.mapfileUploaded && (output.map_file_format == 'xlsx' | output.map_file_format == 'xls'))",
                                                              selectInput(inputId = "map_data_sheets",
                                                                          label = "Select sheet with mapping information",
                                                                          choices = "Sheet1")
                                                            ),
                                                            conditionalPanel(
                                                              condition = "!input.mapping_included_in_parse && output.mapfileUploaded && output.map_file_format == 'csv'",
                                                              selectInput(inputId = "separator_map",
                                                                          label = "Select separator",
                                                                          choices = c("," = ",",
                                                                                      ";" = ";")
                                                              ),

                                                              selectInput(inputId = "decimal_separator_map",
                                                                          label = "Select Decimal separator",
                                                                          choices = c("." = ".",
                                                                                      "," = ",")
                                                              )
                                                            ),
                                                            conditionalPanel(
                                                              condition = "!input.mapping_included_in_parse && output.mapfileUploaded && (output.map_file_format == 'tsv' || output.map_file_format == 'txt')",
                                                              style='padding: 5px; border-color: #ADADAD; padding-bottom: 0',
                                                              selectInput(inputId = "decimal_separator_map",
                                                                          label = "Select Decimal separator",
                                                                          choices = c("." = ".",
                                                                                      "," = ",")
                                                              )
                                                            )
                                                          )
                                                        ),

                                                        selectInput(inputId = 'norm_type_parse',
                                                                    label = 'Select Read for fluorescence normalization',
                                                                    choices = ""),

                                                        tags$div(title="Shall blank values (the mean of samples identified by 'Blank' IDs) be subtracted from values within the same experiment?",
                                                                 checkboxInput(inputId = 'subtract_blank_plate_reader',
                                                                               label = 'Subtract blank',
                                                                               value = TRUE)
                                                        ),

                                                        tags$div(title=HTML(paste("Provide an equation in the form 'y = function(x)' to convert time values. For example, type 'y = x / 60' to convert minutes to hours.\n", "Note: the time unit will affect calculated parameters (e.g., the growth rate in 1/h, 1/min, or 1/s) as well as the time displayed in all plots.")),
                                                                 checkboxInput(inputId = 'convert_time_values_plate_reader',
                                                                               label = 'Convert time values',
                                                                               value = TRUE)
                                                        ),
                                                        conditionalPanel(
                                                          condition = 'input.convert_time_values_plate_reader',
                                                          tags$div(title=HTML(paste("Provide an equation in the form 'y = function(x)' to convert time values. For example, type 'y = x / 60' to convert minutes to hours.\n", "Note: the time unit will affect calculated parameters (e.g., the growth rate in 1/h, 1/min, or 1/s) as well as the time displayed in all plots.")),
                                                                   div(style = "margin-bottom: -10px"),
                                                                   textInput(inputId = "convert_time_equation_plate_reader",
                                                                             label = "Type equation in the form 'y = function(x)'",
                                                                             placeholder = 'y = x / 24')
                                                          )
                                                        ),

                                                        fluidRow(
                                                          column(12,
                                                                 div(
                                                                   actionButton(inputId = "parse_data",
                                                                                label = "Parse data",
                                                                                icon=icon("file-lines"),
                                                                                style="padding:5px; font-size:120%"),
                                                                   style="float:right")
                                                          )
                                                        )
                                                      ),# sidebar panel
                                             ), # Plate reader tabPanel
                                 ), # tabSet Panel

                                 ##____DATA - MAIN PANEL____####

                                 mainPanel(
                                   div(
                                     id = "data_instruction",
                                     conditionalPanel(
                                       condition = "input.tabs_data == 'Custom'",
                                       img(src = 'data_instruction.png',
                                           width = '100%')
                                     )
                                   ),
                                   bsPopover(id = "data_instruction", title = "Custom data layout",
                                             content = paste("Please format your data in the format shown in the figure:",
                                                             paste0(
                                                               "<ul>",
                                                               "<li>The first row contains \\'Time\\' and \\'Blank\\', as well as sample identifiers \\(identical for replicates\\).</li>",
                                                               "<li>The second row contains replicate numbers for identical conditions. If technical replicates were used in addition to biological replicates, indicate technical replicates with the same replicate number. Samples with identical IDs, concentrations, and replicate <i>numbers</i> will be combined by their <i>average</i>.</li>",
                                                               "<li>The third row contains \\(optional\\) concentration values to perform a dose-response analysis, if different concentrations of a compound were used in the experiment.</li>",
                                                               "</ul>"
                                                             ),
                                                             "Details:",
                                                             paste0(
                                                               "<ul>",
                                                               "<li>Different experiments with differing time values and experiment-specific blanks are distinguished by an individual \\'Time\\' column to the left of each dataset.</li>",
                                                               "<li>Blank values \\(for each experiment\\) are combined as their average and subtracted from all remaining values if option \\[Subtract blank\\] is selected.</li>",
                                                               "<li>The metadata in the second and third rows are optional to perform the analysis and can be left empty.</li>",
                                                               "</ul>"
                                                             ),
                                                             sep = "<br>"),
                                             trigger = "hover", options = list(container = "body", template = widePopover)
                                   ),

                                   div(
                                     id = "mapping_layout",
                                     conditionalPanel(
                                       condition = "input.tabs_data != 'Custom' && output.parsefileUploaded",
                                       img(src = 'mapping_layout.png',
                                           width = '60%')
                                     )
                                   ),
                                   bsPopover(id = "mapping_layout", title = "Mapping layout",
                                             content = paste("Please format a table providing sample information in the format shown in the figure:",
                                                             paste0(
                                                               "<ul>",
                                                               "<li>The first column contains the <i>well</i> position/name in the plate.</li>",
                                                               "<li>The second column contains the <i>ID</i> \\(i.e., organism, condition, etc.\\) of each sample. The ID needs to be identical for replicates.</li>",
                                                               "<li>The third column row contains replicate numbers for the same conditions. If technical replicates were used in addition to biological replicates, indicate technical replicates with the same replicate number. Samples with identical IDs, concentrations, and replicate <i>numbers</i> will be combined by their <i>average</i>.</li>",
                                                               "<li>The fourth column contains \\(optional\\) concentration values to perform a dose-response analysis, if different concentrations of a compound were used in the experiment.</li>",
                                                               "</ul>"
                                                             ),
                                                             "Details:",
                                                             paste0(
                                                               "The values in \\'Blank\\' samples are combined as their average and subtracted from all remaining values if option \\[Subtract blank\\] is selected. The metadata in the third and fourth columns are optional to perform the analysis and can be left empty."
                                                             ),
                                                             sep = "<br>"),
                                             trigger = "hover", options = list(container = "body", template = widePopover)
                                   ),

                                   div(id = 'Custom_Data_Tables',
                                       h1("Your Data"),
                                       tabsetPanel(type = "tabs", id = "tabsetPanel_custom_tables",
                                                   tabPanel(title = "Growth plot", value = "tabPanel_custom_plots_growth",
                                                            withSpinner(
                                                              plotOutput("custom_raw_growth_plot",
                                                                         width = "100%", height = "1000px"),

                                                            )
                                                   ),
                                                   tabPanel(title = "Fluorescence plot", value = "tabPanel_custom_plots_fluorescence",
                                                            withSpinner(
                                                              plotOutput("custom_raw_fluorescence_plot",
                                                                         width = "100%", height = "1000px"),

                                                            )
                                                   ),
                                                   tabPanel(title = "norm. Fluorescence plot", value = "tabPanel_custom_plots_norm_fluorescence",
                                                            withSpinner(
                                                              plotOutput("custom_raw_norm_fluorescence_plot",
                                                                         width = "100%", height = "1000px"),

                                                            )
                                                   ),
                                                   tabPanel(title = "Growth", value = "tabPanel_custom_tables_growth_processed",
                                                            withSpinner(
                                                              DT::dataTableOutput("growth_data_custom_processed")
                                                            ),
                                                            downloadButton('download_custom_tables_growth_processed',"Download table")
                                                   ),
                                                   # tabPanel(title = "Fluorescence", value = "tabPanel_custom_tables_fluorescence",
                                                   #          withSpinner(
                                                   #            DT::dataTableOutput("custom_table_fluorescence")
                                                   #          )
                                                   # ),
                                                   tabPanel(title = "Fluorescence", value = "tabPanel_custom_tables_fluorescence_processed",
                                                            withSpinner(
                                                              DT::dataTableOutput("custom_table_fluorescence_processed")
                                                            ),
                                                            downloadButton('download_custom_tables_fluorescence_processed',"Download table")
                                                   ),
                                                   tabPanel(title = "Normalized fluorescence", value = "tabPanel_custom_tables_norm_fluorescence_processed",
                                                            withSpinner(
                                                              DT::dataTableOutput("custom_table_norm_fluorescence_processed")
                                                            ),
                                                            downloadButton('download_custom_tables_norm_fluorescence_processed',"Download table")
                                                   ),
                                                   # tabPanel(title = "Fluorescence 2", value = "tabPanel_custom_tables_fluorescence2",
                                                   #          withSpinner(
                                                   #            DT::dataTableOutput("custom_table_fluorescence2")
                                                   #          )
                                                   # ),
                                                   tabPanel(title = "Experimental Design", value = "tabPanel_custom_tables_expdesign",
                                                            DT::dataTableOutput('custom_data_table_expdesign'),
                                                            downloadButton('download_custom_tables_expdesign',"Download table")
                                                   ),

                                       )
                                   ),
                                   div(id = 'Parsed_Data_Tables',
                                       h1("Parsed Data"),
                                       tabsetPanel(type = "tabs", id = "tabsetPanel_parsed_tables",
                                                   tabPanel(title = "Growth plot", value = "tabPanel_parsed_plots_growth",
                                                            withSpinner(
                                                              plotOutput("parsed_raw_growth_plot",
                                                                         width = "100%", height = "1000px"),

                                                            )
                                                   ),
                                                   tabPanel(title = "Fluorescence plot", value = "tabPanel_parsed_plots_fluorescence",
                                                            withSpinner(
                                                              plotOutput("parsed_raw_fluorescence_plot",
                                                                         width = "100%", height = "1000px"),

                                                            )
                                                   ),
                                                   tabPanel(title = "norm. Fluorescence plot", value = "tabPanel_parsed_plots_norm_fluorescence",
                                                            withSpinner(
                                                              plotOutput("parsed_raw_norm_fluorescence_plot",
                                                                         width = "100%", height = "1000px"),

                                                            )
                                                   ),
                                                   tabPanel(title = "Growth", value = "tabPanel_parsed_tables_growth",
                                                            DT::dataTableOutput('parsed_data_table_growth'),
                                                            downloadButton('download_parsed_tables_growth',"Download table")
                                                   ),
                                                   tabPanel(title = "Fluorescence", value = "tabPanel_parsed_tables_fluorescence",
                                                            DT::dataTableOutput('parsed_data_table_fluorescence'),
                                                            downloadButton('download_parsed_tables_fluorescence',"Download table")
                                                   ),
                                                   tabPanel(title = "Normalized fluorescence", value = "tabPanel_parsed_tables_norm_fluorescence",
                                                            withSpinner(
                                                              DT::dataTableOutput("parsed_data_table_norm_fluorescence")
                                                            ),
                                                            downloadButton('download_parsed_data_table_norm_fluorescence',"Download table")
                                                   ),
                                                   # tabPanel(title = "Fluorescence 2", value = "tabPanel_parsed_tables_fluorescence2",
                                                   #          DT::dataTableOutput('parsed_data_table_fluorescence2')
                                                   # ),
                                                   tabPanel(title = "Experimental Design", value = "tabPanel_parsed_tables_expdesign",
                                                            DT::dataTableOutput('parsed_data_table_expdesign'),
                                                            downloadButton('download_parsed_tables_expdesign',"Download table")
                                                   )
                                       )
                                   )
                                 ) # main panel
                        ), # Navbar 1

                        #____COMPUTATION____####

                        navbarMenu(span("Computation", title = "Run a complete data analysis workflow."),
                                   menuName = "navbarMenu_Computation", icon=icon("gears"),

                                   ##____Computation_Growth____####

                                   tabPanel("Growth", value = "tabPanel_Computation_Growth",
                                            fluidRow(
                                              sidebarLayout(
                                                column(4,
                                                       sidebarPanel( width = 12,
                                                                     style='border-color: #ADADAD',
                                                                     wellPanel(
                                                                       style='padding: 1; border-color: #ADADAD; padding-top: 0; padding-bottom: 0',
                                                                       h2(strong('Growth fit')),
                                                                       h4('Global fit options'),
                                                                       tags$div(title="Perform linear regression on (log-transformed) growth data.",
                                                                                checkboxInput(inputId = 'linear_regression_growth',
                                                                                              label = 'Linear regression',
                                                                                              value = TRUE)
                                                                       ),

                                                                       tags$div(title="Fit a selection of growth models to the data.",
                                                                                checkboxInput(inputId = 'parametric_fit_growth',
                                                                                              label = 'Parametric fit',
                                                                                              value = FALSE)
                                                                       ),

                                                                       tags$div(title="Perform a nonparametric fit to the data using the smooth.spline() function.",
                                                                                checkboxInput(inputId = 'nonparametric_fit_growth',
                                                                                              label = 'Non-parametric fit',
                                                                                              value = TRUE)
                                                                       ),

                                                                       tags$div(title="Apply a ln(x+1) transformation to the time data for linear and nonparametric fits.",
                                                                                checkboxInput(inputId = 'log_transform_time_growth',
                                                                                              label = 'Log-transform time')
                                                                       ),

                                                                       tags$div(title="Only for linear and nonparametric fits:\nExtract growth parameters for two different growth phases (as observed with, e.g., diauxic shifts).",
                                                                                checkboxInput(inputId = 'biphasic_growth',
                                                                                              label = 'Biphasic growth')
                                                                       ),

                                                                       QurvE:::numberInput(
                                                                         inputId = 'growth_threshold_growth',
                                                                         label = 'Growth threshold',
                                                                         value = 1.5,
                                                                         min = NA,
                                                                         max = NA,
                                                                         placeholder = 1.5
                                                                       ),
                                                                       bsPopover(id = "growth_threshold_growth", title = HTML("<em>growth.thresh</em>"), content = "A sample will be considered to have no growth if no growth value is greater than [growth threshold] \\* start growth."),

                                                                       QurvE:::numberInput(
                                                                         inputId = 'minimum_growth_growth',
                                                                         label = 'Minimum growth measurement',
                                                                         value = 0,
                                                                         min = NA,
                                                                         max = NA,
                                                                         placeholder = 0
                                                                       ),
                                                                       bsPopover(id = "minimum_growth_growth", title = HTML("<em>min.growth</em>"), content = "Consider only growth values above [Minimum growth] for the fits."),

                                                                       QurvE:::numberInput(
                                                                         inputId = 'maximum_growth_growth',
                                                                         label = 'Maximum growth measurement',
                                                                         value = NULL,
                                                                         min = NA,
                                                                         max = NA
                                                                       ),
                                                                       bsPopover(id = "maximum_growth_growth", title = HTML("<em>max.growth</em>"), content = "Consider only growth values below and including [Maximum growth measurement] for linear and spline fits."),


                                                                       QurvE:::numberInput(
                                                                         inputId = 't0_growth',
                                                                         label = 't0',
                                                                         value = 0,
                                                                         min = NA,
                                                                         max = NA,
                                                                         placeholder = 0
                                                                       ),
                                                                       bsPopover(id = "t0_growth", title = HTML("<em>t0</em>"), content = "Consider only time values above [t0] for the fits."),

                                                                       QurvE:::numberInput(
                                                                         inputId = 'tmax_growth',
                                                                         label = 'tmax',
                                                                         value = NULL,
                                                                         min = NA,
                                                                         max = NA
                                                                       ),
                                                                       bsPopover(id = "tmax_growth", title = HTML("<em>tmax</em>"), content = "Consider only time values below and including [tmax] for linear and spline fits."),

                                                                     ), # Growth fit


                                                                     wellPanel(
                                                                       style='padding: 1; border-color: #ADADAD; padding-top: 0; padding-bottom: 0',
                                                                       h2(strong('Dose-response Analysis')),
                                                                       checkboxInput(inputId = 'perform_ec50_growth',
                                                                                     label = 'Perform EC50 Analysis',
                                                                                     value = FALSE),


                                                                       conditionalPanel(condition = "input.perform_ec50_growth",
                                                                                        selectInput(inputId = "dr_method_growth",
                                                                                                    label = "Method",
                                                                                                    choices = c("Dose-response models" = "model",
                                                                                                                "Response spline fit" = "spline")
                                                                                        ),
                                                                                        bsPopover(id = "dr_method_growth",
                                                                                                  title = HTML("<em>dr.method</em>"),
                                                                                                  placement = "right",
                                                                                                  content = "Fit either various dose-response models (Ritz et al., 2015) to response-vs.-concentration data and select the best model based on the lowest AIC, or apply a nonparametric (spline) fit.",
                                                                                                  trigger = "hover", options = list(container = "body", template = widePopover)
                                                                                        ),

                                                                                        selectInput(inputId = "response_parameter_growth",
                                                                                                    label = "Response Parameter",
                                                                                                    choices = ""),
                                                                                        bsPopover(id = "response_parameter_growth", title = HTML("<em>dr.parameter</em>"), content = "Choose the response parameter to be used for creating a dose response curve.", placement = "top"),

                                                                                        conditionalPanel(
                                                                                          condition = 'input.dr_method_growth == "spline"',
                                                                                          tags$div(title="Perform a log(x+1) transformation on concentration values.",
                                                                                                   checkboxInput(inputId = 'log_transform_concentration_growth',
                                                                                                                 label = 'Log transform concentration')
                                                                                          ),

                                                                                          tags$div(title="Perform a log(y+1) transformation on response values.",
                                                                                                   checkboxInput(inputId = 'log_transform_response_growth',
                                                                                                                 label = 'Log transform response')
                                                                                          ),

                                                                                          textInput(
                                                                                            inputId = 'smoothing_factor_growth_dr',
                                                                                            label = 'Smoothing factor dose-response splines',
                                                                                            value = "",
                                                                                            placeholder = "NULL (choose automatically)"
                                                                                          ),
                                                                                          bsPopover(id = "smoothing_factor_growth_dr", title = HTML("<em>smooth.dr</em>"), content = "\\'spar\\' argument in the R function smooth.spline() used to create the dose response curve."),

                                                                                          QurvE:::numberInput(
                                                                                            inputId = 'number_of_bootstrappings_dr_growth',
                                                                                            label = 'Number of bootstrappings',
                                                                                            value = 0,
                                                                                            min = NA,
                                                                                            max = NA,
                                                                                            placeholder = 0
                                                                                          ),
                                                                                          bsPopover(id = "number_of_bootstrappings_dr_growth", title = HTML("<em>nboot.dr</em>"), content = "Optional: Define the number of bootstrap samples for EC50 estimation. Bootstrapping resamples the values in a dataset with replacement and performs a spline fit for each bootstrap sample to determine the EC50.")
                                                                                        ), #conditionalPanel(condition = 'input.dr_method_growth == "spline"')
                                                                                        fluidRow(
                                                                                          column(12,
                                                                                                 div(
                                                                                                   actionButton(inputId = "tooltip_growth_dr",
                                                                                                                label = "",
                                                                                                                icon=icon("question"),
                                                                                                                style="padding:2px; font-size:100%"),
                                                                                                   style="float:left")
                                                                                          )
                                                                                        ),
                                                                                        HTML("<br>"),

                                                                       ) # conditionalPanel(condition = "input.perform_ec50_growth"
                                                                     ), #  wellPanel
                                                                     fluidRow(
                                                                       column(12,
                                                                              div(
                                                                                actionButton(inputId = "run_growth",
                                                                                             label = "Run computation",
                                                                                             icon=icon("gears"),
                                                                                             style="padding:5px; font-size:120%"),
                                                                                style="float:right"),
                                                                              div(
                                                                                actionButton(inputId = "tooltip_growth_workflow",
                                                                                             label = "",
                                                                                             icon=icon("question"),
                                                                                             style="padding:2px; font-size:100%"),
                                                                                style="float:left")
                                                                       )
                                                                     )
                                                       ) # sidebarPanel

                                                ), # column
                                                column(8,
                                                       conditionalPanel(
                                                         condition = "input.linear_regression_growth",
                                                         sidebarPanel(
                                                           width = 4,
                                                           style='border-color: #ADADAD; padding-top: 0',
                                                           h3(strong('Linear fit')),

                                                           tags$div(title="Perform a Ln(y/y0) transformation on growth values.",
                                                                    checkboxInput(inputId = 'log_transform_data_linear_growth',
                                                                                  label = 'Log-transform data',
                                                                                  value = TRUE)
                                                           ),
                                                           QurvE:::numberInput(
                                                             inputId = 'R2_threshold_growth',
                                                             label = 'R2 threshold',
                                                             value = 0.95,
                                                             placeholder = 0.95
                                                           ),
                                                           bsPopover(id = "R2_threshold_growth", title = HTML("<em>lin.R2</em>"), content = "R2 threshold for calculated slopes of linear regression windows to be considered for the maximum growth rate."),

                                                           QurvE:::numberInput(
                                                             inputId = 'RSD_threshold_growth',
                                                             label = 'RSD threshold',
                                                             value = 0.1,
                                                             placeholder = 0.1
                                                           ),
                                                           bsPopover(id = "RSD_threshold_growth", title = HTML("<em>lin.RSD</em>"), content = "Relative standard deviation (RSD) threshold for calculated slopes of linear regression windows to be considered for the maximum growth rate."),

                                                           QurvE:::numberInput(
                                                             inputId = 'dY_threshold_growth',
                                                             label = 'dY threshold',
                                                             value = 0.05,
                                                             placeholder = 0.05
                                                           ),
                                                           bsPopover(id = "dY_threshold_growth", title = HTML("<em>lin.dY</em>"), content = "Threshold for the minimum fraction of growth increase a linear regression window should cover to be considered."),

                                                           checkboxInput(inputId = 'custom_sliding_window_size_growth',
                                                                         label = 'Custom sliding window size',
                                                                         value = FALSE),

                                                           conditionalPanel(
                                                             condition = "input.custom_sliding_window_size_growth",
                                                             numericInput(
                                                               inputId = 'custom_sliding_window_size_value_growth',
                                                               label = NULL,
                                                               value = "NULL",
                                                               min = NA,
                                                               max = NA,
                                                             ),
                                                             bsPopover(id = "custom_sliding_window_size_value_growth", title = HTML("<em>lin.h</em>"), content = "If NULL, the sliding windows size (h) is chosen based on the number of data points within the growth phase (until maximum growth measurement)."),
                                                           ),
                                                           fluidRow(
                                                             column(12,
                                                                    div(
                                                                      actionButton(inputId = "tooltip_growth.gcFitLinear",
                                                                                   label = "",
                                                                                   icon=icon("question"),
                                                                                   style="padding:2px; font-size:100%"),
                                                                      style="float:left")
                                                             )
                                                           ),
                                                         ) # sidebarPanel
                                                       ), # conditionalPanel
                                                       conditionalPanel(
                                                         condition = "input.parametric_fit_growth",
                                                         sidebarPanel(
                                                           style='border-color: #ADADAD; padding-top: 0',
                                                           h3(strong('Parametric fit')),

                                                           tags$div(title="Perform a Ln(y/y0) transformation on growth values.",
                                                                    checkboxInput(inputId = 'log_transform_data_parametric_growth',
                                                                                  label = 'Log-transform data',
                                                                                  value = TRUE)
                                                           ),

                                                           wellPanel(
                                                             h4(strong('Models:')),
                                                             style='border-color: #ADADAD; padding: 1; padding-top: 0; padding-bottom: 0',

                                                             tags$div(title="Reference: Zwietering MH, Jongenburger I, Rombouts FM, van 't Riet K. Modeling of the bacterial growth curve. Appl Environ Microbiol. 1990 Jun;56(6):1875-81. doi: 10.1128/aem.56.6.1875-1881.1990",
                                                                      checkboxInput(inputId = 'logistic_growth',
                                                                                    label = 'logistic',
                                                                                    value = TRUE)
                                                             ),

                                                             tags$div(title="Reference: Zwietering MH, Jongenburger I, Rombouts FM, van 't Riet K. Modeling of the bacterial growth curve. Appl Environ Microbiol. 1990 Jun;56(6):1875-81. doi: 10.1128/aem.56.6.1875-1881.1990",
                                                                      checkboxInput(inputId = 'richards_growth',
                                                                                    label = 'Richards',
                                                                                    value = TRUE)
                                                             ),

                                                             tags$div(title="Reference: Zwietering MH, Jongenburger I, Rombouts FM, van 't Riet K. Modeling of the bacterial growth curve. Appl Environ Microbiol. 1990 Jun;56(6):1875-81. doi: 10.1128/aem.56.6.1875-1881.1990",
                                                                      checkboxInput(inputId = 'gompertz_growth',
                                                                                    label = 'Gompertz',
                                                                                    value = TRUE)
                                                             ),

                                                             tags$div(title="Reference: Kahm, M., Hasenbrink, G., Lichtenberg-Fraté, H., Ludwig, J., & Kschischo, M. (2010). grofit: Fitting Biological Growth Curves with R. Journal of Statistical Software, 33(7), 1–21. https://doi.org/10.18637/jss.v033.i07",
                                                                      checkboxInput(inputId = 'extended_gompertz_growth',
                                                                                    label = 'extended Gompertz',
                                                                                    value = TRUE)
                                                             ),

                                                             tags$div(title="Reference: Huang, Lihan (2011) A new mechanistic growth model for simultaneous determination of lag phase duration and exponential growth rate and a new Belehdradek-type model for evaluating the effect of temperature on growth rate. Food Microbiology 28, 770 – 776. doi: 10.1016/j.fm.2010.05.019",
                                                                      checkboxInput(inputId = 'huang_growth',
                                                                                    label = 'Huang',
                                                                                    value = TRUE)
                                                             ),
                                                             tags$div(title="Reference: Baranyi and Roberts (1994) Mathematics of predictive food microbiology. Food Microbiology 26(2), 199 – 218. doi: 10.1016/0168-1605(94)00121-L",
                                                                      checkboxInput(inputId = 'baranyi_growth',
                                                                                    label = 'Baranyi and Roberts',
                                                                                    value = TRUE)
                                                             )
                                                           ),

                                                           fluidRow(
                                                             column(12,
                                                                    div(
                                                                      actionButton(inputId = "tooltip_growth.gcFitModel",
                                                                                   label = "",
                                                                                   icon=icon("question"),
                                                                                   style="padding:2px; font-size:100%"),
                                                                      style="float:left")
                                                             )
                                                           ),

                                                         )
                                                       ),  # conditionalPanel

                                                       conditionalPanel(
                                                         condition = "input.nonparametric_fit_growth",
                                                         sidebarPanel(
                                                           width = 4,
                                                           style='border-color: #ADADAD; padding-top: 0',
                                                           h3(strong('Nonparametric fit')),
                                                           tags$div(title="Perform a Ln(y/y0) transformation on growth values.",
                                                                    checkboxInput(inputId = 'log_transform_data_nonparametric_growth',
                                                                                  label = 'Log-transform data',
                                                                                  value = TRUE)
                                                           ),

                                                           QurvE:::numberInput(
                                                             inputId = 'smoothing_factor_nonparametric_growth',
                                                             label = 'Smoothing factor',
                                                             value = 0.55,
                                                             min = NA,
                                                             max = NA,
                                                             placeholder = 0.55
                                                           ),
                                                           bsPopover(id = "smoothing_factor_nonparametric_growth", title = HTML("<em>smooth.gc</em>"), content = "\\'spar\\' argument within the R function smooth\\.spline\\(\\)."),


                                                           QurvE:::numberInput(
                                                             inputId = 'number_of_bootstrappings_growth',
                                                             label = 'Number of bootstrappings',
                                                             value = 0,
                                                             min = NA,
                                                             max = NA,
                                                             placeholder = 0
                                                           ),
                                                           bsPopover(id = "number_of_bootstrappings_growth", title = HTML("<em>nboot.gc</em>"), content = "Optional: Define the number of bootstrap samples. Bootstrapping resamples the values in a dataset with replacement and performs a spline fit for each bootstrap sample to yield a statistic distribution of growth parameters."),
                                                           fluidRow(
                                                             column(12,
                                                                    div(
                                                                      actionButton(inputId = "tooltip_growth.gcFitSpline",
                                                                                   label = "",
                                                                                   icon=icon("question"),
                                                                                   style="padding:2px; font-size:100%"),
                                                                      style="float:left")
                                                             )
                                                           ),
                                                         )
                                                       )  # conditionalPanel
                                                ) # column
                                              ) # sidebarLayout
                                            ), # fluidRow
                                            textOutput("text")
                                   ), # Growth Tab Panel

                                   "----",
                                   ##____Computation_Fluorescence____####
                                   tabPanel("Fluorescence", value = "tabPanel_Computation_Fluorescence",
                                            fluidRow(
                                              sidebarLayout(
                                                column(4,
                                                       sidebarPanel( width = 12,
                                                                     style = 'border-color: #ADADAD',
                                                                     wellPanel(
                                                                       style = 'padding: 1; border-color: #ADADAD; padding-top: 0; padding-bottom: 0',
                                                                       h2(strong('Fluorescence fit')),
                                                                       h4('Options'),
                                                                       tags$div(title="Perform linear regression on log-transformed growth data.",
                                                                                checkboxInput(
                                                                                  inputId = 'linear_regression_fluorescence',
                                                                                  label = 'linear regression',
                                                                                  value = TRUE
                                                                                )
                                                                       ),

                                                                       tags$div(title="Perform a nonparametric fit to the data using the smooth.spline() function.",
                                                                                checkboxInput(
                                                                                  inputId = 'nonparametric_fit_fluorescence',
                                                                                  label = 'nonparametric fit',
                                                                                  value = TRUE
                                                                                )
                                                                       ),

                                                                       tags$div(title="Extract kinetic parameters for two different phases (as observed with, e.g., regulator-promoter systems with varying response in different growth stages).",
                                                                                checkboxInput(inputId = 'biphasic_fluorescence',
                                                                                              label = 'Biphasic')
                                                                       ),

                                                                       selectInput(
                                                                         inputId = 'data_type_x_fluorescence',
                                                                         label = 'Independent variable (x)',
                                                                         choices = ""
                                                                       ),
                                                                       bsPopover(id = "data_type_x_fluorescence", title = HTML("<em>x_type</em>"), content = "Select the data type that is used as the independent variable for all fits."),

                                                                       conditionalPanel(
                                                                         condition = "input.data_type_x_fluorescence == 'time' && output.normalized_fl_present",
                                                                         tags$div(title="Use normalized fluorescence (divided by growth values) for all fits.",
                                                                                  checkboxInput(inputId = 'normalize_fluorescence',
                                                                                                label = 'Use normalized fluorescence'
                                                                                  )
                                                                         )
                                                                       ),

                                                                       conditionalPanel(
                                                                         condition = 'input.data_type_x_fluorescence.includes("growth")',
                                                                         QurvE:::numberInput(
                                                                           inputId = 'growth_threshold_in_percent_fluorescence',
                                                                           label = 'Growth threshold (in %)',
                                                                           value = 1.5,
                                                                           min = NA,
                                                                           max = NA,
                                                                           placeholder = 1.5
                                                                         ),
                                                                         bsPopover(id = "growth_threshold_in_percent_fluorescence", title = HTML("<em>growth.thresh</em>"), content = "A sample will be considered to have no growth if no growth value is greater than [growth threshold] \\* start growth."),
                                                                       ),

                                                                       conditionalPanel(
                                                                         condition = 'input.data_type_x_fluorescence.includes("growth")',
                                                                         QurvE:::numberInput(
                                                                           inputId = 'minimum_growth_fluorescence',
                                                                           label = 'Minimum growth measurement',
                                                                           value = 0,
                                                                           min = NA,
                                                                           max = NA,
                                                                           placeholder = 0
                                                                         ),
                                                                         bsPopover(id = "minimum_growth_fluorescence", title = HTML("<em>min.growth</em>"), content = "Consider only growth values above [Minimum growth measurement] for the fits."),
                                                                       ),

                                                                       conditionalPanel(
                                                                         condition = 'input.data_type_x_fluorescence.includes("growth")',
                                                                         QurvE:::numberInput(
                                                                           inputId = 'maximum_growth_fluorescence',
                                                                           label = 'Maximum growth measurement',
                                                                           value = NULL,
                                                                           min = NA,
                                                                           max = NA
                                                                         ),
                                                                         bsPopover(id = "maximum_growth_fluorescence", title = HTML("<em>max.growth</em>"), content = "Consider only growth values below and including [Maximum growth] for linear and spline fits."),
                                                                       ),

                                                                       conditionalPanel(
                                                                         condition = 'input.data_type_x_fluorescence.includes("time")',
                                                                         QurvE:::numberInput(
                                                                           inputId = 't0_fluorescence',
                                                                           label = 't0',
                                                                           value = 0,
                                                                           min = NA,
                                                                           max = NA,
                                                                           placeholder = 0
                                                                         )
                                                                       ),
                                                                       bsPopover(id = "t0_fluorescence", title = HTML("<em>t0</em>"), content = "Consider only time values above [t0] for the fits."),

                                                                       conditionalPanel(
                                                                         condition = 'input.data_type_x_fluorescence.includes("time")',
                                                                         QurvE:::numberInput(
                                                                           inputId = 'tmax_fluorescence',
                                                                           label = 'tmax',
                                                                           value = NULL,
                                                                           min = NA,
                                                                           max = NA
                                                                         ),
                                                                         bsPopover(id = "tmax_fluorescence", title = HTML("<em>tmax</em>"), content = "Consider only time values below and including [tmax] for linear and spline fits."),
                                                                       ),
                                                                     ), # wellPanel


                                                                     wellPanel(style='padding: 1; border-color: #ADADAD; padding-top: 0; padding-bottom: 0',

                                                                               h2(strong('Dose-response Analysis')),

                                                                               checkboxInput(inputId = 'perform_ec50_fluorescence',
                                                                                             label = 'Perform dose-response analysis',
                                                                                             value = FALSE),


                                                                               conditionalPanel(condition = 'input.perform_ec50_fluorescence',

                                                                                                selectInput(inputId = "dr_method_fluorescence",
                                                                                                            label = "Method",
                                                                                                            choices = c("Biosensor response model" = "model",
                                                                                                                        "Response spline fit" = "spline")
                                                                                                ),
                                                                                                bsPopover(id = "dr_method_fluorescence",
                                                                                                          placement = "right",
                                                                                                          title = HTML("<em>dr.method</em>"),
                                                                                                          content = "Fit either a biosensor response model (Meyer et al., 2019) to response-vs.-concentration data, or apply a nonparametric (spline) fit."
                                                                                                ),

                                                                                                selectInput(inputId = "response_parameter_fluorescence",
                                                                                                            label = "Response Parameter",
                                                                                                            choices = ""),
                                                                                                bsPopover(id = "response_parameter_fluorescence", title = HTML("<em>dr.parameter</em>"), content = "Choose the response parameter to be used for creating a dose response curve.", placement = "top"),

                                                                                                tags$div(title="Perform a log(x+1) transformation on concentration values.",
                                                                                                         checkboxInput(inputId = 'log_transform_concentration_fluorescence',
                                                                                                                       label = 'log transform concentration')
                                                                                                ),

                                                                                                tags$div(title="Perform a log(x+1) transformation on response values.",
                                                                                                         checkboxInput(inputId = 'log_transform_response_fluorescence',
                                                                                                                       label = 'log transform response')
                                                                                                ),

                                                                                                conditionalPanel(
                                                                                                  condition = 'input.dr_method_fluorescence == "spline"',
                                                                                                  QurvE:::numberInput(
                                                                                                    inputId = 'number_of_bootstrappings_dr_fluorescence',
                                                                                                    label = 'Number of bootstrappings',
                                                                                                    value = 0,
                                                                                                    min = NA,
                                                                                                    max = NA,
                                                                                                    placeholder = 0
                                                                                                  ),
                                                                                                  bsPopover(id = "number_of_bootstrappings_dr_fluorescence", title = HTML("<em>nboot.dr</em>"), content = "Optional: Define the number of bootstrap samples for EC50 estimation. Bootstrapping resamples the values in a dataset with replacement and performs a spline fit for each bootstrap sample to determine the EC50."),
                                                                                                ),

                                                                                                conditionalPanel(
                                                                                                  condition = 'input.dr_method_fluorescence == "spline"',
                                                                                                  textInput(
                                                                                                    inputId = 'smoothing_factor_fluorescence_dr',
                                                                                                    label = 'Smoothing factor dose-response splines',
                                                                                                    value = "",
                                                                                                    placeholder = "NULL (choose automatically)"
                                                                                                  ),
                                                                                                  bsPopover(id = "smoothing_factor_fluorescence_dr", title = HTML("<em>smooth.dr</em>"), content = "\\'spar\\' argument in the R function smooth.spline() used to create the dose response curve."),
                                                                                                ),
                                                                                                fluidRow(
                                                                                                  column(12,
                                                                                                         div(
                                                                                                           actionButton(inputId = "tooltip_fl_dr",
                                                                                                                        label = "",
                                                                                                                        icon=icon("question"),
                                                                                                                        style="padding:2px; font-size:100%"),
                                                                                                           style="float:left")
                                                                                                  )
                                                                                                ),
                                                                                                HTML("<br>"),
                                                                               ) # conditionalPanel(condition = "input.perform_ec50_fluorescence"
                                                                     ), # wellPanel

                                                                     # [Run Computation] button
                                                                     conditionalPanel(
                                                                       condition = 'output.fluorescence_present',
                                                                       fluidRow(
                                                                         column(12,
                                                                                div(
                                                                                  actionButton(inputId = "run_fluorescence",
                                                                                               label = "Run computation",
                                                                                               icon=icon("gears"),
                                                                                               style="padding:5px; font-size:120%"),
                                                                                  style="float:right"),
                                                                                div(
                                                                                  actionButton(inputId = "tooltip_fl_workflow",
                                                                                               label = "",
                                                                                               icon=icon("question"),
                                                                                               style="padding:2px; font-size:100%"),
                                                                                  style="float:left")
                                                                         )
                                                                       )
                                                                     )
                                                       ) # sidebarPanel
                                                ), # column

                                                column(8,
                                                       conditionalPanel(
                                                         condition = "input.linear_regression_fluorescence",
                                                         sidebarPanel(
                                                           width = 4,
                                                           style='border-color: #ADADAD; padding-top: 0',
                                                           h3(strong('Linear fit')),

                                                           QurvE:::numberInput(
                                                             inputId = 'R2_threshold_fluorescence',
                                                             label = 'R2 threshold',
                                                             value = 0.95,
                                                             min = NA,
                                                             max = NA,
                                                             placeholder = 0.95
                                                           ),
                                                           bsPopover(id = "R2_threshold_fluorescence", title = HTML("<em>lin.R2</em>"), content = "R2 threshold for calculated slopes of linear regression windows to be considered for the maximum slope."),

                                                           QurvE:::numberInput(
                                                             inputId = 'RSD_threshold_fluorescence',
                                                             label = 'RSD threshold',
                                                             value = 0.1,
                                                             min = NA,
                                                             max = NA,
                                                             placeholder = 0.1
                                                           ),
                                                           bsPopover(id = "RSD_threshold_fluorescence", title = HTML("<em>lin.RSD</em>"), content = "Relative standard deviation (RSD) threshold for calculated slopes of linear regression windows to be considered for the maximum slope."),

                                                           QurvE:::numberInput(
                                                             inputId = 'dY_threshold_fluorescence',
                                                             label = 'dY threshold',
                                                             value = 0.05,
                                                             min = NA,
                                                             max = NA,
                                                             placeholder = 0.05
                                                           ),
                                                           bsPopover(id = "dY_threshold_fluorescence", title = HTML("<em>lin.dY</em>"), content = "Threshold for the minimum fraction of fluorescence increase a linear regression window should cover to be considered."),

                                                           tags$div(title="Perform a Ln(y/y0) transformation on fluorescence values.",
                                                                    checkboxInput(inputId = 'log_transform_data_linear_fluorescence',
                                                                                  label = 'Log-transform fluorescence data')
                                                           ),

                                                           tags$div(title="Perform a Ln(y/y0) transformation on the independent variable",
                                                                    checkboxInput(inputId = 'log_transform_x_linear_fluorescence',
                                                                                  label = 'Log-transform x data')
                                                           ),

                                                           checkboxInput(inputId = 'custom_sliding_window_size_fluorescence',
                                                                         label = 'custom sliding window size',
                                                                         value = FALSE),

                                                           conditionalPanel(
                                                             condition = "input.custom_sliding_window_size_fluorescence",
                                                             numericInput(
                                                               inputId = 'custom_sliding_window_size_value_fluorescence',
                                                               label = NULL,
                                                               value = "NULL",
                                                               min = NA,
                                                               max = NA,
                                                             ),
                                                             bsPopover(id = "custom_sliding_window_size_value_fluorescence", title = HTML("<em>lin.h</em>"), content = "If NULL, the sliding windows size (h) is chosen based on the number of data points within the phase of fluorescence increase (until maximum fluorescence or growth)."),
                                                           ),
                                                           fluidRow(
                                                             column(12,
                                                                    div(
                                                                      actionButton(inputId = "tooltip_flFitLinear",
                                                                                   label = "",
                                                                                   icon=icon("question"),
                                                                                   style="padding:2px; font-size:100%"),
                                                                      style="float:left")
                                                             )
                                                           ),
                                                         )
                                                       ), # conditionalPanel

                                                       conditionalPanel(
                                                         condition = "input.nonparametric_fit_fluorescence",
                                                         sidebarPanel(
                                                           width = 4,
                                                           style='border-color: #ADADAD; padding-top: 0',
                                                           h3(strong('Nonparametric fit')),

                                                           QurvE:::numberInput(
                                                             inputId = 'smoothing_factor_nonparametric_fluorescence',
                                                             label = 'Smoothing factor',
                                                             value = 0.75,
                                                             min = NA,
                                                             max = NA,
                                                             placeholder = 0.75
                                                           ),
                                                           bsPopover(id = "smoothing_factor_nonparametric_fluorescence", title = HTML("<em>smooth.fl</em>"), content = "\\'spar\\' argument within the R function smooth\\.spline\\(\\)."),

                                                           QurvE:::numberInput(
                                                             inputId = 'number_of_bootstrappings_fluorescence',
                                                             label = 'Number of bootstrappings',
                                                             value = 0,
                                                             min = NA,
                                                             max = NA,
                                                             placeholder = 0
                                                           ),
                                                           bsPopover(id = "number_of_bootstrappings_fluorescence", title = HTML("<em>nboot.fl</em>"), content = "Optional: Define the number of bootstrap samples. Bootstrapping resamples the values in a dataset with replacement and performs a spline fit for each bootstrap sample to yield a statistic distribution of growth parameters."),

                                                           tags$div(title="Perform a Ln(y/y0) transformation on fluorescence values.",
                                                                    checkboxInput(inputId = 'log_transform_data_nonparametric_fluorescence',
                                                                                  label = 'Log-transform fluorescence data')
                                                           ),

                                                           tags$div(title="Perform a Ln(y/y0) transformation on the independent variable",
                                                                    checkboxInput(inputId = 'log_transform_x_nonparametric_fluorescence',
                                                                                  label = 'Log-transform x data')
                                                           ),
                                                           fluidRow(
                                                             column(12,
                                                                    div(
                                                                      actionButton(inputId = "tooltip_flFitSpline",
                                                                                   label = "",
                                                                                   icon=icon("question"),
                                                                                   style="padding:2px; font-size:100%"),
                                                                      style="float:left")
                                                             )
                                                           ),
                                                         )
                                                       )  # conditionalPanel
                                                ) # column
                                              ) # sidebarLayout
                                            ) # fluidRow
                                   ), # tabPanel("Fluorescence"
                        ), # navbarMenu('Computation'

                        #____VALIDATE____####
                        navbarMenu(span("Validation", title = "Graphical display for each fit."),
                                   menuName = "navbarMenu_Validate", icon = icon("user-check"),
                                   ##____Validate_Growth____####
                                   tabPanel(title = "Growth Fits", value = "tabPanel_Validate_Growth",
                                            h1("Growth Fits"),
                                            tabsetPanel(type = "tabs", id = "tabsetPanel_Validate_Growth",
                                                        ###___Linear Fits___####
                                                        tabPanel(title = "Linear Fits", value = "tabPanel_Validate_Growth_Linear",
                                                                 sidebarPanel(width = 5,
                                                                              selectizeInput(inputId = "sample_validate_growth_linear",
                                                                                             label = "Sample:",
                                                                                             width = "100%",
                                                                                             choices = "",
                                                                                             multiple = FALSE,
                                                                                             options = list(closeAfterSelect = FALSE)
                                                                              ),
                                                                              checkboxInput(inputId = 'logy_validate_growth_plot_linear',
                                                                                            label = 'Log-transform y axis',
                                                                                            value = TRUE),
                                                                              checkboxInput(inputId = 'diagnostics_validate_growth_plot_linear',
                                                                                            label = 'Show diagnostics',
                                                                                            value = FALSE),

                                                                              h3('Customize plot appearance'),


                                                                              sliderInput(inputId = 'shape_type_validate_growth_plot_linear',
                                                                                          label = 'Shape type',
                                                                                          min = 1,
                                                                                          max = 25,
                                                                                          value = 21),

                                                                              sliderInput(inputId = 'shape_size_validate_growth_plot_linear',
                                                                                          label = 'Shape size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2,
                                                                                          step = 0.1),



                                                                              sliderInput(inputId = 'axis_size_validate_growth_plot_linear',
                                                                                          label = 'Axis title font size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 1.9,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = 'lab_size_validate_growth_plot_linear',
                                                                                          label = 'Axis label font size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 1.7,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = 'line_width_validate_growth_plot_linear',
                                                                                          label = 'Line width',
                                                                                          min = 0.01,
                                                                                          max = 10,
                                                                                          value = 3),


                                                                              strong("x-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "x_range_min_validate_growth_plot_linear",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "x_range_max_validate_growth_plot_linear",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              strong("y-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "y_range_min_validate_growth_plot_linear",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "y_range_max_validate_growth_plot_linear",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              textInput(
                                                                                inputId = 'color_validate_growth_plot_linear',
                                                                                label = 'Change color',
                                                                                value = "firebrick3"
                                                                              ),
                                                                              bsPopover(id = "color_validate_growth_plot_linear",
                                                                                        title = HTML("<em>Define the colors used to highlight data points used in linear regression and determined slope</em>"), placement = "top",
                                                                                        content = "Enter color either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                              ),

                                                                 ),

                                                                 mainPanel(width = 7,
                                                                           plotOutput("validate_growth_plot_linear", width = "100%", height = "600px"),
                                                                           HTML("<br>"),
                                                                           HTML("<br>"),
                                                                           fluidRow(
                                                                             column(6, align = "center", offset = 3,
                                                                                    actionButton(inputId = "rerun_growth_linear",
                                                                                                 label = "Re-run with modified parameters",
                                                                                                 icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%"),
                                                                                    actionButton(inputId = "restore_growth_linear",
                                                                                                 label = "Restore fit",
                                                                                                 # icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%")
                                                                             )
                                                                           ),

                                                                           HTML("<br>"),
                                                                           h3(strong("Export plot")),

                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "width_download_growth_validate_linear",
                                                                                                 label = "Width (in inches)",
                                                                                                 value = 10)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "height_download_growth_validate_linear",
                                                                                                 label = "Height (in inches)",
                                                                                                 value = 9)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "dpi_download_growth_validate_linear",
                                                                                                 label = "DPI",
                                                                                                 value = 300)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    downloadButton('download_growth_validate_linear',"Download Plot"),
                                                                                    radioButtons("format_download_growth_validate_linear",
                                                                                                 label = NULL,
                                                                                                 choices = c("PNG" = ".png",
                                                                                                             "PDF" = ".pdf"),
                                                                                                 selected = ".png",
                                                                                                 inline = TRUE)
                                                                             ) # column
                                                                           ) # fluidRow
                                                                 ) #mainPanel

                                                        ), #tabPanel(title = "Linear Fits", value = "tabPanel_Validate_Growth_linearFits",
                                                        ###___Spline Fits___####
                                                        tabPanel(title = "Nonparametric fits", value = "tabPanel_Validate_Growth_Spline",
                                                                 sidebarPanel(width = 5,
                                                                              selectizeInput(inputId = "sample_validate_growth_spline",
                                                                                             label = "Sample:",
                                                                                             width = "100%",
                                                                                             choices = "",
                                                                                             multiple = FALSE,
                                                                                             options = list(closeAfterSelect = FALSE)
                                                                              ),

                                                                              sliderInput(inputId = 'shape_type_validate_growth_plot_spline',
                                                                                          label = 'Shape type',
                                                                                          min = 1,
                                                                                          max = 25,
                                                                                          value = 21),

                                                                              checkboxInput(inputId = 'logy_validate_growth_plot_spline',
                                                                                            label = 'Log-transform y axis',
                                                                                            value = TRUE),

                                                                              checkboxInput(inputId = "plot_derivative_validate_growth_plot_spline",
                                                                                            label = "Plot derivative",
                                                                                            value = TRUE),

                                                                              strong("x-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "x_range_min_validate_growth_plot_spline",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "x_range_max_validate_growth_plot_spline",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              strong("y-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "y_range_min_validate_growth_plot_spline",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "y_range_max_validate_growth_plot_spline",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              conditionalPanel(
                                                                                condition = "input.logy_validate_growth_plot_spline",
                                                                                strong("y-Range (derivative)"),
                                                                                fluidRow(
                                                                                  column(5,
                                                                                         textInput(inputId = "y_range_min_derivative_validate_growth_plot_spline",
                                                                                                   label = NULL,
                                                                                                   value = "", placeholder = "min"
                                                                                         )
                                                                                  ),

                                                                                  column(5,
                                                                                         textInput(inputId = "y_range_max_derivative_validate_growth_plot_spline",
                                                                                                   label = NULL,
                                                                                                   value = "", placeholder = "max"
                                                                                         )
                                                                                  )
                                                                                )
                                                                              ),

                                                                              sliderInput(inputId = 'shape_size_validate_growth_plot_spline',
                                                                                          label = 'Shape size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = "line_width_validate_growth_plot_spline",
                                                                                          label = "Line width",
                                                                                          min = 0.01,
                                                                                          max = 10,
                                                                                          value = 1),

                                                                              sliderInput(inputId = 'base_size_validate_growth_plot_spline',
                                                                                          label = 'Base font size',
                                                                                          min = 10,
                                                                                          max = 35,
                                                                                          value = 23,
                                                                                          step = 0.5),

                                                                              sliderInput(inputId = "nbreaks_validate_growth_plot_spline",
                                                                                          label = "Number of breaks on y-axis",
                                                                                          min = 1,
                                                                                          max = 20,
                                                                                          value = 6),

                                                                              textInput(
                                                                                inputId = 'color_validate_growth_plot_spline',
                                                                                label = 'Change color',
                                                                                value = "dodgerblue3"
                                                                              ),
                                                                              bsPopover(id = "color_validate_growth_plot_spline",
                                                                                        title = HTML("<em>Define the colors used to highlight data points used in linear regression and determined slope</em>"), placement = "top",
                                                                                        content = "Enter color either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                              ),

                                                                 ),
                                                                 mainPanel(width = 7,
                                                                           withSpinner(
                                                                             plotOutput("validate_growth_plot_spline",
                                                                                        width = "100%", height = "700px")
                                                                           ),
                                                                           fluidRow(
                                                                             column(6, align = "center", offset = 3,
                                                                                    actionButton(inputId = "rerun_growth_spline",
                                                                                                 label = "Re-run with modified parameters",
                                                                                                 icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%"),
                                                                                    actionButton(inputId = "restore_growth_spline",
                                                                                                 label = "Restore fit",
                                                                                                 # icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%")
                                                                             )
                                                                           ),

                                                                           HTML("<br>"),

                                                                           h3(strong("Export plot")),

                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "width_download_growth_validate_spline",
                                                                                                 label = "Width (in inches)",
                                                                                                 value = 10)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "height_download_growth_validate_spline",
                                                                                                 label = "Height (in inches)",
                                                                                                 value = 9)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "dpi_download_growth_validate_spline",
                                                                                                 label = "DPI",
                                                                                                 value = 300)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    downloadButton('download_growth_validate_spline',"Download Plot"),

                                                                                    radioButtons("format_download_growth_validate_spline",
                                                                                                 label = NULL,
                                                                                                 choices = c("PNG" = ".png",
                                                                                                             "PDF" = ".pdf"),
                                                                                                 selected = ".png",
                                                                                                 inline = TRUE)
                                                                             ) # column
                                                                           ), # fluidRow

                                                                           h3(strong("Export spline values")),
                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    downloadButton('download_growth_validate_spline_values',"Download value table (x-y)")
                                                                             ),
                                                                             column(width = 4,
                                                                                    downloadButton('download_growth_validate_spline_deriv_values',"Download derivative value table (x-y)")
                                                                             ),
                                                                           )

                                                                 ) # mainPanel

                                                        ), # tabPanel(title = "Nonparametric fits", value = "tabPanel_Validate_Growth_splineFits",
                                                        ###___Model Fits___####
                                                        tabPanel(title = "Parametric fits", value = "tabPanel_Validate_Growth_Model",
                                                                 sidebarPanel(width = 5,
                                                                              wellPanel(
                                                                                style='padding: 1; padding-top: 0; padding-bottom: 0',
                                                                                selectizeInput(inputId = "sample_validate_growth_model",
                                                                                               label = "Sample:",
                                                                                               width = "100%",
                                                                                               choices = "",
                                                                                               multiple = FALSE,
                                                                                               options = list(closeAfterSelect = FALSE)
                                                                                ),
                                                                              ),
                                                                              sliderInput(inputId = 'shape_type_validate_growth_plot_model',
                                                                                          label = 'Shape type',
                                                                                          min = 1,
                                                                                          max = 25,
                                                                                          value = 21),
                                                                              sliderInput(inputId = 'shape_size_validate_growth_plot_model',
                                                                                          label = 'Shape size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = "line_width_validate_growth_plot_model",
                                                                                          label = "Line width",
                                                                                          min = 0.01,
                                                                                          max = 10,
                                                                                          value = 1),

                                                                              sliderInput(inputId = 'base_size_validate_growth_plot_model',
                                                                                          label = 'Base font size',
                                                                                          min = 10,
                                                                                          max = 35,
                                                                                          value = 23,
                                                                                          step = 0.5),

                                                                              sliderInput(inputId = "nbreaks_validate_growth_plot_model",
                                                                                          label = "Number of breaks on y-axis",
                                                                                          min = 1,
                                                                                          max = 20,
                                                                                          value = 6),

                                                                              sliderInput(inputId = "eqsize_validate_growth_plot_model",
                                                                                          label = "Equation font size",
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          step = 0.1,
                                                                                          value = 1.9),

                                                                              textInput(
                                                                                inputId = 'color_validate_growth_plot_model',
                                                                                label = 'Change color',
                                                                                value = "forestgreen"
                                                                              ),
                                                                              bsPopover(id = "color_validate_growth_plot_model",
                                                                                        title = HTML("<em>Define the colors used to highlight data points used in linear regression and determined slope</em>"), placement = "top",
                                                                                        content = "Enter color either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                              ),

                                                                 ),
                                                                 mainPanel(width = 7,
                                                                           withSpinner(
                                                                             plotOutput("validate_growth_plot_model",
                                                                                        width = "100%", height = "600px")
                                                                           ),
                                                                           fluidRow(
                                                                             column(6, align = "center", offset = 3,
                                                                                    actionButton(inputId = "rerun_growth_model",
                                                                                                 label = "Re-run with modified parameters",
                                                                                                 icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%"),

                                                                                    actionButton(inputId = "restore_growth_model",
                                                                                                 label = "Restore fit",
                                                                                                 # icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%")
                                                                             )
                                                                           ),

                                                                           HTML("<br>"),

                                                                           h3(strong("Export plot")),

                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "width_download_growth_validate_model",
                                                                                                 label = "Width (in inches)",
                                                                                                 value = 10)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "height_download_growth_validate_model",
                                                                                                 label = "Height (in inches)",
                                                                                                 value = 9)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "dpi_download_growth_validate_model",
                                                                                                 label = "DPI",
                                                                                                 value = 300)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    downloadButton('download_growth_validate_model',"Download Plot"),

                                                                                    radioButtons("format_download_growth_validate_model",
                                                                                                 label = NULL,
                                                                                                 choices = c("PNG" = ".png",
                                                                                                             "PDF" = ".pdf"),
                                                                                                 selected = ".png",
                                                                                                 inline = TRUE)
                                                                             ) # column
                                                                           ) # fluidRow
                                                                 ) # mainPanel
                                                        ), # tabPanel(title = "Parametric fits", value = "tabPanel_Validate_Growth_modelFits",
                                                        ### Growth Boostrapping Spline Plots ####
                                                        tabPanel(title = "Bootstrapping Spline", value = "tabPanel_Validate_Growth_Spline_bt",
                                                                 sidebarPanel(width = 4,
                                                                              selectizeInput(inputId = "sample_validate_growth_spline_bt",
                                                                                             label = "Sample:",
                                                                                             width = "100%",
                                                                                             choices = "",
                                                                                             multiple = FALSE,
                                                                                             options = list(closeAfterSelect = FALSE)
                                                                              ),

                                                                              checkboxInput(inputId = "plot_derivative_growth_spline_bt",
                                                                                            label = "Plot derivative",
                                                                                            value = TRUE),

                                                                              h3('Customize plot appearance'),


                                                                              sliderInput(inputId = 'shape_type_validate_growth_spline_bt',
                                                                                          label = 'Shape type',
                                                                                          min = 1,
                                                                                          max = 25,
                                                                                          value = 1),

                                                                              sliderInput(inputId = 'shape_size_validate_growth_spline_bt',
                                                                                          label = 'Shape size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2,
                                                                                          step = 0.1),



                                                                              sliderInput(inputId = 'axis_size_validate_growth_spline_bt',
                                                                                          label = 'Axis title font size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 1.9,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = 'lab_size_validate_growth_spline_bt',
                                                                                          label = 'Axis label font size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 1.7,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = 'line_width_validate_growth_spline_bt',
                                                                                          label = 'Line width',
                                                                                          min = 0.01,
                                                                                          max = 10,
                                                                                          value = 0.5),


                                                                              strong("x-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "x_range_min_validate_growth_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "x_range_max_validate_growth_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              strong("y-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "y_range_min_validate_growth_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "y_range_max_validate_growth_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),
                                                                              strong("y-Range (derivative)"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "y_range_min_derivative_validate_growth_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "y_range_max_derivative_validate_growth_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                ),

                                                                                textInput(
                                                                                  inputId = 'color_validate_growth_plot_spline_bt',
                                                                                  label = 'Change color',
                                                                                  value = "dodgerblue3"
                                                                                ),
                                                                                bsPopover(id = "color_validate_growth_plot_spline_bt",
                                                                                          title = HTML("<em>Define the colors used to highlight data points used in linear regression and determined slope</em>"), placement = "top",
                                                                                          content = "Enter color either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                                ),
                                                                              ),

                                                                 ), # sidebarPanel

                                                                 mainPanel(width = 8,

                                                                           plotOutput("validate_growth_plot_spline_bt",
                                                                                      width = "100%", height = "1000px"),

                                                                           HTML("<br>"),
                                                                           h3(strong("Export plot")),

                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "width_download_growth_validate_spline_bt",
                                                                                                 label = "Width (in inches)",
                                                                                                 value = 10)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "height_download_growth_validate_spline_bt",
                                                                                                 label = "Height (in inches)",
                                                                                                 value = 9)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "dpi_download_growth_validate_spline_bt",
                                                                                                 label = "DPI",
                                                                                                 value = 300)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    downloadButton('download_growth_validate_spline_bt',"Download Plot"),
                                                                                    radioButtons("format_download_growth_validate_spline_bt",
                                                                                                 label = NULL,
                                                                                                 choices = c("PNG" = ".png",
                                                                                                             "PDF" = ".pdf"),
                                                                                                 selected = ".png",
                                                                                                 inline = TRUE)
                                                                             ) # column
                                                                           ) # fluidRow
                                                                 ) # mainPanel
                                                        ) # tabPanel(title = "Bootstrapping Spline"
                                            ) # tabsetPanel(type = "tabs",
                                   ), # tabPanel(title = "Growth Fits", value = "tabPanel_Validate_Growth",
                                   ##____Validate_Fluorescence____####
                                   tabPanel(title = "Fluorescence Fits", value = "tabPanel_Validate_Fluorescence",
                                            h1("Fluorescence Fits"),
                                            tabsetPanel(type = "tabs", id = "tabsetPanel_Validate_Fluorescence",
                                                        ###___Linear Fits___####
                                                        tabPanel(title = "Linear Fits", value = "tabPanel_Validate_Fluorescence_Linear",
                                                                 sidebarPanel(width = 5,
                                                                              selectizeInput(inputId = "sample_validate_fluorescence_linear",
                                                                                             label = "Sample:",
                                                                                             width = "100%",
                                                                                             choices = "",
                                                                                             multiple = FALSE,
                                                                                             options = list(closeAfterSelect = FALSE)
                                                                              ),
                                                                              checkboxInput(inputId = 'logy_validate_fluorescence_plot_linear',
                                                                                            label = 'Log-transform y axis',
                                                                                            value = FALSE),
                                                                              checkboxInput(inputId = 'diagnostics_validate_fluorescence_plot_linear',
                                                                                            label = 'Show diagnostics',
                                                                                            value = FALSE),

                                                                              h3('Customize plot appearance'),


                                                                              sliderInput(inputId = 'shape_type_validate_fluorescence_plot_linear',
                                                                                          label = 'Shape type',
                                                                                          min = 1,
                                                                                          max = 25,
                                                                                          value = 21),

                                                                              sliderInput(inputId = 'shape_size_validate_fluorescence_plot_linear',
                                                                                          label = 'Shape size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2,
                                                                                          step = 0.1),



                                                                              sliderInput(inputId = 'axis_size_validate_fluorescence_plot_linear',
                                                                                          label = 'Axis title font size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = 'lab_size_validate_fluorescence_plot_linear',
                                                                                          label = 'Axis label font size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 1.8,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = 'line_width_validate_fluorescence_plot_linear',
                                                                                          label = 'Line width',
                                                                                          min = 0.01,
                                                                                          max = 10,
                                                                                          value = 3),


                                                                              strong("x-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "x_range_min_validate_fluorescence_plot_linear",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "x_range_max_validate_fluorescence_plot_linear",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              strong("y-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "y_range_min_validate_fluorescence_plot_linear",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "y_range_max_validate_fluorescence_plot_linear",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              textInput(
                                                                                inputId = 'color_validate_fluorescence_plot_linear',
                                                                                label = 'Change color',
                                                                                value = "firebrick3"
                                                                              ),
                                                                              bsPopover(id = "color_validate_fluorescence_plot_linear",
                                                                                        title = HTML("<em>Define the colors used to highlight data points used in linear regression and determined slope</em>"), placement = "top",
                                                                                        content = "Enter color either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                              ),

                                                                 ),
                                                                 mainPanel(width = 7,
                                                                           plotOutput("validate_fluorescence_plot_linear", width = "100%", height = "600px"),
                                                                           fluidRow(
                                                                             column(6, align = "center", offset = 3,
                                                                                    actionButton(inputId = "rerun_fluorescence_linear",
                                                                                                 label = "Re-run with modified parameters",
                                                                                                 icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%"),
                                                                                    actionButton(inputId = "restore_fluorescence_linear",
                                                                                                 label = "Restore fit",
                                                                                                 # icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%")
                                                                             )
                                                                           ),
                                                                           HTML("<br>"),
                                                                           h3(strong("Export plot")),

                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "width_download_fluorescence_validate_linear",
                                                                                                 label = "Width (in inches)",
                                                                                                 value = 10)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "height_download_fluorescence_validate_linear",
                                                                                                 label = "Height (in inches)",
                                                                                                 value = 9)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "dpi_download_fluorescence_validate_linear",
                                                                                                 label = "DPI",
                                                                                                 value = 300)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    downloadButton('download_fluorescence_validate_linear',"Download Plot"),
                                                                                    radioButtons("format_download_fluorescence_validate_linear",
                                                                                                 label = NULL,
                                                                                                 choices = c("PNG" = ".png",
                                                                                                             "PDF" = ".pdf"),
                                                                                                 selected = ".png",
                                                                                                 inline = TRUE)
                                                                             ) # column
                                                                           ) # fluidRow
                                                                 )

                                                        ),
                                                        ###___Spline Fits___####
                                                        tabPanel(title = "Nonparametric fits", value = "tabPanel_Validate_Fluorescence_Spline",
                                                                 sidebarPanel(width = 5,
                                                                              selectizeInput(inputId = "sample_validate_fluorescence_spline",
                                                                                             label = "Sample:",
                                                                                             width = "100%",
                                                                                             choices = "",
                                                                                             multiple = FALSE,
                                                                                             options = list(closeAfterSelect = FALSE)
                                                                              ),
                                                                              checkboxInput(inputId = 'logy_validate_fluorescence_plot_spline',
                                                                                            label = 'Log-transform y axis',
                                                                                            value = FALSE),

                                                                              checkboxInput(inputId = "plot_derivative_validate_fluorescence_plot_spline",
                                                                                            label = "Plot derivative",
                                                                                            value = TRUE),

                                                                              sliderInput(inputId = 'shape_type_validate_fluorescence_plot_spline',
                                                                                          label = 'Shape type',
                                                                                          min = 1,
                                                                                          max = 25,
                                                                                          value = 21),

                                                                              strong("x-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "x_range_min_validate_fluorescence_plot_spline",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "x_range_max_validate_fluorescence_plot_spline",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              strong("y-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "y_range_min_validate_fluorescence_plot_spline",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "y_range_max_validate_fluorescence_plot_spline",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              conditionalPanel(
                                                                                condition = "input.logy_validate_growth_plot_spline",
                                                                                strong("y-Range (derivative)"),
                                                                                fluidRow(
                                                                                  column(5,
                                                                                         textInput(inputId = "y_range_min_derivative_validate_fluorescence_plot_spline",
                                                                                                   label = NULL,
                                                                                                   value = "", placeholder = "min"
                                                                                         )
                                                                                  ),

                                                                                  column(5,
                                                                                         textInput(inputId = "y_range_max_derivative_validate_fluorescence_plot_spline",
                                                                                                   label = NULL,
                                                                                                   value = "", placeholder = "max"
                                                                                         )
                                                                                  )
                                                                                )
                                                                              ),

                                                                              sliderInput(inputId = 'shape_size_validate_fluorescence_plot_spline',
                                                                                          label = 'Shape size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = "line_width_validate_fluorescence_plot_spline",
                                                                                          label = "Line width",
                                                                                          min = 0.01,
                                                                                          max = 10,
                                                                                          value = 1.1),

                                                                              sliderInput(inputId = 'base_size_validate_fluorescence_plot_spline',
                                                                                          label = 'Base font size',
                                                                                          min = 10,
                                                                                          max = 35,
                                                                                          value = 23,
                                                                                          step = 0.5),

                                                                              sliderInput(inputId = "nbreaks__validate_fluorescence_plot_spline",
                                                                                          label = "Number of breaks on y-axis",
                                                                                          min = 1,
                                                                                          max = 20,
                                                                                          value = 6),

                                                                              textInput(
                                                                                inputId = 'color_validate_fluorescence_plot_spline',
                                                                                label = 'Change color',
                                                                                value = "dodgerblue3"
                                                                              ),
                                                                              bsPopover(id = "color_validate_fluorescence_plot_spline",
                                                                                        title = HTML("<em>Define the colors used to highlight data points used in linear regression and determined slope</em>"), placement = "top",
                                                                                        content = "Enter color either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                              ),

                                                                 ),
                                                                 mainPanel(width = 7,
                                                                           #conditional if diagnostics
                                                                           withSpinner(
                                                                             plotOutput("validate_fluorescence_plot_spline",
                                                                                        width = "100%", height = "700px")
                                                                           ),
                                                                           fluidRow(
                                                                             column(6, align = "center", offset = 3,
                                                                                    actionButton(inputId = "rerun_fluorescence_spline",
                                                                                                 label = "Re-run with modified parameters",
                                                                                                 icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%"),
                                                                                    actionButton(inputId = "restore_fluorescence_spline",
                                                                                                 label = "Restore fit",
                                                                                                 # icon=icon("gears"),
                                                                                                 style="padding:5px; font-size:120%")
                                                                             ) # column
                                                                           ), # fluidRow

                                                                           HTML("<br>"),

                                                                           h3(strong("Export plot")),

                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "width_download_fluorescence_validate_spline",
                                                                                                 label = "Width (in inches)",
                                                                                                 value = 10)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "height_download_fluorescence_validate_spline",
                                                                                                 label = "Height (in inches)",
                                                                                                 value = 9)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "dpi_download_fluorescence_validate_spline",
                                                                                                 label = "DPI",
                                                                                                 value = 300)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    downloadButton('download_fluorescence_validate_spline',"Download Plot"),

                                                                                    radioButtons("format_download_fluorescence_validate_spline",
                                                                                                 label = NULL,
                                                                                                 choices = c("PNG" = ".png",
                                                                                                             "PDF" = ".pdf"),
                                                                                                 selected = ".png",
                                                                                                 inline = TRUE)
                                                                             ) # column
                                                                           ), # fluidRow
                                                                           h3(strong("Export spline values")),
                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    downloadButton('download_fluorescence_validate_spline_values',"Download value table (x-y)")
                                                                             ),
                                                                             column(width = 4,
                                                                                    downloadButton('download_fluorescence_validate_spline_deriv_values',"Download derivative value table (x-y)")
                                                                             ),
                                                                           )
                                                                 ) # mainPanel
                                                        ), # tabPanel(title = "Nonparametric fits", value = "tabPanel_Validate_Fluorescence_splineFits",

                                                        # Bootstrapping spline fit ####

                                                        tabPanel(title = "Bootstrapping Spline", value = "tabPanel_Validate_Fluorescence_Spline_bt",
                                                                 sidebarPanel(width = 4,
                                                                              selectizeInput(inputId = "sample_validate_fluorescence_spline_bt",
                                                                                             label = "Sample:",
                                                                                             width = "100%",
                                                                                             choices = "",
                                                                                             multiple = FALSE,
                                                                                             options = list(closeAfterSelect = FALSE)
                                                                              ),

                                                                              checkboxInput(inputId = "plot_derivative_fluorescence_spline_bt",
                                                                                            label = "Plot derivative",
                                                                                            value = TRUE),

                                                                              h3('Customize plot appearance'),


                                                                              sliderInput(inputId = 'shape_type_validate_fluorescence_spline_bt',
                                                                                          label = 'Shape type',
                                                                                          min = 1,
                                                                                          max = 25,
                                                                                          value = 1),

                                                                              sliderInput(inputId = 'shape_size_validate_fluorescence_spline_bt',
                                                                                          label = 'Shape size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2,
                                                                                          step = 0.1),



                                                                              sliderInput(inputId = 'axis_size_validate_fluorescence_spline_bt',
                                                                                          label = 'Axis title font size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2.8,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = 'lab_size_validate_fluorescence_spline_bt',
                                                                                          label = 'Axis label font size',
                                                                                          min = 0.1,
                                                                                          max = 10,
                                                                                          value = 2.4,
                                                                                          step = 0.1),

                                                                              sliderInput(inputId = 'line_width_validate_fluorescence_spline_bt',
                                                                                          label = 'Line width',
                                                                                          min = 0.01,
                                                                                          max = 10,
                                                                                          value = 0.5),


                                                                              strong("x-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "x_range_min_validate_fluorescence_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "x_range_max_validate_fluorescence_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              strong("y-Range"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "y_range_min_validate_fluorescence_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "y_range_max_validate_fluorescence_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),
                                                                              strong("y-Range (derivative)"),
                                                                              fluidRow(
                                                                                column(5,
                                                                                       textInput(inputId = "y_range_min_derivative_validate_fluorescence_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "min"
                                                                                       )
                                                                                ),

                                                                                column(5,
                                                                                       textInput(inputId = "y_range_max_derivative_validate_fluorescence_spline_bt",
                                                                                                 label = NULL,
                                                                                                 value = "", placeholder = "max"
                                                                                       )
                                                                                )
                                                                              ),

                                                                              textInput(
                                                                                inputId = 'color_validate_fluorescence_spline_bt',
                                                                                label = 'Change color',
                                                                                value = "dodgerblue3"
                                                                              ),
                                                                              bsPopover(id = "color_validate_fluorescence_spline_bt",
                                                                                        title = HTML("<em>Define the colors used to highlight data points used in linear regression and determined slope</em>"), placement = "top",
                                                                                        content = "Enter color either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                              ),

                                                                 ), # sidebarPanel

                                                                 mainPanel(width = 8,

                                                                           plotOutput("validate_fluorescence_plot_spline_bt",
                                                                                      width = "100%", height = "1000px"),

                                                                           HTML("<br>"),
                                                                           h3(strong("Export plot")),

                                                                           fluidRow(
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "width_download_fluorescence_validate_spline_bt",
                                                                                                 label = "Width (in inches)",
                                                                                                 value = 10)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "height_download_fluorescence_validate_spline_bt",
                                                                                                 label = "Height (in inches)",
                                                                                                 value = 9)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    numericInput(inputId = "dpi_download_fluorescence_validate_spline_bt",
                                                                                                 label = "DPI",
                                                                                                 value = 300)
                                                                             ), # column
                                                                             column(width = 4,
                                                                                    downloadButton('download_fluorescence_validate_spline_bt',"Download Plot"),
                                                                                    radioButtons("format_download_fluorescence_validate_spline_bt",
                                                                                                 label = NULL,
                                                                                                 choices = c("PNG" = ".png",
                                                                                                             "PDF" = ".pdf"),
                                                                                                 selected = ".png",
                                                                                                 inline = TRUE)
                                                                             ) # column
                                                                           ) # fluidRow
                                                                 ) # mainPanel
                                                        ) # tabPanel(title = "Bootstrapping Spline"
                                            ) # tabsetPanel(type = "tabs",
                                   ) # tabPanel(title = "Fluorescence Fits", value = "tabPanel_Validate_Fluorescence",
                        ), # navbarMenu("Validate", icon = icon("user-check"),
                        #____RESULTS____####

                        navbarMenu(span("Results", title = "Tabular overview of computation results."),
                                   menuName = "navbarMenu_Results", icon = icon("magnifying-glass-chart"),
                                   ##____Results_Growth___####
                                   tabPanel(title = "Growth", value = "tabPanel_Results_Growth",
                                            tabsetPanel(type = "tabs", id = "tabsetPanel_Results_Growth",
                                                        tabPanel(title = "Linear Fit", value = "tabPanel_Results_Growth_Linear",
                                                                 conditionalPanel(condition = "input.biphasic_growth",
                                                                                  h5("(Values in parentheses indicate parameters for secondary growth phase)")
                                                                 ),

                                                                 checkboxInput(inputId = 'grouped_results_growth_linear',
                                                                               label = 'Group averages',
                                                                               value = TRUE),

                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_growth_linear",
                                                                   DT::dataTableOutput('results_table_growth_linear')
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_growth_linear",
                                                                   DT::dataTableOutput('results_table_growth_linear_group')
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_growth_linear",
                                                                   downloadButton('download_table_growth_linear',"Download table")
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_growth_linear",
                                                                   downloadButton('download_table_growth_linear_group',"Download table")
                                                                 ),
                                                        ),
                                                        tabPanel(title = "Nonparametric Fit", value = "tabPanel_Results_Growth_Spline",
                                                                 conditionalPanel(condition = "input.biphasic_growth",
                                                                                  h5("(Values in parentheses indicate parameters for secondary growth phase)")
                                                                 ),
                                                                 checkboxInput(inputId = 'grouped_results_growth_spline',
                                                                               label = 'Group averages',
                                                                               value = TRUE),
                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_growth_spline",
                                                                   DT::dataTableOutput('results_table_growth_spline')
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_growth_spline",
                                                                   DT::dataTableOutput('results_table_growth_spline_group')
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_growth_spline",
                                                                   downloadButton('download_table_growth_spline',"Download table")
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_growth_spline",
                                                                   downloadButton('download_table_growth_spline_group',"Download table")
                                                                 ),
                                                        ),
                                                        tabPanel(title = "Nonparametric Fit (Bootstrapping)", value = "tabPanel_Results_Growth_Spline_bt",
                                                                 DT::dataTableOutput('results_table_growth_spline_bt'),
                                                                 downloadButton('download_table_growth_spline_bt',"Download table")
                                                        ),
                                                        tabPanel(title = "Parametric Fit", value = "tabPanel_Results_Growth_Model",

                                                                 checkboxInput(inputId = 'grouped_results_growth_model',
                                                                               label = 'Group averages',
                                                                               value = TRUE),

                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_growth_model",
                                                                   DT::dataTableOutput('results_table_growth_model'),
                                                                   downloadButton('download_table_growth_model',"Download table")
                                                                 ),

                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_growth_model",
                                                                   DT::dataTableOutput('results_table_growth_model_group'),
                                                                   downloadButton('download_table_growth_model_group',"Download table")
                                                                 ),
                                                        ),
                                                        tabPanel(title = "Dose-response analysis", value = "tabPanel_Results_Growth_DR",
                                                                 DT::dataTableOutput('results_table_growth_dr_spline'),
                                                                 downloadButton('download_table_growth_dr',"Download table")
                                                        )
                                            )
                                   ),
                                   ##____Results_Fluorescence___####
                                   tabPanel(title = "Fluorescence", value = "tabPanel_Results_Fluorescence",
                                            tabsetPanel(type = "tabs", id = "tabsetPanel_Results_Fluorescence",
                                                        tabPanel(title = "Linear Fit", value = "tabPanel_Results_Fluorescence_Linear",
                                                                 conditionalPanel(condition = "input.biphasic_fluorescence",
                                                                                  h5("(Values in parentheses indicate parameters for secondary phase)")
                                                                 ),
                                                                 checkboxInput(inputId = 'grouped_results_fluorescence_linear',
                                                                               label = 'Group averages',
                                                                               value = TRUE),
                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_fluorescence_linear",
                                                                   DT::dataTableOutput('results_table_fluorescence_linear')
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_fluorescence_linear",
                                                                   DT::dataTableOutput('results_table_fluorescence_linear_group')
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_fluorescence_linear",
                                                                   downloadButton('download_table_fluorescence_linear',"Download table")
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_fluorescence_linear",
                                                                   downloadButton('download_table_fluorescence_linear_group',"Download table")
                                                                 ),
                                                        ),
                                                        tabPanel(title = "Nonparametric Fit", value = "tabPanel_Results_Fluorescence_Spline",
                                                                 conditionalPanel(condition = "input.biphasic_fluorescence",
                                                                                  h5("(Values in parentheses indicate parameters for secondary phase)")
                                                                 ),
                                                                 checkboxInput(inputId = 'grouped_results_fluorescence_spline',
                                                                               label = 'Group averages',
                                                                               value = TRUE),
                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_fluorescence_spline",
                                                                   DT::dataTableOutput('results_table_fluorescence_spline')
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_fluorescence_spline",
                                                                   DT::dataTableOutput('results_table_fluorescence_spline_group')
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "!input.grouped_results_fluorescence_spline",
                                                                   downloadButton('download_table_fluorescence_spline',"Download table")
                                                                 ),
                                                                 conditionalPanel(
                                                                   condition = "input.grouped_results_fluorescence_spline",
                                                                   downloadButton('download_table_fluorescence_spline_group',"Download table")
                                                                 ),
                                                        ),
                                                        tabPanel(title = "Nonparametric Fit (Bootstrapping)", value = "tabPanel_Results_Fluorescence_Spline_bt",
                                                                 DT::dataTableOutput('results_table_fluorescence_spline_bt'),
                                                                 downloadButton('download_table_fluorescence_spline_bt',"Download table")
                                                        ),
                                                        tabPanel(title = "Dose-response analysis", value = "tabPanel_Results_Fluorescence_DR_Spline",
                                                                 DT::dataTableOutput('results_table_fluorescence_dr_spline'),
                                                                 downloadButton('download_table_fluorescence_dr_spline',"Download table")
                                                        ),
                                                        tabPanel(title = "Dose-response analysis", value = "tabPanel_Results_Fluorescence_DR_Model",
                                                                 DT::dataTableOutput('results_table_fluorescence_dr_model'),
                                                                 downloadButton('download_table_fluorescence_dr_model',"Download table")
                                                        )
                                            )
                                   )
                        ),

                        #____Visualize____####
                        navbarMenu(span("Visualization", title = "Visualize computation results for the entire dataset."),
                                   menuName = "navbarMenu_Visualize", icon = icon("chart-line"),
                                   ## Growth Plots ####
                                   tabPanel(title = "Growth Plots", value = "tabPanel_Visualize_Growth",
                                            h1("Growth Plots"),
                                            tabsetPanel(type = "tabs", id = "tabsetPanel_Visualize_Growth",

                                                        ### Growth Group Plots ####

                                                        tabPanel(title = "Group Plots",
                                                                 sidebarPanel(

                                                                   selectInput(inputId = "data_type_growth_group_plot",
                                                                               label = "Data type",
                                                                               choices = c("Raw growth" = "raw",
                                                                                           "Spline fits" = "spline")
                                                                   ),

                                                                   checkboxInput(inputId = "select_string_visualize_growth_group",
                                                                                 label = "(De-)select samples based on string",
                                                                                 value = FALSE),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_growth_group && !input.plot_group_averages_growth_group_plot",
                                                                     selectizeInput(inputId = "samples_visualize_growth_group",
                                                                                    label = "Samples:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_growth_group && input.plot_group_averages_growth_group_plot",
                                                                     selectizeInput(inputId = "groups_visualize_growth_group",
                                                                                    label = "Conditions:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.select_string_visualize_growth_group",
                                                                     textInput(inputId = "select_samples_based_on_string_growth_group_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_string_growth_group_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     ),

                                                                   ),
                                                                   conditionalPanel(
                                                                     condition = "input.plot_group_averages_growth_group_plot || input.select_string_visualize_growth_group",
                                                                     textInput(inputId = "select_samples_based_on_concentration_growth_group_plot",
                                                                               label = "Select sample based on concentration (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_concentration_growth_group_plot",
                                                                               label = "Exclude sample based on concentration (separate by ;)"
                                                                     )
                                                                   ),

                                                                   checkboxInput(inputId = "plot_group_averages_growth_group_plot",
                                                                                 label = "Plot group averages",
                                                                                 value = TRUE),

                                                                   conditionalPanel(
                                                                     condition = "input.data_type_growth_group_plot == 'spline'",
                                                                     checkboxInput(inputId = "plot_derivative_growth_group_plot",
                                                                                   label = "Plot derivative",
                                                                                   value = TRUE)
                                                                   ),

                                                                   h3("Customize plot appearance"),

                                                                   checkboxInput(inputId = "log_transform_y_axis_growth_group_plot",
                                                                                 label = "Log-transform y-axis",
                                                                                 value = TRUE),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_growth_group_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_growth_group_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_growth_group_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_growth_group_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.data_type_growth_group_plot == 'spline'",
                                                                     strong("y-Range (derivative)"),
                                                                     fluidRow(
                                                                       column(5,
                                                                              textInput(inputId = "y_range_min_derivative_growth_group_plot",
                                                                                        label = NULL,
                                                                                        value = "", placeholder = "min"
                                                                              )
                                                                       ),

                                                                       column(5,
                                                                              textInput(inputId = "y_range_max_derivative_growth_group_plot",
                                                                                        label = NULL,
                                                                                        value = "", placeholder = "max"
                                                                              )
                                                                       )
                                                                     )
                                                                   ),

                                                                   textInput(inputId = "y_axis_title_growth_group_plot",
                                                                             label = "y-axis title",
                                                                             value = "Growth [y(t)]"
                                                                   ),

                                                                   textInput(inputId = "x_axis_title_growth_group_plot",
                                                                             label = "x-axis title",
                                                                             value = "Time"
                                                                   ),
                                                                   conditionalPanel(
                                                                     condition = "input.data_type_growth_group_plot == 'spline'",
                                                                     textInput(inputId = "y_axis_title_derivative_growth_group_plot",
                                                                               label = "y-axis title derivative",
                                                                               value = "Growth rate"
                                                                     )
                                                                   ),

                                                                   sliderInput(inputId = "nbreaks_growth_group_plot",
                                                                               label = "Number of breaks on y-axis",
                                                                               min = 1,
                                                                               max = 20,
                                                                               value = 6),

                                                                   sliderInput(inputId = "line_width_growth_group_plot",
                                                                               label = "Line width",
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1.1),

                                                                   sliderInput(inputId = 'base_size_growth_group_plot',
                                                                               label = 'Base font size',
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),

                                                                   selectInput(inputId = "legend_position_group_plot",
                                                                               label = "Legend position",
                                                                               choices = c("Bottom" = "bottom",
                                                                                           "Top" = "top",
                                                                                           "Left" = "left",
                                                                                           "Right" = "right")
                                                                   ),

                                                                   sliderInput(inputId = 'legend_ncol_group_plot',
                                                                               label = 'Number of legend columns',
                                                                               min = 1,
                                                                               max = 10,
                                                                               value = 4,
                                                                               step = 1
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc",
                                                                     checkboxInput(inputId = "color_groups_group_plot",
                                                                                   label = "Color samples by group",
                                                                                   value = TRUE)
                                                                   ),

                                                                   textInput(
                                                                     inputId = 'custom_colors_group_plot',
                                                                     label = 'Custom colors'
                                                                   ),
                                                                   bsPopover(id = "custom_colors_group_plot",
                                                                             title = HTML("<em>Provide custom colors</em>"), placement = "top",
                                                                             content = "Enter colors either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). Separate colors with a comma. A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc && input.color_groups_group_plot",
                                                                     selectizeInput(inputId = "color_palettes_group_plot",
                                                                                    label = "Change color palettes",
                                                                                    width = "100%",
                                                                                    choices = names(QurvE:::single_hue_palettes),
                                                                                    selected = names(QurvE:::single_hue_palettes),
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     ),
                                                                     bsPopover(id = "color_palettes_group_plot",
                                                                               title = HTML("<em>Define the colors used to display sample groups with identical concentrations</em>"), placement = "top",
                                                                               content = "The number of selected color palettes must be at least the number of displayed groups. The order of the chosen palettes corresponds to the oder of conditions in the legend."
                                                                     ),

                                                                   )

                                                                 ), # Side panel growth group plots

                                                                 mainPanel(
                                                                   withSpinner(
                                                                     plotOutput("growth_group_plot",
                                                                                width = "100%", height = "1000px"),

                                                                   ),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_growth_group_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 10)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_growth_group_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 9)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_growth_group_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_growth_group_plot',"Download Plot"),

                                                                            radioButtons("format_download_growth_group_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ) # column
                                                                   ) # fluidRow
                                                                 ) #  mainPanel
                                                        ),

                                                        ### Growth Parameter Plots ####
                                                        tabPanel(title = "Parameter Plots",
                                                                 sidebarPanel(
                                                                   selectInput(inputId = "parameter_parameter_growth_plot",
                                                                               label = "Parameter",
                                                                               choices = ""
                                                                   ),

                                                                   checkboxInput(inputId = "select_string_visualize_parameter_growth_plot",
                                                                                 label = "(De-)select samples based on string",
                                                                                 value = FALSE),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_parameter_growth_plot",
                                                                     selectizeInput(inputId = "samples_visualize_parameter_growth_plot",
                                                                                    label = "Conditions:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.select_string_visualize_parameter_growth_plot",
                                                                     textInput(inputId = "select_sample_based_on_string_growth_parameter_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_sample_based_on_strings_growth_parameter_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     ),

                                                                   ),

                                                                   textInput(inputId = "select_sample_based_on_concentration_growth_parameter_plot",
                                                                             label = "Select sample based on concentration (separate by ;)"
                                                                   ),

                                                                   textInput(inputId = "exclude_sample_based_on_concentration_growth_parameter_plot",
                                                                             label = "Exclude sample based on concentration (separate by ;)"
                                                                   ),

                                                                   checkboxInput(inputId = 'normalize_to_reference_growth_parameter_plot',
                                                                                 label = 'normalize to reference',
                                                                                 value = FALSE),

                                                                   h3("Customize plot appearance"),

                                                                   # Conditional Panel
                                                                   conditionalPanel(condition = "input.normalize_to_reference_growth_parameter_plot",
                                                                                    # reactive selection
                                                                                    selectInput(inputId = 'reference_condition_growth_parameter_plot',
                                                                                                label = 'Reference condition',
                                                                                                choices = ""
                                                                                    ),

                                                                                    # reactive selection
                                                                                    selectInput(inputId = 'reference_concentration_growth_parameter_plot',
                                                                                                label = 'Reference concentration',
                                                                                                choices = ""
                                                                                    ),
                                                                   ),

                                                                   sliderInput(inputId = "shape.size_growth_parameter_plot",
                                                                               label = "Shape size",
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 3,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = "basesize_growth_parameter_plot",
                                                                               label = "Base font size",
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),
                                                                   sliderInput(inputId = "label.size_growth_parameter_plot",
                                                                               label = "Label font size",
                                                                               min = 5,
                                                                               max = 35,
                                                                               value = 17,
                                                                               step = 0.5),

                                                                   selectInput(inputId = "legend_position_growth_parameter_plot",
                                                                               label = "Legend position",
                                                                               choices = c("Bottom" = "bottom",
                                                                                           "Top" = "top",
                                                                                           "Left" = "left",
                                                                                           "Right" = "right"),
                                                                               selected = "right"
                                                                   ),

                                                                   sliderInput(inputId = 'legend_ncol_growth_parameter_plot',
                                                                               label = 'Number of legend columns',
                                                                               min = 1,
                                                                               max = 10,
                                                                               value = 1,
                                                                               step = 1
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc",
                                                                     checkboxInput(inputId = "sort_by_conc_growth_parameter_plot",
                                                                                   label = "Sort samples by concentration",
                                                                                   value = FALSE)
                                                                   ),

                                                                   textInput(
                                                                     inputId = 'custom_colors_growth_parameter_plot',
                                                                     label = 'Custom colors'
                                                                   ),
                                                                   bsPopover(id = "custom_colors_growth_parameter_plot",
                                                                             title = HTML("<em>Provide custom colors</em>"), placement = "top",
                                                                             content = "Enter colors either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). Separate colors with a comma. A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                   ),


                                                                 ),

                                                                 mainPanel(
                                                                   plotOutput("growth_parameter_plot",
                                                                              width = "100%", height = "800px"),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_growth_parameter_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_growth_parameter_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_growth_parameter_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column

                                                                     column(width = 5,
                                                                            downloadButton('download_growth_parameter_plot',"Download Plot"),

                                                                            radioButtons("format_download_growth_parameter_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column


                                                                   ) # fluidRow
                                                                 ) #  mainPanel
                                                        ),

                                                        ### Growth Grid Plots ####

                                                        tabPanel(title = "Plot Grid",
                                                                 sidebarPanel(

                                                                   selectInput(inputId = "data_type_growth_grid_plot",
                                                                               label = "Data type",
                                                                               choices = c("Raw growth" = "raw",
                                                                                           "Spline fits" = "spline")
                                                                   ),

                                                                   selectInput(inputId = "parameter_parameter_grid_plot",
                                                                               label = "Parameter",
                                                                               choices = ""
                                                                   ),

                                                                   checkboxInput(inputId = "select_string_visualize_growth_grid",
                                                                                 label = "(De-)select samples based on string",
                                                                                 value = FALSE),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_growth_grid && !input.plot_group_averages_growth_grid_plot",
                                                                     selectizeInput(inputId = "samples_visualize_growth_grid",
                                                                                    label = "Samples:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     ),
                                                                     checkboxInput(inputId = "order_matters_visualize_growth_grid",
                                                                                   label = "Select order matters",
                                                                                   value = FALSE
                                                                     ),
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_growth_grid && input.plot_group_averages_growth_grid_plot",
                                                                     selectizeInput(inputId = "groups_visualize_growth_grid",
                                                                                    label = "Conditions:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.select_string_visualize_growth_grid",
                                                                     textInput(inputId = "select_samples_based_on_string_growth_grid_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_string_growth_grid_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     ),

                                                                   ),
                                                                   conditionalPanel(
                                                                     condition = "input.plot_group_averages_growth_grid_plot || input.select_string_visualize_growth_grid",
                                                                     textInput(inputId = "select_samples_based_on_concentration_growth_grid_plot",
                                                                               label = "Select sample based on concentration (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_concentration_growth_grid_plot",
                                                                               label = "Exclude sample based on concentration (separate by ;)"
                                                                     )
                                                                   ),

                                                                   checkboxInput(inputId = "plot_group_averages_growth_grid_plot",
                                                                                 label = "Plot group averages",
                                                                                 value = TRUE),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc",
                                                                     checkboxInput(inputId = "sort_by_conc_growth_grid_plot",
                                                                                   label = "Sort by concentration",
                                                                                   value = TRUE)
                                                                   ),

                                                                   h3("Customize plot appearance"),

                                                                   checkboxInput(inputId = "log_transform_y_axis_growth_grid_plot",
                                                                                 label = "Log-transform y-axis",
                                                                                 value = TRUE),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_growth_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_growth_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_growth_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_growth_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("Color scale limits"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "legend_lim_min_growth_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "legend_lim_max_growth_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),


                                                                   textInput(inputId = "y_axis_title_growth_grid_plot",
                                                                             label = "y-axis title",
                                                                             value = "Growth [y(t)]"
                                                                   ),

                                                                   textInput(inputId = "x_axis_title_growth_grid_plot",
                                                                             label = "x-axis title",
                                                                             value = "Time"
                                                                   ),

                                                                   sliderInput(inputId = "nbreaks_growth_grid_plot",
                                                                               label = "Number of breaks on y-axis",
                                                                               min = 1,
                                                                               max = 20,
                                                                               value = 6),

                                                                   sliderInput(inputId = "line_width_growth_grid_plot",
                                                                               label = "Line width",
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1.1),

                                                                   sliderInput(inputId = 'base_size_growth_grid_plot',
                                                                               label = 'Base font size',
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),


                                                                   conditionalPanel(
                                                                     condition = "!input.sort_by_conc_growth_grid_plot",
                                                                     sliderInput(inputId = "nrows_growth_grid_plot",
                                                                                 label = "Number of rows in grid",
                                                                                 min = 1,
                                                                                 max = 20,
                                                                                 value = 2)
                                                                   ),


                                                                   selectInput(inputId = "color_palettes_grid_plot",
                                                                               label = "Change color palette",
                                                                               width = "100%",
                                                                               choices = names(QurvE:::single_hue_palettes),
                                                                               selected = names(QurvE:::single_hue_palettes)[1],
                                                                               multiple = FALSE
                                                                   ),
                                                                   bsPopover(id = "color_palettes_grid_plot",
                                                                             title = HTML("<em>Define the colors used to visualize the value of the chosen parameter</em>"), placement = "top",
                                                                             content = ""
                                                                   ),

                                                                   checkboxInput(inputId = "invert_color_palette_grid_plot",
                                                                                 label = "Invert color palette",
                                                                                 value = FALSE)

                                                                 ), # Side panel growth group plots

                                                                 mainPanel(
                                                                   withSpinner(
                                                                     plotOutput("growth_grid_plot",
                                                                                width = "100%", height = "1000px"),

                                                                   ),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_growth_grid_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 10)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_growth_grid_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 9)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_growth_grid_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_growth_grid_plot',"Download Plot"),

                                                                            radioButtons("format_download_growth_grid_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ) # column
                                                                   ) # fluidRow
                                                                 ) #  mainPanel
                                                        ),

                                                        ### Growth DR Plots Spline ####

                                                        tabPanel(title = "Dose-Response Analysis", value = "tabPanel_Visualize_Growth_DoseResponse_Spline",
                                                                 sidebarPanel(
                                                                   conditionalPanel(
                                                                     condition = "output.more_than_one_drfit_spline",
                                                                     wellPanel(
                                                                       style='padding: 1; border-color: #ADADAD; padding-bottom: 0',
                                                                       checkboxInput(inputId = 'combine_conditions_into_a_single_plot_dose_response_growth_plot',
                                                                                     label = 'Combine conditions into a single plot',
                                                                                     value = FALSE)
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.combine_conditions_into_a_single_plot_dose_response_growth_plot",
                                                                     textInput(inputId = "select_samples_based_on_string_dose_response_growth_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.combine_conditions_into_a_single_plot_dose_response_growth_plot",
                                                                     textInput(inputId = "exclude_samples_based_on_string_dose_response_growth_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     )
                                                                   ),

                                                                   h3('Customize plot appearance'),

                                                                   checkboxInput(inputId = "log_transform_y_axis_dose_response_growth_plot",
                                                                                 label = "Log-transform y-axis",
                                                                                 value = FALSE),

                                                                   checkboxInput(inputId = "log_transform_x_axis_dose_response_growth_plot",
                                                                                 label = "Log-transform x-axis",
                                                                                 value = FALSE),

                                                                   sliderInput(inputId = 'shape_type_dose_response_growth_plot',
                                                                               label = 'Shape type',
                                                                               min = 1,
                                                                               max = 25,
                                                                               value = 15),

                                                                   sliderInput(inputId = 'shape_size_dose_response_growth_plot',
                                                                               label = 'Shape size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 2,
                                                                               step = 0.1),

                                                                   conditionalPanel(
                                                                     condition = "input.combine_conditions_into_a_single_plot_dose_response_growth_plot",
                                                                     sliderInput(inputId = 'base_size_dose_response_growth_plot',
                                                                                 label = 'Base size',
                                                                                 min = 10,
                                                                                 max = 35,
                                                                                 value = 15,
                                                                                 step = 0.5)
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "!input.combine_conditions_into_a_single_plot_dose_response_growth_plot",
                                                                     sliderInput(inputId = 'axis_size_dose_response_growth_plot',
                                                                                 label = 'Axis title font size',
                                                                                 min = 0.1,
                                                                                 max = 10,
                                                                                 value = 1.3,
                                                                                 step = 0.1)
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "!input.combine_conditions_into_a_single_plot_dose_response_growth_plot",
                                                                     sliderInput(inputId = 'lab_size_dose_response_growth_plot',
                                                                                 label = 'Axis label font size',
                                                                                 min = 0.1,
                                                                                 max = 10,
                                                                                 value = 1.3,
                                                                                 step = 0.1)
                                                                   ),

                                                                   sliderInput(inputId = 'line_width_dose_response_growth_plot',
                                                                               label = 'Line width',
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1),

                                                                   checkboxInput(inputId = 'show_ec50_indicator_lines_dose_response_growth_plot',
                                                                                 label = 'Show EC50 indicator lines',
                                                                                 value = TRUE),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_dose_response_growth_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_dose_response_growth_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_dose_response_growth_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_dose_response_growth_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   textInput(inputId = "y_axis_title_dose_response_growth_plot",
                                                                             label = "y-axis title",
                                                                             value = ""
                                                                   ),

                                                                   textInput(inputId = "x_axis_title_dose_response_growth_plot",
                                                                             label = "x-axis title",
                                                                             value = ""
                                                                   )

                                                                 ), # sidebarPanel

                                                                 conditionalPanel(condition = "input.combine_conditions_into_a_single_plot_dose_response_growth_plot",
                                                                                  mainPanel(
                                                                                    h3('Combined plots'),
                                                                                    plotOutput("dose_response_growth_plot_combined",
                                                                                               width = "100%", height = "800px"),

                                                                                    fluidRow(
                                                                                      column(6, align = "center", offset = 3,
                                                                                             actionButton(inputId = "rerun_dr_growth",
                                                                                                          label = "Re-run dose-response analysis with modified parameters",
                                                                                                          icon=icon("gears"),
                                                                                                          style="padding:5px; font-size:120%"),
                                                                                             actionButton(inputId = "restore_dr_growth",
                                                                                                          label = "Restore dose-response analysis",
                                                                                                          # icon=icon("gears"),
                                                                                                          style="padding:5px; font-size:120%")
                                                                                      )
                                                                                    ),

                                                                                    h3(strong("Export plot")),

                                                                                    fluidRow(
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "width_download_dose_response_growth_plot_combined",
                                                                                                          label = "Width (in inches)",
                                                                                                          value = 7)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "height_download_dose_response_growth_plot_combined",
                                                                                                          label = "Height (in inches)",
                                                                                                          value = 6)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "dpi_download_dose_response_growth_plot_combined",
                                                                                                          label = "DPI",
                                                                                                          value = 300)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             downloadButton('download_dose_response_growth_plot_combined',"Download Plot"),

                                                                                             radioButtons("format_download_dose_response_growth_plot_combined",
                                                                                                          label = NULL,
                                                                                                          choices = c("PNG" = ".png",
                                                                                                                      "PDF" = ".pdf"),
                                                                                                          selected = ".png",
                                                                                                          inline = TRUE)
                                                                                      ), # column


                                                                                    ) # fluidRow
                                                                                  ) # mainPanel
                                                                 ),

                                                                 conditionalPanel(condition = "!input.combine_conditions_into_a_single_plot_dose_response_growth_plot",
                                                                                  mainPanel(
                                                                                    h3('Individual plots'),
                                                                                    selectInput(inputId = 'individual_plots_dose_response_growth_plot',
                                                                                                label = 'Select plot',
                                                                                                choices = "",
                                                                                                multiple = FALSE,
                                                                                                selectize = FALSE,
                                                                                                size = 3),
                                                                                    plotOutput("dose_response_growth_plot_individual",
                                                                                               width = "100%", height = "800px"),

                                                                                    fluidRow(
                                                                                      column(6, align = "center", offset = 3,
                                                                                             actionButton(inputId = "rerun_dr_growth2",
                                                                                                          label = "Re-run dose-response analysis with modified parameters",
                                                                                                          icon=icon("gears"),
                                                                                                          style="padding:5px; font-size:120%"),
                                                                                             actionButton(inputId = "restore_dr_growth2",
                                                                                                          label = "Restore dose-response analysis",
                                                                                                          # icon=icon("gears"),
                                                                                                          style="padding:5px; font-size:120%")
                                                                                      )
                                                                                    ),

                                                                                    h3(strong("Export plot")),

                                                                                    fluidRow(
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "width_download_dose_response_growth_plot_individual",
                                                                                                          label = "Width (in inches)",
                                                                                                          value = 7)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "height_download_dose_response_growth_plot_individual",
                                                                                                          label = "Height (in inches)",
                                                                                                          value = 6)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "dpi_download_dose_response_growth_plot_individual",
                                                                                                          label = "DPI",
                                                                                                          value = 300)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             downloadButton('download_dose_response_growth_plot_individual',"Download Plot"),

                                                                                             radioButtons("format_download_dose_response_growth_plot_individual",
                                                                                                          label = NULL,
                                                                                                          choices = c("PNG" = ".png",
                                                                                                                      "PDF" = ".pdf"),
                                                                                                          selected = ".png",
                                                                                                          inline = TRUE)
                                                                                      ), # column
                                                                                    ) # fluidRow
                                                                                  ) #  mainPanel

                                                                 ),


                                                        ), # tabPanel(title = "Dose-response analysis"

                                                        ### Growth DR Plots Model ####

                                                        tabPanel(title = "Dose-Response Analysis", value = "tabPanel_Visualize_Growth_DoseResponse_Model",
                                                                 sidebarPanel(

                                                                   h3('Customize plot appearance'),

                                                                   checkboxInput(inputId = "log_transform_x_axis_dose_response_growth_plot_model",
                                                                                 label = "Log-transform x-axis",
                                                                                 value = TRUE),

                                                                   sliderInput(inputId = 'shape_type_dose_response_growth_plot_model',
                                                                               label = 'Shape type',
                                                                               min = 1,
                                                                               max = 25,
                                                                               value = 15),

                                                                   sliderInput(inputId = 'shape_size_dose_response_growth_plot_model',
                                                                               label = 'Shape size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 2,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'axis_size_dose_response_growth_plot_model',
                                                                               label = 'Axis title font size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 1.3,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'lab_size_dose_response_growth_plot_model',
                                                                               label = 'Axis label font size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 1.3,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'line_width_dose_response_growth_plot_model',
                                                                               label = 'Line width',
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1),

                                                                   conditionalPanel(
                                                                     condition = "input.log_transform_x_axis_dose_response_growth_plot_model",
                                                                     sliderInput(inputId = "nbreaks_x_growth_dose_response_plot_model",
                                                                                 label = "Number of breaks on x-axis",
                                                                                 min = 1,
                                                                                 max = 20,
                                                                                 value = 6)
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.log_transform_y_axis_dose_response_growth_plot_model",
                                                                     sliderInput(inputId = "nbreaks_y_growth_dose_response_plot_model",
                                                                                 label = "Number of breaks on y-axis",
                                                                                 min = 1,
                                                                                 max = 20,
                                                                                 value = 6)
                                                                   ),

                                                                   checkboxInput(inputId = 'show_ec50_indicator_lines_dose_response_growth_plot_model',
                                                                                 label = 'Show EC50 indicator lines',
                                                                                 value = TRUE),

                                                                   conditionalPanel(
                                                                     condition = "input.log_transform_x_axis_dose_response_growth_plot_model",
                                                                     checkboxInput(inputId = 'show_break_dose_response_growth_plot_model',
                                                                                   label = 'Show x axis break',
                                                                                   value = TRUE)
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.show_break_dose_response_growth_plot_model && input.log_transform_x_axis_dose_response_growth_plot_model",
                                                                     QurvE:::numberInput(inputId = 'bp_dose_response_growth_plot_model',
                                                                                         label = 'Break point position',
                                                                                         value = ""),
                                                                   ),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_dose_response_growth_plot_model",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_dose_response_growth_plot_model",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_dose_response_growth_plot_model",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_dose_response_growth_plot_model",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   textInput(inputId = "y_axis_title_dose_response_growth_plot_model",
                                                                             label = "y-axis title",
                                                                             value = ""
                                                                   ),

                                                                   textInput(inputId = "x_axis_title_dose_response_growth_plot_model",
                                                                             label = "x-axis title",
                                                                             value = ""
                                                                   )

                                                                 ), # sidebarPanel

                                                                 mainPanel(

                                                                   selectInput(inputId = 'individual_plots_dose_response_growth_plot_model',
                                                                               label = 'Select plot',
                                                                               choices = "",
                                                                               multiple = FALSE,
                                                                               selectize = FALSE,
                                                                               size = 3),
                                                                   plotOutput("dose_response_growth_plot_model",
                                                                              width = "100%", height = "800px"),

                                                                   fluidRow(
                                                                     column(6, align = "center", offset = 3,
                                                                            actionButton(inputId = "rerun_dr_growth3",
                                                                                         label = "Re-run dose-response analysis with modified parameters",
                                                                                         icon=icon("gears"),
                                                                                         style="padding:5px; font-size:120%"),
                                                                            actionButton(inputId = "restore_dr_growth3",
                                                                                         label = "Restore dose-response analysis",
                                                                                         # icon=icon("gears"),
                                                                                         style="padding:5px; font-size:120%")
                                                                     )
                                                                   ),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_dose_response_growth_plot_model",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_dose_response_growth_plot_model",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_dose_response_growth_plot_model",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_dose_response_growth_plot_model',"Download Plot"),

                                                                            radioButtons("format_download_dose_response_growth_plot_model",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column
                                                                   ) # fluidRow
                                                                 ), # mainPanel
                                                        ), # tabPanel(title = "Dose-response analysis"

                                                        ### Growth DR Plots Bootstrap ####

                                                        tabPanel(title = "Dose-Response Analysis (Bootstrap)", value = "tabPanel_Visualize_Growth_DoseResponse_Spline_bt",
                                                                 sidebarPanel(

                                                                   h3('Customize plot appearance'),


                                                                   sliderInput(inputId = 'shape_type_dose_response_growth_plot_bt',
                                                                               label = 'Shape type',
                                                                               min = 1,
                                                                               max = 25,
                                                                               value = 15),

                                                                   sliderInput(inputId = 'shape_size_dose_response_growth_plot_bt',
                                                                               label = 'Shape size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 2,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'axis_size_dose_response_growth_plot_bt',
                                                                               label = 'Axis title font size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 1.3,
                                                                               step = 0.1),


                                                                   sliderInput(inputId = 'lab_size_dose_response_growth_plot_bt',
                                                                               label = 'Axis label font size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 1.3,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'line_width_dose_response_growth_plot_bt',
                                                                               label = 'Line width',
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1),

                                                                 ), # sidebarPanel

                                                                 mainPanel(
                                                                   h3('Individual plots'),
                                                                   selectInput(inputId = 'individual_plots_dose_response_growth_plot_bt',
                                                                               label = 'Select plot',
                                                                               choices = "",
                                                                               multiple = FALSE,
                                                                               selectize = FALSE,
                                                                               size = 3),
                                                                   plotOutput("dose_response_growth_plot_individual_bt",
                                                                              width = "100%", height = "800px"),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_dose_response_growth_plot_individual_bt",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_dose_response_growth_plot_individual_bt",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_dose_response_growth_plot_individual_bt",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_dose_response_growth_plot_individual_bt',"Download Plot"),

                                                                            radioButtons("format_download_dose_response_growth_plot_individual_bt",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column
                                                                   ) # fluidRow
                                                                 ) #  mainPanel
                                                        ), # tabPanel(title = "Dose-response analysis (Bootstrap)"

                                                        ### Growth DR Parameters ####

                                                        tabPanel(title = "DR Parameter Plots",value = "tabPanel_Visualize_Growth_DoseResponseParameters",
                                                                 sidebarPanel(
                                                                   selectInput(inputId = "parameter_dr_parameter_growth_plot",
                                                                               label = "Parameter",
                                                                               choices = ""
                                                                   ),

                                                                   textInput(inputId = "select_sample_based_on_string_growth_dr_parameter_plot",
                                                                             label = "Select sample based on string (separated by ;)"
                                                                   ),

                                                                   textInput(inputId = "exclude_sample_based_on_strings_growth_dr_parameter_plot",
                                                                             label = "Exclude sample based on strings (separated by ;)"
                                                                   ),

                                                                   checkboxInput(inputId = 'normalize_to_reference_growth_dr_parameter_plot',
                                                                                 label = 'normalize to reference',
                                                                                 value = FALSE),

                                                                   h3("Customize plot appearance"),

                                                                   # Conditional Panel
                                                                   conditionalPanel(condition = "input.normalize_to_reference_growth_dr_parameter_plot",
                                                                                    # reactive selection
                                                                                    selectInput(inputId = 'reference_condition_growth_dr_parameter_plot',
                                                                                                label = 'Reference condition',
                                                                                                choices = ""
                                                                                    )
                                                                   ),


                                                                   sliderInput(inputId = "basesize_growth_dr_parameter_plot",
                                                                               label = "Base font size",
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),

                                                                   sliderInput(inputId = "label.size_growth_dr_parameter_plot",
                                                                               label = "Label font size",
                                                                               min = 5,
                                                                               max = 35,
                                                                               value = 20,
                                                                               step = 0.5)


                                                                 ),

                                                                 mainPanel(
                                                                   plotOutput("growth_dr_parameter_plot",
                                                                              width = "100%", height = "800px"),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_growth_dr_parameter_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_growth_dr_parameter_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_growth_dr_parameter_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column

                                                                     column(width = 5,
                                                                            downloadButton('download_growth_dr_parameter_plot',"Download Plot"),

                                                                            radioButtons("format_download_growth_dr_parameter_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column


                                                                   ) # fluidRow
                                                                 ) #  mainPanel
                                                        ), # tabPanel Growth_Parameter_Plots
                                            )
                                   ),

                                   ## Fluorescence Plots ####
                                   tabPanel(title = "Fluorescence Plots",  value = "tabPanel_Visualize_Fluorescence",
                                            h1("Fluorescence Plots"),
                                            tabsetPanel(type = "tabs",id = "tabsetPanel_Visualize_Fluorescence",

                                                        ### Fluorescence Group Plots ####

                                                        tabPanel(title = "Group plots",
                                                                 sidebarPanel(

                                                                   selectInput(inputId = "data_type_fluorescence_group_plot",
                                                                               label = "Data type",
                                                                               choices = c("Raw fluorescence" = "raw",
                                                                                           "Spline fits FL" = "spline",
                                                                                           "Normalized FL" = "norm.fl"
                                                                               )
                                                                   ),

                                                                   checkboxInput(inputId = "select_string_visualize_fluorescence_group",
                                                                                 label = "(De-)select samples based on string",
                                                                                 value = FALSE),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_fluorescence_group && !input.plot_group_averages_fluorescence_group_plot",
                                                                     selectizeInput(inputId = "samples_visualize_fluorescence_group",
                                                                                    label = "Samples:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_fluorescence_group && input.plot_group_averages_fluorescence_group_plot",
                                                                     selectizeInput(inputId = "groups_visualize_fluorescence_group",
                                                                                    label = "Conditions:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.select_string_visualize_fluorescence_group",
                                                                     textInput(inputId = "select_samples_based_on_string_fluorescence_group_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_string_fluorescence_group_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     ),

                                                                   ),
                                                                   conditionalPanel(
                                                                     condition = "input.plot_group_averages_fluorescence_group_plot || input.select_string_visualize_fluorescence_group",
                                                                     textInput(inputId = "select_samples_based_on_concentration_fluorescence_group_plot",
                                                                               label = "Select sample based on concentration (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_concentration_fluorescence_group_plot",
                                                                               label = "Exclude sample based on concentration (separate by ;)"
                                                                     )
                                                                   ),

                                                                   checkboxInput(inputId = "plot_group_averages_fluorescence_group_plot",
                                                                                 label = "Plot group averages",
                                                                                 value = TRUE),

                                                                   conditionalPanel(
                                                                     condition = "input.data_type_fluorescence_group_plot == 'spline' ",
                                                                     checkboxInput(inputId = "plot_derivative_fluorescence_group_plot",
                                                                                   label = "Plot derivative",
                                                                                   value = TRUE)
                                                                   ),

                                                                   h3("Customize plot appearance"),

                                                                   checkboxInput(inputId = "log_transform_y_axis_fluorescence_group_plot",
                                                                                 label = "Log-transform y-axis",
                                                                                 value = FALSE),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_fluorescence_group_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_fluorescence_group_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_fluorescence_group_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_fluorescence_group_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),
                                                                   conditionalPanel(
                                                                     condition = "input.data_type_fluorescence_group_plot == 'spline'",
                                                                     strong("y-Range (derivative)"),
                                                                     fluidRow(
                                                                       column(5,
                                                                              textInput(inputId = "y_range_min_derivative_fluorescence_group_plot",
                                                                                        label = NULL,
                                                                                        value = "min", placeholder = "min"
                                                                              )
                                                                       ),

                                                                       column(5,
                                                                              textInput(inputId = "y_range_max_derivative_fluorescence_group_plot",
                                                                                        label = NULL,
                                                                                        value = "", placeholder = "max"
                                                                              )
                                                                       )
                                                                     )
                                                                   ),

                                                                   textInput(inputId = "y_axis_title_fluorescence_group_plot",
                                                                             label = "y-axis title",
                                                                             value = ""
                                                                   ),

                                                                   textInput(inputId = "x_axis_title_fluorescence_group_plot",
                                                                             label = "x-axis title",
                                                                             value = ""
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.data_type_fluorescence_group_plot == 'spline' ",
                                                                     textInput(inputId = "y_axis_title_derivative_fluorescence_group_plot",
                                                                               label = "y-axis title derivative",
                                                                               value = ""
                                                                     )
                                                                   ),

                                                                   sliderInput(inputId = "nbreaks_fluorescence_group_plot",
                                                                               label = "Number of breaks on y-axis",
                                                                               min = 1,
                                                                               max = 20,
                                                                               value = 6),

                                                                   sliderInput(inputId = "line_width_fluorescence_group_plot",
                                                                               label = "Line width",
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1.1),

                                                                   sliderInput(inputId = 'base_size_fluorescence_group_plot',
                                                                               label = 'Base font size',
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),

                                                                   sliderInput(inputId = 'legend_ncol_fluorescence_group_plot',
                                                                               label = 'Number of legend columns',
                                                                               min = 1,
                                                                               max = 10,
                                                                               value = 4,
                                                                               step = 1),

                                                                   selectInput(inputId = "legend_position_fluorescence_group_plot",
                                                                               label = "Legend position",
                                                                               choices = c("Bottom" = "bottom",
                                                                                           "Top" = "top",
                                                                                           "Left" = "left",
                                                                                           "Right" = "right")
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc",
                                                                     checkboxInput(inputId = "color_groups_fluorescence_group_plot",
                                                                                   label = "Color samples by group",
                                                                                   value = TRUE)
                                                                   ),

                                                                   textInput(
                                                                     inputId = 'custom_colors_fluorescence_group_plot',
                                                                     label = 'Custom colors'
                                                                   ),
                                                                   bsPopover(id = "custom_colors_fluorescence_group_plot",
                                                                             title = HTML("<em>Provide custom colors</em>"), placement = "top",
                                                                             content = "Enter colors either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). Separate colors with a comma. A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc && input.color_groups_fluorescence_group_plot",
                                                                     selectizeInput(inputId = "color_palettes_fluorescence_group_plot",
                                                                                    label = "Change color palettes",
                                                                                    width = "100%",
                                                                                    choices = names(QurvE:::single_hue_palettes),
                                                                                    selected = names(QurvE:::single_hue_palettes),
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     ),
                                                                     bsPopover(id = "color_palettes_fluorescence_group_plot",
                                                                               title = HTML("<em>Define the colors used to display sample groups with identical concentrations</em>"), placement = "top",
                                                                               content = "The number of selected color palettes must be at least the number of displayed groups. The order of the chosen palettes corresponds to the oder of conditions in the legend."
                                                                     ),
                                                                   ),

                                                                 ), # Side panel growth group plots

                                                                 mainPanel(
                                                                   withSpinner(
                                                                     plotOutput("fluorescence_group_plot",
                                                                                width = "100%", height = "1000px")
                                                                   ),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_fluorescence_group_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_fluorescence_group_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_fluorescence_group_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_fluorescence_group_plot',"Download Plot"),

                                                                            radioButtons("format_download_fluorescence_group_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column


                                                                   ) # fluidRow
                                                                 ) # mainPanel


                                                        ), # tabPanel Group_Plots

                                                        ### Dual Plots ####

                                                        tabPanel(title = "Growth & Flourescence Plot", value = "tabPabel_Visualize_Dual",
                                                                 h1("Growth & Flourescence Plot"),

                                                                 sidebarPanel(

                                                                   selectInput(inputId = "fluorescence_type_dual_plot",
                                                                               label = "Fluorescence type",
                                                                               choices = c("Fluorescence" = "fl",
                                                                                           "Normalized fluorescence" = "norm.fl"
                                                                               )
                                                                   ),

                                                                   checkboxInput(inputId = "select_string_visualize_dual_plot",
                                                                                 label = "(De-)select samples based on string",
                                                                                 value = FALSE),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_dual_plot",
                                                                     selectizeInput(inputId = "samples_visualize_dual_plot",
                                                                                    label = "Samples:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.select_string_visualize_dual_plot",
                                                                     textInput(inputId = "select_samples_based_on_string_dual_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_string_dual_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     ),

                                                                   ),
                                                                   conditionalPanel(
                                                                     condition = "input.plot_group_averages_dual_plot || input.select_string_visualize_dual_plot",
                                                                     textInput(inputId = "select_samples_based_on_concentration_dual_plot",
                                                                               label = "Select sample based on concentration (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_concentration_dual_plot",
                                                                               label = "Exclude sample based on concentration (separate by ;)"
                                                                     )
                                                                   ),

                                                                   checkboxInput(inputId = "plot_group_averages_dual_plot",
                                                                                 label = "Plot group averages",
                                                                                 value = TRUE),

                                                                   h3("Customize plot appearance"),

                                                                   checkboxInput(inputId = "log_transform_y_axis_growth_dual_plot",
                                                                                 label = "Log-transform y-axis (growth)",
                                                                                 value = FALSE),

                                                                   checkboxInput(inputId = "log_transform_y_axis_fluorescence_dual_plot",
                                                                                 label = "Log-transform y-axis (Fluorescence)",
                                                                                 value = FALSE),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_dual_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_dual_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range (growth)"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_growth_dual_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_growth_dual_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range (Fluorescence"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_fluorescence_dual_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_fluorescence_dual_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   textInput(inputId = "y_axis_title_growth_dual_plot",
                                                                             label = "y-axis title (growth)",
                                                                             value = ""
                                                                   ),

                                                                   textInput(inputId = "y_axis_title_fluorescence_dual_plot",
                                                                             label = "y-axis title (Fluorescence)",
                                                                             value = ""
                                                                   ),

                                                                   textInput(inputId = "x_axis_title_dual_plot",
                                                                             label = "x-axis title",
                                                                             value = ""
                                                                   ),

                                                                   sliderInput(inputId = "nbreaks_dual_plot",
                                                                               label = "Number of breaks on y-axis",
                                                                               min = 1,
                                                                               max = 20,
                                                                               value = 6),

                                                                   sliderInput(inputId = "line_width_dual_plot",
                                                                               label = "Line width",
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1.1),

                                                                   sliderInput(inputId = 'base_size_dual_plot',
                                                                               label = 'Base font size',
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),

                                                                   selectInput(inputId = "legend_position_dual_plot",
                                                                               label = "Legend position",
                                                                               choices = c("Bottom" = "bottom",
                                                                                           "Top" = "top",
                                                                                           "Left" = "left",
                                                                                           "Right" = "right")
                                                                   ),

                                                                   sliderInput(inputId = 'legend_ncol_dual_plot',
                                                                               label = 'Number of legend columns',
                                                                               min = 1,
                                                                               max = 10,
                                                                               value = 4,
                                                                               step = 1
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc",
                                                                     checkboxInput(inputId = "color_groups_dual_plot",
                                                                                   label = "Color samples by group",
                                                                                   value = TRUE)
                                                                   ),

                                                                   textInput(
                                                                     inputId = 'custom_colors_dual_plot',
                                                                     label = 'Custom colors'
                                                                   ),
                                                                   bsPopover(id = "custom_colors_dual_plot",
                                                                             title = HTML("<em>Provide custom colors</em>"), placement = "top",
                                                                             content = "Enter colors either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). Separate colors with a comma. A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc && input.color_groups_dual_plot",
                                                                     selectizeInput(inputId = "color_palettes_dual_plot",
                                                                                    label = "Change color palettes",
                                                                                    width = "100%",
                                                                                    choices = names(QurvE:::single_hue_palettes),
                                                                                    selected = names(QurvE:::single_hue_palettes),
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     ),
                                                                     bsPopover(id = "color_palettes_dual_plot",
                                                                               title = HTML("<em>Define the colors used to display sample groups with identical concentrations</em>"), placement = "top",
                                                                               content = "The number of selected color palettes must be at least the number of displayed groups. The order of the chosen palettes corresponds to the oder of conditions in the legend."
                                                                     ),
                                                                   ),
                                                                 ),

                                                                 mainPanel(
                                                                   withSpinner(
                                                                     plotOutput("dual_plot",
                                                                                width = "100%", height = "1000px")
                                                                   ),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_dual_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_dual_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_dual_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_dual_plot',"Download Plot"),

                                                                            radioButtons("format_download_dual_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column
                                                                   ) # fluidRow
                                                                 ) # mainPanel
                                                        ), # tabPanel(title = "Growth & Flourescence Plot")

                                                        ### Fluorescence Parameter Plots ####

                                                        tabPanel(title = "Parameter plots",
                                                                 sidebarPanel(
                                                                   selectInput(inputId = "parameter_fluorescence_parameter_fluorescence_plot",
                                                                               label = "Parameter",
                                                                               choices = ""
                                                                   ),
                                                                   checkboxInput(inputId = "select_string_visualize_parameter_fluorescence_plot",
                                                                                 label = "(De-)select samples based on string",
                                                                                 value = FALSE),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_parameter_fluorescence_plot",
                                                                     selectizeInput(inputId = "samples_visualize_parameter_fluorescence_plot",
                                                                                    label = "Conditions:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.select_string_visualize_parameter_fluorescence_plot",
                                                                     textInput(inputId = "select_sample_based_on_string_fluorescence_parameter_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_sample_based_on_strings_fluorescence_parameter_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     ),

                                                                   ),

                                                                   textInput(inputId = "select_sample_based_on_concentration_fluorescence_parameter_plot",
                                                                             label = "Select sample based on concentration (separate by ;)"
                                                                   ),

                                                                   textInput(inputId = "exclude_sample_based_on_concentration_fluorescence_parameter_plot",
                                                                             label = "Exclude sample based on concentration (separate by ;)"
                                                                   ),

                                                                   checkboxInput(inputId = 'normalize_to_reference_fluorescence_parameter_plot',
                                                                                 label = 'normalize to reference',
                                                                                 value = FALSE),

                                                                   # Conditional Panel
                                                                   conditionalPanel(condition = "input.normalize_to_reference_fluorescence_parameter_plot",
                                                                                    # reactive selection
                                                                                    selectInput(inputId = 'reference_condition_fluorescence_parameter_plot',
                                                                                                label = 'Reference condition',
                                                                                                choices = ""
                                                                                    ),

                                                                                    # reactive selection
                                                                                    selectInput(inputId = 'reference_concentration_fluorescence_parameter_plot',
                                                                                                label = 'Reference concentration',
                                                                                                choices = ""
                                                                                    ),
                                                                   ),

                                                                   h3("Customize plot appearance"),

                                                                   sliderInput(inputId = "shape.size_fluorescence_parameter_plot",
                                                                               label = "Shape size",
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 3,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = "basesize_fluorescence_parameter_plot",
                                                                               label = "Base font size",
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),

                                                                   sliderInput(inputId = "label.size_fluorescence_parameter_plot",
                                                                               label = "Label font size",
                                                                               min = 5,
                                                                               max = 35,
                                                                               value = 17,
                                                                               step = 0.5),

                                                                   selectInput(inputId = "legend_position_fluorescence_parameter_plot",
                                                                               label = "Legend position",
                                                                               choices = c("Bottom" = "bottom",
                                                                                           "Top" = "top",
                                                                                           "Left" = "left",
                                                                                           "Right" = "right"),
                                                                               selected = "right"
                                                                   ),

                                                                   sliderInput(inputId = 'legend_ncol_fluorescence_parameter_plot',
                                                                               label = 'Number of legend columns',
                                                                               min = 1,
                                                                               max = 10,
                                                                               value = 1,
                                                                               step = 1
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc",
                                                                     checkboxInput(inputId = "sort_by_conc_fluorescence_parameter_plot",
                                                                                   label = "Sort samples by concentration",
                                                                                   value = FALSE)
                                                                   ),

                                                                   textInput(
                                                                     inputId = 'custom_colors_fluorescence_parameter_plot',
                                                                     label = 'Custom colors'
                                                                   ),
                                                                   bsPopover(id = "custom_colors_fluorescence_parameter_plot",
                                                                             title = HTML("<em>Provide custom colors</em>"), placement = "top",
                                                                             content = "Enter colors either by name (e.g., red, blue, coral3) or via their hexadecimal code (e.g., #AE4371, #CCFF00FF, #0066FFFF). Separate colors with a comma. A full list of colors available by name can be found at http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf"
                                                                   ),


                                                                 ),

                                                                 mainPanel(
                                                                   plotOutput("fluorescence_parameter_plot",
                                                                              width = "100%", height = "800px"),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_fluorescence_parameter_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_fluorescence_parameter_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_fluorescence_parameter_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_fluorescence_parameter_plot',"Download Plot"),

                                                                            radioButtons("format_download_fluorescence_parameter_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column
                                                                   ) # fluidRow
                                                                 ) # mainPanel
                                                        ), #  tabPanel(title = "Parameter plots"
                                                        ### Fluorescence Grid Plots ####

                                                        tabPanel(title = "Plot Grid",
                                                                 sidebarPanel(

                                                                   selectInput(inputId = "data_type_fluorescence_grid_plot",
                                                                               label = "Data type",
                                                                               choices = c("Raw growth" = "raw",
                                                                                           "Spline fits" = "spline")
                                                                   ),

                                                                   selectInput(inputId = "parameter_parameter_grid_plot_fluorescence",
                                                                               label = "Parameter",
                                                                               choices = ""
                                                                   ),

                                                                   checkboxInput(inputId = "select_string_visualize_fluorescence_grid",
                                                                                 label = "(De-)select samples based on string",
                                                                                 value = FALSE),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_fluorescence_grid && !input.plot_group_averages_fluorescence_grid_plot",
                                                                     selectizeInput(inputId = "samples_visualize_fluorescence_grid",
                                                                                    label = "Samples:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     ),
                                                                     checkboxInput(inputId = "order_matters_visualize_fluorescence_grid",
                                                                                   label = "Select order matters",
                                                                                   value = FALSE
                                                                     ),
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "!input.select_string_visualize_fluorescence_grid && input.plot_group_averages_fluorescence_grid_plot",
                                                                     selectizeInput(inputId = "groups_visualize_fluorescence_grid",
                                                                                    label = "Conditions:",
                                                                                    width = "100%",
                                                                                    choices = "",
                                                                                    multiple = TRUE,
                                                                                    options = list(closeAfterSelect = FALSE,
                                                                                                   plugins= list('remove_button'))
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.select_string_visualize_fluorescence_grid",
                                                                     textInput(inputId = "select_samples_based_on_string_fluorescence_grid_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_string_fluorescence_grid_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     ),

                                                                   ),
                                                                   conditionalPanel(
                                                                     condition = "input.plot_group_averages_fluorescence_grid_plot || input.select_string_visualize_fluorescence_grid",
                                                                     textInput(inputId = "select_samples_based_on_concentration_fluorescence_grid_plot",
                                                                               label = "Select sample based on concentration (separate by ;)"
                                                                     ),

                                                                     textInput(inputId = "exclude_samples_based_on_concentration_fluorescence_grid_plot",
                                                                               label = "Exclude sample based on concentration (separate by ;)"
                                                                     )
                                                                   ),

                                                                   checkboxInput(inputId = "plot_group_averages_fluorescence_grid_plot",
                                                                                 label = "Plot group averages",
                                                                                 value = TRUE),

                                                                   conditionalPanel(
                                                                     condition = "output.more_than_two_conc",
                                                                     checkboxInput(inputId = "sort_by_conc_fluorescence_grid_plot",
                                                                                   label = "Sort by concentration",
                                                                                   value = TRUE)
                                                                   ),

                                                                   h3("Customize plot appearance"),

                                                                   checkboxInput(inputId = "log_transform_y_axis_fluorescence_grid_plot",
                                                                                 label = "Log-transform y-axis",
                                                                                 value = TRUE),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_fluorescence_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_fluorescence_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_fluorescence_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_fluorescence_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("Color scale limits"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "legend_lim_min_fluorescence_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "legend_lim_max_fluorescence_grid_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),


                                                                   textInput(inputId = "y_axis_title_fluorescence_grid_plot",
                                                                             label = "y-axis title",
                                                                             value = ""
                                                                   ),

                                                                   textInput(inputId = "x_axis_title_fluorescence_grid_plot",
                                                                             label = "x-axis title",
                                                                             value = ""
                                                                   ),

                                                                   sliderInput(inputId = "nbreaks_fluorescence_grid_plot",
                                                                               label = "Number of breaks on y-axis",
                                                                               min = 1,
                                                                               max = 20,
                                                                               value = 6),

                                                                   sliderInput(inputId = "line_width_fluorescence_grid_plot",
                                                                               label = "Line width",
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1.1),

                                                                   sliderInput(inputId = 'base_size_fluorescence_grid_plot',
                                                                               label = 'Base font size',
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),


                                                                   conditionalPanel(
                                                                     condition = "!input.sort_by_conc_fluorescence_grid_plot",
                                                                     sliderInput(inputId = "nrows_fluorescence_grid_plot",
                                                                                 label = "Number of rows in grid",
                                                                                 min = 1,
                                                                                 max = 20,
                                                                                 value = 2)
                                                                   ),


                                                                   selectInput(inputId = "color_palettes_grid_plot_fluorescence",
                                                                               label = "Change color palette",
                                                                               width = "100%",
                                                                               choices = names(QurvE:::single_hue_palettes),
                                                                               selected = names(QurvE:::single_hue_palettes)[1],
                                                                               multiple = FALSE
                                                                   ),
                                                                   bsPopover(id = "color_palettes_grid_plot_fluorescence",
                                                                             title = HTML("<em>Define the colors used to visualize the value of the chosen parameter</em>"), placement = "top",
                                                                             content = ""
                                                                   ),

                                                                   checkboxInput(inputId = "invert_color_palette_grid_plot_fluorescence",
                                                                                 label = "Invert color palette",
                                                                                 value = FALSE)

                                                                 ), # Side panel fluorescence group plots

                                                                 mainPanel(
                                                                   withSpinner(
                                                                     plotOutput("fluorescence_grid_plot",
                                                                                width = "100%", height = "1000px"),

                                                                   ),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_fluorescence_grid_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 10)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_fluorescence_grid_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 9)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_fluorescence_grid_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_fluorescence_grid_plot',"Download Plot"),

                                                                            radioButtons("format_download_fluorescence_grid_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ) # column
                                                                   ) # fluidRow
                                                                 ) #  mainPanel
                                                        ),
                                                        ### Fluorescence DR Plots Spline ####

                                                        tabPanel(title = "Dose-response analysis", value = "tabPanel_Visualize_Fluorescence_DoseResponse_spline",
                                                                 sidebarPanel(
                                                                   wellPanel(
                                                                     style='padding: 1; border-color: #ADADAD; padding-bottom: 0',
                                                                     checkboxInput(inputId = 'combine_conditions_into_a_single_plot_dose_response_fluorescence_plot',
                                                                                   label = 'Combine conditions into a single plot',
                                                                                   value = TRUE)
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.combine_conditions_into_a_single_plot_dose_response_fluorescence_plot",
                                                                     textInput(inputId = "select_samples_based_on_string_dose_response_fluorescence_plot",
                                                                               label = "Select sample based on string (separate by ;)"
                                                                     )
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "input.combine_conditions_into_a_single_plot_dose_response_fluorescence_plot",
                                                                     textInput(inputId = "exclude_samples_based_on_string_dose_response_fluorescence_plot",
                                                                               label = "Exclude sample based on string (separate by ;)"
                                                                     )
                                                                   ),

                                                                   h3('Customize plot appearance'),

                                                                   checkboxInput(inputId = "log_transform_y_axis_dose_response_fluorescence_plot",
                                                                                 label = "Log-transform y-axis",
                                                                                 value = FALSE),

                                                                   checkboxInput(inputId = "log_transform_x_axis_dose_response_fluorescence_plot",
                                                                                 label = "Log-transform x-axis",
                                                                                 value = FALSE),

                                                                   sliderInput(inputId = 'shape_type_dose_response_fluorescence_plot',
                                                                               label = 'Shape type',
                                                                               min = 1,
                                                                               max = 25,
                                                                               value = 15),

                                                                   sliderInput(inputId = 'shape_size_dose_response_fluorescence_plot',
                                                                               label = 'Shape size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 2,
                                                                               step = 0.1),

                                                                   conditionalPanel(
                                                                     condition = "input.combine_conditions_into_a_single_plot_dose_response_fluorescence_plot",
                                                                     sliderInput(inputId = 'base_size_dose_response_fluorescence_plot',
                                                                                 label = 'Base font size',
                                                                                 min = 10,
                                                                                 max = 35,
                                                                                 value = 15,
                                                                                 step = 0.5)
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "!input.combine_conditions_into_a_single_plot_dose_response_fluorescence_plot",
                                                                     sliderInput(inputId = 'axis_size_dose_response_fluorescence_plot',
                                                                                 label = 'Axis title font size',
                                                                                 min = 0.1,
                                                                                 max = 10,
                                                                                 value = 1.5,
                                                                                 step = 0.1)
                                                                   ),

                                                                   conditionalPanel(
                                                                     condition = "!input.combine_conditions_into_a_single_plot_dose_response_fluorescence_plot",
                                                                     sliderInput(inputId = 'lab_size_dose_response_fluorescence_plot',
                                                                                 label = 'Axis label font size',
                                                                                 min = 0.1,
                                                                                 max = 10,
                                                                                 value = 1.3,
                                                                                 step = 0.1)
                                                                   ),

                                                                   sliderInput(inputId = 'line_width_dose_response_fluorescence_plot',
                                                                               label = 'Line width',
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1),

                                                                   checkboxInput(inputId = 'show_ec50_indicator_lines_dose_response_fluorescence_plot',
                                                                                 label = 'Show EC50 indicator lines',
                                                                                 value = TRUE),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_dose_response_fluorescence_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_dose_response_fluorescence_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_dose_response_fluorescence_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_dose_response_fluorescence_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   textInput(inputId = "y_axis_title_dose_response_fluorescence_plot",
                                                                             label = "y-axis title",
                                                                             value = ""
                                                                   ),

                                                                   textInput(inputId = "x_axis_title_dose_response_fluorescence_plot",
                                                                             label = "x-axis title",
                                                                             value = ""
                                                                   )

                                                                 ), # sidebarPanel

                                                                 conditionalPanel(condition = "input.combine_conditions_into_a_single_plot_dose_response_fluorescence_plot",
                                                                                  mainPanel(
                                                                                    h3('Combined plots'),
                                                                                    plotOutput("dose_response_plot_fluorescence_combined",
                                                                                               width = "100%", height = "800px"),

                                                                                    fluidRow(
                                                                                      column(6, align = "center", offset = 3,
                                                                                             actionButton(inputId = "rerun_dr_fluorescence",
                                                                                                          label = "Re-run dose-response analysis with modified parameters",
                                                                                                          icon=icon("gears"),
                                                                                                          style="padding:5px; font-size:120%"),
                                                                                             actionButton(inputId = "restore_dr_fluorescence",
                                                                                                          label = "Restore dose-response analysis",
                                                                                                          # icon=icon("gears"),
                                                                                                          style="padding:5px; font-size:120%")
                                                                                      )
                                                                                    ),

                                                                                    h3(strong("Export plot")),

                                                                                    fluidRow(
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "width_download_dose_response_plot_fluorescence_combined",
                                                                                                          label = "Width (in inches)",
                                                                                                          value = 7)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "height_download_dose_response_plot_fluorescence_combined",
                                                                                                          label = "Height (in inches)",
                                                                                                          value = 6)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "dpi_download_dose_response_plot_fluorescence_combined",
                                                                                                          label = "DPI",
                                                                                                          value = 300)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             downloadButton('download_dose_response_plot_fluorescence_combined',"Download Plot"),

                                                                                             radioButtons("format_download_dose_response_plot_fluorescence_combined",
                                                                                                          label = NULL,
                                                                                                          choices = c("PNG" = ".png",
                                                                                                                      "PDF" = ".pdf"),
                                                                                                          selected = ".png",
                                                                                                          inline = TRUE)
                                                                                      ), # column


                                                                                    ) # fluidRow
                                                                                  ) # mainPanel
                                                                 ),

                                                                 conditionalPanel(condition = "!input.combine_conditions_into_a_single_plot_dose_response_fluorescence_plot",
                                                                                  mainPanel(
                                                                                    h3('Individual plots'),
                                                                                    selectInput(inputId = 'individual_plots_dose_response_fluorescence_plot',
                                                                                                label = 'Select plot',
                                                                                                choices = "",
                                                                                                multiple = FALSE,
                                                                                                selectize = FALSE,
                                                                                                size = 3),

                                                                                    plotOutput("dose_response_fluorescence_plot_individual",
                                                                                               width = "100%", height = "800px"),

                                                                                    fluidRow(
                                                                                      column(6, align = "center", offset = 3,
                                                                                             actionButton(inputId = "rerun_dr_fluorescence2",
                                                                                                          label = "Re-run dose-response analysis with modified parameters",
                                                                                                          icon=icon("gears"),
                                                                                                          style="padding:5px; font-size:120%"),
                                                                                             actionButton(inputId = "restore_dr_fluorescence2",
                                                                                                          label = "Restore dose-response analysis",
                                                                                                          # icon=icon("gears"),
                                                                                                          style="padding:5px; font-size:120%")
                                                                                      )
                                                                                    ),

                                                                                    h3(strong("Export plot")),

                                                                                    fluidRow(
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "width_download_dose_response_fluorescence_plot_individual",
                                                                                                          label = "Width (in inches)",
                                                                                                          value = 7)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "height_download_dose_response_fluorescence_plot_individual",
                                                                                                          label = "Height (in inches)",
                                                                                                          value = 6)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             numericInput(inputId = "dpi_download_dose_response_fluorescence_plot_individual",
                                                                                                          label = "DPI",
                                                                                                          value = 300)
                                                                                      ), # column
                                                                                      column(width = 4,
                                                                                             downloadButton('download_dose_response_fluorescence_plot_individual',"Download Plot"),

                                                                                             radioButtons("format_download_dose_response_fluorescence_plot_individual",
                                                                                                          label = NULL,
                                                                                                          choices = c("PNG" = ".png",
                                                                                                                      "PDF" = ".pdf"),
                                                                                                          selected = ".png",
                                                                                                          inline = TRUE)
                                                                                      ), # column
                                                                                    ) # fluidRow
                                                                                  ) # mainPanel

                                                                 ), # conditionalPanel
                                                        ), #  tabPanel(title = "Dose-response analysis", value = "tabPanel_Visualize_Fluorescence_DoseResponse_spline",

                                                        ### Fluorescence DR Plots Model ####
                                                        tabPanel(title = "Dose-response analysis", value = "tabPanel_Visualize_Fluorescence_DoseResponse_model",
                                                                 sidebarPanel(

                                                                   checkboxInput(inputId = "log_transform_y_axis_dose_response_model_fluorescence_plot",
                                                                                 label = "Log-transform y-axis",
                                                                                 value = TRUE),

                                                                   checkboxInput(inputId = "log_transform_x_axis_dose_response_model_fluorescence_plot",
                                                                                 label = "Log-transform x-axis",
                                                                                 value = TRUE),

                                                                   h3('Customize plot appearance'),
                                                                   sliderInput(inputId = 'shape_type_dose_response_model_fluorescence_plot',
                                                                               label = 'Shape type',
                                                                               min = 1,
                                                                               max = 25,
                                                                               value = 15),

                                                                   sliderInput(inputId = 'shape_size_dose_response_model_fluorescence_plot',
                                                                               label = 'Shape size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 2,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'axis_size_dose_response_model_fluorescence_plot',
                                                                               label = 'Axis title font size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 1.5,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'lab_size_dose_response_model_fluorescence_plot',
                                                                               label = 'Axis label font size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 1.3,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'line_width_dose_response_model_fluorescence_plot',
                                                                               label = 'Line width',
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1),

                                                                   checkboxInput(inputId = 'show_ec50_indicator_lines_dose_response_model_fluorescence_plot',
                                                                                 label = 'Show EC50 indicator lines',
                                                                                 value = TRUE),

                                                                   strong("x-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "x_range_min_dose_response_model_fluorescence_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "x_range_max_dose_response_model_fluorescence_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),

                                                                   strong("y-Range"),
                                                                   fluidRow(
                                                                     column(5,
                                                                            textInput(inputId = "y_range_min_dose_response_model_fluorescence_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "min"
                                                                            )
                                                                     ),

                                                                     column(5,
                                                                            textInput(inputId = "y_range_max_dose_response_model_fluorescence_plot",
                                                                                      label = NULL,
                                                                                      value = "", placeholder = "max"
                                                                            )
                                                                     )
                                                                   ),
                                                                 ), # sidebarPanel

                                                                 mainPanel(
                                                                   selectInput(inputId = 'individual_plots_dose_response_model_fluorescence_plot',
                                                                               label = 'Select plot',
                                                                               choices = "",
                                                                               multiple = FALSE,
                                                                               selectize = FALSE,
                                                                               size = 3),
                                                                   plotOutput("dose_response_model_fluorescence_plot_individual",
                                                                              width = "100%", height = "800px"),

                                                                   fluidRow(
                                                                     column(6, align = "center", offset = 3,
                                                                            actionButton(inputId = "rerun_dr_fluorescence3",
                                                                                         label = "Re-run dose-response analysis with modified parameters",
                                                                                         icon=icon("gears"),
                                                                                         style="padding:5px; font-size:120%"),
                                                                            actionButton(inputId = "restore_dr_fluorescence3",
                                                                                         label = "Restore dose-response analysis",
                                                                                         # icon=icon("gears"),
                                                                                         style="padding:5px; font-size:120%")
                                                                     )
                                                                   ),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_dose_response_model_fluorescence_plot_individual",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_dose_response_model_fluorescence_plot_individual",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_dose_response_model_fluorescence_plot_individual",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_dose_response_model_fluorescence_plot_individual',"Download Plot"),

                                                                            radioButtons("format_download_dose_response_model_fluorescence_plot_individual",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column


                                                                   ) # fluidRow
                                                                 ) # mainPanel
                                                        ), # tabPanel(title = "Dose-response analysis",

                                                        ### Fluorescence DR Plots Bootstrap ####

                                                        tabPanel(title = "Dose-Response Analysis (Bootstrap)", value = "tabPanel_Visualize_Fluorescence_DoseResponse_bt",
                                                                 sidebarPanel(

                                                                   h3('Customize plot appearance'),


                                                                   sliderInput(inputId = 'shape_type_dose_response_fluorescence_plot_bt',
                                                                               label = 'Shape type',
                                                                               min = 1,
                                                                               max = 25,
                                                                               value = 15),

                                                                   sliderInput(inputId = 'shape_size_dose_response_fluorescence_plot_bt',
                                                                               label = 'Shape size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 2,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'axis_size_dose_response_fluorescence_plot_bt',
                                                                               label = 'Axis title font size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 1.3,
                                                                               step = 0.1),


                                                                   sliderInput(inputId = 'lab_size_dose_response_fluorescence_plot_bt',
                                                                               label = 'Axis label font size',
                                                                               min = 0.1,
                                                                               max = 10,
                                                                               value = 1.3,
                                                                               step = 0.1),

                                                                   sliderInput(inputId = 'line_width_dose_response_fluorescence_plot_bt',
                                                                               label = 'Line width',
                                                                               min = 0.01,
                                                                               max = 10,
                                                                               value = 1),

                                                                 ), # sidebarPanel

                                                                 mainPanel(
                                                                   h3('Individual plots'),
                                                                   selectInput(inputId = 'individual_plots_dose_response_fluorescence_plot_bt',
                                                                               label = 'Select plot',
                                                                               choices = "",
                                                                               multiple = FALSE,
                                                                               selectize = FALSE,
                                                                               size = 3),
                                                                   plotOutput("dose_response_fluorescence_plot_individual_bt",
                                                                              width = "100%", height = "800px"),

                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_dose_response_fluorescence_plot_individual_bt",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_dose_response_fluorescence_plot_individual_bt",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_dose_response_fluorescence_plot_individual_bt",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            downloadButton('download_dose_response_fluorescence_plot_individual_bt',"Download Plot"),

                                                                            radioButtons("format_download_dose_response_fluorescence_plot_individual_bt",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column
                                                                   ) # fluidRow
                                                                 ) #  mainPanel
                                                        ), # tabPanel(title = "Dose-response analysis (Bootstrap)"



                                                        ### Fluorescence DR Parameters ####

                                                        tabPanel(title = "DR Parameter Plots",value = "tabPanel_Visualize_Fluorescence_DoseResponseParameters",
                                                                 sidebarPanel(
                                                                   selectInput(inputId = "parameter_dr_parameter_fluorescence_plot",
                                                                               label = "Parameter",
                                                                               choices = ""
                                                                   ),

                                                                   textInput(inputId = "select_sample_based_on_string_fluorescence_dr_parameter_plot",
                                                                             label = "Select sample based on string (separated by ;)"
                                                                   ),

                                                                   textInput(inputId = "exclude_sample_based_on_strings_fluorescence_dr_parameter_plot",
                                                                             label = "Exclude sample based on strings (separated by ;)"
                                                                   ),

                                                                   checkboxInput(inputId = 'normalize_to_reference_fluorescence_dr_parameter_plot',
                                                                                 label = 'normalize to reference',
                                                                                 value = FALSE),

                                                                   h3("Customize plot appearance"),

                                                                   # Conditional Panel
                                                                   conditionalPanel(condition = "input.normalize_to_reference_fluorescence_dr_parameter_plot",
                                                                                    # reactive selection
                                                                                    selectInput(inputId = 'reference_condition_fluorescence_dr_parameter_plot',
                                                                                                label = 'Reference condition',
                                                                                                choices = ""
                                                                                    )
                                                                   ),


                                                                   sliderInput(inputId = "basesize_fluorescence_dr_parameter_plot",
                                                                               label = "Base font size",
                                                                               min = 10,
                                                                               max = 35,
                                                                               value = 23,
                                                                               step = 0.5),

                                                                   sliderInput(inputId = "label.size_fluorescence_dr_parameter_plot",
                                                                               label = "Label font size",
                                                                               min = 5,
                                                                               max = 35,
                                                                               value = 20,
                                                                               step = 0.5)


                                                                 ),

                                                                 mainPanel(

                                                                   plotOutput("fluorescence_dr_parameter_plot",
                                                                              width = "100%", height = "800px"),


                                                                   h3(strong("Export plot")),

                                                                   fluidRow(
                                                                     column(width = 4,
                                                                            numericInput(inputId = "width_download_fluorescence_dr_parameter_plot",
                                                                                         label = "Width (in inches)",
                                                                                         value = 7)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "height_download_fluorescence_dr_parameter_plot",
                                                                                         label = "Height (in inches)",
                                                                                         value = 6)
                                                                     ), # column
                                                                     column(width = 4,
                                                                            numericInput(inputId = "dpi_download_fluorescence_dr_parameter_plot",
                                                                                         label = "DPI",
                                                                                         value = 300)
                                                                     ), # column

                                                                     column(width = 5,
                                                                            downloadButton('download_fluorescence_dr_parameter_plot',"Download Plot"),

                                                                            radioButtons("format_download_fluorescence_dr_parameter_plot",
                                                                                         label = NULL,
                                                                                         choices = c("PNG" = ".png",
                                                                                                     "PDF" = ".pdf"),
                                                                                         selected = ".png",
                                                                                         inline = TRUE)
                                                                     ), # column


                                                                   ) # fluidRow
                                                                 ) #  mainPanel
                                                        ), # tabPanel Fluorescence_Parameter_Plots
                                            ) # tabsetPanel(type = "tabs",
                                   ), # tabPanel(title = "Fluorescence Plots"


                        ), # navbarMenu("Visualize"

                        #____REPORT____####


                        tabPanel(span("Report", title = "Generate a PDF or HTML report summarizing the results."),
                                 value = "tabPanel_Report", icon=icon("file-contract"),
                                 tabsetPanel(type = "tabs", id = "tabsetPanel_Report",
                                             ##____Growth report___####
                                             tabPanel(title = "Growth", value = "tabPanel_report_growth",
                                                      sidebarPanel(width = 6,

                                                                   selectInput(inputId = 'report_filetype_growth',
                                                                               label = 'Choose file type',
                                                                               choices = c('PDF' = 'pdf', 'HTML' = 'html')),

                                                                   conditionalPanel(condition = "input.report_filetype_growth == 'pdf'",
                                                                                    fluidRow(
                                                                                      column(12,
                                                                                             div(
                                                                                               downloadButton(outputId = 'download_report_growth_pdf',
                                                                                                              label = "Render Report",
                                                                                                              icon = icon("file-pdf"),
                                                                                                              style="padding:5px; font-size:120%"),
                                                                                               style="float:right")
                                                                                      )
                                                                                    )
                                                                   ),
                                                                   conditionalPanel(condition = "input.report_filetype_growth == 'html'",
                                                                                    fluidRow(
                                                                                      column(12,
                                                                                             div(
                                                                                               downloadButton(outputId = 'download_report_growth_html',
                                                                                                              label = "Render Report",
                                                                                                              icon = icon("file-code"),
                                                                                                              style="padding:5px; font-size:120%"),
                                                                                               style="float:right")
                                                                                      )
                                                                                    )
                                                                   ),
                                                      ) # sidebarPanel
                                             ), # tabPanel(title = "Growth", value = "tabs_export_data_growth",
                                             tabPanel(title = "Fluorescence", value = "tabPanel_report_fluorescence",
                                                      sidebarPanel(width = 6,
                                                                   selectInput(inputId = 'report_filetype_fluorescence',
                                                                               label = 'Choose file type',
                                                                               choices = c('PDF' = 'pdf', 'HTML' = 'html')),

                                                                   conditionalPanel(condition = "input.report_filetype_fluorescence == 'pdf'",
                                                                                    fluidRow(
                                                                                      column(12,
                                                                                             div(
                                                                                               downloadButton(outputId = 'download_report_fluorescence_pdf',
                                                                                                              label = "Render Report",
                                                                                                              icon = icon("file-pdf"),
                                                                                                              style="padding:5px; font-size:120%"),
                                                                                               style="float:right")
                                                                                      )
                                                                                    )
                                                                   ),
                                                                   conditionalPanel(condition = "input.report_filetype_fluorescence == 'html'",
                                                                                    fluidRow(
                                                                                      column(12,
                                                                                             div(
                                                                                               downloadButton(outputId = 'download_report_fluorescence_html',
                                                                                                              label = "Render Report",
                                                                                                              icon = icon("file-code"),
                                                                                                              style="padding:5px; font-size:120%"),
                                                                                               style="float:right")
                                                                                      )
                                                                                    )
                                                                   ),
                                                      ) # sidebarPanel
                                             ) # tabPanel(title = "fluorescence", value = "tabs_export_data_fluorescence",
                                 ), # tabsetPanel(type = "tabs", id = "tabs_report",
                        ), # tabPanel("Report",  value = "tabPanel_Report", icon=icon("file-contract"),
                        #___Export RData___####
                        tabPanel(span("Data Export", title = "Export all computation results as RData file."),
                                 icon = icon("download"),
                                 value = "tabPanel_Export_RData",
                                 tabsetPanel(type = "tabs", id = "tabsetPanel_Export_Data",
                                             ##____Growth results export____####
                                             tabPanel(title = "Growth", value = "tabPanel_export_data_growth",
                                                      sidebarPanel(width = 3,
                                                                   fluidRow(
                                                                     column(12,
                                                                            div(
                                                                              downloadButton(outputId = 'export_RData_growth',
                                                                                             label = "Export RData file",
                                                                                             icon = icon("file-export"),
                                                                                             style="padding:5px; font-size:120%"),
                                                                              style="float:right")
                                                                     )
                                                                   )
                                                      )

                                             ),
                                             ## Fluorescence results export____####
                                             tabPanel(title = "Fluorescence", value = "tabPanel_export_data_fluorescence",
                                                      sidebarPanel(width = 3,
                                                                   fluidRow(
                                                                     column(12,
                                                                            div(
                                                                              downloadButton(outputId = 'export_RData_fluorescence',
                                                                                             label = "Export RData file",
                                                                                             icon = icon("file-export"),
                                                                                             style="padding:5px; font-size:120%"),
                                                                              style="float:right")
                                                                     )
                                                                   )
                                                      )

                                             ),
                                 )
                        ),
                        #___Import RData___####
                        tabPanel(span("Data Import", title = "Import and RData file with results from a previous QurvE analysis."),
                                 icon = icon("upload"),
                                 value = "tabPanel_Import_RData",
                                 tabsetPanel(type = "tabs", id = "tabsetPanel_Import_Data",
                                             ##____Growth results export____####
                                             tabPanel(title = "Growth", value = "tabPanel_import_data_growth",
                                                      sidebarPanel(width = 3,
                                                                   fluidRow(
                                                                     column(12,
                                                                            fileInput(inputId = 'import_RData_growth',
                                                                                      label = 'Choose growth RData file',
                                                                                      accept = c('.rdata')
                                                                            ),
                                                                            conditionalPanel(
                                                                              condition = 'output.RData_growth_uploaded',
                                                                              div(
                                                                                actionButton(inputId = "read_RData_growth",
                                                                                             label = "Read data",
                                                                                             icon=icon("upload"),
                                                                                             style="padding:5px; font-size:120%"),
                                                                                style="float:right")
                                                                            ),

                                                                     )
                                                                   )
                                                      )

                                             ),
                                             ## Fluorescence results export____####
                                             tabPanel(title = "Fluorescence", value = "tabPanel_import_data_fluorescence",
                                                      sidebarPanel(width = 3,
                                                                   fluidRow(
                                                                     column(12,
                                                                            fileInput(inputId = 'import_RData_fluorescence',
                                                                                      label = 'Choose fluorescence RData file',
                                                                                      accept = c('.rdata')
                                                                            ),
                                                                            conditionalPanel(
                                                                              condition = 'output.RData_fluorescence_uploaded',
                                                                              div(
                                                                                actionButton(inputId = "read_RData_fluorescence",
                                                                                             label = "Read data",
                                                                                             icon=icon("upload"),
                                                                                             style="padding:5px; font-size:120%"),
                                                                                style="float:right")
                                                                            ),
                                                                     )
                                                                   )
                                                      )

                                             ),
                                 )
                        ),
                        #____ABOUT US____####


                        tabPanel("About Us",
                                 mainPanel(
                                   h2("Creators"),
                                   'Nicolas Wirth', tags$a(icon("twitter"), href="https://twitter.com/JonathanFunk12"), br(),
                                   'Jonathan Funk', tags$a(icon("twitter"), href="https://twitter.com/The_NiWi"),
                                   h2("Bug reports"),
                                   uiOutput("bug_report"),
                                   h2("Cite QurvE"),
                                   "Wirth, N. and Funk, J. (2023). QurvE: Robust and User-Friendly Analysis of Growth and Fluorescence Curves. R package version 1.0. https://CRAN.R-project.org/package=QurvE"
                                   # h2("Publications"),
                                   # ''
                                 )
                        ),
                      ) #  navbarPage
                    ) # div(
                  ) # hidden(
                ) # tagList(
)
