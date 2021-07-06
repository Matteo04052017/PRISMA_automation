# pylint: disable=unused-variable
# idl -e "event, '20210602T220831_UT', config_file='/astrometry/settings/configuration.ini'"
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




