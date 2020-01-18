import psycopg2
import sys
import re
if len(sys.argv) == 2 :
    code = sys.argv[1]
elif len(sys.argv) == 1:
    code = "ENGG"
else :
    print("Usage: q4.py [code]")
    sys.exit()

try:
    conn = psycopg2.connect("dbname = a3")
except Exception as e:
    print("Unable to connect to the database a3")

query  = """
select * from q4helper;
"""
cur1 = conn.cursor()
cur1.execute(query)
mylist = list()
for tup1 in cur1.fetchall():
    term,name,count = tup1
    if term not in mylist:
        print(term)
        mylist.append(term)
    if name.find(code) != -1:
        print(" ",name,'(',count,')',sep='')


conn.close()
    
