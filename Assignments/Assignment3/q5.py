import psycopg2
import sys
import re
if len(sys.argv) == 2 :
    code = sys.argv[1]
elif len(sys.argv) == 1:
    code = "COMP1521"
else :
    print("Usage: q5.py [course]")
    sys.exit()

try:
    conn = psycopg2.connect("dbname = a3")
except Exception as e:
    print("Unable to connect to the database a3")

query  = """
select * from q5helper2;
"""
cur1 = conn.cursor()
cur1.execute(query)
mylist = list()
for tup in cur1.fetchall():
    course,name,tag, percentage = tup
    if course == code:
        result = name+' '+tag.replace(" ","")+' is '+str(percentage)+'% '+'full'
        print (result)

cur1.close()  
conn.close()