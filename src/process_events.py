import getopt
import sys

from prisma.event import main_loop

# parse arguments
try:
    opts, args = getopt.getopt(sys.argv[1:], "m:", ["months="])

except getopt.GetoptError:
    print("Please provide proper arguments.")
    print("Usage: $python3 process_events.py --m=<months>")
    sys.exit(2)
for opt, arg in opts:
    if opt in ("-m", "--months"):
        last_n_days = int(arg)*30

if __name__ == "__main__":
    main_loop()
