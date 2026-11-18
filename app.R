library(shiny)
library(bslib)
library(ggplot2)
source('R/model.R')
input_data <- read_model()
b <- input_data$baseline
usd <- function(x) sprintf('$%.4f',x)
qt <- function(x) if(is.na(x)) 'Not achievable' else sprintf('%.3f',x/1e15)
theme_set(theme_minimal(base_size=13)+theme(panel.grid.minor=element_blank(),plot.title=element_text(face='bold'),legend.position='bottom'))
ui <- page_sidebar(
  title='DeepSeek / Inference Economics',
  theme=bs_theme(version=5, bg='#f5f6fa',fg='#1c293b',primary='#176b68',base_font=font_collection('Segoe UI','Arial','sans-serif')),
  tags$head(tags$link(rel='stylesheet',href='style.css')),
  sidebar=sidebar(title='Scenario assumptions',width=300,
    p('Workbook baseline: 16 September 2026',class='muted'),
    sliderInput('flash_cache','Flash billable input cache hit',0,1,b$flash_cache,.01),
    sliderInput('pro_cache','Pro billable input cache hit',0,1,b$pro_cache,.01),
    sliderInput('peak','Peak traffic share',0,1,b$peak,.001),
    sliderInput('mix','Flash share of total API tokens',0,1,b$flash_share,.01),
    numericInput('owned','Owned-like USD / GPU-hour',b$owned_rate,min=0,step=.1),
    numericInput('retail','Retail USD / GPU-hour',b$retail_rate,min=0,step=.1),
    selectInput('target','Hypothetical annual contribution target',choices=setNames(c(1e8,2.5e8,5e8,1e9,1.6e9),c('$100 million','$250 million','$500 million','$1 billion','$1.6 billion')),selected=5e8),
    actionButton('reset','Reset to workbook baseline',class='btn-primary'),
    p('Pro token share is the remainder. Cache reuse, traffic timing and model mix are scenarios, not observed commercial metrics.',class='muted')),
  navset_tab(
    nav_panel('Research overview',
      div(class='research-head',p('INDEPENDENT RESEARCH / AI INFRASTRUCTURE',class='eyebrow'),h1('Can inference help fund a research-first strategy?'),p('At what scale could DeepSeek’s commercial inference become a meaningful funding source for its research-first strategy?',class='lead'),p('Selected B200 AgentX deployments connect technical throughput to API pricing, serving contribution and hypothetical annual token requirements.')),
      uiOutput('kpis'),
      layout_columns(card(card_header('Technical performance meets commercial pricing'),plotOutput('overview_plot',height=320)),card(card_header('What the workbook supports'),p('Under the baseline assumptions, the selected deployments have positive serving contribution. Pro has higher contribution per token, driven by its higher API prices.'),p('Pricing treatment and product mix strongly affect the scale required to fund a target. Actual API demand is unknown.'),h5('Read the result carefully'),p('Serving contribution excludes training, R&D and other costs outside the GPU-hour serving budget. It does not establish company profit.'),p('The two runs use different engines, concurrency and offload settings. Their comparison describes deployments rather than isolated architecture effects.')))),
    nav_panel('Unit economics',card(card_header('Revenue and GPU serving cost'),p('All dollar amounts below are USD per one million total input + output tokens.'),plotOutput('unit_plot',height=360),tableOutput('units')),card(card_header('Selected benchmark configurations'),tableOutput('configs'),p('Workload composition uses full returned token arrays, including warmup. Cost uses measured-window throughput. These intervals are intentionally preserved from Excel.'))),
    nav_panel('Scenario explorer',card(card_header('Billable cache sensitivity'),p('Both models’ billable cache rates vary together along the x axis. Peak traffic, GPU rates and model mix remain at the current sidebar settings.'),plotOutput('cache_plot',height=370)),card(card_header('Portfolio composition'),plotOutput('mix_plot',height=340),p('Model shares are weighted by total tokens, not requests or revenue. Changing the billable-cache controls does not alter benchmark throughput.'))),
    nav_panel('Contribution scale',uiOutput('scale_note'),card(card_header('Annual contribution versus total token volume'),plotOutput('scale_plot',height=380)),card(card_header('Workbook contribution targets'),tableOutput('scale_table'),p('Quadrillion = 10^15 tokens. Serving break-even is a unit revenue threshold equal to serving cost. No fixed cost curve is modeled, so the model cannot estimate a company break-even volume.'))),
    nav_panel('Sources & methods',card(card_header('Model and scope'),p('Snapshot: 2026-09-16. This is an independent research project, not an official DeepSeek, NVIDIA, SemiAnalysis or Huawei project.'),tags$ul(tags$li('Observed in the workbook: API price snapshot, selected benchmark configurations and throughput, raw input/output token totals.'),tags$li('Modeled: owned-like and retail GPU-hour cost rates.'),tags$li('Hypothetical: billable input cache hit, peak usage, total-token model mix and annual contribution targets.')),h5('Equations'),tags$pre('Input price = peak × [hit × peak hit price + (1−hit) × peak miss price]\n            + (1−peak) × [hit × off-peak hit price + (1−hit) × off-peak miss price]\nRevenue / 1M total = input share × input price + output share × output price\nGPU cost / 1M total = hourly GPU rate × physical GPU count × 1,000,000 / (deployment tokens/s × 3,600)\nServing contribution = revenue − GPU serving cost\nPortfolio = total-token-share weighted model results\nRequired tokens/year = annual contribution target / positive contribution per 1M × 1,000,000'),h5('Limitations'),p('Technical HBM/CPU cache telemetry is not billable API reuse. Benchmark throughput may not represent production traffic or utilization. Full-run arrays and telemetry include warmup, unlike the measured throughput window. Source cache buckets do not reconcile perfectly to prompt telemetry; no complementary miss rate is imposed. Actual demand, model mix, total R&D cost and company profit are unknown.'),p('Official pricing was checked on 2026-11-18: price rates match the workbook, but the live Flash model version has advanced to V4.1-Flash-1017. The app retains the historical workbook benchmark. Uniform-time traffic uses 35/168; public-holiday effects are not modeled.'),h5('Primary sources'),tags$ul(tags$li(tags$a(href='https://api-docs.deepseek.com/quick_start/pricing/',target='_blank','DeepSeek official Models & Pricing')),tags$li(tags$a(href='https://inferencex.semianalysis.com/',target='_blank','SemiAnalysis InferenceX')),tags$li('Result 442167: Flash, B200, vLLM, FP4, 4 GPUs, concurrency 64, no KV offload.'),tags$li('Result 442268: Pro, B200, SGLang, FP4, 8 GPUs, concurrency 160, DRAM / HiCache.')),p('Minimum aggregate inputs and cell-level Excel validation fixtures are included. Third-party raw traces and the full workbook are excluded from public distribution while data redistribution terms remain unconfirmed.'),downloadButton('download','Download current scenario (CSV)')))
  )
)
server <- function(input,output,session) {
  results <- reactive({
    req(input$owned,input$retail,input$peak,input$mix)
    tryCatch(economics(input_data$models,c(input$flash_cache,input$pro_cache),input$peak,input$owned,input$retail),error=function(e){validate(need(FALSE,conditionMessage(e)))})
  })
  port <- reactive(portfolio(results(),input$mix))
  observeEvent(input$reset,{
    updateSliderInput(session,'flash_cache',value=b$flash_cache);updateSliderInput(session,'pro_cache',value=b$pro_cache)
    updateSliderInput(session,'peak',value=b$peak);updateSliderInput(session,'mix',value=b$flash_share)
    updateNumericInput(session,'owned',value=b$owned_rate);updateNumericInput(session,'retail',value=b$retail_rate);updateSelectInput(session,'target',selected=5e8)
  })
  output$kpis <- renderUI({p<-port();layout_columns(
    value_box('Portfolio revenue / 1M total tokens',usd(p['revenue']),theme='primary'),
    value_box('Owned-like contribution / 1M',usd(p['owned_contribution']),theme='primary'),
    value_box('Quadrillion tokens/year for selected target',qt(required_tokens(as.numeric(input$target),unname(p['owned_contribution']))),theme='primary'))})
  plot_units <- reactive({d<-results();z<-rbind(data.frame(model=d$model,metric='API revenue',value=d$revenue),data.frame(model=d$model,metric='Owned-like GPU cost',value=d$owned_cost),data.frame(model=d$model,metric='Retail GPU cost',value=d$retail_cost));ggplot(z,aes(model,value,fill=metric))+geom_col(position='dodge',width=.7)+scale_fill_manual(values=c('#176b68','#90b9b5','#dd9e54'))+labs(x=NULL,y='USD / 1M total tokens',fill=NULL)})
  output$overview_plot<-renderPlot(plot_units());output$unit_plot<-renderPlot(plot_units())
  output$units<-renderTable({d<-results();data.frame(Model=d$model,Revenue=usd(d$revenue),`Owned cost`=usd(d$owned_cost),`Retail cost`=usd(d$retail_cost),`Owned contribution`=usd(d$owned_contribution),`Retail contribution`=usd(d$retail_contribution),`Owned margin`=sprintf('%.1f%%',d$owned_margin*100),`Retail margin`=sprintf('%.1f%%',d$retail_margin*100),check.names=FALSE)},striped=TRUE)
  output$configs<-renderTable({d<-results();data.frame(Model=d$model,Result=d$result_id,Engine=d$engine,Precision=d$precision,GPUs=d$gpus,Concurrency=d$concurrency,`Total tok/s/GPU`=round(d$throughput/d$gpus),`Tok/s/user`=round(d$interactivity,2),`Input share`=sprintf('%.3f%%',100*d$input_share),check.names=FALSE)},striped=TRUE)
  output$cache_plot<-renderPlot({z<-do.call(rbind,lapply(seq(0,1,.02),function(h){p<-portfolio(economics(input_data$models,c(h,h),input$peak,input$owned,input$retail),input$mix);data.frame(hit=h,Owned=p['owned_contribution'],Retail=p['retail_contribution'])}));ggplot(z,aes(hit,Owned))+geom_line(color='#176b68',linewidth=1)+geom_line(aes(y=Retail),color='#dd9e54',linewidth=1)+geom_hline(yintercept=0,color='grey60',linetype=2)+labs(x='Billable input cache hit share (0–1)',y='Serving contribution / 1M total tokens (USD)',subtitle='Teal: owned-like. Amber: retail.')})
  output$mix_plot<-renderPlot({d<-results();z<-data.frame(mix=seq(0,1,.02));z$value<-vapply(z$mix,function(s)unname(portfolio(d,s)['owned_contribution']),numeric(1));ggplot(z,aes(mix,value))+geom_line(color='#176b68',linewidth=1)+geom_vline(xintercept=input$mix,linetype=2,color='#dd9e54')+labs(x='Flash share of total API tokens (0–1)',y='Owned-like contribution / 1M total tokens (USD)')})
  output$scale_note<-renderUI({p<-port();card(card_header('Hypothetical scale requirement'),h3(paste(qt(required_tokens(as.numeric(input$target),unname(p['owned_contribution']))),'owned-like /',qt(required_tokens(as.numeric(input$target),unname(p['retail_contribution']))),'retail quadrillion tokens/year')),p('This is a requirement under the selected scenario, not an estimate of DeepSeek demand.'))})
  output$scale_plot<-renderPlot({p<-port();z<-data.frame(tokens=seq(0,8,length.out=100));ggplot(z,aes(tokens,tokens*1e9*p['owned_contribution']/1e6))+geom_line(color='#176b68',linewidth=1)+geom_line(aes(y=tokens*1e9*p['retail_contribution']/1e6),color='#dd9e54',linewidth=1)+geom_hline(yintercept=as.numeric(input$target)/1e6,linetype=2)+labs(x='Annual total tokens (quadrillion)',y='Annual serving contribution (USD million)',subtitle='Teal: owned-like. Amber: retail. Dashed: selected target.')})
  output$scale_table<-renderTable({p<-port();t<-c(1e8,2.5e8,5e8,1e9,1.6e9);data.frame(`Target (USD million)`=t/1e6,`Owned quadrillion tokens/year`=vapply(t,function(x)qt(required_tokens(x,unname(p['owned_contribution']))),character(1)),`Retail quadrillion tokens/year`=vapply(t,function(x)qt(required_tokens(x,unname(p['retail_contribution']))),character(1)),check.names=FALSE)},striped=TRUE)
  output$download<-downloadHandler(filename=function()'deepseek-scenario.csv',content=function(file){d<-results();d$billable_cache<-c(input$flash_cache,input$pro_cache);d$peak_share<-input$peak;d$flash_portfolio_share<-input$mix;d$owned_hourly_rate<-input$owned;d$retail_hourly_rate<-input$retail;write.csv(d,file,row.names=FALSE)})
}
shinyApp(ui,server)
