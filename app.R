####################################################################
# AF-PROM Integration Dashboard
# Interactive Decision-Support Tool for PROM Integration in AF Care
# Aligned with ESC 2024 AF-CARE Framework
#
# Sokolova E, Sen SE, Goetz O, Grinberga K, Kupics K,
# Maca-Kaleja A, Rudzitis A, Behmane D, Kalejs O
####################################################################

library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(RColorBrewer)

# ---- DATA ----

domains <- c("Physical functioning", "Symptoms", "Emotional well-being",
             "Social functioning", "Cognitive function", "Treatment satisfaction",
             "Economic burden", "Health perception", "Sexual health", "Sleep quality")

instruments <- c("AFEQT", "EQ-5D", "SF-36", "MLHFQ", "AFSS")

# Coverage: Full=2, Partial=1, None=0
# Rows = domains, Cols = instruments
cov_mat <- matrix(c(
  2, 2, 2, 2, 1,
  2, 1, 1, 1, 2,
  2, 2, 2, 2, 1,
  2, 1, 2, 1, 1,
  1, 0, 1, 1, 0,
  2, 0, 0, 1, 0,
  1, 0, 0, 0, 0,
  2, 2, 2, 2, 1,
  0, 0, 0, 0, 0,
  1, 0, 1, 1, 0
), nrow = 10, byrow = TRUE, dimnames = list(domains, instruments))

cov_labels <- ifelse(cov_mat == 2, "Full", ifelse(cov_mat == 1, "Partial", "None"))

domain_info <- data.frame(
  Domain = domains,
  Clinical = c("Functional limitation", "Core AF burden", "Mental health impact",
               "Participation restriction", "Risk of decline", "Adherence",
               "Cost awareness", "Overall status", "QoL determinant", "AF trigger"),
  Policy = c("Rehabilitation planning", "Treatment evaluation", "Integrated care",
             "Social support systems", "Screening strategies", "Care quality indicators",
             "Health financing", "Outcome monitoring", "Patient-centred care", "Preventive strategies"),
  stringsAsFactors = FALSE
)

# AF-CARE mapping
afcare <- data.frame(
  Domain = c("Symptoms", "Physical functioning", "Emotional well-being",
             "Cognitive function", "Sleep quality", "Treatment satisfaction",
             "Economic burden", "Health perception"),
  Component = c("R", "E", "E", "C", "C", "E", "E", "A"),
  Label = c("R - Rate/rhythm control", "E - Evaluation and follow-up",
            "E - Evaluation and follow-up", "C - Comorbidity and risk factors",
            "C - Comorbidity and risk factors", "E - Evaluation and follow-up",
            "E - Evaluation and follow-up", "A - Avoid stroke"),
  Diagnostic = c(
    "Reflects AF burden and symptom variability",
    "Indicates functional limitation and disease impact",
    "Associated with psychological burden and symptom perception",
    "May indicate neurocognitive impairment related to AF",
    "Linked to AF triggers and recurrence (e.g., sleep apnea)",
    "Reflects perceived treatment effectiveness",
    "Indicates indirect disease impact and healthcare utilisation",
    "Integrates overall patient-reported health status"),
  Clinical = c(
    "Guides rhythm vs rate control decisions",
    "Supports treatment intensity adjustment",
    "May influence adherence and follow-up strategy",
    "Triggers further neurological evaluation",
    "Supports screening for comorbid conditions",
    "May guide therapy optimisation",
    "Relevant for system-level planning and resource allocation",
    "Supports global disease severity assessment"),
  stringsAsFactors = FALSE
)

# Gap analysis
gaps <- data.frame(
  Domain = c("Cognitive function", "Sleep quality", "Sexual health",
             "Economic burden", "Social functioning"),
  Status = c("Partially captured", "Limited", "Not captured", "Limited", "Partially captured"),
  Avg_Pct = c(20, 20, 0, 10, 47),
  Consequence = c(
    "Underrecognition of cognitive decline and neurovascular risk",
    "Missed identification of AF triggers (e.g., sleep apnea)",
    "Incomplete assessment of quality of life and treatment impact",
    "Underestimation of healthcare utilisation and patient burden",
    "Reduced understanding of patient participation and daily limitations"),
  stringsAsFactors = FALSE
)

