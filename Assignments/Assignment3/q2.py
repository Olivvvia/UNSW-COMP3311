import psycopg2
import sys

if len(sys.argv) == 2 :
    number = int(sys.argv[1])
elif len(sys.argv) == 1:
    number = 2
else :
    print("Usage: q2.py [incommon]")
    sys.exit()
#print ("The second argument is : " , number)

try:
    conn = psycopg2.connect("dbname = a3")
except Exception as e:
    print("Unable to connect to the database a3")

query1 = """
select * from q2helper2
;    
"""
query2 = """
select * from q2helper1
;    
"""
cur1 = conn.cursor()
cur1.execute(query1)
cur2 = conn.cursor()
mylist = []        
cur2.execute(query2)
for tup2 in cur2.fetchall():
    mylist.append(tup2)

for tup1 in cur1.fetchall():
    code, count = tup1 
    if count == number:
        print(code[0],':',end=' ',sep='')
        counter = 1
        for tup2 in mylist:
            id,course,digit = tup2  
            if digit[0] == code[0] and counter != number:                
                print (course[0], end=' ',sep='')
                counter = counter + 1
            elif digit[0] == code[0] and counter == number: 
                print (course[0], end='',sep='')
        print('')

    
conn.close()