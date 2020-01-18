import psycopg2
try:
    conn = psycopg2.connect("dbname = a3")
except Exception as e:
    print("Unable to connect to the database a3")

query = """
select s.code, c.quota, n.count as enrolled
from subjects s
join courses c on c.subject_id = s.id
join nenroll n on n.course_id = c.id
join terms t on t.id = c.term_id
where c.quota > 50 and t.id = 5199 and n.count > c.quota
order by s.code
"""

cur = conn.cursor()
cur.execute(query)
for tup in cur.fetchall():
    course,quota,enrolled = tup
    percentage = int(round(enrolled/quota * 100))
    #if percentage > 100 :
    print (course, str(percentage) +'%')
conn.close()
