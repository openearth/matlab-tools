# -*- coding: utf-8 -*-
"""
Created on Fri Aug 11 14:01:45 2017

- From a given set of JPEG images of mud columns observations
- Read IMG header to get date
- Given a mask_white.jpg file indicating where the columns are
- Process each column to determine mud levels using color quantification + Kmeans
- Output estimations in csv format and bokeh plots

@authors:
Joan Sala Calero (joan.salacalero@deltares.nl)
"""

from ast import literal_eval
from datetime import datetime

import logging
import shutil
import os
import time
import ConfigParser
import cv2
import exifread
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

class Mudseries():

    # Configuration defaults - files
    dname = os.path.dirname(os.path.realpath(__file__))
    CONFIG_FILE = os.path.join(dname, 'mudseries_config.txt')
    MASK_FILE = os.path.join(dname, 'mask_white.jpg')
    LOG_FILE = os.path.join(dname, 'mudseries_log.txt')

    # Configuration defaults - values
    WRITE_IMG = False
    DEBUG = False
    MARGIN_TOP_PX = 1
    MARGIN_BOTTOM_PX = 1
    MARGIN_LEFT_PX = 1
    MARGIN_RIGHT_PX = 1
    NBCLUSTERS = 4
    MUDCLUSTERS = 1
    DARK_THR_PERCENT = 70
    THR_BLAME = 2
    THR_MIN_PERC = 20
    THR_MAX_PERC = 80
    THR_BLK_SIZE = 10

    # Init with input values from notebook
    def __init__(self, input_dir):
        # Standard names make easier to share among users, besides less things to input
        self.INPUT_DIR = input_dir
        self.MASK_FILE = os.path.join(input_dir, 'mask_white.jpg')
        self.CONFIG_FILE = os.path.join(input_dir, 'mudseries_config.txt')
        self.OUTPUT_DIR = os.path.join(input_dir, 'preprocess')
        # Fixed colors
        self.cmap = ['sienna', 'darkviolet', 'green', 'darkorange', 'magenta', 'gold', 'limegreen', 'blue', 'darkgray',
                     'pink', 'cyan', 'purple']  # every column one colour [red is forbidden, used for fitting later]

    # Read configuration file into class
    def read_config(self):
        # Parse configuration
        cf = ConfigParser.RawConfigParser()
        self.cf = cf
        cf.read(self.CONFIG_FILE)
        self.config = {s: {n: literal_eval(i) for n, i in cf.items(s)}
                       for s in cf.sections()}

        # Basic configurations, show preview, write images
        try:
            self.WRITE_IMG = cf.get('previews', 'writeImg') == 'True'
        except:
            self.WRITE_IMG = False  # totally optional
        try:
            self.DEBUG = cf.get('previews', 'debug') == 'True'
        except:
            self.DEBUG = False  # totally optional

        try:
            # Cutting images by margin to reduce errors
            self.MARGIN_TOP_PX = 1
            self.MARGIN_BOTTOM_PX = 1
            self.MARGIN_LEFT_PX = cf.getint('cropping', 'margin_left_px')
            self.MARGIN_RIGHT_PX = cf.getint('cropping', 'margin_right_px')

            # Kmeans color quantification options
            self.NBCLUSTERS = cf.getint('kmeans', 'nbclusters')
            self.MUDCLUSTERS = cf.getint('kmeans', 'mudclusters')

            # Thresholds to detect mud line percentage of mud in the block
            self.DARK_THR_PERCENT = cf.getint('levels', 'dark_thr_percent')

            # Directories default
            self.KMEANS_DIR = os.path.join(self.OUTPUT_DIR, "kmeans")
        except:
            print('ERROR: Mandatory parameters not set, please check mudseries_config.txt')

        # Filtering options [Defaults below]
        try:
            self.THR_BLAME = cf.getint('filtering', 'thr_blame')
            self.THR_MIN_PERC = cf.getint('filtering', 'thr_min_perc')
            self.THR_MAX_PERC = cf.getint('filtering', 'thr_max_perc')
            self.THR_BLK_SIZE = cf.getint('filtering', 'blk_size')
        except:
            pass

        # Default variables
        self.binmask = None
        self.columns = None

    # Write configuration object to file [save configuration] and save used mask
    def save_inputs(self):
        with open(os.path.join(self.OUTPUT_DIR, "mudseries_used_config.txt"), "wb") as f:
            self.cf.write(f)
        shutil.copyfile(os.path.join(self.INPUT_DIR, 'mask_white.jpg'), os.path.join(self.OUTPUT_DIR, 'mask_white_used.jpg'))

        # Directories init/create
    def create_dirs(self, cols):
        if not os.path.exists(self.OUTPUT_DIR):
            os.makedirs(self.OUTPUT_DIR)

        # Optional previews
        if self.WRITE_IMG:
            if not os.path.exists(self.KMEANS_DIR):
                os.makedirs(self.KMEANS_DIR)
            for c in range(len(cols)):
                if not os.path.exists(self.KMEANS_DIR + '/C' + str(c)):
                    os.makedirs(self.KMEANS_DIR + '/C' + str(c))

    # Read mask file to identify the columns position
    def read_mask(self, minSize=100000):
        columns = []
        xlist = []

        # Record size and position
        if not os.path.exists(self.OUTPUT_DIR): os.makedirs(self.OUTPUT_DIR)
        csv_path = os.path.join(self.OUTPUT_DIR, "columns_geometry.csv")

        with open(csv_path, "w") as f:
            # Header
            f.write('column;x;y;w;h\n')

            # Read image into array
            #
            img = cv2.imread(self.MASK_FILE)

            # BW conversion + apply threshold to get white part
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            ret, gray = cv2.threshold(gray, 254, 255, 0)  # white mask

            # Find contours/objects
            mask = np.zeros(gray.shape, np.uint8)
            contours, hier = cv2.findContours(gray, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

            # Get coordinates of each column
            for cnt in contours:
                # Avoid small artifacts [we only want columns here]
                if minSize < cv2.contourArea(cnt):
                    x, y, w, h = cv2.boundingRect(cnt)
                    columns.append({'x': x, 'y': y, 'w': w, 'h': h})
                    xlist.append(x)
                    cv2.drawContours(mask, [cnt], 0, 255, -1)
                    print('Mask generation - volume detected x,y=({},{})- {} x {}'.format(x, y, w, h))
                    logging.info('Mask generation - volume detected x,y=({},{})- {} x {}'.format(x, y, w, h))

            # Order columns in the X-axis
            xord = [i[0] for i in sorted(enumerate(xlist), key=lambda x:x[1])]
            ord_cols = []
            inc=0
            for c in xord:
                ord_cols.append(columns[c])
                f.write('{};{};{};{};{}\n'.format(inc, columns[c]['x'], columns[c]['y'], columns[c]['w'], columns[c]['h']))
                inc+=1

            # Save geometries to disk
            f.close()
        return mask, ord_cols

    # Apply mask and cut margins[top,bottom] to avoid errors (ex: round edges)
    def apply_mask(self, rgb_file):
        img = cv2.imread(rgb_file)
        return cv2.bitwise_and(img, img, mask=self.binmask)

    # Apply colour quantification with KMeans
    def kmeans(self, img):
        # Reshape RGB image to be a list of pixels
        Z = img.reshape((-1, 1))

        # convert to np.float32
        Z = np.float32(Z)

        # define criteria, number of clusters(K) and apply kmeans()
        criteria = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_MAX_ITER, 1, 10)
        ret, label, center = cv2.kmeans(Z, self.NBCLUSTERS, None, criteria, 5, cv2.KMEANS_PP_CENTERS)

        # Now convert back into uint8, and make original image
        center = np.uint8(center)
        res = center[label.flatten()]
        res2 = res.reshape((img.shape))
        return res2, center

    # Get mud level within a column
    def get_level_RGB(self, arr, centers, ahead_lines=60):
        # Image size
        nrows = arr.shape[0]
        ncols = arr.shape[1]

        # Block counters
        row = 0
        last_row = ahead_lines
        selected_row = 0
        selected_per = 0
        alternative_row = 0
        max_percent = 0
        obs = []
        rwobs = []

        # Sort centers and get threshold (ndarray does weird things apparently... whatever)
        lc = []
        for c in centers:
            lc.append(c)
        lcsort = sorted(lc)
        thrbw1 = lcsort[self.MUDCLUSTERS - 1]
        thrbw2 = lcsort[self.MUDCLUSTERS]

        # Estimate by blocks of chosen size
        logging.debug('START from the top')
        while (row + ahead_lines < nrows):
            # number of dark pixels of block [dark=0 ... 255=white]
            block = np.where(arr[row:last_row, :] <= thrbw1)
            percent = 100.0 * len(block[0]) / (ncols * ahead_lines)

            # Get Peak
            if percent > max_percent:
                max_percent = percent
                alternative_row = row

            # First occurrence of high concentration of mud
            meanblck = np.mean(arr[row:last_row, :])
            if percent > self.DARK_THR_PERCENT and meanblck < ((thrbw2 + thrbw1) / 2.0):
                selected_row = row
                selected_per = percent
                break

            logging.debug("""DEBUG ( block=[{r} -> {lr}], percent={lp} , mean={mn} vs thr2={th2} thr1={th1} )""".format(
                lp=percent, r=row, lr=last_row, mn=meanblck, th2=thrbw2, th1=thrbw1))

            # Increment line ahead [Sliding window block]
            last_row += 1
            row += 1
            obs.append(percent)
            rwobs.append(row)

        # Condition was not found, we take the maximum value
        if selected_row == 0:
            selected_per = max_percent
            selected_row = alternative_row
        else:
            selected_row += ahead_lines / 2

        logging.debug('STOP reached the end')
        logging.debug("""selected_row={sr}, percent={lp}""".format(
            lp=selected_per, sr=selected_row))

        # row where it is not dark anymore (top, bottom)
        return selected_per, selected_row, nrows - selected_row

    # BW to RGB function
    def to_RGB(self, im):
        w, h = im.shape
        ret = np.empty((w, h, 3), dtype=np.uint8)
        ret[:, :, :] = im[:, :, np.newaxis]
        return ret

    # Equalize Histogram image [not used for now]
    def equ_hist_img(self, img):
        # BW convert
        img_yuv = cv2.cvtColor(img, cv2.COLOR_BGR2YUV)

        # equalize the histogram of the Y channel
        img_yuv[:, :, 0] = cv2.equalizeHist(img_yuv[:, :, 0])

        # convert the YUV image back to RGB format
        return cv2.cvtColor(img_yuv, cv2.COLOR_YUV2BGR)

    # Write a green horizontal line for kmeans previews
    def write_green_line(self, im, mudlvl):
        im[mudlvl - 1, :] = (0, 255, 0)
        im[mudlvl, :] = (0, 255, 0)
        return im

    # Some error checking
    def check_inputs(self):
        print(self.MASK_FILE)
        if os.path.exists(self.MASK_FILE) == False:
            logging.error('The specified mask file does not exist')
            return 'The specified mask file does not exist'

        mudfiles = [f for f in os.listdir(self.INPUT_DIR) if f.endswith('.JPG') and not(f.startswith(('mask')))]
        if len(mudfiles) == 0:
            logging.error('Missing JPG files in the specified directory')
            return 'Missing JPG files in the specified directory'
        else:
            print('{} images found'.format(len(mudfiles)))

        # Mask size matches image size
        img = cv2.imread(os.path.join(self.INPUT_DIR, mudfiles[0]))
        ih, iw, ic = img.shape
        msk = cv2.imread(self.MASK_FILE)
        mh, mw, mc = msk.shape
        if (mh == ih and mw == iw and mc == ic):
            return "" # ok
        else:
            logging.error('The mask file has a different size than the input files')
            return 'The mask file has a different size than the input files'

    # Setup logging
    def setup_logging(self):
        if self.DEBUG:
            loglevel = logging.DEBUG
        else:
            loglevel = logging.INFO
        logFile = os.path.join(self.OUTPUT_DIR, 'mudseries_pre_processing.log')
        logging.basicConfig(filename=logFile, level=loglevel,
                            format="%(asctime)s %(message)s")
        print("Log file available at: {}".format(logFile))
        logging.getLogger().addHandler(logging.StreamHandler())
        logging.info('Mudseries Pre-Processing START')

    # Read config and mask [prepare step]
    def prepare(self):
        # Create directories
        self.read_config()

        # Mask file (get objects)
        self.binmask, self.columns = self.read_mask()

        # Create directories
        self.create_dirs(self.columns)

        # Logging
        self.setup_logging()

    # Preview plot [matplotlib]
    def preview_plots(self):
        csv_path = os.path.join(self.OUTPUT_DIR, "columns.csv")
        df = pd.read_csv(csv_path, sep=";")
        cols = df.column.unique()
        n = len(cols)
        fig = plt.figure(1)
        fig.set_size_inches(16, 6 * n)
        maxY = max(df['pixel'])
        for col in cols:
            ax = plt.subplot(int('{}{}{}'.format(n, 1, col + 1)))
            ax.set_title('Column = C' + str(col))
            plt.ylim(0, maxY)
            plt.ylabel('mud level [pix]')
            plt.xlabel('elapsed time [sec]')
            d = df[df.column == col]
            plt.plot(d["elapsed time [s]"], d["pixel"], marker='o', linestyle='-', c=self.cmap[col % 10])

        # All columns plot
        plt.savefig(os.path.join(self.OUTPUT_DIR, 'plot_preproc_columns_ALL.png'))

    # Outliers between min - max percentile
    def outliers_iqr(self, ys):
        quartile_1, quartile_3 = np.percentile(ys, [self.THR_MIN_PERC, self.THR_MAX_PERC])
        iqr = quartile_3 - quartile_1
        lower_bound = quartile_1 - (iqr * 1.5)
        upper_bound = quartile_3 + (iqr * 1.5)
        return np.where((ys > upper_bound) | (ys < lower_bound))

    # Outliers filter function [given final result]
    def filter_outliers(self, unfiltered_csv):
        # Final csv
        final_csv = unfiltered_csv.replace('_unfiltered', '')
        data = pd.read_csv(unfiltered_csv, delimiter=";")
        maxY = max(data['pixel'])
        with open(final_csv, 'w') as f:
            f.write("column;pixel;date;percentage;filename;elapsed time [s]\n")

        # For every column / Filter outliers
        for i, column in enumerate(data.column.unique()):
            # Slice per column
            cr = data[data.column == i]
            h = cr["pixel"]

            # Avoid error [if nonsense value provided take 10%)
            if len(cr) <= self.THR_BLK_SIZE:
                self.THR_BLK_SIZE = max(3, round(len(cr)*0.1))
                print('Changing blk_size')

            # For every row
            outliers = np.zeros(len(h))
            current_blk = []
            ind = 0
            for pixel in h:
                # Sliding window
                if len(current_blk) == self.THR_BLK_SIZE:
                    current_blk.pop(0)
                current_blk.append(pixel)

                # Detect block outliers and add to general outliers counter
                blk_outliers = self.outliers_iqr(current_blk)[0]
                for ol in blk_outliers:
                    outliers[ind - (self.THR_BLK_SIZE - ol) + 1] += 1

                # Increment general index
                ind += 1

            # Filter outliers by number of times they have blamed to be an outlier + last value only visited once
            real_outliers = np.where(outliers > self.THR_BLAME)[0]
            cr_filt = cr.drop(cr.index[real_outliers])[0:-1]

            # Make plots to proove that the system works
            fig = plt.figure(1)
            fig.set_size_inches(16, 6 * 2)
            ax = plt.subplot(211)
            plt.ylim(0, maxY)
            ax.set_title('Column = C{} [{} observed]'.format(i,len(h)))
            plt.ylabel('mud level [pix]')
            plt.xlabel('elapsed time [sec]')
            plt.plot(cr["elapsed time [s]"], cr.pixel, marker='o', linestyle='-', c='blue')
            ax = plt.subplot(212)
            plt.ylim(0, maxY)
            ax.set_title('Column = C{} [{}% discarted]'.format(i, int(100. * float(len(real_outliers)) / len(h))))
            plt.ylabel('mud level [pix]')
            plt.xlabel('elapsed time [sec]')
            plt.plot(cr_filt["elapsed time [s]"], cr_filt.pixel, marker='o', linestyle='-', c='green')
            plt.savefig(os.path.join(self.OUTPUT_DIR, 'plot_preproc_column_{}.png'.format(i)))
            plt.clf()

            # Concatenate filtered lines to final csv file
            with open(final_csv, 'a') as f:
                cr_filt.to_csv(f, header=False, sep=";", index=False)

    # --- MAIN --- #
    def run(self):
        # Write used config
        self.save_inputs()

        # Basic check
        if self.binmask is None or self.columns is None:
            logging.error(
                "No mask or columns found, please run prepare() first.")
            return

        # File filter
        mudfiles = [f for f in os.listdir(self.INPUT_DIR) if f.endswith('.JPG') and not(f.startswith(('mask')))]
        N=float(len(mudfiles))

        # Store time series per column [now a dict of lists]
        self.tseries = dict()
        self.pseries = []
        for n in range(len(self.columns)):  self.tseries[n] = []

        # Loop over files
        total_elapsed = 0.0
        imgsp = 0
        last_perc = -1
        for fn in mudfiles:
            # Progress, every 10%
            imgsp += 1
            perc = int(100.*imgsp/N)
            if (perc % 10 == 0) and (perc != last_perc):
                print('{}% -> {} of {} images processed'.format(perc, imgsp, N))
                last_perc = perc

            # Start time
            start_time = time.time()

            # Get file
            fname, ext = os.path.splitext(fn)

            # Get date from EXIF JPG metadata
            jpg = open(os.path.join(self.INPUT_DIR, fn), 'rb')
            tags = exifread.process_file(jpg)
            dtm = datetime.strptime(
                str(tags['Image DateTime']), '%Y:%m:%d %H:%M:%S')
            logging.info('Processing image={} with date={}'.format(fn, dtm))

            # Apply binary mask to current image
            masked = self.apply_mask(os.path.join(self.INPUT_DIR, fn))

            # For every column inside the image
            for c, col in enumerate(self.columns):
                logging.debug("START img={i} col={c}".format(i=fname, c=c))

                # Crop by selected mud column + Error Margins [config]
                mask_crop = masked[col['y']:col['y'] + col['h'], col['x']:col['x'] + col['w']]
                mask_crop = mask_crop[self.MARGIN_TOP_PX:-self.MARGIN_BOTTOM_PX,
                                      self.MARGIN_LEFT_PX:-self.MARGIN_RIGHT_PX]

                # Equalize image [equ_mask_crop = self.equ_hist_img(mask_crop)]
                equ_mask_crop = mask_crop
                equ_mask_crop_bw = cv2.cvtColor(equ_mask_crop, cv2.COLOR_BGR2GRAY)

                # KMeans color clustering
                start_time_KM = time.time()
                kmeans_crop, centers = self.kmeans(equ_mask_crop_bw)
                elapsed_time = time.time() - start_time_KM
                logging.debug("Elapsed time KMEANS = {}".format(elapsed_time))

                # Find mud level - single band grey
                start_time_ML = time.time()
                per, mud, nmud = self.get_level_RGB(kmeans_crop, centers)
                elapsed_time = time.time() - start_time_ML
                logging.debug("Elapsed time MUD LEVEL = {}".format(elapsed_time))

                # Store Time-Series [number, datetime, percentage, filename]
                self.tseries[c].append(
                    (nmud, dtm, per, os.path.join(self.INPUT_DIR, fn)))
                self.pseries.append(
                    (c, nmud, dtm, per, os.path.join(self.INPUT_DIR, fn)))

                # Previewing
                if self.WRITE_IMG:
                    # Write result - green line
                    imgKGRGB = self.to_RGB(kmeans_crop)
                    imgKGRGB = self.write_green_line(imgKGRGB, mud)
                    # Write preview
                    preview_img = np.append(mask_crop, np.zeros_like(mask_crop), axis=1)
                    preview_img = np.append(preview_img, self.equ_hist_img(equ_mask_crop), axis=1)
                    preview_img = np.append(preview_img, np.zeros_like(mask_crop), axis=1)
                    preview_img = np.append(preview_img, imgKGRGB, axis=1)
                    cv2.imwrite("{d}/C{cl}/{fn}_level_column_{cl}.png".format(
                        d=self.KMEANS_DIR, cl=c, fn=fname), preview_img)

            # Elapsed time per image
            elapsed_time = time.time() - start_time
            total_elapsed += elapsed_time
            logging.debug('Elapsed time = {}'.format(elapsed_time))

        # Total processing time
        logging.info('TOTAL images processed = {} images'.format(len(mudfiles)))
        logging.info('TOTAL processing time = {} seconds'.format(
            int(total_elapsed)))

        # Add together to DataFrame and save it as csv [excel compatible with ;]
        data = pd.DataFrame.from_records(self.pseries, columns=(
            "column", "pixel", "date", "percentage", "filename"))
        data["elapsed time [s]"] = (
            data["date"] - min(data["date"])).astype("timedelta64[s]")
        data = data.sort_values(by=['column', 'date'])
        csv_path = os.path.join(self.OUTPUT_DIR, "columns_unfiltered.csv")
        data.to_csv(csv_path, sep=";", index=False)
        self.data = data

        # Filter outliers
        self.filter_outliers(csv_path)

        # Save default postprocessing config
        pconfig = []
        for c, _ in enumerate(self.columns):
            p = self.config['post']
            row = (c, p["expdur"], p["sample"], p["ci"], p["cg"], p["h_ini"],
                   p["rho_s"], p["rho_w"], p["sandfrac"], min(data["elapsed time [s]"]),
                   max(data["elapsed time [s]"]), p["h_final"], p["pix2m"], p["khm"])
            pconfig.append(row)
        cdata = pd.DataFrame.from_records(pconfig, columns=("column","expdur", "sample",
            "ci", "cg", "h_ini", "rho_s", "rho_w", "sandfrac", "t1", "t2", "h_final", "pix2m", "khm"))
        csv_path = os.path.join(self.OUTPUT_DIR, "postproc_config.csv")
        cdata.to_csv(csv_path, sep=";", index=False)
