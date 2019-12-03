# Description: This script clean's up (deletes) files older than a specific nr 
# of days

# Usage syntax:
# cleanup.py directory1 directory2 drirectoryn.. nr_of_days savemode
# if savemode is > 0 than the files are not deleted but listed


import os, sys, time

if len(sys.argv) < 4:
	print "usage: cleanup.py directory nr_of_days savemode"
	print "\tif savemode is > 0 than the files are not deleted but listed"
	exit(1)

path = sys.argv[1]
now = time.time()

for i in range(1,len(sys.argv) - 2):
	path = sys.argv[i]
	print path
	for f in os.listdir(path):
		if os.stat(os.path.join(path,f)).st_mtime < now - int(sys.argv[len(sys.argv) - 2]) * 86400:
			if os.path.isfile(os.path.join(path,f)):
				if int(sys.argv[len(sys.argv) -1]) > 0:
					print "not deleting " + os.path.join(path, f)
				else:
					os.remove(os.path.join(path, f))
				
