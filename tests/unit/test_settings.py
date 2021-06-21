from datetime import date, timedelta

from prisma.settings import get_camera_code, get_days_to_work

cameras_to_sync = [
    "ITCL01",
    "ITCP01",
    "ITCP02",
    "ITCP03",
    "ITCP04",
    "ITER01",
    "ITER02",
    "ITER03",
    "ITER04",
    "ITER05",
    "ITER06",
    "ITER07",
    "ITER08",
    "ITFV01",
    "ITFV02",
    "ITLA01",
    "ITLA02",
    "ITLI01",
    "ITLI02",
    "ITLO01",
    "ITLO02",
    "ITLO03",
    "ITLO04",
    "ITLO05",
    "ITMA01",
    "ITMA02",
    "ITMA03",
    "ITPI01",
    "ITPI02",
    "ITPI03",
    "ITPI04",
    "ITPI05",
    "ITPI06",
    "ITPU01",
    "ITPU02",
    "ITPU03",
    "ITSA01",
    "ITSA02",
    "ITSA03",
    "ITSI01",
    "ITSI02",
    "ITSI03",
    "ITTA01",
    "ITTA02",
    "ITTN02",
    "ITTO01",
    "ITTO02",
    "ITTO03",
    "ITTO04",
    "ITTO05",
    "ITTO06",
    "ITTO07",
    "ITUM01",
    "ITUM02",
    "ITVA01",
    "ITVE01",
    "ITVE02",
    "ITVE03",
    "ITVE04",
    "ITVE05",
    "ITVE06",
]


def test_get_camera_code():
    codes = get_camera_code(
        "idl/astrometry_v1.30/workspace/settings/solutions.ini"
    )
    for code in codes:
        assert code in cameras_to_sync

    for key in codes.keys():
        assert key in cameras_to_sync


def test_last_n_days():
    day_capture_directories, month_capture_directories = get_days_to_work(10)
    for i in range(10):
        check = date.today() - timedelta(days=i + 1)
        assert check.strftime("%Y%m%d") in day_capture_directories
        assert check.strftime("%Y%m") in month_capture_directories