# Implementation framework (15 items)
impl <- data.frame(
  Level = rep(c("Clinical", "Organisational", "Policy"), each = 5),
  Action = c(
    "Routine PROM collection at baseline",
    "PROM collection every 3-6 months at follow-up",
    "PROM-triggered clinical reassessment protocols",
    "AFEQT score change tracking (\u22655 points threshold)",
    "Symptom-driven treatment adjustment pathways",
    "EHR-embedded PROM data capture",
    "Multidisciplinary PROM interpretation teams",
    "Care coordination across primary and specialist settings",
    "Standardised PROM reporting templates",
    "Staff training on PROM administration and interpretation",
    "Link PROMs to national AF registries",
    "Integrate PROMs into reimbursement models",
    "Establish PROM-based performance benchmarks",
    "Cross-national PROM data comparability standards",
    "PROM integration into health technology assessment"),
  Indicator = c(
    "PROM completion rate at first visit",
    "Follow-up PROM completion rate",
    "Number of PROM-triggered reassessments",
    "Proportion with tracked AFEQT trajectories",
    "Treatment adjustment rate linked to PROM data",
    "EHR integration rate for PROM modules",
    "Interdisciplinary referral frequency",
    "Care pathway adherence rate",
    "Reporting template adoption rate",
    "Staff competency assessment scores",
    "AF registry PROM coverage rate",
    "Reimbursement models incorporating PROM data",
    "Benchmark attainment across institutions",
    "Countries with comparable PROM datasets",
    "HTA submissions incorporating PROM evidence"),
  AFCARE = c(
    "R - Rate/rhythm; E - Evaluation", "E - Evaluation and follow-up",
    "E - Evaluation and follow-up", "E - Evaluation and follow-up",
    "R - Rate/rhythm control",
    "C - Comorbidity; A - Avoid stroke", "C - Comorbidity management",
    "E - Evaluation and follow-up", "E - Evaluation and follow-up",
    "E - Evaluation and follow-up",
    "E - Evaluation; system-level VBHC", "E - Evaluation; system-level VBHC",
    "E - Evaluation; system-level VBHC", "E - Evaluation; system-level VBHC",
    "E - Evaluation; system-level VBHC"),
  stringsAsFactors = FALSE
)

# Country data (all costs in EUR)
countries <- data.frame(
  Country = c("Latvia", "Ireland", "Germany", "Netherlands", "United Kingdom",
              "France", "Italy", "Spain", "United States"),
  Prevalence = c(2.1, 1.8, 2.5, 2.3, 2.0, 2.2, 2.4, 2.1, 1.9),
  Pop_M = c(1.8, 5.1, 83.2, 17.5, 67.0, 67.4, 59.0, 47.4, 331.0),
  Cost_EUR = c(2800, 5200, 6100, 5800, 5500, 5900, 4800, 4200, 7500),
  PROM_Status = c("Limited", "Developing", "Moderate", "Advanced",
                  "Moderate", "Developing", "Limited", "Developing", "Moderate"),
  stringsAsFactors = FALSE
)
countries$AF_Patients <- round(countries$Pop_M * 1e6 * countries$Prevalence / 100)
countries$Total_Cost_M <- round(countries$AF_Patients * countries$Cost_EUR / 1e6)

# AFEQT thresholds
afeqt_cats <- data.frame(
  Category = c("Severe", "Moderate", "Mild", "Minimal/No impact"),
  Min = c(0, 34, 54, 74),
  Max = c(33, 53, 73, 100),
  Hex = c("#D32F2F", "#F57C00", "#FBC02D", "#388E3C"),
  Action = c(
    "Urgent clinical review; consider rhythm control escalation",
    "Schedule reassessment within 4 weeks; optimise current therapy",
    "Continue current management; monitor at 3-6 month intervals",
    "Maintain current strategy; routine follow-up"),
  stringsAsFactors = FALSE
)

# ---- COLOURS ----

afcare_pal <- c(C = "#7B1FA2", A = "#C62828", R = "#1565C0", E = "#2E7D32")
cov_pal <- c(Full = "#2E7D32", Partial = "#F9A825", None = "#C62828")
gap_colour <- function(x) ifelse(x < 30, "#C62828", ifelse(x <= 60, "#F57C00", "#2E7D32"))

# ---- CSS ----

