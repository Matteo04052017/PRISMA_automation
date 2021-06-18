#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# get capture and events from ftp fripon

import os
import sys
import time
import datetime
import getopt
import logging
import json
import mysql
from datetime import date, timedelta
from ssh_client import PRISMASSHClient
from asyncio import ensure_future, gather, run, Semaphore
from mysql.connector import connect, errorcode

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
fripon_single_events_directory = "/data/fripon_detections/single"
fripon_events_directory = "/data/fripon_detections/multiple"

prisma_capture_diretory = "/prismadata/stations"
prisma_events_directory = "/prismadata/detections/multiple"
prisma_single_events_directory = "/prismadata/detections/single"

last_n_days = 30
# cameras_to_sync = ["ITCL01", "ITCP01", "ITCP02", "ITCP03", "ITCP04", "ITER01", "ITER02", "ITER03", "ITER04", "ITER05", "ITER06", "ITER07", "ITER08", "ITFV01", "ITFV02", "ITLA01", "ITLA02", "ITLI01", "ITLI02", "ITLO01", "ITLO02", "ITLO03", "ITLO04", "ITLO05", "ITMA01", "ITMA02", "ITMA03", "ITPI01", "ITPI02", "ITPI03",
#                    "ITPI04", "ITPI05", "ITPI06", "ITPU01", "ITPU02", "ITPU03", "ITSA01", "ITSA02", "ITSA03", "ITSI01", "ITSI02", "ITSI03", "ITTA01", "ITTA02", "ITTN02", "ITTO01", "ITTO02", "ITTO03", "ITTO04", "ITTO05", "ITTO06", "ITTO07", "ITUM01", "ITUM02", "ITVA01", "ITVE01", "ITVE02", "ITVE03", "ITVE04", "ITVE05", "ITVE06"]
# cameras_to_sync = ["ITMA01"]

def get_camera_list():
    camera_codes = []
    camera_names = []
    with open('procedures_config.json') as pc:
        default_config = json.load(pc)

    config = default_config['process_calibration']['db_config']
    try:
        connection  = connect(**config)
        sql_select_Query = "select code from pr_camera"
        cursor = connection.cursor()
        cursor.execute(sql_select_Query)
        records = cursor.fetchall()

        for row in records:
            camera_codes.append(row[0])

        sql_select_Query = "select relative_path from pr_node"
        cursor = connection.cursor()
        cursor.execute(sql_select_Query)
        records = cursor.fetchall()

        for row in records:
            camera_names.append(row[0])

        return camera_codes, camera_names
        
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            logger.error('Something is wrong with your username or password')
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            logger.error('Database does not exist')
        else:
            logger.error(err)
        exit()


def get_multiple_events_to_sync(client, camera_names):
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

    for capture_dir in month_capture_directories:
        events_dir = fripon_events_directory + "/" + str(capture_dir)
        logger.info("Processing multiple events directory %s", events_dir)
        all_events_dirs = client.list_from_directory(events_dir)
        for multiple_event_dir in all_events_dirs:
            # d like 20210616T222449_UT
            check_name = str(str(multiple_event_dir.decode()).split('_')[0])[:8]
            if check_name in day_capture_directories:
                detections_dir = events_dir + '/' + str(multiple_event_dir.decode())
                detections = client.list_from_directory(detections_dir)
                for detection in detections:
                    # detection CASERTA_20210524T015103_UT
                    logger.info("Processing multiple event detection %s", detection.decode())
                    camera_name = detection.decode().split('_')[0]
                    if camera_name in camera_names:
                        download_dir = fripon_events_directory + "/" + str(capture_dir) +  "/" + multiple_event_dir.decode() + "/" + detection.decode()
                        fits2D_download_dir = fripon_events_directory + "/" + str(capture_dir) +  "/" + multiple_event_dir.decode() + "/" + detection.decode() + "/fits2D"
                        local_dir = prisma_events_directory + "/" + str(capture_dir) +  "/" + multiple_event_dir.decode() + "/" + detection.decode() 
                        fits2D_local_dir = prisma_events_directory + "/" + str(capture_dir) +  "/" + multiple_event_dir.decode() + "/" + detection.decode() + "/fits2D"
                        if not os.path.isdir(fits2D_local_dir):
                            os.makedirs(fits2D_local_dir)
                        
                        files2download = client.list_from_directory(fits2D_download_dir)
                        for f in files2download:
                            remote_file = fits2D_download_dir + "/" + str(f.decode())
                            local_file = fits2D_local_dir + "/" + str(f.decode())
                            logger.debug("Processing file %s", remote_file)
                            yield { "remote_file" : remote_file, "local_file":local_file }

                        files2download = client.list_from_directory(download_dir)
                        for f in files2download:
                            if "fits2D" in str(f.decode()):
                                continue
                            remote_file = download_dir + "/" + str(f.decode())
                            local_file = local_dir + "/" + str(f.decode())
                            logger.debug("Processing file %s", remote_file)
                            yield { "remote_file" : remote_file, "local_file":local_file }

    logger.info("Get events of the last %s days...DONE", last_n_days)

