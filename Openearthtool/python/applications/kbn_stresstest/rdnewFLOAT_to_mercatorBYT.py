import os
import glob

# Config
INDIR = r'C:\Users\wcp_w1903446\Desktop\roads_NL_talud_dist'
OUTDIR = r'C:\Users\wcp_w1903446\Desktop\roads_NL_talud_dist_3857'
if not os.path.exists(OUTDIR):
	os.mkdir(OUTDIR)

# Loop over tiff tiles
for filename in glob.iglob('{src}/*.tif'.format(src=INDIR), recursive=False):   
    src = os.path.join(INDIR, os.path.basename(filename))
    dst = os.path.join(OUTDIR, os.path.basename(filename))
    cmd = 'gdalwarp -co COMPRESS=LZW -co TILED=YES -ot \"Byte\" -t_srs epsg:3857 {} {}'.format(src, dst)
    print (cmd)
    os.system (cmd)