#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# get capture and events from ftp fripon

import os
import sys
import time
import datetime
import getopt
import logging
from datetime import date, timedelta
from ssh_client import PRISMASSHClient
from asyncio import ensure_future, gather, run, Semaphore

# create logger
logger = logging.getLogger('sync_fripon_logger')
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)

SLEEP_TIME = 1800 # 30 minutes
DOWNLOAD_LIMIT = 5

fripon_address = "ssh.fripon.org"
fripon_username = "dgardiol"
#fripon_password = None
fripon_capture_diretory = "/data/fripon_stations"
fripon_events_directory = "/data/fripon_detections/multiple"

prisma_capture_diretory = "/prismadata/stations"
prisma_events_directory = "/prismadata/detections/multiple"

last_n_days = 5
cameras_to_sync = ["ITCL01", "ITCP01", "ITCP02", "ITCP03", "ITCP04", "ITER01", "ITER02", "ITER03", "ITER04", "ITER05", "ITER06", "ITER07", "ITER08", "ITFV01", "ITFV02", "ITLA01", "ITLA02", "ITLI01", "ITLI02", "ITLO01", "ITLO02", "ITLO03", "ITLO04", "ITLO05", "ITMA01", "ITMA02", "ITMA03", "ITPI01", "ITPI02", "ITPI03",
                   "ITPI04", "ITPI05", "ITPI06", "ITPU01", "ITPU02", "ITPU03", "ITSA01", "ITSA02", "ITSA03", "ITSI01", "ITSI02", "ITSI03", "ITTA01", "ITTA02", "ITTN02", "ITTO01", "ITTO02", "ITTO03", "ITTO04", "ITTO05", "ITTO06", "ITTO07", "ITUM01", "ITUM02", "ITVA01", "ITVE01", "ITVE02", "ITVE03", "ITVE04", "ITVE05", "ITVE06"]
# cameras_to_sync = ["ITMA01"]

def get_file_to_sync(client):
    result = {}
    logger.info("Get capture of the last %s days", last_n_days)
    month_capture_directories = [date.today().strftime("%Y%m")]
    to_date = date.today() - timedelta(days=1)  # yesterday
    from_date = to_date - timedelta(days=last_n_days)
    time_elapsed = to_date - from_date
    for x in range(int(time_elapsed.days / 30)):
        date_to_consider = to_date - timedelta(days=x)
        month_capture_directories.append(date_to_consider.strftime("%Y%m"))

    day_capture_directories = []
    for x in range(time_elapsed.days):
        date_to_consider = to_date - timedelta(days=x)
        day_capture_directories.append(date_to_consider.strftime("%Y%m%d"))

    for camera in cameras_to_sync:
        logger.info("Processing camera %s", camera)
        for capture_dir in month_capture_directories:
            list_dir = fripon_capture_diretory + "/" + \
                str(camera) + "/" + str(capture_dir)
            all_capture_files = client.list_from_directory(list_dir)
            logger.info("Processing directory %s", list_dir)
            download_dir = prisma_capture_diretory + \
                "/" + str(camera) + "/" + str(capture_dir)
            if not os.path.isdir(download_dir):
                os.makedirs(download_dir)

            for f in all_capture_files:
                check_name = str(str(f.decode()).split('_')[1])[:8]
                if check_name in day_capture_directories:
                    remote_file = list_dir + "/" + str(f.decode())
                    local_file = download_dir + "/" + str(f.decode())
                    logger.debug("Processing file %s", remote_file)
                    result[remote_file] = local_file
    logger.info("Get capture of the last %s days...DONE", last_n_days)
    return result

async def download_one(client, remote_file, local_file, sem):
    async with sem:
        if not os.path.isfile(local_file):
            logger.info("Downloading %s", remote_file)
            await client.download_file(remote_file, local_file)
            logger.info("DONE")

async def main_loop():
    while True:
        
        st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')
        logger.info("Start execution at " + st)
        
        sem = Semaphore(DOWNLOAD_LIMIT)
        tasks = list()

        try:
            client = PRISMASSHClient(fripon_address, user=fripon_username)
            files2download = get_file_to_sync(client)

            logger.info("File to download: %s", len(files2download))

            for f in files2download:
                tasks.append(ensure_future(download_one(client, f, files2download[f], sem)))

            logger.info("Start downloading")

            await gather(*tasks)
        finally:
            client.close()

        st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')
        logger.info("Stop execution at " + st)
        time.sleep(SLEEP_TIME)


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

if __name__ == '__main__':
    run(main_loop())
