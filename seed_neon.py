"""Seed only an empty database, preserve source CSV values, create a SELECT-only reader.

Usage: python seed_neon.py (reads NEON_ADMIN_DATABASE_URL), or --stdin-url.
The administrative credential is never persisted. The reader URL goes in ignored .env.
"""
import csv, hashlib, io, json, os, secrets, sys
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit, quote
import psycopg2
from psycopg2 import sql

ROOT=Path(__file__).resolve().parent
TABLES=('customers','routes','shipments','status_history')
EXPECTED=(600,80,4000,12747)

def seed(url):
    with psycopg2.connect(url,sslmode='require',connect_timeout=15) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT tablename FROM pg_tables WHERE schemaname='public'")
            if cur.fetchall():
                raise RuntimeError('Database is not empty; refusing to overwrite existing data.')
            cur.execute((ROOT/'schema.sql').read_text(encoding='utf-8'))
            manifest={}
            for table,expected in zip(TABLES,EXPECTED):
                path=ROOT/'data'/f'{table}.csv'
                with path.open(encoding='utf-8-sig',newline='') as f:
                    reader=csv.reader(f)
                    columns=next(reader)
                    rows=list(reader)
                assert len(rows)==expected,(table,len(rows))
                buffer=io.StringIO()
                writer=csv.writer(buffer,lineterminator='\n')
                writer.writerow(columns)
                writer.writerows(rows)
                buffer.seek(0)
                query=sql.SQL('COPY {} ({}) FROM STDIN WITH (FORMAT CSV, HEADER TRUE)').format(sql.Identifier(table),sql.SQL(',').join(map(sql.Identifier,columns)))
                cur.copy_expert(query,buffer)
                cur.execute(sql.SQL('SELECT COUNT(*) FROM {}').format(sql.Identifier(table)))
                assert cur.fetchone()[0]==expected
                manifest[table]={'rows':expected,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
            cur.execute('REVOKE CREATE ON SCHEMA public FROM PUBLIC')
            password=secrets.token_urlsafe(36)
            cur.execute(sql.SQL('CREATE ROLE kirimlaju_reader LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT PASSWORD {}').format(sql.Literal(password)))
            cur.execute('GRANT USAGE ON SCHEMA public TO kirimlaju_reader')
            cur.execute('GRANT SELECT ON ALL TABLES IN SCHEMA public TO kirimlaju_reader')
            cur.execute("ALTER ROLE kirimlaju_reader SET default_transaction_read_only = on")
            cur.execute("ALTER ROLE kirimlaju_reader SET statement_timeout = '10s'")
            cur.execute("ALTER ROLE kirimlaju_reader SET idle_in_transaction_session_timeout = '15s'")
            cur.execute('SELECT current_database()')
            cur.execute(sql.SQL('GRANT CONNECT ON DATABASE {} TO kirimlaju_reader').format(sql.Identifier(cur.fetchone()[0])))
    parsed=urlsplit(url)
    host=parsed.hostname
    if '-pooler' not in host:
        host=host.replace('.','-pooler.',1)
    reader_url=urlunsplit((parsed.scheme,f'kirimlaju_reader:{quote(password)}@{host}'+(f':{parsed.port}' if parsed.port else ''),parsed.path,parsed.query,parsed.fragment))
    env=ROOT/'.env'
    if env.exists():
        raise RuntimeError('.env exists; reader created but local credential was not overwritten.')
    env.write_text(f'DATABASE_URL={reader_url}\nREQUIRE_NON_SUPERUSER=true\n',encoding='utf-8')
    (ROOT/'data/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    print('Seeded 17,427 rows. SELECT-only reader configured in ignored .env. Admin URL not persisted.')

if __name__=='__main__':
    if '--stdin-url' in sys.argv:
        print('Ready for admin URL on stdin (input is hidden).',flush=True)
        import getpass
        url=getpass.getpass('')
    else:
        url=os.environ['NEON_ADMIN_DATABASE_URL']
    seed(url.strip())
