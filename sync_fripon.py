# get capture and events from ftp fripon

# import shutil
# import tarfile
import os
import time
import datetime
# import getopt
from datetime import date, timedelta
# from archive import get_archived_files
from ssh_client import PRISMASSHClient

SLEEP_TIME = 1800 # 30 minutes
last_n_days = 5
cameras_to_sync = ["ITCL01", "ITCP01", "ITCP02", "ITCP03", "ITCP04", "ITER01", "ITER02", "ITER03", "ITER04", "ITER05", "ITER06", "ITER07", "ITER08", "ITFV01", "ITFV02", "ITLA01", "ITLA02", "ITLI01", "ITLI02", "ITLO01", "ITLO02", "ITLO03", "ITLO04", "ITLO05", "ITMA01", "ITMA02", "ITMA03", "ITPI01", "ITPI02", "ITPI03",
                   "ITPI04", "ITPI05", "ITPI06", "ITPU01", "ITPU02", "ITPU03", "ITSA01", "ITSA02", "ITSA03", "ITSI01", "ITSI02", "ITSI03", "ITTA01", "ITTA02", "ITTN02", "ITTO01", "ITTO02", "ITTO03", "ITTO04", "ITTO05", "ITTO06", "ITTO07", "ITUM01", "ITUM02", "ITVA01", "ITVE01", "ITVE02", "ITVE03", "ITVE04", "ITVE05", "ITVE06"]

# parse arguments
# try:
#     opts, args = getopt.getopt(sys.argv[1:], "d:", ["days_to_sync="])

# except getopt.GetoptError:
#     print("Please provide proper arguments.")
#     print("Usage: $python3 sync_fripon.py --d=<days>")
#     sys.exit(2)
# for opt, arg in opts:
#     elif opt in ("-d", "--days_to_sync"):
#         last_n_days = int(arg)

fripon_address = "ssh.fripon.org"
fripon_username = "dgardiol"
#fripon_password = None
fripon_capture_diretory = "/data/fripon_stations"
fripon_events_directory = "/data/fripon_detections/multiple"

prisma_capture_diretory = "/prismadata/stations"
prisma_events_directory = "/prismadata/detections/multiple"

while True:

    st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')
    print("Start execution at " + st)

    # get capture of the last n days
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

    try:
        client = PRISMASSHClient(fripon_address, user=fripon_username)
        print("Connected to " + fripon_address)
        for camera in cameras_to_sync:
            for capture_dir in month_capture_directories:
                list_dir = fripon_capture_diretory + "/" + \
                    str(camera) + "/" + str(capture_dir)
                all_capture_files = client.list_from_directory(list_dir)
                print("list_from_directory " + list_dir)
                download_dir = prisma_capture_diretory + \
                    "/" + str(camera) + "/" + str(capture_dir)
                if not os.path.isdir(download_dir):
                    os.makedirs(download_dir)

                for f in all_capture_files:
                    check_name = str(str(f.decode()).split('_')[1])[:8]
                    if check_name in day_capture_directories:
                        remote_file = list_dir + "/" + str(f.decode())
                        local_file = download_dir + "/" + str(f.decode())
                        if not os.path.isfile(local_file) or not client.size_of_file(remote_file) == os.stat(local_file).st_size:
                            print("Downloading %s", remote_file)
                            client.download_file(remote_file, local_file)
    finally:
        client.close()

    st = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')
    print("Stop execution at " + st)
    time.sleep(SLEEP_TIME)

