import psycopg2
import sys
import re
if len(sys.argv) == 2 :
    course1 = sys.argv[1]
elif len(sys.argv) == 3:
    course1 = sys.argv[1]
    course2 = sys.argv[2]
elif len(sys.argv) == 4:
    course1 = sys.argv[1]
    course2 = sys.argv[2]
    course3 = sys.argv[3]
else :
    print("Usage: q8.py [course1] [optional-course2] [optional-course3]")
    sys.exit()
try:
    conn = psycopg2.connect("dbname = a3")
except Exception as e:
    print("Unable to connect to the database a3")
query = """
select * from q8helper1 where code = %s;
"""
cur1 = conn.cursor()
cur2 = conn.cursor()
cur3 = conn.cursor()
total_hour = 0
nday = 0
mylist = list()
mylist1 = list()
mylist2 = list()
mylist3 = list()
mycourse = list()
myday = list()
myclasstype = list()
myclassid = list()
LectureTime = dict()
LectureTime1 = dict()
LectureTime2 = dict()
LectureTime3 = dict()
HasTimetable = True
def takedaytime(mylist):
    #return start time for sorting class in same day
    return mylist[4]
def sortmyday(myday):
    m = {'Fri': 4, 'Thu': 3, 'Wed': 2, 'Tue': 1, 'Mon': 0}
    myday = list(dict.fromkeys(myday))
    myday = sorted(myday, key=m.get)
    return myday 
def printcourse(mycourse,myday):
    mycourse = list(dict.fromkeys(mycourse))
    for Day in myday:
        print("  ",Day,sep='')
        sortday = list()
        for tup in mycourse:
            course,id,ctype,day,start,end,hours = tup              
            if (day == Day):
               sortday.append(tup)  
        sortday = sorted(sortday,key=takedaytime)                        
        for tup1 in sortday:  
            course,id,ctype,day,start,end,hours = tup1                
            print("    ",course," ",ctype,": ",start,"-",end,sep='')   
    return
#find the start-end time for each day, use for final print
def SummaryDayTime(mycourse):
    mycourse = list(dict.fromkeys(mycourse))
    Updated = dict()
    for tup in mycourse:
        course,id,ctype,day,start,end,hours = tup              
        Updated[day] = start,end
    for tmpday in Updated:
        tmpstart,tmpend = Updated[tmpday]    
        for tup in mycourse:
            course,id,ctype,day,start,end,hours = tup  
            if(day == tmpday):
                if (start < tmpstart):
                    tmpstart = start
                if(end > tmpend):
                    tmpend = end
        Updated[tmpday] = tmpstart,tmpend
    #for tmpday in Updated:
    #    print("UPDATE:",tmpday,Updated[tmpday])
    
    return Updated

# Update current daytime for each course, return list of Mon-Fri courses
def UpdateDayTime(mycourse,myday):
    mycourse = list(dict.fromkeys(mycourse))
    mycourse = sorted(mycourse,key=takedaytime)  
    myday = sortmyday(myday)
    Updated = list()
    for DAY in myday:
        for tup in mycourse:
            course,cid,ctype,day,start,end,hours = tup              
            if day == DAY:
                Updated.append(tup)
    
    #for tmpday in Updated:
    #    print("UPDATE:",tmpday)
    
    return Updated
#Take 1 list and 1 tuple, return whether or not there is overlap
#List 2 is where tup2 from, check if there is same id with tup2 
#in list2 which overlapped
def noOverlap(list1,tup2,list2):
    mycourse = list()
    mycourse.append(tup2)
    course2,cid2,ctype2,day2,start2,end2,hours2 = tup2

    for tup1 in list1:
        course1,cid1,ctype1,day1,start1,end1,hours1 = tup1
        if (day1 == day2):
            if (start1 == start2 or end1 == end2 or (start1 < start2 and end1 > end2) or (start1 > start2 and end1 < end2)):
                return False
    for tup1 in list2:
        course1,cid1,ctype1,day1,start1,end1,hours1 = tup1
        if (cid1 == cid2 and day1 == day2 and tup1 != tup2):
            if (start1 == start2 or end1 == end2 or (start1 < start2 and end1 > end2) or (start1 > start2 and end1 < end2)):
                return False
    return True

