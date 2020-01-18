import psycopg2
import sys
import re
if len(sys.argv) == 2 :
    code = sys.argv[1]
elif len(sys.argv) == 1:
    code = "ENGG"
else :
    print("Usage: q3.py [code]")
    sys.exit()

try:
    conn = psycopg2.connect("dbname = a3")
except Exception as e:
    print("Unable to connect to the database a3")
query  = """
select * from q3helper;
"""
cur1 = conn.cursor()
cur1.execute(query)
mylist = list()
lst = []
for tup1 in cur1.fetchall():
    lst.append(tup1)

for tup1 in lst:
    building,name = tup1   
    if name.find(code) != -1 and building not in mylist:
        print(building)
        for tup2 in lst:
            if tup2[0] == building and tup2[1].find(code) != -1 :
                print(" ",tup2[1],sep='')
                mylist.append(building)
    