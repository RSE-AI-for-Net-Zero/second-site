from sqlalchemy import create_engine, text

engine = create_engine("postgresql://postgres:anything_at_all_here@10.0.3.89/testdb")

with engine.connect() as conn:
    #conn.execute(text("DROP TABLE test_table"))
    conn.execute(text("CREATE TABLE test_table (x int)"))
    conn.execute(
        text("INSERT INTO test_table (x) VALUES (:x)"),
        [{"x": 22}]
    )
    conn.commit()


with engine.connect() as conn:
    res = conn.execute(text("SELECT * FROM test_table"))

line = res.fetchone()
print(line)
assert line[0] == 22
