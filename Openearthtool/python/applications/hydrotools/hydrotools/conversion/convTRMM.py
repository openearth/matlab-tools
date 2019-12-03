# convTRMM.py
# Reads TRMM 3B42 RT 3-hr data and converts to rain depths (mm/3hr) in arc/ascii format

# import relevant packages
import logging
import logging.handlers
from numpy import *
from scipy import *
from struct import unpack
import string
import sys,  gzip, os, os.path
import ftplib
"""
This convTRMM.py script retrieves and converts TRMM (3842RT) data
It takes the following arguments:
1) Maximum number of files (last by date) to retrieve
2) directory to store the retrived (raw) data
3) directory to store the concerted files in asc ASCII format suitable for
import into Delft-FEWS
4) path to the logfile of this program

For each file it retrieves the program will check if it already resides in the
raw data directory. If that is the case the file is not downloaded and the next 
file is processed
"""



def get_TRMM(nr_LastFiles,unzip,verbose,convert,bindir,convdir):
	"""
	def get_TRMM(nr_LastFiles,unzip,verbose):
	
	Wrapper function that sets the last "nr_LastFiles" of the mergeIRMicro 
	product.
	- If unzip is True also unzip the retrieved file(s) and delete the 
	originals
	- If verbose is True print progress information
	- If convert is True convert to ArcAscii
	- bindir: store retrives files here
	- convdir: store converted files here
	"""
	
	def handleDownload(block):
		file.write(block)
		
	
	# Create an instance of the FTP object
	# Optionally, you could specify username and password:
	# FTP('hostname', 'username', 'password')
	ftp = ftplib.FTP('trmmopen.gsfc.nasa.gov')
	
	
	# Log in to the server
	logger.info("logging in")
	# You can specify username and password here if you like:
	# ftp.login('username', 'password')
	# Otherwise, it defaults to Anonymous
	try:
		tmp = ftp.login()
	except ftplib.all_errors:
		logger.error('Problem during login')
		sys.exit(2)
		
	logger.debug(tmp)
		
	# This is the directory that we want to go to
	directory = '/pub/merged/mergeIRMicro/'
	# Let's change to that directory.  You kids might call these 'folders'
	logger.debug('Changing to ' + directory)
	ftp.cwd(directory)
	
	# Print the contents of the directory
	try:
		filenames = ftp.nlst('*.gz')
	except ftplib.all_errors:
		logger.error('Problem getting file list')
		sys.exit(2)
		
	filenames.sort()

	for filename in filenames[max(0,len(filenames)-nr_LastFiles):len(filenames)]:
		
		storename = bindir + "/" + filename
		print storename
		
		
		if os.path.exists(storename):
			if (os.path.getsize(storename) < 80000):
				os.unlink(storename)
		if os.path.exists(storename) or os.path.exists(os.path.splitext(storename)[0]):
			logger.debug("skipping " + storename)
		else:
			logger.debug('Opening local file ' + filename)
			try:
				file = open(storename, 'wb')
			except IOError:
				logger.error('Could not open local filename: ' + storename)
				sys.exit(2)
			# 
			# # Download the file a chunk at a time
			# # Each chunk is sent to handleDownload
			# # We append the chunk to the file and then print a '.' for progress
			# # RETR is an FTP command
			logger.debug('Getting ' + filename)
			
			try:
				ftp.retrbinary('RETR ' + filename, handleDownload)
			except:
				logger.error('Problem retrieving file, deleting it')
				file.close()
				os.unlink(storename)
				sys.exit(2)
			
			# 
			# Clean up time
			logger.debug('\nClosing file ' + filename)
			file.close()
			if unzip:
				logger.debug('UnZipping ' + storename)
				Gunzip(storename)
				if convert:
					storename = os.path.splitext(storename)[0]
					logger.debug('Converting ' + storename)
					convert_TRMM(storename,"RAIN",True,convdir,verbose)
		
	logger.info('Closing FTP connection')
	ftp.close()
	
	
def getfiles(dirpath):
    a = [s for s in os.listdir(dirpath)
         if os.path.isfile(os.path.join(dirpath, s))]
    a.sort(key=lambda s: os.path.getmtime(os.path.join(dirpath, s)))
    return a

def Gunzip(file):
        '''Gunzip the given file.'''
        r_file = gzip.GzipFile(file, 'rb')
        write_file = string.rstrip(file, '.gz')
        w_file = open(write_file, 'wb')
        w_file.write(r_file.read())
        w_file.close()
        r_file.close()
        os.unlink(file) # Yes this one too.

        
            
def convert_TRMM(FileName,product,zipit,outputdir,verbose):
	""" Converts FileNname from TRMM to ArcAscii format
	suitable for import into Delft-FEWS
	- if zipit is True the resulting file will be gzipped and
	the uncompressed file will be deleted
	- outdir: created converted files here"""
	
	# Processing
	fn = os.path.basename(FileName)
	
	Date = fn[7:17]
	
	# Open file for binary-reading
	try:
		ffile  = open(FileName,'rb>')
	except IOError:
		logger.error('Cannot open local file for converting: ' + FileName)
		sys.exit(2)
		
	header = ffile.read(2880)
	
	headerlist = string.split(header,' ')
		
	data = fromfile(ffile, dtype='>h', count=691200) # >h means 2-byte signed integer, big-endian
	
	ffile.close()
	
	
	# Reshape data to correct format
	mat  = reshape(data, (480,-1))
	newmat = zeros([480,1440])
	#newmat[:] = array
	# Reshape array from 0 to 360 long, to -180 to 180 long.
	newmat[:,0:720] = mat[:,720:1440]
	newmat[:,720:1440] = mat[:,0:720]
	# convert from 0.01 mm/hr to mm/3hr (depth over whole time step)
	newmat = newmat*0.01*3
	
	# All values < 0 are given NaN value
	newmat[newmat < 0] = -9999
	
	# Create Output filename from (FEWS) product name and date and open for writing
	FileOut = outputdir + "/" + product + '_' + Date + '0000.asc'
	try:
		ffile = open(FileOut,'w')
	except IOError:
		logger.error('Cannot open arcascii file for writing: ' + FileOut)
		sys.exit(2)
		
	# Write header + data to file
	ffile.write('NCOLS 1440\n')
	ffile.write('NROWS 480\n')
	ffile.write('XLLCORNER -180\n')
	ffile.write('YLLCORNER -60\n')
	ffile.write('CELLSIZE 0.25\n')
	ffile.write('NODATA_value -9999\n')
	# Now use numpy's save routine to save the body of the data
	savetxt(ffile,newmat,fmt='%3.2f',delimiter=' ')
	ffile.close()

	
	
# Command line arguments
#1: nr of files
#2: backup directory
#3: Fews_import

# standard operation is to get the last 10 files and decompress them

if len(sys.argv) < 5:
	print "Usage: convTRMM max_nr_of_files_to_get backup_dir fews_import_dir"
else:
	logfile= sys.argv[4]
	#create logger
	logger = logging.getLogger("convTRMM")
	logger.setLevel(logging.DEBUG)
	#create console handler and set level to debug
	ch = logging.handlers.RotatingFileHandler(logfile,maxBytes=200000, backupCount=5)
	console = logging.StreamHandler()
	console.setLevel(logging.DEBUG)
	ch.setLevel(logging.DEBUG)
	#create formatter
	formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
	#add formatter to ch
	console.setFormatter(formatter)
	ch.setFormatter(formatter)
	#add ch to logger
	logger.addHandler(ch)
	logger.addHandler(console)
	get_TRMM(int(sys.argv[1]),True,True,True,sys.argv[2],sys.argv[3])
	exit(0)


