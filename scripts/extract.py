from pathlib import Path
import openpyxl,csv,json,hashlib,sys
root=Path(__file__).resolve().parents[1]
for p in ['R','data','scripts','tests','docs','www','.github/workflows']: (root/p).mkdir(parents=True,exist_ok=True)
src=Path(sys.argv[1]); w=openpyxl.load_workbook(src,data_only=True); f=openpyxl.load_workbook(src,data_only=False)
def write(name,rows):
 with (root/name).open('w',newline='',encoding='utf-8') as out:
  wr=csv.DictWriter(out,fieldnames=list(rows[0]));wr.writeheader();wr.writerows(rows)
u=w['Unit_Economics']; b=w['B200 Run Inputs']; c=w['B200 Run Costs']; pc=w['Pricing_Cache']
rows=[]
for i,(name,off,col) in enumerate([('V4.1 Flash',0,'B'),('V4 Pro 0813',44,'C')]):
 row=dict(model=name,result_id=b[f'{col}5'].value,gpus=u[f'B{7+off}'].value,throughput=u[f'B{8+off}'].value,input_tokens=u[f'B{16+off}'].value,output_tokens=u[f'B{17+off}'].value,engine=b[f'{col}8'].value,precision=b[f'{col}9'].value,concurrency=b[f'{col}20'].value,interactivity=b[f'{col}21'].value,benchmark_date=str(b[f'{col}38'].value),technical_cache=c[f'{col}31'].value)
 for key,r in [('peak_hit',27),('off_hit',28),('peak_miss',29),('off_miss',30),('peak_output',31),('off_output',32)]:row[key]=u[f'B{r+off}'].value
 rows.append(row)
write('data/models.csv',rows)
write('data/baseline.csv',[dict(flash_cache=pc['B12'].value,pro_cache=pc['B25'].value,peak=pc['B33'].value,flash_share=w['API_Portfolio']['B6'].value,owned_rate=c['B47'].value,retail_rate=c['B48'].value)])
expected=[]
for i,off in enumerate([0,44]):
 for metric,r in [('revenue',41),('owned_cost',23),('retail_cost',24),('owned_contribution',42),('retail_contribution',43),('owned_margin',44),('retail_margin',45)]:expected.append(dict(group='model',index=i+1,metric=metric,value=u[f'B{r+off}'].value,sheet='Unit_Economics',cell=f'B{r+off}'))
for metric,col in [('revenue','D'),('owned_cost','E'),('retail_cost','F'),('owned_contribution','G'),('retail_contribution','H'),('owned_margin','I'),('retail_margin','J')]:expected.append(dict(group='portfolio',index=1,metric=metric,value=w['API_Portfolio'][col+'12'].value,sheet='API_Portfolio',cell=col+'12'))
for r in range(14,19):
 for metric,col in [('owned','C'),('retail','G')]:expected.append(dict(group='scale',index=w['BreakEven_Scale'][f'A{r}'].value,metric=metric,value=w['BreakEven_Scale'][f'{col}{r}'].value,sheet='BreakEven_Scale',cell=f'{col}{r}'))
write('data/excel_expected.csv',expected)
sens=[]
for model,header,start in [(1,45,46),(2,77,78)]:
 for r in range(start,start+5):
  for col in 'BCDE':sens.append(dict(model=model,cache=pc[f'A{r}'].value,peak=pc[f'{col}{header}'].value,revenue=pc[f'{col}{r}'].value,cell=f'{col}{r}'))
write('data/excel_sensitivity.csv',sens)
audit=[]; errors=[]; sources=[]
for s in f:
 for row in s:
  for cell in row:
   if cell.data_type=='f':
    value=w[s.title][cell.coordinate].value
    audit.append(dict(sheet=s.title,cell=cell.coordinate,formula=cell.value,cached=value))
    if isinstance(value,str) and value.startswith(('#REF!','#DIV/0!','#VALUE!','#NAME?','#NUM!','#N/A')):errors.append(dict(sheet=s.title,cell=cell.coordinate,error=value))
   if isinstance(cell.value,str) and cell.value.startswith('https://'):sources.append(dict(sheet=s.title,cell=cell.coordinate,url=cell.value))
   if cell.hyperlink:sources.append(dict(sheet=s.title,cell=cell.coordinate,url=cell.hyperlink.target))
write('data/sources.csv',sources)
# Formula audit and original workbook remain local: third-party raw-data redistribution is not established.
(root/'docs/workbook-manifest.json').write_text(json.dumps(dict(sha256=hashlib.sha256(src.read_bytes()).hexdigest(),snapshot='2026-09-16',sheets=[dict(name=s.title,rows=s.max_row,columns=s.max_column) for s in f],formula_count=len(audit),cached_errors=errors),indent=2),encoding='utf-8')
(root/'local').mkdir(exist_ok=True)
(root/'local/formula-audit.json').write_text(json.dumps(audit,default=str),encoding='utf-8')
print(json.dumps(dict(models=rows,errors=errors,formula_count=len(audit)),default=str))

