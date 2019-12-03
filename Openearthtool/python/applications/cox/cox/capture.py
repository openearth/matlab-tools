import os
import time
import cox
import logging

import numpy as np
from datetime import datetime, date

# image path options
camtype = 'c1'
root    = 'Z:/stream/'

interval = 600
isError  = False

# create root directory
if not os.path.exists(root):
    os.makedirs(root)

# determine current time
posix          = time.time()
posix_midnight = int(time.mktime(date.today().timetuple()))

# determine filenames
ncfile         = '%d.%s.temp.nc' % (posix_midnight, camtype)
logfile        = '%d.%s.temp.log' % (posix_midnight, camtype)

# initialize log
logging.basicConfig(filename=os.path.join(root, logfile), 
    format='%(asctime)s %(message)s [%(levelname)s]', level=logging.DEBUG)
logging.info('Log started')

try:

    # connect to camera
    cHandle, cTimerID = cox.connection.OpenConnect()

    logging.info('Connected to camera')

    try:

        # get image data
        t, n = cox.image.GetIRImageStream(cHandle, cTimerID, interval, 2)

        logging.info('Captured %d frames', n)
        
        # close connection
        cox.connection.CloseConnect(cHandle, cTimerID)
        
        logging.info('Closed connection to camera')

        try:

            logging.info('Using storage path %s', root)

            # update todays netCDF file
            logging.info('Appending to netCDF:')

            try:
                cox.netcdf.add_to_netcdf(os.path.join(root, ncfile), \
                    temperature=t['snap'],         \
                    temperature_timex=t['timex'],  \
                    temperature_min=t['min'],      \
                    temperature_max=t['max'],      \
                    temperature_var=t['var']         )

                logging.info('    %s', ncfile)
            except Exception as e:
                logging.warning('    NETCDF failed: %s', e.message)

            try:

                # write images to disk
                logging.info('Saving image files:')

                for imgtype, img in t.iteritems():
                    fname = '%d.%s.%s.png' % (posix, camtype, imgtype)

                    try:
                        img   = cox.plot.plot_image(img, filename=os.path.join(root, fname))
                        logging.info('    %s', fname)
                    except Exception as e:
                        logging.warning('    PLOT failed: %s', e.message)

            except Exception as e:
                logging.error('PLOT error: %s', e.message)
                isError = True
        except Exception as e:
            logging.error('NETCDF error: %s', e.message)
            isError = True
    except Exception as e:
        logging.error('STREAM error: %s', e.message)
        isError = True
except Exception as e:
    logging.error('CONNECTION error: %s', e.message)
    isError = True

print '-' * 60

if isError:
    raise Exception