import psycopg2
import sys
import re
def takerid(mylist):
    return mylist[1]
if len(sys.argv) == 2 :
    if sys.argv[1] == '19T1' or sys.argv[1] == '19T2' or sys.argv[1] == '19T3':
        term = sys.argv[1]        
    else:
        print("Invalid Term")
        sys.exit()
elif len(sys.argv) == 1:
    term = '19T1'
else :
    print("Usage: q7.py [term]")
    sys.exit()
try:
    conn = psycopg2.connect("dbname = a3")
except Exception as e:
    print("Unable to connect to the database a3")

query0  = """
select * from q7helper1 where term = %s;
"""
query1 = """
select * from q7helper2;
"""
query2 = """
select * from overlap where term = %s;
"""
query3 = """
select * from overlap1 where term = %s;
"""
mylist1 = list()
myroom = dict()
overlaptup = list()
cur1 = conn.cursor()
query = cur1.mogrify(query0,[term])
cur1.execute(query)
for tup1 in cur1.fetchall():
    mylist1.append(tup1)

cur1.execute(query1)    
total = 0
for tup2 in cur1.fetchall():
    total = total+1
    myroom[tup2[0]] = 0

myclass = dict()
for tup in mylist1:
    cid, rid, room, term ,day,start,end,binary = tup
    if cid not in myclass:
        myclass[cid]= rid, room, term ,day,start,end,binary
    nweeks = binary.count('1')
    nhours = (end-start)/100
    if re.match("^.*1$", binary):
        nweeks = nweeks - 1
    if re.match("([0-9]+).3$",str(nhours)):
        nhours = str(nhours).replace(".3",".5")
    if re.match("([0-9]+).7$",str(nhours)):    
        nhours = str(nhours).replace(".7",".5")
    hours = float(nhours)*nweeks
    myroom[rid] = myroom[rid] + hours

count = 0
for rid in myroom:
    if (myroom[rid] < 200):
        count = count+1
        

#print("total rooms: ",total)
#print("Under-utilised rooms: ",count)
print(round(count/total*100,1),"%", sep='')

cur1.close()
conn.close()