#Find the maximum wait time for each day, 
#return the day has max waiting time -> try to fill that first
#Updated is the list of sorted tuples
#this step is done after set up lecture time
def findwaittime(Updated,myday):
    waittime = dict()
    myday = sortmyday(myday)
    maxtime = 0
    maxday = ''
    for DAY in myday:
        waittime = 0
        total_hour = 0
        x = 0
        for tup in Updated:
            course,cid,ctype,day,start,end,hours = tup    
            if day == DAY:
                if x == 0:
                    START = start
                total_hour = total_hour+hours
                x = x + 1
                END = end
                
        waittime = (END-START)/100-total_hour
        #print("LOOPING:",DAY,waittime)
        if waittime > maxtime:
            maxtime = waittime
            maxday = DAY
            #print("Maxdday",maxday,maxtime)

    return maxday
    
if len(sys.argv) == 2 :
    query = cur1.mogrify(query,[course1])
    cur1.execute(query)
    for tup in cur1.fetchall():   
        mylist.append(tup) 
    #Find earlist lecture
    for tup in mylist:    
        course,cid,ctype,day,start,end,hours = tup            
        if (ctype == "Lecture"):
            if (ctype not in myclasstype):
                lectureid = cid
                myclasstype.append(ctype)
                total_hour = total_hour + hours      
                mycourse.append(tup)
                if day not in myday:
                    myday.append(day)
                    nday = nday+1
            elif (ctype in myclasstype and cid == lectureid):
                total_hour = total_hour + hours      
                mycourse.append(tup)
                if day not in myday:
                    myday.append(day)
                    nday = nday+1
            if LectureTime.get(day) == None:
                LectureTime[day] = start,end
                            
    #count for wait time 
    tutid = 0 
    myclasstype = list()
    minimum = 5
    for key in LectureTime.keys():
        START,END = LectureTime[key] 
        for tup in mylist:       
            #print(key,LectureTime[key])
            course,cid,ctype,day,start,end,hours = tup
            if (day == key and ctype != 'Lecture' and start is not None):
                waittime = min(abs((start-END)/100),abs((end-START)/100))
                #find minimin waiting time
                #print(waittime)
                if (minimum > waittime):
                    minimum = waittime
                    tutid = cid
                    if (minimum == 0):
                        break
    for tup in mylist:        
        course,cid,ctype,day,start,end,hours = tup
        if (cid == tutid):
            myclasstype.append(ctype)
            myclassid.append(cid)
            mycourse.append(tup)
            total_hour = total_hour + hours