def get_single_events_to_sync(client, cameras_to_sync):
    logger.info("Get single events of the last %s days", last_n_days)
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

    for camera in cameras_to_sync:
        logger.info("Processing single camera events %s", camera)
        for capture_dir in month_capture_directories:
            list_dir = fripon_single_events_directory + "/" + \
                str(camera) + "/" + str(capture_dir)
            logger.info("Processing single event directory %s", list_dir)
            
            all_events_dirs = client.list_from_directory(list_dir)
            
            download_dir = prisma_single_events_directory + \
                "/" + str(camera) + "/" + str(capture_dir)
            if not os.path.isdir(download_dir):
                os.makedirs(download_dir)

            for d in all_events_dirs:
                # d like NOVEZZINA_20210614T220727_UT
                check_name = str(str(d.decode()).split('_')[1])[:8]
                if check_name in day_capture_directories:
                    # ok to download
                    # create dir if not existing
                    local_dir = download_dir +  "/" + d.decode()
                    if not os.path.isdir(local_dir):
                        os.makedirs(local_dir)
                    all_capture_files = client.list_from_directory(list_dir + "/" + d.decode())
                    for f in all_capture_files:
                        remote_file = list_dir + "/" + d.decode() + "/" + str(f.decode())
                        local_file = local_dir + "/" + str(f.decode())
                        logger.debug("Processing file %s", remote_file)
                        yield { "remote_file" : remote_file, "local_file":local_file }
    logger.info("Get single events of the last %s days...DONE", last_n_days)


def get_captures_to_sync(client, cameras_to_sync):
    logger.info("Get capture of the last %s days", last_n_days)
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

    for camera in cameras_to_sync:
        logger.info("Processing camera for capture %s", camera)
        for capture_dir in month_capture_directories:
            list_dir = fripon_capture_diretory + "/" + \
                str(camera) + "/" + str(capture_dir)
            all_capture_files = client.list_from_directory(list_dir)
            logger.info("Processing capture directory %s", list_dir)
            download_dir = prisma_capture_diretory + \
                "/" + str(camera) + "/" + str(capture_dir)
            if not os.path.isdir(download_dir):
                os.makedirs(download_dir)

            for f in all_capture_files:
                check_name = str(str(f.decode()).split('_')[1])[:8]
                if check_name in day_capture_directories:
                    remote_file = list_dir + "/" + str(f.decode())
                    local_file = download_dir + "/" + str(f.decode())
                    logger.debug("Processing capture file %s", remote_file)
                    yield { "remote_file" : remote_file, "local_file":local_file }
    logger.info("Get capture of the last %s days...DONE", last_n_days)

async def download_one(client, remote_file, local_file, sem):
    async with sem:
        if not os.path.isfile(local_file) and not "jpg" in local_file:
            logger.info("Downloading %s", remote_file)
            await client.download_file(remote_file, local_file)
            logger.info("DONE")

async def main_loop():
    while True:
        
        st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')
        logger.info("Start execution at " + st)

        cameras_to_sync, camera_names = get_camera_list()
        
        sem = Semaphore(DOWNLOAD_LIMIT)
        tasks = list()

        try:
            client = PRISMASSHClient(fripon_address, user=fripon_username)

            captures = get_captures_to_sync(client, cameras_to_sync)
            for f in captures:
                tasks.append(ensure_future(download_one(client, f["remote_file"], f["local_file"], sem)))

            single = get_single_events_to_sync(client, cameras_to_sync)
            for f in single:
                tasks.append(ensure_future(download_one(client, f["remote_file"], f["local_file"], sem)))
            
            events = get_multiple_events_to_sync(client, camera_names)
            for f in events:
                tasks.append(ensure_future(download_one(client, f["remote_file"], f["local_file"], sem)))

            logger.info("Start downloading")

            await gather(*tasks)

            logger.info("Done downloading")
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
