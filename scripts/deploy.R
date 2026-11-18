# Use rsconnect::setAccountInfo interactively if your account is not configured.
# Never paste tokens into this file or commit credentials.
if(!requireNamespace('rsconnect',quietly=TRUE))stop('Install rsconnect first')
options(repos=c(CRAN='https://cloud.r-project.org'))
rsconnect::deployApp(appDir='.',appName='deepseek-inference-economics',account='peppermint',
  appFiles=c('app.R','R/model.R','data/models.csv','data/baseline.csv','www/style.css'),
  launch.browser=FALSE)
