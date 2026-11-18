read_model <- function(path = 'data') {
  list(models = read.csv(file.path(path, 'models.csv')), baseline = read.csv(file.path(path, 'baseline.csv')))
}
scalar <- function(x, name, lower=0, upper=Inf) {
  if (!is.numeric(x) || length(x)!=1 || is.na(x) || !is.finite(x) || x<lower || x>upper)
    stop(paste(name, 'must be a finite number between', lower, 'and', upper))
  x
}
economics <- function(models, cache=c(.5,.5), peak=35/168, owned_rate=1.73, retail_rate=3.7) {
  if(length(cache)!=nrow(models)) stop('One cache assumption is required per model')
  invisible(lapply(cache, scalar, name='Billable cache', upper=1))
  scalar(peak,'Peak share',upper=1);scalar(owned_rate,'Owned GPU rate');scalar(retail_rate,'Retail GPU rate')
  if(any(!is.finite(as.matrix(models[c('gpus','throughput','input_tokens','output_tokens')])))) stop('Missing benchmark inputs')
  if(any(models$throughput<=0 | models$gpus<=0 | models$input_tokens<0 | models$output_tokens<0 | models$input_tokens+models$output_tokens<=0)) stop('Invalid benchmark inputs')
  d <- models
  d$input_share <- d$input_tokens/(d$input_tokens+d$output_tokens)
  d$input_price <- peak*(cache*d$peak_hit+(1-cache)*d$peak_miss)+(1-peak)*(cache*d$off_hit+(1-cache)*d$off_miss)
  d$output_price <- peak*d$peak_output+(1-peak)*d$off_output
  d$revenue <- d$input_share*d$input_price+(1-d$input_share)*d$output_price
  d$owned_cost <- owned_rate*d$gpus*1e6/(d$throughput*3600)
  d$retail_cost <- retail_rate*d$gpus*1e6/(d$throughput*3600)
  d$owned_contribution <- d$revenue-d$owned_cost
  d$retail_contribution <- d$revenue-d$retail_cost
  d$owned_margin <- ifelse(d$revenue==0,NA_real_,d$owned_contribution/d$revenue)
  d$retail_margin <- ifelse(d$revenue==0,NA_real_,d$retail_contribution/d$revenue)
  d
}
portfolio <- function(d, flash_share=.5) {
  scalar(flash_share,'Flash share',upper=1)
  if(nrow(d)!=2) stop('Expected Flash and Pro')
  cols <- c('revenue','owned_cost','retail_cost','owned_contribution','retail_contribution')
  p <- vapply(d[cols],function(x)sum(x*c(flash_share,1-flash_share)),numeric(1))
  c(p,owned_margin=if(p['revenue']==0) NA_real_ else unname(p['owned_contribution']/p['revenue']),retail_margin=if(p['revenue']==0) NA_real_ else unname(p['retail_contribution']/p['revenue']))
}
required_tokens <- function(target, contribution) {
  scalar(target,'Annual contribution target')
  scalar(contribution,'Contribution',lower=-Inf)
  if(target==0) return(0)
  if(contribution<=0) return(NA_real_)
  target/contribution*1e6
}
baseline_args <- function(b) list(cache=c(b$flash_cache,b$pro_cache),peak=b$peak,owned_rate=b$owned_rate,retail_rate=b$retail_rate)
