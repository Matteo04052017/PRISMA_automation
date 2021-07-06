# pylint: disable=unused-variable
import datetime
import logging
import os
import subprocess
import time

from prisma.settings import get_days_to_work

SLEEP_TIME = 1800  # 30 minutes
DOWNLOAD_LIMIT = 5

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)

last_n_days = 180
errors = []


def is_event_processed(event_str):
    logger.info(event_str)
    return False


def event(month_capture_directories):
    for month in month_capture_directories:
        for x in os.listdir(f"/astrometry/workspace/events/{month}"):
            if x in errors:
                continue
            if not os.path.isdir(x):
                continue
            if is_event_processed(x):
                logger.info("is_event_processed(%s) True. Continue.", x)
                continue

            cmd = [
                "bash",
                "-c",
                f"/usr/local/harris/idl/bin/idl -e \"event, '{x}', config_file='/astrometry/workspace/settings/configuration.ini'\"",  # noqa: E501
            ]
            separator = " "
            logger.info(separator.join(cmd))
            try:
                output = subprocess.run(
                    cmd,
                    universal_newlines=True,
                    check=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )
                logger.info(output.stdout)
                logger.error(output.stderr)
                if "Execution halted" in output.stdout:
                    errors.append(x)
            except Exception as ex:
                logger.error("%s", ex)
                errors.append(x)
                logger.append("idl event error for (%s)", x)


def main_loop():
    while True:
        st = datetime.datetime.fromtimestamp(time.time()).strftime(
            "%Y-%m-%d %H:%M:%S"
        )
        logger.info("Start execution at %s", st)

        day_capture_directories, month_capture_directories = get_days_to_work(
            last_n_days
        )

        event(month_capture_directories)

        logger.info("Stop execution at %s", st)
        time.sleep(SLEEP_TIME)
