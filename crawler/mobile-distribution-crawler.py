import requests
import os
from datetime import datetime
from bs4 import BeautifulSoup
import json
import csv
import io
from time import strptime


# url = "https://gs.statcounter.com/os-version-market-share/ios/mobile-tablet/worldwide#monthly-202402-202402-bar"
# url = "https://gs.statcounter.com/os-version-market-share/android/mobile-tablet/worldwide#monthly-202402-202402-bar"

baseDir = 'crawler/resources'

# get current date in format yyyy-mm
now = datetime.now()
currentMonth = now.strftime('%Y-%m')
currentMonthInt = now.strftime('%Y%m')
currentMonthAbbr = now.strftime('%b %Y')
currentMonthLongName = now.strftime('%B, %Y')
print(f'currentMonth: {currentMonth}, currentMonthInt: {currentMonthInt}, currentMonthAbbr: {currentMonthAbbr}, currentMonthLongName: {currentMonthLongName}')

iOSCsvUrl = f"https://gs.statcounter.com/ios-version-market-share/mobile-tablet/worldwide/chart.php?bar=1&device=Mobile%20%26%20Tablet&device_hidden=mobile%2Btablet&multi-device=true&statType_hidden=ios_version&region_hidden=ww&granularity=monthly&statType=iOS%20Version&region=Worldwide&fromInt={currentMonthInt}&toInt={currentMonthInt}&fromMonthYear={currentMonth}&toMonthYear={currentMonth}&csv=1"

androidCsvUrl = f"https://gs.statcounter.com/android-version-market-share/mobile-tablet/worldwide/chart.php?bar=1&device=Mobile%20%26%20Tablet&device_hidden=mobile%2Btablet&multi-device=true&statType_hidden=android_version&region_hidden=ww&granularity=monthly&statType=Android%20Version&region=Worldwide&fromInt={currentMonthInt}&toInt={currentMonthInt}&fromMonthYear={currentMonth}&toMonthYear={currentMonth}&csv=1"


androidCsvResponse = requests.get(androidCsvUrl)


androidCsv = io.StringIO(androidCsvResponse.text)
# 讀取 CSV 資料
reader = csv.DictReader(androidCsv)
rows = list(reader)


androidOtherPercentage = 0
androidFilteredRows = []

# 過濾掉市場份額小於 1% 的 Android 版本, 並將其歸類為 Other
for row in rows:
    if float(row['Market Share Perc. (Mar 2024)']) < 1 or row['Android Version'] == 'Other':
        androidOtherPercentage += float(row[f'Market Share Perc. ({currentMonthAbbr})'])
    else :
        androidFilteredRows.append([row['Android Version'], row['Android Version'].split(' ')[0],row[f'Market Share Perc. ({currentMonthAbbr})']])    

androidFilteredRows.append(['Other', "-1", "{:.1f}".format(androidOtherPercentage)])

# 處理累積分佈, 按Android版本排序 14 > 13 > 12 > 11 > 10 > ... > Other
sortedAndroidFilteredRows = androidFilteredRows.copy()
sortedAndroidFilteredRows.sort(key=lambda x: float(x[1]), reverse=True)
androidCumulativePercentage = 0
androidCumulativeRows = []
for row in sortedAndroidFilteredRows:
    androidCumulativePercentage += float(row[2])
    androidCumulativeRows.append([row[0], row[1], "{:.1f}".format(androidCumulativePercentage)])
    
result = [
    {'最後更新': currentMonthLongName},
    {'版本分佈': androidFilteredRows},
    {'累積分佈': androidCumulativeRows}
]

# 將資料轉換為 JSON
json_data = json.dumps(result, ensure_ascii=False, indent=4)

try:
    json.loads(json_data)
    with open(f'{baseDir}/android-distribution.json', 'w', encoding='utf-8') as f:
        f.write(json_data) 
    os.system(f'mv {baseDir}/android-distribution.json ./resources/android-distribution.json')        
except ValueError as e:   
    print(f'invalid json: {e}')
    pass


# ========================

iOSCsvResponse = requests.get(iOSCsvUrl)
iOSCsv = io.StringIO(iOSCsvResponse.text)
# 讀取 CSV 資料
reader = csv.DictReader(iOSCsv)
rows = list(reader)

iOSOtherPercentage = 0
iOSFilteredRows = []

# 過濾掉市場份額小於 1% 的 iOS 版本, 並將其歸類為 Other
for row in rows:
    if float(row['Market Share Perc. (Mar 2024)']) < 1 or row['iOS Version'] == 'Other':
        iOSOtherPercentage += float(row[f'Market Share Perc. ({currentMonthAbbr})'])
    else :
        iOSFilteredRows.append([row['iOS Version'], row['iOS Version'].split(' ')[1], row[f'Market Share Perc. ({currentMonthAbbr})']])
        
iOSFilteredRows.append(['Other', "-1", "{:.1f}".format(iOSOtherPercentage)])        


sortedIoSFilteredRows = iOSFilteredRows.copy()
sortedIoSFilteredRows.sort(key=lambda x: float(x[1]), reverse=True)
iOSCumulativePercentage = 0
iOSCumulativeRows = []
for row in sortedIoSFilteredRows:
    iOSCumulativePercentage += float(row[2])
    iOSCumulativeRows.append([row[0], row[1], "{:.1f}".format(iOSCumulativePercentage)])
    
result = [
    {'最後更新': currentMonthLongName},
    {'版本分佈': iOSFilteredRows},
    {'累積分佈': iOSCumulativeRows}
]


# 將資料轉換為 JSON
json_data = json.dumps(result, ensure_ascii=False, indent=4)

try:
    json.loads(json_data)
    with open(f'{baseDir}/ios-distribution.json', 'w', encoding='utf-8') as f:
        f.write(json_data) 
    os.system(f'mv {baseDir}/ios-distribution.json ./resources/ios-distribution.json')        
except ValueError as e:   
    print(f'invalid json: {e}')
    pass