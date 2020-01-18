import psycopg2
import sys

try:
    conn = psycopg2.connect("dbname = a3")
except Exception as e:
    print("Unable to connect to the database a3")

query1  = """
select id, weeks, weeks_binary from meetings;
"""
query2 = """
UPDATE Meetings
SET weeks_binary = %s
where id = %s;
"""

cur1 = conn.cursor()
cur1.execute(query1)
for tup1 in cur1.fetchall():
    id, week, weeks_binary = tup1
    binary = '00000000000'   
    if 'N' in week or '<' in week:
        binary = '00000000000'   
    else:
        for x in range(2, 10):
            if str(x) in week:
                binary = binary[:x-1] + '1' + binary[x:] 
        
        if '10' in week:
            binary = binary[:9] + '1' + binary[10:]
        if '11' in week:
            binary = binary[:10] + '1'
        
        # Only in week 1
        if len(week) == 1 and week[0] == '1':
            binary = binary[:0] + '1' + binary[1:]

        
        for i in range(len(week)-1):
            if week[i] == '1' and week[i+1] != '0' and week[i+1] != '1':
                binary = binary[:0] + '1' + binary[1:]
            # digit - digit
            if  week[i] == '-' and week[i-1].isdigit() and week[i+1].isdigit():           
                if '10-' in week:
                    break
                elif week[i+1] == '1' and week[i+2] == '1':
                    n2 = 11               
                elif week[i+1] == '1' and week[i+2] == '0':
                    n2 = 10              
                else:
                    n2 = int(week[i+1])  
                n = int(week[i-1])                 
                while (n <= n2):
                    binary = binary[:n-1] + '1' + binary[n:]                  
                    n = n+1
            
    query = cur1.mogrify(query2,[binary,id])
    cur1.execute(query)

   
cur1.close()
conn.commit()  
conn.close()