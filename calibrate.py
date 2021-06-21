import os
import sys
import time
import datetime
import getopt
import logging
import json
import mysql
import subprocess
from datetime import date, timedelta
from mysql.connector import connect, errorcode

SLEEP_TIME = 1800 # 30 minutes
DOWNLOAD_LIMIT = 5

logger = logging.getLogger('sync_fripon_logger')
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)

last_n_days = 30
cameras_to_sync = ["ITCL01", "ITCP01", "ITCP02", "ITCP03", "ITCP04", "ITER01", "ITER02", "ITER03", "ITER04", "ITER05", "ITER06", "ITER07", "ITER08", "ITFV01", "ITFV02", "ITLA01", "ITLA02", "ITLI01", "ITLI02", "ITLO01", "ITLO02", "ITLO03", "ITLO04", "ITLO05", "ITMA01", "ITMA02", "ITMA03", "ITPI01", "ITPI02", "ITPI03",
                   "ITPI04", "ITPI05", "ITPI06", "ITPU01", "ITPU02", "ITPU03", "ITSA01", "ITSA02", "ITSA03", "ITSI01", "ITSI02", "ITSI03", "ITTA01", "ITTA02", "ITTN02", "ITTO01", "ITTO02", "ITTO03", "ITTO04", "ITTO05", "ITTO06", "ITTO07", "ITUM01", "ITUM02", "ITVA01", "ITVE01", "ITVE02", "ITVE03", "ITVE04", "ITVE05", "ITVE06"]

def get_camera_code(solution_ini_file):
    result = []
    
    with open(solution_ini_file, 'r') as reader:
        # Read & print the entire file
        lines = reader.readlines()
        for line in lines:
            if line.startswith("#") or len(line) < 6:
                continue
            split = line.split("      ")
            if len(split)>0:
                result.append(split[0])
    return result

# parse arguments
try:
    opts, args = getopt.getopt(sys.argv[1:], "d:", ["days_to_sync="])

except getopt.GetoptError:
    print("Please provide proper arguments.")
    print("Usage: $python3 sync_fripon.py --d=<days>")
    sys.exit(2)
for opt, arg in opts:
    if opt in ("-d", "--days_to_sync"):
        last_n_days = int(arg)

def getlast_n_days(last_n_days):
    logger.info("Get multiple events of the last %s days", last_n_days)
    month_capture_directories = [date.today().strftime("%Y%m")]
    to_date = date.today() - timedelta(days=1)  # yesterday
    from_date = to_date - timedelta(days=last_n_days)
    time_elapsed = to_date - from_date
    day_capture_directories = []
    for x in range(time_elapsed.days):
        date_to_consider = to_date - timedelta(days=x)
        str_month = date_to_consider.strftime("%Y%m")
        if str_month not in month_capture_directories:
            month_capture_directories.append(str_month)
        day_capture_directories.append(date_to_consider.strftime("%Y%m%d"))
    return day_capture_directories

def calibrate_byday(day_capture_directories, camera_list):
    for c in camera_list:
        for d in day_capture_directories:
            cmd = ['bash', '-c', f'/usr/local/harris/idl/bin/idl -e "calibration, \'{c}\', \'{d}\', process_image=1, process_day=1, process_month=0, config_file=\'/astrometry/workspace/settings/configuration.ini\'"']
            separator = " "
            logger.info(separator.join(cmd))
            cp = subprocess.run(cmd, universal_newlines=True)
            if cp.returncode != 0:
                logger.error("subprocess stderr %s", cp.stderr)
            else:
                logger.info("subprocess stdout %s", cp.stdout)

def main_loop():
    while True:
        st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')
        logger.info("Start execution at " + st)

        camera_codes = get_camera_code('/astrometry/workspace/settings/solutions.ini')

        logger.info(camera_codes)

        calibrate_byday(getlast_n_days(last_n_days), camera_codes)

        logger.info("Stop execution at " + st)
        time.sleep(SLEEP_TIME)

if __name__ == '__main__':
    main_loop()
