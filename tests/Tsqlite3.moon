#!../bin/moon
arg.path = {}
arg.path.ffi = '.'
sql = require "sqlite3"
conn = sql.open("") -- Open a temporary in-memory database.
  
-- Execute SQL commands separated by the ';' character:
conn\exec "CREATE TABLE t(id TEXT, num REAL); INSERT INTO t VALUES('myid1', 200);"
-- Prepared statements are supported:
stmt = conn\prepare("INSERT INTO t VALUES(?, ?)")
for i=2,4
  stmt\reset()\bind('myid'..i, 200*i)\step()
  
-- Command-line shell feature which here prints all records:
conn "SELECT * FROM t"
--> id    num
--> myid1 200
--> myid2 400
--> myid3 600
--> myid4 800
  
t = conn\exec("SELECT * FROM t") -- Records are by column.
-- Access to columns via column numbers or names:
assert(t[1] == t.id)
-- Nested indexing corresponds to the record number:
assert(t[1][3] == 'myid3')
  
-- Convenience function returns multiple values for one record:
id, num = conn\rowexec("SELECT * FROM t WHERE id=='myid3'")
print(id, num) --> myid3 600
 
-- Custom scalar function definition, aggregates supported as well.
fn = (x) -> return x/100
conn\setscalar("MYFUN", fn)
conn "SELECT MYFUN(num) FROM t"
--> MYFUN(num)
--> 2
--> 4
--> 6
--> 8
 

----
conn\exec "CREATE TABLE it(id TEXT, num REAL); INSERT INTO it VALUES('imyid1', 200); INSERT INTO it VALUES('imyid2', 400);"
stmt2 = conn\prepare("SELECT * FROM it")
for row in stmt2\rows!
    print(unpack(row))

conn\close() -- Close stmt as well.
