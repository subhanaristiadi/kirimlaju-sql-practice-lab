"""Curriculum coverage and API safety/validation regression checks."""
import json, re, sys, unittest
from pathlib import Path
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
import server

class LabTests(unittest.TestCase):
    def test_all_original_questions_are_preserved(self):
        source=(ROOT/'docs/kirimlaju_business_questions.md').read_text(encoding='utf-8')
        original=re.findall(r'^\d+\. (.+)$',source,re.M)
        exercises=list(server.EXERCISES.values())
        self.assertEqual(len(exercises),75)
        self.assertEqual(len(original),55)
        self.assertEqual([e['source_question'] for e in exercises[:55]],list(range(1,56)))
        translated=(ROOT/'docs/business_questions.en.md').read_text(encoding='utf-8')
        self.assertEqual([e['business_question'] for e in exercises],re.findall(r'^\d+\. (.+)$',translated,re.M))
        self.assertEqual(set(server.EXERCISES),set(server.REFERENCES))
        for e in exercises:
            self.assertTrue(e['expected_output'],e['id'])
            server.validate_sql(server.REFERENCES[e['id']]['sql'])

    def test_write_and_multi_statement_queries_rejected(self):
        for query in ['DELETE FROM shipments','DROP TABLE routes','SELECT 1; SELECT 2',
                      'WITH x AS (DELETE FROM shipments RETURNING *) SELECT * FROM x',
                      'SELECT * INTO copy_shipments FROM shipments','COPY shipments TO STDOUT']:
            with self.subTest(query=query),self.assertRaises(ValueError):
                server.validate_sql(query)

    def test_comparison_keeps_duplicates_and_nulls(self):
        result=lambda rows:{'columns':['value'],'rows':rows,'truncated':False}
        policy={'order_matters':False}
        self.assertTrue(server.compare_results(result([[1],[None],[1]]),result([[None],[1],[1]]),policy)['passed'])
        self.assertFalse(server.compare_results(result([[1],[None],[2]]),result([[None],[1],[1]]),policy)['passed'])
        self.assertFalse(server.compare_results({**result([[1]]),'truncated':True},result([[1]]),policy)['passed'])

    def test_api_rejects_invalid_input(self):
        with server.app.test_client() as c:
            self.assertEqual(c.post('/api/query',json={'sql':''}).status_code,400)
            self.assertEqual(c.post('/api/validate',json={'exercise_id':'unknown','sql':'SELECT 1'}).status_code,404)
            response=c.get('/api/exercises',headers={'Origin':'https://subhanaristiadi.github.io'})
            self.assertEqual(len(response.json),75)
            self.assertEqual(response.headers['Access-Control-Allow-Origin'],'https://subhanaristiadi.github.io')
            self.assertNotIn('Access-Control-Allow-Origin',c.get('/api/exercises',headers={'Origin':'https://example.invalid'}).headers)

if __name__=='__main__':unittest.main()
