import datetime

from prisma.calibrate import days_in_month


def test_day_in_month():
    month_str = "202106"
    month = int(month_str[4:6])
    year = int(month_str[0:4])
    days = days_in_month(month, year)
    res_days = []
    for x in range(days):
        mydate = datetime.date(year, month, x + 1)
        res_days.append(mydate.strftime("%Y%m%d"))
    assert "20210601" in res_days
    assert "20210630" in res_days
