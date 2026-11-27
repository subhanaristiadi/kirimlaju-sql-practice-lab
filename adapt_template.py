"""Apply Kirimlaju content while preserving Sedukopi's layout and CSS."""
import json, re
from pathlib import Path
ROOT = Path(__file__).resolve().parent
for name in ['index.html','server.py']:
    p=ROOT/name
    s=p.read_text(encoding='utf-8')
    s=s.replace('SEDUKOPI','KIRIMLAJU').replace('Sedukopi','Kirimlaju').replace('sedukopi','kirimlaju')
    s=s.replace('https://kirimlaju-sql-practice-lab.onrender.com','https://krimlaju-sql-practice-lab.onrender.com')
    if name=='index.html':
        s=s.replace('☕ Kirimlaju','📦 Kirimlaju').replace('id="totalCount">45','id="totalCount">75')
        s=s.replace('Safety note: run this service on localhost only. Read-only transactions are a secondary control; use a dedicated PostgreSQL role with SELECT privileges only.', 'Latihan memakai dataset simulasi Kirimlaju. Query dijalankan dengan akun PostgreSQL khusus SELECT; progres dan catatan tersimpan di browser ini.')
        s=s.replace('if(!r.ok)throw new Error(d.error||d.message||`HTTP ${r.status}`)', 'if(!r.ok)throw new Error([d.error||d.message||`HTTP ${r.status}`,d.detail].filter(Boolean).join(": "))')
        schema={}
        ddl=(ROOT/'schema.sql').read_text(encoding='utf-8')
        rels={
            'customers':['Referenced by shipments.customer_id'],
            'routes':['Referenced by shipments.route_id'],
            'shipments':['customer_id → customers.customer_id','route_id → routes.route_id','Referenced by status_history.shipment_id'],
            'status_history':['shipment_id → shipments.shipment_id']}
        for table,body in re.findall(r'CREATE TABLE (\w+) \((.*?)\n\);',ddl,re.S):
            cols=re.findall(r'^\s+(\w+)\s+(?:text|date|integer|numeric|timestamp)\b',body,re.M)
            schema[table]={'columns':cols,'relationships':rels[table]}
        s=re.sub(r'const DATA_SCHEMA = \{.*?\n\};','const DATA_SCHEMA = '+json.dumps(schema,ensure_ascii=False,indent=2)+';',s,flags=re.S)
    else:
        s=s.replace('TABLES = ("outlets", "staff", "menu_items", "orders", "order_details")','TABLES = ("customers", "routes", "shipments", "status_history")')
        s=s.replace('all five Kirimlaju tables','all four Kirimlaju tables')
        s=s.replace('with conn.cursor(cursor_factory=RealDictCursor) as cur:', 'with conn.cursor() as cur:')
        s=s.replace('rows = [[json_safe(row.get(c)) for c in columns] for row in raw_rows]', 'rows = [[json_safe(value) for value in row] for row in raw_rows]')
    p.write_text(s,encoding='utf-8')
