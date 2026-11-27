"""Smoke-test the deployed Pages → Render → Neon contract without admin credentials."""
import json,urllib.request,urllib.error
from pathlib import Path
ROOT=Path(__file__).resolve().parent
API='https://krimlaju-sql-practice-lab.onrender.com'
SITE='https://subhanaristiadi.github.io/krimlaju-sql-practice-lab/'
report=[]
def request(path,body=None,origin='https://subhanaristiadi.github.io'):
    req=urllib.request.Request(API+path,data=None if body is None else json.dumps(body).encode(),headers={'Content-Type':'application/json','Origin':origin})
    try:
        with urllib.request.urlopen(req,timeout=90) as response:
            return response.status,json.load(response),{k.lower():v for k,v in response.headers.items()}
    except urllib.error.HTTPError as e:
        return e.code,json.load(e),{k.lower():v for k,v in e.headers.items()}
def check(label,condition):
    assert condition,label
    report.append({'check':label,'passed':True})
    print('PASS',label,flush=True)

status,h,_=request('/health')
check('Health: Neon connected',status==200 and h['database']=='connected')
status,exercises,headers=request('/api/exercises')
check('75 exercises with expected columns',status==200 and len(exercises)==75 and all(e['expected_output'] for e in exercises))
check('CORS allows Pages',headers.get('access-control-allow-origin')=='https://subhanaristiadi.github.io')
_,_,headers=request('/api/exercises',origin='https://example.invalid')
check('CORS excludes unknown origins','access-control-allow-origin' not in headers)
status,result,_=request('/api/query',{'sql':"SELECT (SELECT COUNT(*) FROM customers) AS customers,(SELECT COUNT(*) FROM routes) AS routes,(SELECT COUNT(*) FROM shipments) AS shipments,(SELECT COUNT(*) FROM status_history) AS status_history,COUNT(*) FILTER(WHERE status='delivered' AND actual_delivery IS NULL) AS delivered_missing_actual FROM shipments"})
check('All 17,427 source rows and 50 audit anomalies',status==200 and result['rows']==[[600,80,4000,12747,50]])
status,result,_=request('/api/query',{'sql':'SELECT 1 AS value,2 AS value'})
check('Duplicate column names preserve positional values',status==200 and result['rows']==[[1,2]])
status,result,_=request('/api/query',{'sql':'SELECT 1; SELECT 2'})
check('Multiple statements rejected',status==422)
status,result,_=request('/api/query',{'sql':'DELETE FROM shipments WHERE false'})
check('Write SQL rejected before execution',status==422)
status,result,_=request('/api/query',{'sql':"SELECT current_user AS role,has_database_privilege(current_user,current_database(),'CREATE') AS can_create,has_table_privilege(current_user,'shipments','INSERT') AS can_insert"})
check('Dedicated reader without CREATE/INSERT',status==200 and result['rows']==[['kirimlaju_reader',False,False]])
status,ref,_=request('/api/exercises/KL-21/reference')
check('Reference endpoint available',status==200 and 'sql' in ref)
status,result,_=request('/api/validate',{'exercise_id':'KL-21','sql':ref['sql']})
check('600-customer answer validates without truncation',status==200 and result['validation']['passed'] and result['result']['row_count']==600 and not result['result']['truncated'])
status,result,_=request('/api/validate',{'exercise_id':'KL-01','sql':'SELECT 0 AS total_shipments,0 AS transaction_value_idr,0 AS avg_cost_idr,0 AS avg_weight_kg'})
check('Wrong answer fails validation',status==200 and not result['validation']['passed'])
with urllib.request.urlopen(SITE,timeout=30) as response:
    html=response.read().decode()
    check('Pages serves Kirimlaju frontend',response.status==200 and 'Kirimlaju SQL Practice Lab' in html and API in html)
try:
    urllib.request.urlopen(SITE+'data/shipments.csv',timeout=30)
    exposed=True
except urllib.error.HTTPError as e:
    exposed=e.code!=404
check('Pages artifact excludes raw CSV',not exposed)
(ROOT/'docs/deployment_verification.json').write_text(json.dumps({'checks':report,'pages':SITE,'api':API,'render_deploy':'dep-dc4e19rl550s7390q6s0','runtime_log_check':'Render log provider returned 503; runtime requests and browser checks passed.'},indent=2)+'\n',encoding='utf-8')
