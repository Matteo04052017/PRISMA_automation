## get capture and events from camera 

import shutil
import tarfile
import os
import os.path
import sys, getopt
from archive import get_archived_files
from ssh_client import PRISMASSHClient

camera_name = "teststation"
camera_address = "10.8.0.8"
camera_directory_to_sync = "/prismadata/rsync"
capture_directory = "/prismadata/capture"
detection_directory  = "/prismadata/detection"

archived_already = []

## parse arguments
# try:
#     opts, args = getopt.getopt(sys.argv[1:], "a:d:l:", ["address=", "directory=", "local_directory="])

# except getopt.GetoptError:
#     print("Please provide proper arguments.")
#     print("Usage: $python sync_camera.py --address=<camera_address> --directory=<camera_directory_to_sync> --local_directory=<local_directory>")
#     sys.exit(2)
# for opt, arg in opts:
#     if opt in ("-a", "--address"):
#         camera_address = arg
#     if opt in ("-d", "--directory"):
#         camera_directory_to_sync = arg
#     if opt in ("-l", "--local_directory"):
#         local_directory = arg

client = PRISMASSHClient(camera_address, "system")

try:
    archived_already = get_archived_files()

    files_to_sync = client.list_from_directory(camera_directory_to_sync + "/capture")
    for f in files_to_sync:
        if not f in archived_already:
            camera_directory = capture_directory + "/" + camera_name 
            if not os.path.isdir(camera_directory):
                os.makedirs(camera_directory)
            remote_file = camera_directory_to_sync + "/capture/" + str(f.decode())
            local_file = camera_directory + "/" + str(f.decode())
            if not os.path.isfile(local_file) or not client.size_of_file(remote_file) == os.stat(local_file).st_size:
                client.download_file(remote_file, local_file)

    files_to_sync = client.list_from_directory(camera_directory_to_sync + "/events")
    for f in files_to_sync:
        if not f in archived_already:
            if not os.path.isdir(detection_directory):
                os.makedirs(detection_directory)
            remote_file = camera_directory_to_sync + "/events/" + str(f.decode())
            local_file = detection_directory + "/" + str(f.decode())
            if not os.path.isfile(local_file) or not client.size_of_file(remote_file) == os.stat(local_file).st_size:
                client.download_file(remote_file, local_file)

finally:
    client.close()
