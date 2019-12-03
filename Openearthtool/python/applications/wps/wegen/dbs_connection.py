import psycopg2
import numpy as np
import matplotlib.pyplot as plt

#Database credentials
host = "localhost"
database = "wegen"
user = "postgres"
password = "postgres"

#Table Name
tableName = "aran_schema"

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
def formQuery(inputs):
    sqlQuery = """SELECT meting, datum, vankm, totkm
                      FROM {}
                      WHERE naam = '{}'
                      AND baan = '{}'
                      AND strook = '{}'
                      AND code = '{}'
                      AND vankm >= {}
                      AND totkm <= {}
                      AND (datum BETWEEN '{}' AND '{}')
                      ORDER BY datum
                      ;""".format(*inputs)
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
        
#Plot
def plot(data):
    if data:
        array = np.array(data) #Convert to array
            
        #Plot results
        #Convert datetimes to labels
        dates = list(array[:,1])
        dateLabels = []
        for date in dates:
            dataLabel = str(date)
            dateLabels.append(dataLabel)
        plt.plot(dateLabels, array[:,0])
        
        #Design plot
        plt.title('WEG: {} - METING: {} \n VANKM: {} - TOTKM: {}'.format(naam, code, vankm, totkm))
        plt.xticks(dateLabels, dateLabels, rotation='vertical') #Rotate labels
        plt.xlabel('Datum')
        plt.ylabel('{}'.format(code))
        plt.show()
    else:
        print("No available data...")
        
if __name__ == "__main__":
    conn, cur = connect()
    
    #Query Inputs
    naam = 'RW11' #Road name
    baan = 'L' #Baan (L or R)
    strook = 'L' #Strook (L or R)
    code = 'IRI' #Measurement type
    dat1 = '2000-01-01'
    dat2 = '2018-01-01'
    
    #Measurement steps for each individual type
    steps = {'BGS':0.02,
             'DWH':0.02,
             'IRI':0.10,
             'LPR':0.01,
             'RAF':0.10,
             'RSD':0.10,
             'STR':0.10,
             'SWF':0.10}
    
    #From kilometer to kilometer
    start = round(0.36, 1) #From kilometer
    end = round(1.58, 1) #To kilometer
    
    for km in np.arange(start, end, steps[code]):
        vankm = km #From kilometer
        totkm = km + steps[code] #To kilometer
        inputs = (tableName,
                  naam,
                  baan,
                  strook,
                  code,
                  vankm,
                  totkm,
                  dat1,
                  dat2)
        
        sqlQuery = formQuery(inputs)           
        data = execute(sqlQuery, cur)
        plot(data)

    cur.close()
    conn.close()