import psycopg2
from psycopg2 import extensions as ext
import os
from datetime import datetime

#Select folder to read .csv files
folder = "D:/bouzas/Desktop/CSV"

#Database credentials
host = "localhost"
database = "wegen"
user = "postgres"
password = "postgres"

#Table Name
tableName = "meas"

#SQL Forbidden Characters
#Not all characters are allowed in SQL. Enlist any forbidden characters
#by adding the characters in the following string
chars = "-"

#Connect to PostgreSQL
def connect():
    conn = None
    try:
        #Connect to the PostgreSQL server
        print("Connecting to the PostgreSQL database...")
        conn = psycopg2.connect(host=host,
                                database=database,
                                user=user,
                                password=password)
        
        #Create cursor
        cur = conn.cursor()
        print("Connection was successful... \n")
        return conn, cur
        
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
#Read type
tests = [(int,int),
         (float, float),
         (datetime, lambda value: datetime.strptime(value, "%Y-%m-%d"))] #Date 2013-08-02

def getType(value):
     for typ, test in tests:
         try:
             test(value)
             return typ
         except ValueError:
             continue
     # No match
     return str
 
#Read .csv fields/types
def tableFields(fil):
    fileName = folder + "/" + fil
    f = open(fileName, 'r')
    
    #Read fields
    fields = f.readline().strip().split(",")
    
    #Read types
    values = f.readline().strip().split(",")
    
    types = []
    for value in values:
        typ = getType(value)
        types.append(typ)
            
    f.close()
    return fields, types

#Read CSV
def readCSV(fil):
    fileName = folder + "/" + fil
    f = open(fileName, 'r')
    return f

if __name__ == "__main__":   
    #Establish connection to database
    conn, cur = connect()
    
    #Define fields/types
    fil = os.listdir(folder)[0] #All files have same fields and types
    fields, types = tableFields(fil)
    
    #Create tables for files
    createQuery = "CREATE TABLE {} (".format(tableName)
    for field, typ in zip(fields, types):
        if typ == int:
            createQuery += field + " INTEGER,"
        elif typ == float:
            createQuery += field + " FLOAT,"
        elif typ == str:
            createQuery += field + " VARCHAR(50),"
        elif typ == datetime:
            createQuery += field + " DATE,"
    cur.execute(createQuery[:-1] + ");")
        
    #Insert data into table
    insertQuery = "INSERT INTO {} (".format(tableName)
    insertFields = ",".join(fields) #Fields to be updated
    insertQuery += insertFields + ") VALUES ("
    
    #Insert fields
    files = os.listdir(folder)
    numFiles = len(files)
    num = 1
    for fil in files:
        print("Inserting data from file ({}/{}): {}".format(num, numFiles,fil))
        f = readCSV(fil)
        f.readline() #Skip fields
        
        #Insert values
        line = f.readline().strip().split(",")
        while line[0]:
            values = []
            insertData = ""
            for word,typ in zip(line, types):
                if typ != datetime: #Dates remain untouched
                    for char in chars:
                        word = word.replace(char,"") #Remove forbidden characters
                
                #Compensate for non-existing values
                if word == "":
                    values.append("NULL")
                else:
                    values.append("'{}'".format(word))
                    
            insertData = insertQuery + ",".join(values) + ");" #Execute query
            cur.execute(insertData)
            
            line = f.readline().strip().split(",") #Proceed reading
        
        num += 1
        print("File processing finished... \n")
        f.close()
    
    print("Processing finished.End of program")
    cur.close()
    conn.commit()
    conn.close()