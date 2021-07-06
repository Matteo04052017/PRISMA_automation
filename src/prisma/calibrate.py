# pylint: disable=unused-variable
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

last_n_days = 30
errors = []


def leap_year(year):
    if year % 400 == 0:
        return True
    if year % 100 == 0:
        return False
    if year % 4 == 0:
        return True
    return False


def days_in_month(month, year):
    if month in {1, 3, 5, 7, 8, 10, 12}:
        return 31
    if month == 2:
        if leap_year(year):
            return 29
        return 28
    return 30


def is_calibrated(camera_code, day):
    for check_file in check_files:
        filename = [camera_code, day, check_file]
        local_file = "_".join(filename)
        complete_path = f"/astrometry/workspace/astrometry/{camera_code}/{day[0:6]}/{local_file}"  # noqa: E501
        if not os.path.isfile(complete_path):
            logger.info("Missing %s for calibration", complete_path)
            return False
    return True


def is_month_complete(camera_code, month_str):
    month = int(month_str[4:6])
    year = int(month_str[0:4])
    days = days_in_month(month, year)
    for x in range(days):
        mydate = datetime.date(year, month, x + 1)
        if not is_calibrated(camera_code, mydate.strftime("%Y%m%d")):
            return False
    return True


def calibrate_byday(day_capture_directories, camera_list):
    for c in camera_list:
        for d in day_capture_directories:
            error_str = "(%s, %s)", c, d
            if error_str in errors:
                continue
            if is_calibrated(c, d):
                logger.info("is_calibrated(%s, %s) True", c, d)
                continue
            cmd = [
                "bash",
                "-c",
                f"/usr/local/harris/idl/bin/idl -e \"calibration, '{c}', '{d}', process_image=1, process_day=1, process_month=0, config_file='/astrometry/workspace/settings/configuration.ini'\"",  # noqa: E501
            ]
            separator = " "
            logger.info(separator.join(cmd))
            try:
                output = subprocess.run(cmd, universal_newlines=True, check=True)
                if "Execution halted" in output.stdout:
                    errors.append(error_str)
            except Exception as ex:
                logger.error("%s", ex)
                errors.append(error_str)
                errors.append("calibration error for (%s, %s)", c, d)


def calibrate_bymonth(month_capture_directories, camera_list):
    for c in camera_list:
        for m in month_capture_directories:
            error_str = "(%s, %s)", c, m
            if error_str in errors:
                continue
            if not is_month_complete(c, m):
                logger.info("is_month_complete(%s, %s) False", c, m)
                continue
            cmd = [
                "bash",
                "-c",
                f"/usr/local/harris/idl/bin/idl -e \"calibration, '{c}', '{m}', process_image=0, process_day=0, process_month=1, config_file='/astrometry/workspace/settings/configuration.ini'\"",  # noqa: E501
            ]
            separator = " "
            logger.info(separator.join(cmd))
            try:
                subprocess.run(cmd, universal_newlines=True, check=True)
            except Exception as ex:
                logger.error("%s", ex)
                errors.append(error_str)
                logger.error("calibration error for (%s, %s)", c, m)


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

        day_capture_directories, month_capture_directories = get_days_to_work(
            last_n_days
        )

        calibrate_bymonth(month_capture_directories, camera_codes)

        calibrate_byday(day_capture_directories, camera_codes)

        logger.info("Stop execution at %s", st)
        time.sleep(SLEEP_TIME)