css <- "
body { font-family: 'Source Sans Pro', 'Segoe UI', Tahoma, sans-serif; }
.content-wrapper { background: #F5F7FA; }
.skin-blue .main-header .logo { background: #1A237E; font-weight: 700; font-size: 15px; }
.skin-blue .main-header .navbar { background: #1A237E; }
.skin-blue .main-sidebar { background: #0D1B2A; }
.skin-blue .sidebar-menu > li.active > a { border-left-color: #00ACC1; }

.box { border-radius: 6px; border-top: 3px solid #1A237E; }
.box-header .box-title { font-weight: 600; color: #1A237E; font-size: 14px; }

.mod-info {
  background: linear-gradient(135deg, #E8EAF6, #E3F2FD);
  border-left: 4px solid #1A237E;
  padding: 12px 16px; margin-bottom: 16px;
  border-radius: 0 6px 6px 0;
  font-size: 13px; line-height: 1.5; color: #263238;
}

.main-footer { background: #0D1B2A; color: #90A4AE; border-top: none; font-size: 11px; }
.main-footer a { color: #00ACC1; }

table.dataTable thead th { background: #1A237E; color: #fff; font-weight: 600; }
table.dataTable { font-size: 13px; }

.afeqt-box {
  background: #fff; border-radius: 8px; padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.07); text-align: center; margin-bottom: 12px;
}
.afeqt-box h2 { margin: 0; font-size: 38px; font-weight: 700; }
.afeqt-box .sub { font-size: 13px; color: #546E7A; }

.check-item {
  padding: 8px 12px; margin: 3px 0; background: #fff;
  border-radius: 5px; font-size: 13px;
  box-shadow: 0 1px 2px rgba(0,0,0,0.04);
}
.check-item.lev-clin { border-left: 4px solid #1565C0; }
.check-item.lev-org  { border-left: 4px solid #7B1FA2; }
.check-item.lev-pol  { border-left: 4px solid #2E7D32; }
"

# ---- UI ----

ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "AF-PROM Dashboard", titleWidth = 250),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      id = "tabs",
      menuItem("Overview",           tabName = "home",  icon = icon("home")),
      menuItem("1. Domain Coverage",  tabName = "mod1",  icon = icon("chart-bar")),
      menuItem("2. Gap Analysis",     tabName = "mod2",  icon = icon("search")),
      menuItem("3. AF-CARE Mapper",   tabName = "mod3",  icon = icon("project-diagram")),
      menuItem("4. Implementation",   tabName = "mod4",  icon = icon("clipboard-check")),
      menuItem("5. Country Compare",  tabName = "mod5",  icon = icon("globe-europe")),
      menuItem("6. AFEQT Simulator",  tabName = "mod6",  icon = icon("heartbeat"))
    ),
    hr(),
    div(style = "padding: 8px 15px; font-size: 11px; color: #78909C; line-height: 1.4;",
        HTML("Sokolova E, Sen SE, Goetz O,<br>Grinberga K, Kupics K, Maca-Kaleja A,<br>Rudzitis A, Behmane D, Kalejs O"))
  ),
  
  dashboardBody(
    tags$head(tags$style(HTML(css))),
    
    tabItems(
      
      # -- HOME --
      tabItem("home",
              fluidRow(column(12, div(style = "text-align:center; padding: 25px 20px 5px;",
                                      h2(style = "font-weight:700; color:#1A237E;", "AF-PROM Integration Dashboard"),
                                      p(style = "font-size:14px; color:#546E7A; max-width:680px; margin:0 auto;",
                                        "Interactive decision-support tool for integrating Patient-Reported Outcome Measures",
                                        "into AF care, aligned with the ESC 2024 AF-CARE framework.")
              ))),
              fluidRow(
                valueBox(5,  "Instruments",       icon = icon("clipboard-list"), color = "blue",   width = 2),
                valueBox(10, "QoL Domains",        icon = icon("th"),             color = "purple", width = 2),
                valueBox(4,  "AF-CARE Components", icon = icon("project-diagram"),color = "green",  width = 2),
                valueBox(9,  "Countries",          icon = icon("globe"),          color = "orange", width = 2),
                valueBox(15, "Implementation Items",icon = icon("tasks"),         color = "maroon", width = 2),
                valueBox(6,  "Modules",            icon = icon("cubes"),          color = "teal",   width = 2)
              ),
              fluidRow(
                box(title = "About", width = 6, status = "primary",
                    div(class = "mod-info", HTML(
                      "<b>Purpose:</b> This dashboard operationalises the PROM integration framework
              from the companion Diagnostics paper. It enables interactive exploration of
              domain coverage, gap analysis, AF-CARE pathway mapping, multilevel implementation
              planning, cross-country burden comparison, and AFEQT score simulation.<br><br>
              <b>Users:</b> Clinicians selecting instruments for AF care, health economists
              evaluating measurement gaps, policymakers planning PROM implementation.<br><br>
              <b>Data:</b> Structured narrative review (65 studies, 1992&ndash;2024), AF-CARE
              mapping framework, AF prevalence and cost data for 9 countries, AFEQT thresholds."))
                ),
                box(title = "AF-CARE Pathway", width = 6, status = "primary",
                    div(class = "mod-info", HTML(
                      "<b>C</b> &ndash; <span style='color:#7B1FA2;font-weight:600;'>Comorbidity and risk factors</span>:
              Cognitive function, Sleep quality<br>
              <b>A</b> &ndash; <span style='color:#C62828;font-weight:600;'>Avoid stroke</span>:
              Health perception, Functional status<br>
              <b>R</b> &ndash; <span style='color:#1565C0;font-weight:600;'>Rate and rhythm control</span>:
              Symptom burden<br>
              <b>E</b> &ndash; <span style='color:#2E7D32;font-weight:600;'>Evaluation and follow-up</span>:
              Physical functioning, Emotional well-being, Treatment satisfaction, Economic burden"))
                )
              ),
              fluidRow(
                box(title = "How to Use", width = 12, status = "primary",
                    div(class = "mod-info", HTML(
                      "Navigate using the sidebar.<br>
              <b>Module 1:</b> Which instruments cover which domains?<br>
              <b>Module 2:</b> Where are the measurement gaps?<br>
              <b>Module 3:</b> How do PROMs map to AF-CARE?<br>
              <b>Module 4:</b> What does implementation require at each level?<br>
              <b>Module 5:</b> How does AF burden compare across countries?<br>
              <b>Module 6:</b> How do AFEQT changes translate into clinical actions?"))
                )
              )
      ),
      
      # -- MODULE 1: Domain Coverage --
      tabItem("mod1",
              div(class = "mod-info", HTML(
                "<b>Module 1 &ndash; Domain Coverage Explorer:</b> Compare how five QoL instruments
          cover 10 quality-of-life domains. Select instruments and visualisation type.")),
              fluidRow(
                box(title = "Controls", width = 3, status = "primary",
                    checkboxGroupInput("m1_inst", "Instruments:", instruments, selected = instruments),
                    radioButtons("m1_type", "Chart type:",
                                 c("Radar" = "radar", "Heatmap" = "heatmap"), "radar")
                ),
                box(title = "Visualisation", width = 9, status = "primary",
                    plotlyOutput("m1_plot", height = "460px"))
              ),
              fluidRow(
                box(title = "Coverage Matrix", width = 12, status = "primary",
                    DTOutput("m1_table"))
              )
      ),
      
      # -- MODULE 2: Gap Analysis --
      tabItem("mod2",
              div(class = "mod-info", HTML(
                "<b>Module 2 &ndash; Gap Analysis:</b> Average coverage across all instruments per domain.
          <span style='color:#C62828;font-weight:600;'>Red</span> &lt;30%,
          <span style='color:#F57C00;font-weight:600;'>Amber</span> 30&ndash;60%,
          <span style='color:#2E7D32;font-weight:600;'>Green</span> &gt;60%.")),
              fluidRow(
                box(title = "Coverage by Domain (All Instruments)", width = 7, status = "primary",
                    plotlyOutput("m2_bar", height = "420px")),
                box(title = "Gap Severity Summary", width = 5, status = "primary",
                    DTOutput("m2_summary"))
              ),
              fluidRow(
                box(title = "Diagnostic Consequences of Measurement Gaps", width = 12, status = "primary",
                    DTOutput("m2_gaps"))
              )
      ),
      
      # -- MODULE 3: AF-CARE Mapper --
      tabItem("mod3",
              div(class = "mod-info", HTML(
                "<b>Module 3 &ndash; AF-CARE Pathway Mapper:</b> How PROM domains align with each
          AF-CARE component (C, A, R, E).")),
              fluidRow(
                box(title = "Controls", width = 3, status = "primary",
                    selectInput("m3_comp", "AF-CARE Component:",
                                c("All", "C - Comorbidity", "A - Avoid stroke",
                                  "R - Rate/rhythm", "E - Evaluation"))
                ),
                box(title = "Domain Mapping", width = 9, status = "primary",
                    plotlyOutput("m3_scatter", height = "400px"))
              ),
              fluidRow(
                box(title = "Detailed Mapping", width = 12, status = "primary",
                    DTOutput("m3_table"))
              )
      ),
      
      # -- MODULE 4: Implementation --
      tabItem("mod4",
              div(class = "mod-info", HTML(
                "<b>Module 4 &ndash; Implementation Readiness Scorecard:</b> 15 checklist items
          across clinical, organisational, and policy levels.")),
              fluidRow(
                box(title = "Controls", width = 3, status = "primary",
                    selectInput("m4_level", "Level:",
                                c("All", "Clinical", "Organisational", "Policy"))
                ),
                box(title = "Implementation Framework", width = 9, status = "primary",
                    DTOutput("m4_table"))
              ),
              fluidRow(
                box(title = "Readiness Checklist", width = 12, status = "primary",
                    uiOutput("m4_checklist"))
              )
      ),
      
      # -- MODULE 5: Country Compare --
      tabItem("mod5",
              div(class = "mod-info", HTML(
                "<b>Module 5 &ndash; Cross-Country AF Burden Comparator:</b> Prevalence, hospitalisation
          costs (&euro;), and PROM integration status across 9 countries.")),
              fluidRow(
                box(title = "Controls", width = 3, status = "primary",
                    checkboxGroupInput("m5_countries", "Countries:",
                                       countries$Country, selected = countries$Country)
                ),
                box(title = "AF Burden Comparison", width = 9, status = "primary",
                    plotlyOutput("m5_bar", height = "420px"))
              ),
              fluidRow(
                box(title = "Country Data", width = 12, status = "primary",
                    DTOutput("m5_table"))
              )
      ),
      
      # -- MODULE 6: AFEQT Simulator --
      tabItem("mod6",
              div(class = "mod-info", HTML(
                "<b>Module 6 &ndash; AFEQT Score Simulator:</b> Simulate baseline and follow-up scores
          to see severity category changes and recommended clinical actions.
          Clinically meaningful change threshold: &ge;5 points.")),
              fluidRow(
                box(title = "Score Input", width = 4, status = "primary",
                    sliderInput("m6_base", "Baseline AFEQT:", 0, 100, 45, step = 1),
                    sliderInput("m6_fu",   "Follow-up AFEQT:", 0, 100, 55, step = 1),
                    hr(),
                    uiOutput("m6_interpret")
                ),
                box(title = "Score Trajectory", width = 8, status = "primary",
                    plotlyOutput("m6_traj", height = "350px"),
                    br(),
                    DTOutput("m6_cats"))
              )
      )
    )
  )
)

# ---- SERVER ----

server <- function(input, output, session) {
  
  # Helper: get category for an AFEQT score
  get_cat <- function(score) {
    idx <- which(score >= afeqt_cats$Min & score <= afeqt_cats$Max)
    if (length(idx) == 0) return(list(cat = "Unknown", col = "#999", action = ""))
    list(cat = afeqt_cats$Category[idx], col = afeqt_cats$Hex[idx], action = afeqt_cats$Action[idx])
  }
  
  # ---- MODULE 1 ----
  
  output$m1_plot <- renderPlotly({
    sel <- input$m1_inst
    req(length(sel) > 0)
    
    if (input$m1_type == "radar") {
      p <- plot_ly(type = "scatterpolar", fill = "toself")
      cols <- brewer.pal(max(3, length(sel)), "Set2")
      for (i in seq_along(sel)) {
        vals <- cov_mat[, sel[i]]
        p <- add_trace(p, r = c(vals, vals[1]), theta = c(domains, domains[1]),
                       name = sel[i], line = list(color = cols[i], width = 2),
                       fillcolor = paste0(cols[i], "33"))
      }
      p %>% layout(
        polar = list(radialaxis = list(visible = TRUE, range = c(0, 2),
                                       tickvals = c(0, 1, 2), ticktext = c("None", "Partial", "Full"))),
        showlegend = TRUE, margin = list(t = 40),
        title = list(text = "Domain Coverage Comparison", font = list(size = 14))
      )
      
    } else {
      mat <- cov_mat[, sel, drop = FALSE]
      p <- plot_ly(z = mat, x = sel, y = domains, type = "heatmap",
                   colorscale = list(c(0, "#C62828"), c(0.5, "#F9A825"), c(1, "#2E7D32")),
                   zmin = 0, zmax = 2, hoverinfo = "text",
                   text = cov_labels[, sel, drop = FALSE],
                   colorbar = list(tickvals = c(0, 1, 2), ticktext = c("None", "Partial", "Full")))
      p %>% layout(
        yaxis = list(autorange = "reversed"),
        margin = list(l = 140, t = 40),
        title = list(text = "Domain Coverage Heatmap", font = list(size = 14))
      )
    }
  })
  
  output$m1_table <- renderDT({
    df <- data.frame(Domain = domains, cov_labels, domain_info$Clinical, domain_info$Policy,
                     stringsAsFactors = FALSE)
    names(df) <- c("Domain", instruments, "Clinical Relevance", "Policy Relevance")
    datatable(df, rownames = FALSE, options = list(pageLength = 10, dom = "t"),
              class = "compact stripe") %>%
      formatStyle(instruments,
                  backgroundColor = styleEqual(c("Full", "Partial", "None"),
                                               c("#C8E6C9", "#FFF9C4", "#FFCDD2")))
  })
  
  # ---- MODULE 2 ----
  
  avg_cov <- setNames(round(rowMeans(cov_mat) / 2 * 100), domains)
  
  output$m2_bar <- renderPlotly({
    df <- data.frame(Domain = names(avg_cov), Pct = as.numeric(avg_cov), stringsAsFactors = FALSE)
    df <- df[order(df$Pct), ]
    df$Domain <- factor(df$Domain, levels = df$Domain)
    df$Col <- gap_colour(df$Pct)
    
    plot_ly(df, y = ~Domain, x = ~Pct, type = "bar", orientation = "h",
            marker = list(color = df$Col),
            text = paste0(df$Pct, "%"), textposition = "outside",
            hoverinfo = "text",
            hovertext = paste0(df$Domain, ": ", df$Pct, "% average coverage")) %>%
      layout(xaxis = list(title = "Average Coverage (%)", range = c(0, 105)),
             yaxis = list(title = ""),
             margin = list(l = 150, t = 40),
             title = list(text = "Average Domain Coverage Across All Instruments",
                          font = list(size = 14)))
  })
  
  output$m2_summary <- renderDT({
    df <- data.frame(Domain = names(avg_cov), Coverage = paste0(avg_cov, "%"),
                     stringsAsFactors = FALSE)
    df$Severity <- ifelse(avg_cov < 30, "Critical gap",
                          ifelse(avg_cov <= 60, "Moderate gap", "Adequate"))
    df <- df[order(avg_cov), ]
    datatable(df, rownames = FALSE, options = list(pageLength = 10, dom = "t"),
              class = "compact stripe") %>%
      formatStyle("Severity",
                  backgroundColor = styleEqual(
                    c("Critical gap", "Moderate gap", "Adequate"),
                    c("#FFCDD2", "#FFF9C4", "#C8E6C9")))
  })
  
  output$m2_gaps <- renderDT({
    datatable(gaps, rownames = FALSE, colnames = c("Domain", "Coverage Status",
                                                   "Avg Coverage (%)", "Diagnostic Consequence"),
              options = list(pageLength = 5, dom = "t"), class = "compact stripe")
  })
  
  # ---- MODULE 3 ----
  
  output$m3_scatter <- renderPlotly({
    df <- afcare
    sel <- input$m3_comp
    if (sel != "All") {
      letter <- substr(sel, 1, 1)
      df <- df[df$Component == letter, ]
    }
    req(nrow(df) > 0)
    
    # x position by component
    comp_x <- c(C = 1, A = 2, R = 3, E = 4)
    df$x <- comp_x[df$Component]
    # spread y within component
    df$y <- ave(seq_len(nrow(df)), df$Component, FUN = seq_along)
    
    plot_ly(df, x = ~x, y = ~y, type = "scatter", mode = "markers+text",
            text = ~Domain, textposition = "right",
            marker = list(size = 14, color = afcare_pal[df$Component]),
            hoverinfo = "text",
            hovertext = paste0("<b>", df$Domain, "</b><br>",
                               df$Label, "<br><br>",
                               df$Diagnostic)) %>%
      layout(
        xaxis = list(tickvals = 1:4, ticktext = c("C", "A", "R", "E"),
                     title = "AF-CARE Component", range = c(0.5, 5.5)),
        yaxis = list(title = "", showticklabels = FALSE, range = c(0, 6)),
        margin = list(t = 40),
        title = list(text = "PROM Domain Mapping to AF-CARE", font = list(size = 14)),
        showlegend = FALSE
      )
  })
  
  output$m3_table <- renderDT({
    df <- afcare
    sel <- input$m3_comp
    if (sel != "All") {
      letter <- substr(sel, 1, 1)
      df <- df[df$Component == letter, ]
    }
    datatable(df[, c("Domain", "Label", "Diagnostic", "Clinical")],
              rownames = FALSE,
              colnames = c("Domain", "AF-CARE Component", "Diagnostic Relevance", "Clinical Implication"),
              options = list(pageLength = 8, dom = "t"), class = "compact stripe")
  })
  
  # ---- MODULE 4 ----
  
  output$m4_table <- renderDT({
    df <- impl
    if (input$m4_level != "All") df <- df[df$Level == input$m4_level, ]
    datatable(df, rownames = FALSE,
              colnames = c("Level", "Action", "Measurable Indicator", "AF-CARE Alignment"),
              options = list(pageLength = 15, dom = "t"), class = "compact stripe") %>%
      formatStyle("Level",
                  backgroundColor = styleEqual(
                    c("Clinical", "Organisational", "Policy"),
                    c("#E3F2FD", "#F3E5F5", "#E8F5E9")))
  })
  
  output$m4_checklist <- renderUI({
    df <- impl
    if (input$m4_level != "All") df <- df[df$Level == input$m4_level, ]
    
    lev_class <- c(Clinical = "lev-clin", Organisational = "lev-org", Policy = "lev-pol")
    
    tags$div(
      lapply(seq_len(nrow(df)), function(i) {
        cls <- paste("check-item", lev_class[df$Level[i]])
        tags$div(class = cls,
                 tags$input(type = "checkbox", style = "margin-right: 8px;"),
                 tags$span(style = "font-weight:600;", paste0("[", df$Level[i], "] ")),
                 df$Action[i]
        )
      })
    )
  })
  
  # ---- MODULE 5 ----
  
  output$m5_bar <- renderPlotly({
    sel <- input$m5_countries
    req(length(sel) > 0)
    df <- countries[countries$Country %in% sel, ]
    
    plot_ly(df) %>%
      add_bars(x = ~Country, y = ~Prevalence, name = "Prevalence (%)",
               marker = list(color = "#1565C0"), yaxis = "y") %>%
      add_bars(x = ~Country, y = ~Cost_EUR, name = "Avg Cost (\u20AC)",
               marker = list(color = "#E65100"), yaxis = "y2") %>%
      layout(
        yaxis  = list(title = "AF Prevalence (%)", side = "left", range = c(0, 3.5)),
        yaxis2 = list(title = "Hospitalisation Cost (\u20AC)", side = "right",
                      overlaying = "y", range = c(0, 9000)),
        barmode = "group",
        legend = list(orientation = "h", y = -0.15),
        margin = list(t = 40, b = 80),
        title = list(text = "AF Prevalence and Hospitalisation Cost by Country",
                     font = list(size = 14))
      )
  })
  
  output$m5_table <- renderDT({
    sel <- input$m5_countries
    req(length(sel) > 0)
    df <- countries[countries$Country %in% sel, ]
    df_show <- df[, c("Country", "Prevalence", "Pop_M", "AF_Patients",
                      "Cost_EUR", "Total_Cost_M", "PROM_Status")]
    names(df_show) <- c("Country", "Prevalence (%)", "Population (M)",
                        "Est. AF Patients", "Avg Cost (\u20AC)",
                        "Est. Total Cost (\u20ACM)", "PROM Status")
    datatable(df_show, rownames = FALSE,
              options = list(pageLength = 9, dom = "t"), class = "compact stripe") %>%
      formatStyle("PROM Status",
                  backgroundColor = styleEqual(
                    c("Limited", "Developing", "Moderate", "Advanced"),
                    c("#FFCDD2", "#FFF9C4", "#C8E6C9", "#A5D6A7"))) %>%
      formatCurrency("Avg Cost (\u20AC)", currency = "\u20AC", digits = 0) %>%
      formatRound("Est. AF Patients", digits = 0)
  })
  
  # ---- MODULE 6 ----
  
  output$m6_traj <- renderPlotly({
    b <- input$m6_base
    f <- input$m6_fu
    
    # Threshold bands
    shapes <- lapply(seq_len(nrow(afeqt_cats)), function(i) {
      list(type = "rect", x0 = -0.5, x1 = 2.5,
           y0 = afeqt_cats$Min[i], y1 = afeqt_cats$Max[i] + 0.5,
           fillcolor = paste0(afeqt_cats$Hex[i], "22"),
           line = list(width = 0), layer = "below")
    })
    
    plot_ly() %>%
      add_trace(x = c("Baseline", "Follow-up"), y = c(b, f),
                type = "scatter", mode = "lines+markers",
                line = list(color = "#1A237E", width = 3),
                marker = list(size = 12, color = "#1A237E"),
                hoverinfo = "text",
                text = c(paste0("Baseline: ", b), paste0("Follow-up: ", f))) %>%
      layout(
        shapes = shapes,
        yaxis = list(title = "AFEQT Score", range = c(0, 105)),
        xaxis = list(title = ""),
        margin = list(t = 40),
        title = list(text = "AFEQT Score Trajectory", font = list(size = 14)),
        annotations = lapply(seq_len(nrow(afeqt_cats)), function(i) {
          list(x = 2.3, y = (afeqt_cats$Min[i] + afeqt_cats$Max[i]) / 2,
               text = afeqt_cats$Category[i], showarrow = FALSE,
               font = list(size = 10, color = afeqt_cats$Hex[i]))
        }),
        showlegend = FALSE
      )
  })
  
  output$m6_interpret <- renderUI({
    b <- input$m6_base; f <- input$m6_fu
    change <- f - b
    b_cat <- get_cat(b); f_cat <- get_cat(f)
    meaningful <- abs(change) >= 5
    
    direction <- if (change > 0) "Improvement" else if (change < 0) "Deterioration" else "No change"
    clin_sig <- if (meaningful) "Yes (\u22655 points)" else "No (<5 points)"
    
    tags$div(
      tags$div(class = "afeqt-box",
               tags$h2(style = paste0("color:", b_cat$col), b),
               tags$div(class = "sub", paste0("Baseline: ", b_cat$cat))
      ),
      tags$div(class = "afeqt-box",
               tags$h2(style = paste0("color:", f_cat$col), f),
               tags$div(class = "sub", paste0("Follow-up: ", f_cat$cat))
      ),
      tags$div(class = "afeqt-box",
               tags$h2(style = if (change > 0) "color:#2E7D32" else if (change < 0) "color:#C62828" else "color:#546E7A",
                       paste0(ifelse(change > 0, "+", ""), change)),
               tags$div(class = "sub", direction)
      ),
      tags$div(style = "background:#fff; border-radius:8px; padding:12px; margin-top:8px;
                        box-shadow: 0 2px 8px rgba(0,0,0,0.07); font-size:13px;",
               tags$b("Clinically meaningful: "), clin_sig, tags$br(),
               tags$b("Recommended: "), f_cat$action
      )
    )
  })
  
  output$m6_cats <- renderDT({
    df <- afeqt_cats[, c("Category", "Min", "Max", "Action")]
    names(df) <- c("Severity", "Score Min", "Score Max", "Recommended Action")
    datatable(df, rownames = FALSE,
              options = list(pageLength = 4, dom = "t"), class = "compact stripe") %>%
      formatStyle("Severity",
                  color = styleEqual(c("Severe", "Moderate", "Mild", "Minimal/No impact"),
                                     c("#D32F2F", "#F57C00", "#FBC02D", "#388E3C")),
                  fontWeight = "bold")
  })
}

shinyApp(ui, server)
