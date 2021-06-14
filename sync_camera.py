## get capture and events from camera 
import os, sys, getopt
import json
from archive import get_archived_files
from ssh_client import PRISMASSHClient
from datetime import date, timedelta

cameras_to_sync = [
    {
        "name": "itsi04", 
        "address": "10.8.0.7", 
        "username": "matteo",
        "acq_regulat_prefix": "racalmuto"
    },
    {
        "name": "teststation", 
        "address": "10.8.0.6", 
        "username": "root",
        "acq_regulat_prefix": "teststation"
    }
]
last_n_days = 5

## parse arguments
try:
    opts, args = getopt.getopt(sys.argv[1:], "i:d:", ["input_json_file=", "days_to_sync="])

except getopt.GetoptError:
    print("Please provide proper arguments.")
    print("Usage: $python3 sync_camera.py --i=<filename> --d=<days>")
    sys.exit(2)
for opt, arg in opts:
    if opt in ("-i", "--input_json_file"):
        with open(arg, "r") as read_file:
            cameras_to_sync = json.load(read_file)
    elif opt in ("-d", "--days_to_sync"):
        last_n_days = int(arg)

camera_data_folder = "/prismadata"
prisma_capture_diretory = "/prismadata/stations"
prisma_events_directory = "/prismadata/detections/single"

## get capture of the last n days
month_capture_directories = [date.today().strftime("%Y%m")]
today = date.today() #yesterday
from_date = today - timedelta(days=last_n_days)
time_elapsed = today - from_date

day_capture_directories = []
for x in range(time_elapsed.days):
    date_to_consider = today - timedelta(days=x)
    day_capture_directories.append(date_to_consider.strftime("%Y%m%d"))

for camera in cameras_to_sync:
    camera_address = camera["address"]
    camera_username = camera["username"]
    camera_name = camera["name"]
    acq_regulat_prefix = camera["acq_regulat_prefix"]

    client = PRISMASSHClient(camera_address, camera_username)

    try:
        for day in day_capture_directories:
            camera_directory_to_sync = camera_data_folder + "/" + acq_regulat_prefix + "/" + camera_name + "_" + day
            files_to_sync = client.list_from_directory(camera_directory_to_sync + "/captures")

            for f in files_to_sync:
                local_directory = prisma_capture_diretory + "/" + camera_name + "/" + day[:6]
                if not os.path.isdir(local_directory):
                    os.makedirs(local_directory)
                remote_file = camera_directory_to_sync + "/captures/" + str(f.decode())
                local_file = local_directory + "/" + str(f.decode())
                if not os.path.isfile(local_file) or not client.size_of_file(remote_file) == os.stat(local_file).st_size:
                    client.download_file(remote_file, local_file)

            events_folder_to_sync = client.list_from_directory(camera_directory_to_sync + "/events")
            for event_folder in events_folder_to_sync:
                complete_remote_path_to_sync = camera_directory_to_sync + "/events"
                files_to_sync = client.list_from_directory(camera_directory_to_sync + "/events/" + str(event_folder.decode()))
                for f in files_to_sync:
                    remote_file = camera_directory_to_sync + "/events/" + str(event_folder.decode()) + "/" + str(f.decode())
                    local_directory = prisma_events_directory + "/" + camera_name + "/" + day[:6] + "/" + str(event_folder.decode())
                    if not os.path.isdir(local_directory):
                        os.makedirs(local_directory)
                    local_file = local_directory + "/" + str(f.decode())
                    if not os.path.isfile(local_file) or not client.size_of_file(remote_file) == os.stat(local_file).st_size:
                        client.download_file(remote_file, local_file)
    finally:
        client.close()
