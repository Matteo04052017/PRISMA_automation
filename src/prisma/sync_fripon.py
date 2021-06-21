#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# get capture and events from ftp fripon

import datetime
import logging
import os
import time
from asyncio import Semaphore, ensure_future, gather

from prisma.settings import get_camera_code, get_days_to_work
from prisma.ssh_client import PRISMASSHClient

# create logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)

SLEEP_TIME = 1800  # 30 minutes
DOWNLOAD_LIMIT = 5

fripon_address = "ssh.fripon.org"
fripon_username = "dgardiol"
# fripon_password = None
fripon_capture_diretory = "/data/fripon_stations"
fripon_single_events_directory = "/data/fripon_detections/single"
fripon_events_directory = "/data/fripon_detections/multiple"

prisma_capture_diretory = "/prismadata/stations"
prisma_events_directory = "/prismadata/detections/multiple"
prisma_single_events_directory = "/prismadata/detections/single"

last_n_days = 30


def get_multiple_events_to_sync(client, camera_names):
    day_capture_directories, month_capture_directories = get_days_to_work(
        last_n_days
    )

    for capture_dir in month_capture_directories:
        events_dir = fripon_events_directory + "/" + str(capture_dir)
        logger.info("Processing multiple events directory %s", events_dir)
        all_events_dirs = client.list_from_directory(events_dir)
        for multiple_event_dir in all_events_dirs:
            # d like 20210616T222449_UT
            check_name = str(str(multiple_event_dir.decode()).split("_")[0])[
                :8
            ]
            if check_name in day_capture_directories:
                detections_dir = (
                    events_dir + "/" + str(multiple_event_dir.decode())
                )
                detections = client.list_from_directory(detections_dir)
                for detection in detections:
                    # detection CASERTA_20210524T015103_UT
                    logger.info(
                        "Processing multiple event detection %s",
                        detection.decode(),
                    )
                    camera_name = detection.decode().split("_")[0]
                    if camera_name in camera_names:
                        download_dir = (
                            fripon_events_directory
                            + "/"
                            + str(capture_dir)
                            + "/"
                            + multiple_event_dir.decode()
                            + "/"
                            + detection.decode()
                        )
                        fits2D_download_dir = (
                            fripon_events_directory
                            + "/"
                            + str(capture_dir)
                            + "/"
                            + multiple_event_dir.decode()
                            + "/"
                            + detection.decode()
                            + "/fits2D"
                        )
                        local_dir = (
                            prisma_events_directory
                            + "/"
                            + str(capture_dir)
                            + "/"
                            + multiple_event_dir.decode()
                            + "/"
                            + detection.decode()
                        )
                        fits2D_local_dir = (
                            prisma_events_directory
                            + "/"
                            + str(capture_dir)
                            + "/"
                            + multiple_event_dir.decode()
                            + "/"
                            + detection.decode()
                            + "/fits2D"
                        )
                        if not os.path.isdir(fits2D_local_dir):
                            os.makedirs(fits2D_local_dir)

                        files2download = client.list_from_directory(
                            fits2D_download_dir
                        )
                        for f in files2download:
                            remote_file = (
                                fits2D_download_dir + "/" + str(f.decode())
                            )
                            local_file = (
                                fits2D_local_dir + "/" + str(f.decode())
                            )
                            logger.debug("Processing file %s", remote_file)
                            yield {
                                "remote_file": remote_file,
                                "local_file": local_file,
                            }

                        files2download = client.list_from_directory(
                            download_dir
                        )
                        for f in files2download:
                            if "fits2D" in str(f.decode()):
                                continue
                            remote_file = download_dir + "/" + str(f.decode())
                            local_file = local_dir + "/" + str(f.decode())
                            logger.debug("Processing file %s", remote_file)
                            yield {
                                "remote_file": remote_file,
                                "local_file": local_file,
                            }

    logger.info("Get events of the last %s days...DONE", last_n_days)


