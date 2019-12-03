import csv # import the python csv library 

testfilepath = 'd:\\test2.csv'

# Create a CSV file
with open(testfilepath, 'wb') as csvfile: # create the file test2.csv
    writer = csv.writer(csvfile, delimiter=',') # create writer
    
    # write values
    writer.writerow(["name", "Number"])
    writer.writerow(["a", 10])
    writer.writerow(["b", 20])

#Read a CSV file
with open(testfilepath) as csvfile: # open the file test2.csv
    lines = csv.reader(csvfile, delimiter=',') # read lines as collection of arrays

    # print all values
    for line in lines:
        for field in line:
            print field
