## get capture and events from ftp fripon

import shutil
import tarfile
import os
from datetime import date, timedelta
from archive import get_archived_files
from ssh_client import PRISMASSHClient

fripon_address = "ssh.fripon.org"
fripon_username = "dgardiol"
#fripon_password = None
fripon_capture_diretory = "/data/fripon_stations"
fripon_events_directory = "/data/fripon_detections/multiple"
cameras_to_sync = ["ITER01"]
prisma_capture_diretory = "/prismadata/stations"
prisma_events_directory = "/prismadata/detections/multiple"
last_n_days = 5

## get capture of the last n days
month_capture_directories = [date.today().strftime("%Y%m")]
to_date = date.today() - timedelta(days=1) #yesterday
from_date = to_date - timedelta(days=last_n_days)
time_elapsed = to_date - from_date
for x in range(int(time_elapsed.days / 30)):
    date_to_consider = to_date - timedelta(days=x)
    month_capture_directories.append(date_to_consider.strftime("%Y%m"))

day_capture_directories = []
for x in range(time_elapsed.days):
    date_to_consider = to_date - timedelta(days=x)
    day_capture_directories.append(date_to_consider.strftime("%Y%m%d"))

try:
    client = PRISMASSHClient(fripon_address, user=fripon_username)

    for camera in cameras_to_sync:
        for capture_dir in month_capture_directories: 
            list_dir = fripon_capture_diretory + "/" + str(camera) + "/" + str(capture_dir)
            all_capture_files = client.list_from_directory(list_dir)
            
            download_dir = prisma_capture_diretory + "/" + str(camera) + "/" + str(capture_dir)
            if not os.path.isdir(download_dir):
                os.makedirs(download_dir)

            for f in all_capture_files:
                check_name = str(str(f.decode()).split('_')[1])[:8]
                if check_name in day_capture_directories:
                    remote_file = list_dir + "/" + str(f.decode())
                    local_file = download_dir + "/" + str(f.decode())
                    client.download_file(remote_file, local_file)
finally:
    client.close()

