import os
import csv
import xlrd

#Directory where xlsx files are located
directory = "D:/bouzas/Desktop/Data/Measurements/RW11RW12RW27"

#Select folder to save .csv files
folder = "D:/bouzas/Desktop/CSV"

#Traverse and convert all .xlsx files
for root, dirs, files in os.walk(directory):
    numFiles = len(files)
    print("#-----------#")
    print("Directory " + root)
    print("Processing: " + str(numFiles) + " files \n")
    
    processed = 0
    for fil in files:
        if fil.endswith(".xlsx"):
            fileName = fil[:-5] #Remove .xlsx
            csvName = folder + "/" + fileName + ".csv"

            #Open .csv file
            f = open(csvName, "wb")
            wf = csv.writer(f, delimiter = ",")
            
            #Convert .xlxs to .csv
            workbook = xlrd.open_workbook(root + "/" + fil)
            sheet = workbook.sheet_by_index(0)
            for row in range(sheet.nrows):
                wf.writerow(sheet.row_values(row))
            
            processed += 1
            print("Completed: " + fileName)
            print("Files processed: " + str(processed) + "/" + str(numFiles) + "\n")
            
            f.close()

print("#-----------#")          
print("Conversion completed. End of program")
            
        