elif len(sys.argv) == 3 :    
    query1 = cur1.mogrify(query,[course1]) 
    query2 = cur2.mogrify(query,[course2])
    cur1.execute(query1)
    cur2.execute(query2)
    for tup in cur1.fetchall():   
        mylist1.append(tup)
    for tup in cur2.fetchall():   
        mylist2.append(tup) 
    count_lecstream1 = list()
    count_lecstream2 = list()
    for tup in mylist1:    
        course,cid,ctype,day,start,end,hours = tup            
        if (ctype == "Lecture" and day is not None and cid not in count_lecstream1):
            
            count_lecstream1.append(cid)

    for tup in mylist2:    
        course,cid,ctype,day,start,end,hours = tup            
        if (ctype == "Lecture" and day is not None and cid not in count_lecstream2):
            count_lecstream2.append(cid)

    #find which course has less choice of lecture stream
    nlec1 = len(count_lecstream1)
    nlec2 = len(count_lecstream2)
    #print(nlec1,nlec2,count_lecstream1,count_lecstream2)
    #If course1 has single lecture stream
    if (nlec1 == 1 or nlec1 <= nlec2 or nlec1 == 0 or nlec2 == 0):
        #=== COURSE 1 LECTURE ===
        for tup in mylist1:    
            course,cid,ctype,day,start,end,hours = tup            
            if (ctype == "Lecture"):
                if (ctype not in myclasstype):
                    lectureid = cid
                    myclasstype.append(ctype)
                    mycourse.append(tup)
                    if day not in myday:
                        myday.append(day)
                        LectureTime1[day] = start,end
                elif (cid == lectureid and day not in myday):
                    mycourse.append(tup)
                    myday.append(day)
                    LectureTime1[day] = start,end
        #=== COURSE 2 LECTURE ===
        myclasstype1 = list()
        #print("xxx",myday)
        for key in LectureTime1.keys():
            for tup in mylist2:       
                course,cid,ctype,day,start,end,hours = tup            
                if (ctype == "Lecture" and ctype not in myclasstype1):
                    if (day == key):
                        lectureid = cid
                        mycourse.append(tup)
                        myclasstype1.append(ctype)
                        LectureTime2[day] = start,end
            for tup in mylist2:  
                course,cid,ctype,day,start,end,hours = tup
                if (cid == lectureid and tup not in mycourse):
                    #print(tup)
                    mycourse.append(tup)
                    myday.append(day)
                    LectureTime2[day] = start,end
        #print ("My Lecture",LectureTime2)
    #============================================================      
    else:   
        #=== COURSE 2 LECTURE === 
        for tup in mylist2:    
            course,cid,ctype,day,start,end,hours = tup            
            if (ctype == "Lecture"):
                if (ctype not in myclasstype):
                    lectureid = cid
                    total_hour = total_hour + hours     
                    myclasstype.append(ctype) 
                    mycourse.append(tup)
                    if day not in myday:
                        myday.append(day)
                        LectureTime2[day] = start,end
                elif (cid == lectureid and day not in myday):
                    total_hour = total_hour + hours      
                    mycourse.append(tup)
                    myday.append(day)
                    LectureTime2[day] = start,end
        myclasstype1 = list()
        #=== COURSE 1 LECTURE ===
        for key in LectureTime2.keys():
            for tup in mylist1:       
                course,cid,ctype,day,start,end,hours = tup            
                if (ctype == "Lecture" and ctype not in myclasstype1):
                    if (day == key):
                        lectureid = cid
                        mycourse.append(tup)
                        myclasstype1.append(ctype)
                        LectureTime1[day] = start,end
                elif (cid == lectureid):
                    mycourse.append(tup)
                    myday.append(day)
                    LectureTime1[day] = start,end

        #print ("My Lecture",LectureTime1)
    
    
    #===== Check Lecture time =====
    #print("CHECK: ",LectureTime1)
    #print("CHECK: ",LectureTime2)
    myclasstype = list()
    minimum = 5
    Lectureday = list()
    #Check for Lecture Clashing
    for key2 in LectureTime2.keys():
        START2,END2 = LectureTime2[key2] 
        Lectureday.append(key2)
        for key1 in LectureTime1.keys():
            START1,END1 = LectureTime1[key1] 
            Lectureday.append(key1)
            if (key1 == key2):
                if (START1 == START2 or END1 == END2 or (START1 < START2 and END1 > END2) or (START1 > START2 and END1 < END2)):
                    HasTimetable = False
                    #print(LectureTime1[key1])
                    #print(LectureTime2[key2])
                    break
                
    #Sort Lecture Days
    m = {'Fri': 4, 'Thu': 3, 'Wed': 2, 'Tue': 1, 'Mon': 0}
    Lectureday = sorted(Lectureday, key=m.get)
    Lectureday = list(dict.fromkeys(Lectureday))

    #===== Find NON-Lecture For Class1 =====
    #SWAP lists -- choose non-lecture for less choice course first
    if nlec1 < nlec2:
        tmplist = list()
        tmplist = mylist1
        mylist1 = mylist2
        mylist2 = tmplist
        #print("swap")
    mytutid = list() 
    UpdatedTime = dict()
    UpdatedTime = UpdateDayTime(mycourse, myday)
    for class1 in UpdatedTime:
        #print(class1)
        course1,cid1,ctype1,day1,START,END,hours1 = class1    
        for tup in mylist1:       
            course,cid,ctype,day,start,end,hours = tup
            if (day == day1 and ctype not in myclasstype and ctype != 'Lecture' and start is not None):
                waittime = min(abs((start-END)/100),abs((end-START)/100))                   
                if (minimum > waittime):
                    minimum = waittime
                    #Found class with 0 waiting time
                    if (minimum == 0):
                        mytutid.append(cid)
                        myclasstype.append(ctype)
                        minimum = 5
                        #Connect after lecture
                        if (start == END):
                            END = end
                        #Connect before lecture
                        elif (end == START):
                            START = start
    #print("xxx",myclasstype)
    for tup in mylist1:
        course,cid,ctype,day,start,end,hours = tup
        for tutid in mytutid:
            if (cid == tutid):
                mycourse.append(tup)
   
    UpdatedTime = UpdateDayTime(mycourse, myday)
   #===== Find NON-Lecture For Class2 =====
    minimum = 5
    mytutid = list()
    myclasstype = list()
    for class1 in UpdatedTime:
        #print("UpdatedTime:",class1)
        course1,cid1,ctype1,day1,START,END,hours1 = class1
        for tup in mylist2:       
            course,cid,ctype,day,start,end,hours = tup
            if (day == day1 and ctype not in myclasstype and ctype != 'Lecture' and start is not None):
                if noOverlap(UpdatedTime,tup,mylist2): 
                   # print("nooverlap:",tup)                          
                    waittime = min(abs((start-END)/100),abs((end-START)/100))
                    #find minimin waiting time
                    if (minimum > waittime):
                        minimum = waittime
                        #print(tup)
                        #Found class with 0 waiting time
                        if (minimum == 0):
                            mytutid.append(cid)
                            myclasstype.append(ctype)
                            minimum = 5
                            #Connect after lecture
                            if (start == END):
                                END = end
                            #Connect before lecture
                            elif (end == START):
                                START = start
    for tup in mylist2:        
        course,cid,ctype,day,start,end,hours = tup
        for tutid in mytutid:
            if (cid == tutid):
                myclasstype.append(ctype)
                myclassid.append(cid)
                mycourse.append(tup)

