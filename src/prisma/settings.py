import logging
from datetime import date, timedelta

# create logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)


def get_camera_code(solution_ini_file):
    result = {}

    with open(solution_ini_file, "r") as reader:
        # Read & print the entire file
        lines = reader.readlines()
        for line in lines:
            if line.startswith("#") or len(line) < 6:
                continue
            split = line.split("      ")
            if len(split) > 0:
                result[split[0].strip()] = split[1].strip()
    return result


def get_days_to_work(last_n_days):
    logger.info("Get last_n_days %s days", last_n_days)
    month_capture_directories = [date.today().strftime("%Y%m")]
    to_date = date.today() - timedelta(days=1)  # yesterday
    from_date = to_date - timedelta(days=last_n_days)
    time_elapsed = to_date - from_date
    day_capture_directories = []
    for x in range(time_elapsed.days):
        date_to_consider = to_date - timedelta(days=x)
        str_month = date_to_consider.strftime("%Y%m")
        if str_month not in month_capture_directories:
            month_capture_directories.append(str_month)
        day_capture_directories.append(date_to_consider.strftime("%Y%m%d"))
    logger.info("Get last_n_days %s days", last_n_days)
    return day_capture_directories, month_capture_directories
