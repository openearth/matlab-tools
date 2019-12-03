def databaseConnect(postgres_db):
    from sqlalchemy import create_engine
    global engine
    engine = create_engine('postgresql+psycopg2://'+postgres_db['username']+':'+postgres_db['password']+'@'+postgres_db['host']+':'+str(postgres_db['port'])+'/'+postgres_db['database'], strategy='threadlocal')
    #return(engine)