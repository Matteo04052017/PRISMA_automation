import datetime
import logging
import os
import subprocess
import time

from prisma.settings import get_camera_code, get_days_to_work

SLEEP_TIME = 1800  # 30 minutes
DOWNLOAD_LIMIT = 5

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)

last_n_days = 30


def is_calibrated(camera_code, day):
    # ITCP02_20210614_assoc.txt
    # ITCP02_20210614_astro_covar.txt
    # ITCP02_20210614_astro_error.txt
    # ITCP02_20210614_astro_param.txt
    # ITCP02_20210614_astro_report.pdf
    # ITCP02_20210614_astro_sigma.txt
    # ITCP02_20210614_astro_solution.txt
    # ITCP02_20210614_photo_param.txt
    # ITCP02_20210614_photo_report.pdf
    # ITCP02_20210614_photo_sigma.txt
    # ITCP02_20210614_photo_solution.txt
    check_files = [
        "assoc.txt",
        "astro_covar.txt",
        "astro_error.txt",
        "astro_param.txt",
        "astro_report.pdf",
        "astro_sigma.txt",
        "astro_solution.txt",
        "photo_param.txt",
        "photo_report.pdf",
        "photo_sigma.txt",
        "photo_solution.txt",
    ]
    for check_file in check_files:
        filename = [camera_code, day, check_file]
        logger.info("filename %s", filename)
        local_file = "_".join(filename)
        if not os.path.isfile(local_file):
            return False
    return True


def calibrate_byday(day_capture_directories, camera_list):
    for c in camera_list:
        for d in day_capture_directories:
            if is_calibrated(c, d):
                continue
            cmd = [
                "bash",
                "-c",
                f"/usr/local/harris/idl/bin/idl -e \"calibration, '{c}', '{d}', process_image=1, process_day=1, process_month=0, config_file='/astrometry/workspace/settings/configuration.ini'\"",  # noqa: E501
            ]
            separator = " "
            logger.info(separator.join(cmd))
            try:
                subprocess.run(cmd, universal_newlines=True, check=True)
            except Exception as ex:
                logger.error("%s", ex)


def main_loop():
    while True:
        st = datetime.datetime.fromtimestamp(time.time()).strftime(
            "%Y-%m-%d %H:%M:%S"
        )
        logger.info("Start execution at %s", st)

        camera_codes = get_camera_code(
            "/astrometry/workspace/settings/solutions.ini"
        )

        logger.info(camera_codes)

        res = get_days_to_work(last_n_days)

        calibrate_byday(res.day_capture_directories, camera_codes)

        logger.info("Stop execution at %s", st)
        time.sleep(SLEEP_TIME)
