source('R/model.R')
x<-read_model();b<-x$baseline
d<-do.call(economics,c(list(models=x$models),baseline_args(b)));p<-portfolio(d,b$flash_share)
checks<-0
eq<-function(actual,expected,label,tol=1e-10){if(!isTRUE(all.equal(unname(actual),unname(expected),tolerance=tol)))stop(label,': actual=',actual,' expected=',expected);checks<<-checks+1}
bad<-function(expr){if(!inherits(try(force(expr),silent=TRUE),'try-error'))stop('Invalid input accepted');checks<<-checks+1}
e<-read.csv('data/excel_expected.csv')
for(i in seq_len(nrow(e))){r<-e[i,];a<-switch(r$group,model=d[[r$metric]][r$index],portfolio=p[r$metric],scale=required_tokens(r$index,unname(p[paste0(r$metric,'_contribution')])));eq(a,r$value,paste(r$sheet,r$cell))}
s<-read.csv('data/excel_sensitivity.csv')
for(i in seq_len(nrow(s))){r<-s[i,];a<-economics(x$models,rep(r$cache,2),r$peak,b$owned_rate,b$retail_rate);eq(a$revenue[r$model],r$revenue,paste('Pricing_Cache',r$cell))}
eq(b$peak,35/168,'Peak baseline');eq(b$flash_cache,.5,'Flash cache');eq(b$pro_cache,.5,'Pro cache');eq(b$flash_share,.5,'Mix')
eq(d$input_share,x$models$input_tokens/(x$models$input_tokens+x$models$output_tokens),'Composition')
eq(portfolio(d,0)['revenue'],d$revenue[2],'All Pro');eq(portfolio(d,1)['revenue'],d$revenue[1],'All Flash')
eq(required_tokens(100,1),1e8,'Million conversion');eq(required_tokens(0,-1),0,'Zero target')
stopifnot(is.na(required_tokens(100,0)),is.na(required_tokens(100,-1)))
for(z in c(-.1,1.1,NA_real_,Inf)){bad(portfolio(d,z));bad(economics(x$models,c(z,.5)));bad(economics(x$models,peak=z))}
bad(economics(x$models,cache=.5));bad(economics(x$models,owned_rate=-1));bad(required_tokens(-1,1));bad(required_tokens(1,NA_real_))
z<-x$models;z$throughput[1]<-0;bad(economics(z))
z<-x$models;z[,c('peak_hit','off_hit','peak_miss','off_miss','peak_output','off_output')]<-0
stopifnot(all(is.na(economics(z)$owned_margin)))
stopifnot(all(economics(x$models,owned_rate=1000)$owned_contribution<0))
cat('PASS:',checks,'numeric and invalid-input checks, plus zero/negative contribution and zero-revenue checks.\n')
