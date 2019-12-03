from Libraries.Utils.Project import *
import urllib2, base64, os
import requests

def _gettargetpath():
	from DeltaShell.Plugins.MorphAn.Domain import TransectLocation as _TransectLocation
	base_location = _TransectLocation().GetType().Assembly.Location.replace('DeltaShell.Plugins.MorphAn.Domain.dll','Data\\jrk\\')

	if not(os.access(base_location, os.W_OK)):
		raise Exception("Could not write in target directory, because access was denied.")
	
	return base_location

def _downloadfile(kustvak_name, targetdir, username, password):
	url="https://svn.oss.deltares.nl/repos/openearthrawdata/trunk/rijkswaterstaat/jarkus/raw/total/%s.txt" % (kustvak_name)
	
	req = urllib2.Request(url)
	if (password != None and username != None):
		req.add_header("Authorization", "Basic %s" % base64.encodestring('%s:%s' % (username, password)).replace('\n', ''))

	try :
		result=urllib2.urlopen(req)
	except :
		raise Eexception("Could not find or access source file. Please check your internet connection or credentials.")

	file_name = url.split('/')[-1]
	target_file = "%s\\%s" % (targetdir,file_name)
	full_target_file = target_file.replace(".txt",".jrk")

	with open(full_target_file, "wb") as local_file:
		local_file.write(result.read())
		local_file.close()

def get_all_files():
	url="https://svn.oss.deltares.nl/repos/openearthrawdata/trunk/rijkswaterstaat/jarkus/raw/total/"
	
    req = urllib2.Request(url)
    if (password != None and username != None):
		req.add_header("Authorization", "Basic %s" % base64.encodestring('%s:%s' % (username, password)).replace('\n', ''))
	
	response = urllib2.urlopen(req).read()
	
	import re
	files = []
	pattern = """<a\s+href=(?:"[^"]+"|'[^']+').*?>(.*?)</a>"""
for filename in re.findall(pattern,response):
	files.append(filename)

print len(files)
print files[3]

kustvak_names = [
	"Ameland",
	"Delfland",
	"Goeree",
	"Maasvlakte",
	"Noord-Beveland",
	"Noord-Holland",
	"Rijnland",
	"Schiermonnikoog",
	"Schouwen",
	"Terschelling",
	"Texel",
	"Vlieland",
	"Voorne",
	"Walcheren",
	"Zeeuws-Vlaanderen"]
	
username=None
password=None
# targetdir = _gettargetpath()
targetdir = "D:\\Test\Jarkus"

for kustvak in kustvak_names:
	PrintMessage("Downloading : " + kustvak)
	_downloadfile(kustvak, targetdir, username, password)