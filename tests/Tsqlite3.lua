#!../bin/moon
arg.path = {}
arg.path.ffi = '.'
T = require "u-test"
sql = require "sqlite3"
conn = sql.open("") -- Open a temporary in-memory database.

-- Execute SQL commands separated by the ';' character:
conn\exec "CREATE TABLE t(id TEXT, num REAL); INSERT INTO t VALUES('myid1', 200);"
-- Prepared statements are supported:
stmt = conn\prepare("INSERT INTO t VALUES(?, ?)")
for i=2,4
  stmt\reset()\bind('myid'..i, 200*i)\step()

-- Command-line shell feature which here prints all records:
t = conn\exec "SELECT * FROM t"
T["test1 (prepared statements and conn:exec)"] = ->
  T.equal(t[1], t.id)
  T.equal(t[2], t.num)
  T.equal(t[1][1], 'myid1')
  T.equal(t[1][2], 'myid2')
  T.equal(t[1][3], 'myid3')
  T.equal(t[1][4], 'myid4')
  T.equal(t["num"][1], 200)
  T.equal(t["num"][2], 400)
  T.equal(t["num"][3], 600)
  T.equal(t["num"][4], 800)

-- Convenience function returns multiple values for one record:
id, num = conn\rowexec("SELECT * FROM t WHERE id=='myid3'")
T["test2 (conn:rowexec)"] = ->
  T.equal(id, 'myid3')
  T.equal(num, 600)

-- Custom scalar function definition, aggregates supported as well.
fn = (x) -> return x/100
conn\setscalar("MYFUN", fn)
t = conn\exec "SELECT MYFUN(num) FROM t"
T["test3 (custom scalar function)"] = ->
  T.equal(t[1][1], 2)
  T.equal(t[1][2], 4)
  T.equal(t[1][3], 6)
  T.equal(t[1][4], 8)

conn\exec "CREATE TABLE it(id TEXT, num REAL); INSERT INTO it VALUES('imyid1', 200); INSERT INTO it VALUES('imyid2', 400);"
stmt2 = conn\prepare("SELECT * FROM it")
x = {}
for row in stmt2\rows!
  x[#x+1] = row[1]
  x[#x+1] = row[2]
T["test4 (rows iterator)"] = ->
  T.equal(x[1], 'imyid1')
  T.equal(x[2], 200)
  T.equal(x[3], 'imyid2')
  T.equal(x[4], 400)

conn\close() -- Close stmt as well.