elif len(sys.argv) == 4 : 
    if len(sys.argv) > 0: #this if should be deleted!!!!!
        query1 = cur1.mogrify(query,[course1]) 
        query2 = cur2.mogrify(query,[course2])
        query3 = cur2.mogrify(query,[course3])
        cur1.execute(query1)
        cur2.execute(query2)
        cur3.execute(query3)
        for tup in cur1.fetchall():   
            mylist1.append(tup)
        for tup in cur2.fetchall():   
            mylist2.append(tup)
        for tup in cur3.fetchall():   
            mylist3.append(tup)     
        count_lecstream1 = list()
        count_lecstream2 = list()
        count_lecstream3 = list()
        for tup in mylist1:    
            course,cid,ctype,day,start,end,hours = tup            
            if (ctype == "Lecture" and day is not None and cid not in count_lecstream1):
                count_lecstream1.append(cid)
        for tup in mylist2:    
            course,cid,ctype,day,start,end,hours = tup
            if (ctype == "Lecture" and day is not None and cid not in count_lecstream2):
                count_lecstream2.append(cid)   
        for tup in mylist3:    
            course,cid,ctype,day,start,end,hours = tup        
            if (ctype == "Lecture" and day is not None and cid not in count_lecstream3):
                count_lecstream3.append(cid)
        #find which course has less choice of lecture stream
        nlec1 = len(count_lecstream1)
        nlec2 = len(count_lecstream2)
        nlec3 = len(count_lecstream3)
        #print(nlec1,count_lecstream1)
        #print(nlec2,count_lecstream2)
        #print(nlec3,count_lecstream3)
    #If all 3 lectures have single lecture stream
    if (nlec1 <= nlec2 <= nlec3 or nlec1 == 0 or nlec2 == 0 or nlec3 == 0):
       #=== COURSE 1 LECTURE ===
        for tup in mylist1:    
            course,cid,ctype,day,start,end,hours = tup            
            if (ctype == "Lecture"):
                if (ctype not in myclasstype):
                    lectureid = cid
                    myclasstype.append(ctype)
                    mycourse.append(tup)
                    if day not in myday:
                        myday.append(day)
                        LectureTime1[day] = start,end
                elif (cid == lectureid):
                    mycourse.append(tup)
                    myday.append(day)
                    LectureTime1[day] = start,end
        #=== COURSE 2 LECTURE ===
        myclasstype = list()
        for tup in mylist2:    
            course,cid,ctype,day,start,end,hours = tup  
            if (ctype == "Lecture"):
                if (ctype not in myclasstype):
                    lectureid = cid
                    myclasstype.append(ctype)
                    mycourse.append(tup)
                    if day not in myday:
                        myday.append(day)
                        LectureTime2[day] = start,end
                elif (cid == lectureid):
                    mycourse.append(tup)
                    myday.append(day)
                    LectureTime2[day] = start,end        
        #=== COURSE 3 LECTURE ===
        myclasstype = list()
        for tup in mylist3:    
            course,cid,ctype,day,start,end,hours = tup            
            if (ctype == "Lecture"):
                if (ctype not in myclasstype):
                    lectureid = cid
                    myclasstype.append(ctype)
                    mycourse.append(tup)
                    if day not in myday:
                        myday.append(day)
                        LectureTime3[day] = start,end
                elif (cid == lectureid):
                    mycourse.append(tup)
                    myday.append(day)
                    LectureTime3[day] = start,end

    #===== Find NON-Lecture For Class1 =====
    mytutid = list()
    myclasstype = list()
    minimum = 5.0
    UpdatedTime = dict()
    UpdatedTime = UpdateDayTime(mycourse, myday)
    maxday = findwaittime(UpdatedTime, myday)
    #print("Max waitting day1: ", maxday)
    overlap = list()
    for class1 in UpdatedTime:
        course1,cid1,ctype1,day1,START,END,hours1 = class1    
        for class1 in mylist1:       
            course,cid,ctype,DAY,start,end,hours = class1
            if noOverlap(UpdatedTime,class1,mylist1):       
                if(DAY == maxday and start is not None): 
                    waittime = min(abs((start-END)/100),abs((end-START)/100))
                    if (ctype not in myclasstype and ctype != 'Lecture'):
                        if (minimum > waittime):
                            minimum = waittime
                            #Found class with 0 waiting time
                            if (minimum == 0):
                                mytutid.append(cid)
                                myclasstype.append(ctype)
                                minimum = 5
                                #Connect after lecture
                                if (start == END):
                                    END = end
                                #Connect before lecture
                                elif (end == START):
                                    START = start
            else:
                overlap.append(cid)
    UpdatedTime = UpdateDayTime(mycourse,myday)                                        
    for class1 in UpdatedTime:
        #print(class1)
        course1,cid1,ctype1,day1,START,END,hours1 = class1    
        for class1 in mylist1:       
            course,cid,ctype,DAY,start,end,hours = class1
            if noOverlap(UpdatedTime,class1,mylist1):                
                if(DAY == day1 and cid not in overlap):
                    waittime = min(abs((start-END)/100),abs((end-START)/100))
                    #print(waittime,minimum)
                    if (ctype not in myclasstype and ctype != 'Lecture'):
                        if (minimum > waittime):
                            minimum = waittime
                            #print(waittime,class1)
                            #Found class with 0 waiting time
                            if (minimum == 0):
                                #print(class1)
                                mytutid.append(cid)
                                myclasstype.append(ctype)
                                minimum = 5
                                #Connect after lecture
                                if (start == END):
                                    END = end
                                #Connect before lecture
                                elif (end == START):
                                    START = start
    #print("xxx",myclasstype)
    for tup in mylist1:
        course,cid,ctype,day,start,end,hours = tup
        for tutid in mytutid:
            if (cid == tutid):
                mycourse.append(tup)
    
    UpdatedTime = UpdateDayTime(mycourse,myday)
    #===== Find NON-Lecture For Class2 =====
    minimum = 5
    mytutid = list()
    myclasstype = list()
    maxday = findwaittime(UpdatedTime, myday)
    #print("Max waitting day2: ", maxday)
    overlap = list()
    for class1 in UpdatedTime:
        course1,cid1,ctype1,day1,START,END,hours1 = class1
        for class2 in mylist2:  
            course,cid,ctype,day,start,end,hours = class2
            if noOverlap(UpdatedTime,class2,mylist2): 
                #print("XXX",class2)

                if(day == maxday):
                    waittime = min(abs((start-END)/100),abs((end-START)/100))
                    if (ctype not in myclasstype and ctype != 'Lecture'):
                        #find minimin waiting time
                        if (minimum > waittime):
                            minimum = waittime
                            #Found class with 0 waiting time
                            if (minimum == 0):
                                #print("FOUND",class2)
                                mytutid.append(cid)
                                myclasstype.append(ctype) 
                                #If there is other classtype
                                minimum = 5
                                #Connect after lecture
                                if (start == END):
                                    END = end
                                #Connect before lecture
                                elif (end == START):
                                    START = start  
            else:
                overlap.append(cid)
    
    UpdatedTime = UpdateDayTime(mycourse,myday)                            
    for class1 in UpdatedTime:
        course1,cid1,ctype1,day1,START,END,hours1 = class1
        for class2 in mylist2:  
            course,cid,ctype,day,start,end,hours = class2
            if noOverlap(UpdatedTime,class2,mylist2):                 
                if(day1 == day and start is not None and cid not in overlap):
                    waittime = min(abs((start-END)/100),abs((end-START)/100))
                    if (ctype not in myclasstype and ctype != 'Lecture'):
                        #find minimin waiting time
                        if (minimum > waittime):
                            minimum = waittime
                            #print("xx",class2)
                            #Found class with 0 waiting time
                            if (minimum == 0):
                                #print("FOUND",tup)
                                mytutid.append(cid)
                                myclasstype.append(ctype)
                                #If there is other classtype
                                minimum = 5
                                #Connect after lecture
                                if (start == END):
                                    END = end
                                #Connect before lecture
                                elif (end == START):
                                    START = start
                            

    for tup in mylist2:        
        course,cid,ctype,day,start,end,hours = tup
        for tutid in mytutid:
            if (cid == tutid):
                #print("COMP1531:",tup)
                myclasstype.append(ctype)
                mycourse.append(tup)
    
    #===== Find NON-Lecture For Class3 =====
    minimum = 5
    mytutid = list()
    myclasstype = list()
    UpdatedTime = UpdateDayTime(mycourse,myday)
    maxday = findwaittime(UpdatedTime, myday)
    #print("Max waitting day3: ", maxday)
    overlap = list()
    for class1 in UpdatedTime:
        course1,cid1,ctype1,day1,START,END,hours1 = class1
        for class2 in mylist3:  
            course,cid,ctype,day,start,end,hours = class2
            if (day == maxday and start is not None):

                if noOverlap(UpdatedTime,class2,mylist3): 
                    waittime = min(abs((start-END)/100),abs((end-START)/100))
                    if (ctype not in myclasstype and ctype != 'Lecture'):
                        #print("nooverlap",class2,myclasstype)
                        #find minimum waiting time
                        if (minimum > waittime):
                            minimum = waittime
                            #print("xx",class2, minimum)
                            #print("start-END:",(start-END),"end-START:",(end-START))
                            #Found class with 0 waiting time
                            if (minimum == 0):
                                #print("FOUND",class2)
                                mytutid.append(cid)
                                myclasstype.append(ctype)
                                #If there is other classtype
                                minimum = 5
                                #Connect after lecture
                                if (start == END):
                                    END = end
                                #Connect before lecture
                                elif (end == START):
                                    START = start
                overlap.append(cid)
    UpdatedTime = UpdateDayTime(mycourse,myday)                            
    for class1 in UpdatedTime:
        course1,cid1,ctype1,day1,START,END,hours1 = class1
        #print("XXX",class1)
        for class2 in mylist3:  
            course,cid,ctype,day,start,end,hours = class2
            if noOverlap(UpdatedTime,class2,mylist3) and cid not in overlap: 
                if(day1 == day):
                    #print("nooverlap:",class2)      
                    waittime = min(abs((start-END)/100),abs((end-START)/100))
                    if (ctype not in myclasstype and ctype != 'Lecture'):
                        #print(ctype,course)
                        #find minimum waiting time
                        if (minimum > waittime):
                                    minimum = waittime
                                    #print("xx",class2)
                                    #Found class with 0 waiting time
                                    if (minimum == 0):
                                        #print("FOUND",class2)
                                        mytutid.append(cid)
                                        myclasstype.append(ctype)
                                        #If there is other classtype
                                        minimum = 5
                                        #Connect after lecture
                                        if (start == END):
                                            END = end
                                        #Connect before lecture
                                        elif (end == START):
                                            START = start
                                

    for tup in mylist3:        
        course,cid,ctype,day,start,end,hours = tup
        for tutid in mytutid:
            if (cid == tutid):
                #print("COMP2521:",tup)
                myclasstype.append(ctype)
                mycourse.append(tup)

 


#====================================
myday = sortmyday(myday)
nday = len(myday)
#print(nday)
UpdatedTime = dict()
UpdatedTime = SummaryDayTime(mycourse)
total_hour = 0
for key in UpdatedTime:
    start,end = UpdatedTime[key]
    for day in myday:
        if (key == day):
            hours = (end-start)/100
            total_hour = total_hour + hours

total_hour = total_hour+nday*2
if re.match("([0-9]+).3$",str(total_hour)):
        total_hour = str(total_hour).replace(".3",".5")
if HasTimetable == False :
    print(total_hour,"hours, but clashing timetable")
else:
    print("Total hours:",format(float(total_hour), '.1f'))
    printcourse(mycourse,myday)
        




cur1.close()  
cur2.close()
cur3.close()
conn.close()