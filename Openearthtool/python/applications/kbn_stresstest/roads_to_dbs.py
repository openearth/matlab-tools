import psycopg2
import numpy as np

#Database credentials
host = "localhost"
database = "wegen"
user = "postgres"
password = "postgres"

#Input Table
inputTable = "wegvakken"

#Output Table
outputTable = "aran_wegen"

#Roads
roads = {'RW11', 'RW12', 'RW27'}
#Road sides (baan)
sides = {'L', 'R'}

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
        
#Form SQL query
#wegnr_aw = road code, rpe_code = baan, bst_code = HR
def formQuery(inputTable, road, side):
    sqlQuery = """SELECT wegnr_aw, rpe_code, ST_AsText(ST_LineMerge(ST_Union(geom)))
                  FROM {}
                  WHERE wegnr_aw = '{}'
                  AND bst_code = 'HR'
                  AND rpe_code = '{}'
                  GROUP BY wegnr_aw, rpe_code
                  ;""".format(inputTable, road, side)
    return sqlQuery

#Execute SQL query       
def execute(sqlQuery, cur):
    try:
        cur.execute(sqlQuery)
        data = cur.fetchall()
        #print("Entries recovered: {}".format(len(data)))
        return data
    except Exception as e:
        print("Query unsuccessful..")
        print(e)
        
#Create table in PostgreSQL
def createTable(cur):
    try:
        create = """CREATE TABLE {} (
                    naam VARCHAR(10),
                    baan VARCHAR(10)
                    );""".format(outputTable)
        cur.execute(create)
        
        addGeometry = """SELECT AddGeometryColumn(
                         '{}', 'geom', 28992, 'LINESTRING', 2);""".format(outputTable)
        cur.execute(addGeometry)
        
        print("Table created...")
    except Exception as e:
        print('Table not created...')
        print(e)

#Load data to table
def updateTable(geoms, cur):
    try:
        for geo in geoms:
            naam, baan, geom = geo[0][0], geo[0][1], geo[0][2]
            update = """INSERT INTO {}
                        (naam, baan, geom)
                        VALUES ('{}', '{}', ST_GeomFromText('{}', 28992))""".format(outputTable, naam, baan, geom)
            cur.execute(update)
        print('Table updated...')
    except Exception as e:
        print('Table not updated...')
        print(e)
        
if __name__ == "__main__":
    conn, cur = connect()
    
    geoms =[]
    for road in roads:
        for side in sides:
            sqlQuery = formQuery(inputTable, road, side)
            geom = execute(sqlQuery, cur)
            geoms.append(geom)
 
    createTable(cur)
    updateTable(geoms, cur)
    
    cur.close()
    conn.commit()
    conn.close()
    
    

