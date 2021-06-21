import getopt
import sys

from prisma.calibrate import main_loop

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

if __name__ == "__main__":
    main_loop()