def get_single_events_to_sync(client, cameras_to_sync):
    day_capture_directories, month_capture_directories = get_days_to_work(
        last_n_days
    )

    for camera in cameras_to_sync:
        logger.info("Processing single camera events %s", camera)
        for capture_dir in month_capture_directories:
            list_dir = (
                fripon_single_events_directory
                + "/"
                + str(camera)
                + "/"
                + str(capture_dir)
            )
            logger.info("Processing single event directory %s", list_dir)

            all_events_dirs = client.list_from_directory(list_dir)

            download_dir = (
                prisma_single_events_directory
                + "/"
                + str(camera)
                + "/"
                + str(capture_dir)
            )
            if not os.path.isdir(download_dir):
                os.makedirs(download_dir)

            for d in all_events_dirs:
                # d like NOVEZZINA_20210614T220727_UT
                check_name = str(str(d.decode()).split("_")[1])[:8]
                if check_name in day_capture_directories:
                    # ok to download
                    # create dir if not existing
                    local_dir = download_dir + "/" + d.decode()
                    if not os.path.isdir(local_dir):
                        os.makedirs(local_dir)
                    all_capture_files = client.list_from_directory(
                        list_dir + "/" + d.decode()
                    )
                    for f in all_capture_files:
                        remote_file = (
                            list_dir + "/" + d.decode() + "/" + str(f.decode())
                        )
                        local_file = local_dir + "/" + str(f.decode())
                        logger.debug("Processing file %s", remote_file)
                        yield {
                            "remote_file": remote_file,
                            "local_file": local_file,
                        }
    logger.info("Get single events of the last %s days...DONE", last_n_days)


def get_captures_to_sync(client, cameras_to_sync):
    day_capture_directories, month_capture_directories = get_days_to_work(
        last_n_days
    )

    for camera in cameras_to_sync:
        logger.info("Processing camera for capture %s", camera)
        for capture_dir in month_capture_directories:
            list_dir = (
                fripon_capture_diretory
                + "/"
                + str(camera)
                + "/"
                + str(capture_dir)
            )
            all_capture_files = client.list_from_directory(list_dir)
            logger.info("Processing capture directory %s", list_dir)
            download_dir = (
                prisma_capture_diretory
                + "/"
                + str(camera)
                + "/"
                + str(capture_dir)
            )
            if not os.path.isdir(download_dir):
                os.makedirs(download_dir)

            for f in all_capture_files:
                check_name = str(str(f.decode()).split("_")[1])[:8]
                if check_name in day_capture_directories:
                    remote_file = list_dir + "/" + str(f.decode())
                    local_file = download_dir + "/" + str(f.decode())
                    logger.debug("Processing capture file %s", remote_file)
                    yield {
                        "remote_file": remote_file,
                        "local_file": local_file,
                    }
    logger.info("Get capture of the last %s days...DONE", last_n_days)


async def download_one(client, remote_file, local_file, sem):
    async with sem:
        if not os.path.isfile(local_file) and "jpg" not in local_file:
            logger.info("Downloading %s", remote_file)
            await client.download_file(remote_file, local_file)
            logger.info("DONE")


async def main_loop():
    while True:

        st = datetime.datetime.fromtimestamp(time.time()).strftime(
            "%Y-%m-%d %H:%M:%S"
        )
        logger.info("Start execution at %s", st)

        camera_codes = get_camera_code("/solutions.ini")

        sem = Semaphore(DOWNLOAD_LIMIT)
        tasks = list()

        try:
            client = PRISMASSHClient(fripon_address, user=fripon_username)

            captures = get_captures_to_sync(client, camera_codes.keys())
            for f in captures:
                tasks.append(
                    ensure_future(
                        download_one(
                            client, f["remote_file"], f["local_file"], sem
                        )
                    )
                )

            single = get_single_events_to_sync(client, camera_codes.keys())
            for f in single:
                tasks.append(
                    ensure_future(
                        download_one(
                            client, f["remote_file"], f["local_file"], sem
                        )
                    )
                )

            events = get_multiple_events_to_sync(client, camera_codes.keys())
            for f in events:
                tasks.append(
                    ensure_future(
                        download_one(
                            client, f["remote_file"], f["local_file"], sem
                        )
                    )
                )

            logger.info("Start downloading")

            await gather(*tasks)

            logger.info("Done downloading")
        finally:
            client.close()

        st = datetime.datetime.fromtimestamp(time.time()).strftime(
            "%Y-%m-%d %H:%M:%S"
        )
        logger.info("Stop execution at %s", st)
        time.sleep(SLEEP_TIME)
