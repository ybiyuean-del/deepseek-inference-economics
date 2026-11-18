app<-source('app.R')$value
shiny::testServer(server,{
 session$setInputs(flash_cache=.5,pro_cache=.5,peak=35/168,mix=.5,owned=1.73,retail=3.7,target='500000000')
 stopifnot(abs(port()['revenue']-.2610949324206076)<1e-10)
 initial<-port()
 session$setInputs(flash_cache=0,pro_cache=0,mix=.7)
 stopifnot(abs(port()['revenue']-initial['revenue'])>.01)
 session$setInputs(reset=1)
 # Browser input updates are sent to the client. Inspect messages and simulate client response.
 session$setInputs(flash_cache=b$flash_cache,pro_cache=b$pro_cache,peak=b$peak,mix=b$flash_share,owned=b$owned_rate,retail=b$retail_rate,target='500000000')
 stopifnot(isTRUE(all.equal(port(),initial)))
 for(id in c('kpis','overview_plot','unit_plot','units','configs','cache_plot','mix_plot','scale_note','scale_plot','scale_table')) stopifnot(!is.null(output[[id]]))
})
cat('PASS: reactive scenario changes and all dashboard outputs render. Reset client roundtrip is simulated.\n')
