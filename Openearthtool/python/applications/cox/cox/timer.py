import os
import time
import cox
import logging

import numpy as np
from datetime import datetime, date

# image path options
station = 'kijkduinIR'
camtype = 'c1'

#roots   = ['Y:/', 'Z:/stream/']
roots   = ['Z:/stream/']

interval = 600

# create root directory
for root in roots:
    if not os.path.exists(root):
        os.makedirs(root)

# start daily loop
startDate = datetime.now()
while datetime.now().day == startDate.day:

    isError = False

    # determine current time
    posix          = time.time()
    posix_midnight = int(time.mktime(date.fromtimestamp(posix).timetuple()))

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

            try:

                for root in roots:

                    #imgpath = datetime.fromtimestamp(posix).strftime('%Y/%%s/%j_%b.%d/') % camtype

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
                            #fname = datetime.fromtimestamp(posix).strftime('%%d.%a.%b.%d_%H_%M_%S.UTC.%Y.%%s.%%s.%%s.png') % (posix, station, camtype, imgtype)

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

    try:

        # close connection
        cox.connection.CloseConnect(cHandle, cTimerID)
        
        logging.info('Closed connection to camera')

    except Exception as e:
        logging.error('CLOSING error: %s', e.message)
        isError = true

    if isError:
        raise Exception