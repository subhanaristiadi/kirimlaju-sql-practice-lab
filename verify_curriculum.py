"""Execute every reference against the seeded PostgreSQL, derive exact output columns."""
import json
from pathlib import Path
import server
ROOT=Path(__file__).resolve().parent
exercises=json.loads((ROOT/'exercises.json').read_text(encoding='utf-8'))
report=[]
for e in exercises:
    result=server.execute_query(server.REFERENCES[e['id']]['sql'])
    assert not result['truncated'],e['id']
    assert len(result['columns'])==len(set(result['columns'])),e['id']
    e['expected_output']=result['columns']
    report.append({'id':e['id'],'rows':result['row_count'],'columns':result['columns'],'passed':True})
    print(e['id'],result['row_count'],'rows',flush=True)
(ROOT/'exercises.json').write_text(json.dumps(exercises,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(ROOT/'docs/reference_verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
coverage='# Cakupan 75 business question\n\n55 pertanyaan sumber dipertahankan verbatim. 20 pertanyaan tambahan berada di docs/additional_business_questions.md. Semua referensi dijalankan di PostgreSQL 16 dengan role SELECT-only.\n\n| Latihan | Sumber | Judul | Baris hasil |\n|---|---|---|---|\n'
for e,r in zip(exercises,report):
    coverage+=f"| {e['id']} | {e['source_question'] or 'Tambahan'} | {e['title']} | {r['rows']} |\n"
(ROOT/'coverage_matrix.md').write_text(coverage,encoding='utf-8')
print('All 75 reference queries verified; expected output columns saved.')
