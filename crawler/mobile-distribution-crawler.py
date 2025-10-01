import requests
import os
from datetime import datetime
from datetime import timedelta
import json
import csv
import io
import re

def formatFloat(floatValue):
    return re.sub('0+$|\.0+$', '', "{:.2f}".format(floatValue))

def find_market_share_key(rows):
    """尋找市場份額欄位的輔助函數"""
    if not rows or len(rows) == 0:
        return None

    # 嘗試使用上個月
    previousMonth = datetime.now().replace(day=1) - timedelta(days=1)
    market_share_key = None

    for date_format in date_formats:
        try:
            market_share_key = f'Market Share Perc. ({previousMonth.strftime(date_format)})'
            if market_share_key in rows[0]:
                print(f"找到欄位: {market_share_key}")
                return market_share_key
        except Exception as e:
            pass

    # 如果找不到，嘗試使用當前月份
    currentMonth = datetime.now()
    for date_format in date_formats:
        try:
            market_share_key = f'Market Share Perc. ({currentMonth.strftime(date_format)})'
            if market_share_key in rows[0]:
                print(f"使用當前月份欄位: {market_share_key}")
                return market_share_key
        except Exception as e:
            pass

    # 如果還是找不到，列出所有可用的欄位並嘗試自動匹配
    print(f"可用的欄位: {list(rows[0].keys())}")
    for key in rows[0].keys():
        if key.startswith('Market Share Perc.'):
            market_share_key = key
            print(f"自動匹配到欄位: {market_share_key}")
            return market_share_key

    return None

# 獲取腳本所在目錄
script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(script_dir)
baseDir = os.path.join(script_dir, 'resources')
outputDir = os.path.join(project_root, 'resources')

# 確保目錄存在
os.makedirs(baseDir, exist_ok=True)
os.makedirs(outputDir, exist_ok=True)

# 計算上個月的日期
previousMonth = datetime.now().replace(day=1) - timedelta(days=1)
queryMonth = previousMonth.strftime('%Y-%m')
queryMonthInt = previousMonth.strftime('%Y%m')
queryMonthAbbr = previousMonth.strftime('%b %Y')
queryMonthLongName = previousMonth.strftime('%B %Y')

# 定義 CSV 檔案的可能日期格式
date_formats = [
    "%Y-%m",
    "%Y%m",
    "%b %Y",
    "%B %Y"
]

def rearrange_name(data):
    processed_data = []
    for row in data:
        if len(row) >= 2 and isinstance(row[0], str):
            parts = row[0].split(' ', 1) # 以第一個空格分割字串，最多分割一次
            if len(parts) == 2:
                number_str, name = parts
                try:
                    float(number_str) # 嘗試將分割出的第一部分轉換為浮點數，判斷是否為數值
                    new_first_element = f"{name} {number_str}"
                    new_row = [new_first_element] + row[1:]
                    processed_data.append(new_row)
                except ValueError:
                    # 如果第一個空格分割出的第一部分不是數值，則不進行處理
                    processed_data.append(row)
            else:
                # 如果第一個元素中沒有空格，則不進行處理
                processed_data.append(row)
        else:
            # 如果子陣列長度小於 2 或第一個元素不是字串，則不進行處理
            processed_data.append(row)
    return processed_data

def process_outer_array_final(data):
    if len(data) >= 14:
        sum_of_values = round(sum(float(row[2]) for row in data[13:]), 2)
        if data:
            cacheLast = data[len(data) - 1]
            del data[13:] # 移除第 14 個及其之後的所有子陣列
            if data: # 再次檢查，確保移除後列表不為空
                cacheLast[2] = str(sum_of_values) # 將總和儲存到現在最後一個子陣列的最後一個位置
                data.append(cacheLast)
    return data

def process_outer_cumulative_array_final(data):
    if len(data) >= 14:
        result_value = 100.0 - float(data[12][2])
        if data:
            cacheLast = data[len(data) - 1]
            del data[13:] # 移除第 14 個及其之後的所有子陣列
            if data: # 再次檢查，確保移除後列表不為空
                cacheLast[2] = str(100.0) # 將總和儲存到現在最後一個子陣列的最後一個位置
                data.append(cacheLast)
    return data


# Android 版本名稱對照表
android_version_names = {
    "16.0": "Baklava",
    "15.0": "Vanilla Ice",
    "14.0": "Upside Down Cake",
    "13.0": "Tiramisu",
    "12.0": "Snow Cone",
    "11.0": "Red Velvet Cake",
    "10.0": "Quince Tart"
}

# 抓取和處理 Android 資料的函式
def fetch_and_process_android_data(csv_url):
    try:
        csv_response = requests.get(csv_url)
        csv_data = io.StringIO(csv_response.text)
        reader = csv.DictReader(csv_data)
        rows = list(reader)
    except Exception as e:
        print(f"錯誤: {e}")
        return None

    # 使用輔助函數尋找市場份額欄位
    market_share_key = find_market_share_key(rows)
    if market_share_key is None:
        print("找不到市場份額的欄位")
        return None

    # 過濾掉 Android 版本中兩位數且以 2 開頭的版本
    filtered_rows = []
    for row in rows:
        version = row.get('Android Version')
        if version == 'Other':
            filtered_rows.append(row)
            continue
        try:
            # 使用正則表達式匹配 Android 版本號
            pattern = r'^(\d+\.?\d*)'
            version_number = float(re.search(pattern, version).group(1))
            if not (20 <= version_number < 30 and version_number % 1 != 0):
                filtered_rows.append(row)
        except (ValueError, AttributeError):
            print(f"無法解析版本號：{version}")

    # 定義排序鍵函式
    def android_sort_key(x):
        match = re.search(r'^(\d+\.?\d*)', x.get('Android Version'))
        if match:
            return float(match.group(1))
        else:
            return -1  # 如果找不到版本號，則使用 -1

    # 依照版本號排序
    sorted_rows = sorted(filtered_rows, key=lambda x: android_sort_key(x), reverse=True)
    len = sorted_rows.__len__()
    print(f"Android Raw版本數量: {len}")

    other_percentage = 0.0
    processed_rows = []
    for i, row in enumerate(sorted_rows):
        market_share = float(row[market_share_key])
        if i < 13:
            version = row['Android Version']
            # 使用正則表達式匹配 Android 版本號
            pattern = r'^(\d+\.?\d*)'
            version_number = re.search(pattern, version).group(1)
            # 檢查版本號是否 >= 10.0 且存在於 android_version_names 中
            if float(version_number) >= 10.0 and version_number in android_version_names:
                # 若存在，則將版本號加上對應的字串
                version_name = f"{version_number} {android_version_names[version_number]}"
            else:
                version_name = version
            processed_rows.append([version_name, version_number, str(market_share)])
        else:
            # 將剩餘版本的市佔率加總到 other_percentage
            other_percentage += market_share

    # 新增 "Other" 到 processed_rows
    if other_percentage > 0:
        processed_rows.append(['Other', "-1", formatFloat(other_percentage)])

    # 計算累積分佈
    cumulative_percentage = 0.0
    cumulative_rows = []
    for row in processed_rows:
        cumulative_percentage += float(row[2])
        cumulative_rows.append([row[0], row[1], formatFloat(cumulative_percentage)])

    # 累積分佈使用版本號排序，最新的版本在前面
    cumulative_rows.sort(key=lambda x: float(x[1]) if x[1] != "-1" else -1, reverse=True)
    len = cumulative_rows.__len__()
    print(f"Android 累積分佈版本數量: {len}")
    
    processed_rows = process_outer_array_final(rearrange_name(processed_rows))
    cumulative_rows = process_outer_cumulative_array_final(rearrange_name(cumulative_rows))
    
    result = [
        {'最後更新': queryMonthLongName},
        {'版本分佈': processed_rows},
        {'累積分佈': cumulative_rows}
    ]
    return result

    try:
        csv_response = requests.get(csv_url)
        csv_data = io.StringIO(csv_response.text)
        reader = csv.DictReader(csv_data)
        rows = list(reader)
    except Exception as e:
        print(f"錯誤: {e}")
        return None

    # 使用輔助函數尋找市場份額欄位
    market_share_key = find_market_share_key(rows)
    if market_share_key is None:
        print("找不到市場份額的欄位")
        return None

    # 定義排序鍵函式
    def ios_sort_key(x):
        match = re.search(r'iOS (\d+\.?\d*)\s*', x.get('iOS Version'))
        if match:
            return -float(match.group(1))
        else:
            return -1  # 如果找不到版本號，則使用 -1

    # 依照版本號排序
    sorted_rows = sorted(rows, key=lambda x: ios_sort_key(x), reverse=True)

    other_percentage = 0.0
    processed_rows = []
    for i, row in enumerate(sorted_rows):
        market_share = float(row[market_share_key])
        if i < 13:
            version = row['iOS Version']
            # 使用正則表達式匹配 iOS 版本號
            pattern = r'iOS (\d+\.?\d*)'
            version_number = re.search(pattern, version).group(1) if re.search(pattern, version) else "-1"
            processed_rows.append([version, version_number, str(market_share)])
        else:
            # 將剩餘版本的市佔率加總到 other_percentage
            other_percentage += market_share

    # 新增 "Other" 到 processed_rows
    if other_percentage > 0:
        processed_rows.append(['Other', "-1", formatFloat(other_percentage)])

    # 計算累積分佈
    cumulative_percentage = 0.0
    cumulative_rows = []
    for row in processed_rows:
        cumulative_percentage += float(row[2])
        cumulative_rows.append([row[0], row[1], formatFloat(cumulative_percentage)])

    # 累積分佈使用版本號排序，最新的版本在前面
    # 因為 iOS 版本號格式固定，所以直接使用版本號排序即可
    cumulative_rows.sort(key=lambda x: float(x[1]) if x[1] != "-1" else -1, reverse=True)

    return {
        '最後更新': queryMonthLongName,
        '版本分佈': processed_rows,
        '累積分佈': cumulative_rows
    }


    try:
        csv_response = requests.get(csv_url)
        csv_data = io.StringIO(csv_response.text)
        reader = csv.DictReader(csv_data)
        rows = list(reader)
    except Exception as e:
        print(f"錯誤: {e}")
        return None

    # 使用輔助函數尋找市場份額欄位
    market_share_key = find_market_share_key(rows)
    if market_share_key is None:
        print("找不到市場份額的欄位")
        return None

    # 定義排序鍵函式
    def ios_sort_key(x):
        match = re.search(r'iOS (\d+\.?\d*)\s*', x.get('iOS Version'))
        if match:
            return -float(match.group(1))
        else:
            return -1  # 如果找不到版本號，則使用 -1

    # 依照版本號排序
    sorted_rows = sorted(rows, key=lambda x: ios_sort_key(x), reverse=True)

    other_percentage = 0.0
    processed_rows = []
    for i, row in enumerate(sorted_rows):
        market_share = float(row[market_share_key])
        if i < 13:
            version = row['iOS Version']
            # 使用正則表達式匹配 iOS 版本號
            pattern = r'iOS (\d+\.?\d*)'
            version_number = re.search(pattern, version).group(1) if re.search(pattern, version) else "-1"
            processed_rows.append([version, version_number, str(market_share)])
        else:
            # 將剩餘版本的市佔率加總到 other_percentage
            other_percentage += market_share

    # 新增 "Other" 到 processed_rows
    if other_percentage > 0:
        processed_rows.append(['Other', "-1", formatFloat(other_percentage)])

    # 將 "Other" 排序到最後
    processed_rows.sort(key=lambda x: x[0] == 'Other')

    # 計算累積分佈
    cumulative_percentage = 0.0
    cumulative_rows = []
    for row in processed_rows:
        cumulative_percentage += float(row[2])
        cumulative_rows.append([row[0], row[1], formatFloat(cumulative_percentage)])

    # 累積分佈使用市佔率排序
    cumulative_rows.sort(key=lambda x: float(x[2]), reverse=True)

    return {
        '最後更新': queryMonthLongName,
        '版本分佈': processed_rows,
        '累積分佈': cumulative_rows
    }

# 抓取和處理 iOS 資料的函式

    try:
        csv_response = requests.get(csv_url)
        csv_data = io.StringIO(csv_response.text)
        reader = csv.DictReader(csv_data)
        rows = list(reader)
    except Exception as e:
        print(f"錯誤: {e}")
        return None

    # 使用輔助函數尋找市場份額欄位
    market_share_key = find_market_share_key(rows)
    if market_share_key is None:
        print("找不到市場份額的欄位")
        return None

    # 定義排序鍵函式
    def ios_sort_key(x):
        match = re.search(r'iOS (\d+\.?\d*)\s*', x.get('iOS Version'))
        if match:
            return -float(match.group(1))
        else:
            return -1  # 如果找不到版本號，則使用 -1

    # 依照版本號排序
    sorted_rows = sorted(rows, key=lambda x: ios_sort_key(x), reverse=True)

    other_percentage = 0.0
    processed_rows = []
    for row in sorted_rows:
        market_share = float(row[market_share_key])
        version = row['iOS Version']
        # 使用正則表達式匹配 iOS 版本號
        pattern = r'iOS (\d+\.?\d*)'
        version_number = re.search(pattern, version).group(1) if re.search(pattern, version) else "-1"
        processed_rows.append([version, version_number, str(market_share)])

    # 計算累積分佈
    cumulative_percentage = 0.0
    cumulative_rows = []
    for row in processed_rows:
        cumulative_percentage += float(row[2])
        cumulative_rows.append([row[0], row[1], formatFloat(cumulative_percentage)])

    # 累積分佈使用版本號排序，最新的版本在前面
    cumulative_rows.sort(key=lambda x: float(x[1]) if x[1] != "-1" else -1, reverse=True)

    return {
        '最後更新': queryMonthLongName,
        '版本分佈': processed_rows,
        '累積分佈': cumulative_rows
    }


    try:
        csv_response = requests.get(csv_url)
        csv_data = io.StringIO(csv_response.text)
        reader = csv.DictReader(csv_data)
        rows = list(reader)
    except Exception as e:
        print(f"錯誤: {e}")
        return None

    # 使用輔助函數尋找市場份額欄位
    market_share_key = find_market_share_key(rows)
    if market_share_key is None:
        print("找不到市場份額的欄位")
        return None

    # 定義排序鍵函式
    def ios_sort_key(x):
        match = re.search(r'iOS (\d+\.?\d*)\s*', x.get('iOS Version'))
        if match:
            return -float(match.group(1))
        else:
            return -1  # 如果找不到版本號，則使用 -1

    # 依照版本號排序
    sorted_rows = sorted(rows, key=lambda x: ios_sort_key(x), reverse=True)

    other_percentage = 0.0
    processed_rows = []
    for row in sorted_rows:
        market_share = float(row[market_share_key])
        version = row['iOS Version']
        # 使用正則表達式匹配 iOS 版本號
        pattern = r'iOS (\d+\.?\d*)'
        version_number = re.search(pattern, version).group(1) if re.search(pattern, version) else "-1"
        processed_rows.append([version, version_number, str(market_share)])


    # 計算累積分佈
    cumulative_percentage = 0.0
    cumulative_rows = []
    for row in processed_rows:
        cumulative_percentage += float(row[2])
        cumulative_rows.append([row[0], row[1], formatFloat(cumulative_percentage)])

    # 累積分佈使用版本號排序，最新的版本在前面
    cumulative_rows.sort(key=lambda x: float(x[1]) if x[1] != "-1" else -1, reverse=True)

    # 版本分佈使用市佔率排序
    processed_rows.sort(key=lambda x: float(x[2]), reverse=True)

    return {
        '最後更新': queryMonthLongName,
        '版本分佈': processed_rows,
        '累積分佈': cumulative_rows
    }


    try:
        csv_response = requests.get(csv_url)
        csv_data = io.StringIO(csv_response.text)
        reader = csv.DictReader(csv_data)
        rows = list(reader)
    except Exception as e:
        print(f"錯誤: {e}")
        return None

    # 使用輔助函數尋找市場份額欄位
    market_share_key = find_market_share_key(rows)
    if market_share_key is None:
        print("找不到市場份額的欄位")
        return None

    # 定義排序鍵函式
    def ios_sort_key(x):
        match = re.search(r'iOS (\d+\.?\d*)\s*', x.get('iOS Version'))
        if match:
            return -float(match.group(1))
        else:
            return -1  # 如果找不到版本號，則使用 -1

    # 依照版本號排序
    sorted_rows = sorted(rows, key=lambda x: ios_sort_key(x), reverse=True)

    other_percentage = 0.0
    processed_rows = []
    for row in sorted_rows:
        market_share = float(row[market_share_key])
        version = row['iOS Version']
        # 使用正則表達式匹配 iOS 版本號
        pattern = r'iOS (\d+\.?\d*)'
        version_number = re.search(pattern, version).group(1) if re.search(pattern, version) else "-1"
        processed_rows.append([version, version_number, str(market_share)])

    # 計算累積分佈
    cumulative_percentage = 0.0
    cumulative_rows = []
    for row in processed_rows:
        cumulative_percentage += float(row[2])
        cumulative_rows.append([row[0], row[1], formatFloat(cumulative_percentage)])

    # 累積分佈以市佔率降冪排序
    cumulative_rows.sort(key=lambda x: float(x[2]), reverse=True)

    return {
        '最後更新': queryMonthLongName,
        '版本分佈': processed_rows,
        '累積分佈': cumulative_rows
    }


    try:
        csv_response = requests.get(csv_url)
        csv_data = io.StringIO(csv_response.text)
        reader = csv.DictReader(csv_data)
        rows = list(reader)
    except Exception as e:
        print(f"錯誤: {e}")
        return None

    # 使用輔助函數尋找市場份額欄位
    market_share_key = find_market_share_key(rows)
    if market_share_key is None:
        print("找不到市場份額的欄位")
        return None

    # 定義排序鍵函式
    def ios_sort_key(x):
        match = re.search(r'iOS (\d+\.?\d*)\s*', x.get('iOS Version'))
        if match:
            return -float(match.group(1))
        else:
            return -1  # 如果找不到版本號，則使用 -1

    # **版本分佈**：依照版本號排序
    sorted_rows = sorted(rows, key=lambda x: ios_sort_key(x), reverse=True)

    other_percentage = 0.0
    processed_rows = []
    for row in sorted_rows:
        market_share = float(row[market_share_key])
        version = row['iOS Version']
        # 使用正則表達式匹配 iOS 版本號
        pattern = r'iOS (\d+\.?\d*)'
        version_number = re.search(pattern, version).group(1) if re.search(pattern, version) else "-1"
        processed_rows.append([version, version_number, str(market_share)])

    # 計算累積分佈
    cumulative_percentage = 0.0
    cumulative_rows = []
    for row in processed_rows:
        cumulative_percentage += float(row[2])
        cumulative_rows.append([row[0], row[1], formatFloat(cumulative_percentage)])

    # **累積分佈**: 以市佔率降冪排序
    cumulative_rows.sort(key=lambda x: float(x[2]), reverse=True)

    return {
        '最後更新': queryMonthLongName,
        '版本分佈': processed_rows,  # 使用已排序的 processed_rows
        '累積分佈': cumulative_rows
    }

# 抓取和處理 iOS 資料的函式
def fetch_and_process_ios_data(csv_url):
    try:
        print(f"抓取 iOS 資料: {csv_url}")
        csv_response = requests.get(csv_url)
        csv_data = io.StringIO(csv_response.text)
        reader = csv.DictReader(csv_data)
        rows = list(reader)
    except Exception as e:
        print(f"錯誤: {e}")
        return None

    # 使用輔助函數尋找市場份額欄位
    market_share_key = find_market_share_key(rows)
    if market_share_key is None:
        print("找不到市場份額的欄位")
        return None

    # 定義排序鍵函式
    def ios_sort_key(x):
        match = re.search(r'iOS (\d+\.?\d*)\s*', x.get('iOS Version'))
        if match:
            return -float(match.group(1))
        else:
            return -1  # 如果找不到版本號，則使用 -1

    # 依照版本號排序
    sorted_rows = sorted(rows, key=lambda x: ios_sort_key(x), reverse=False)
    len = sorted_rows.__len__()
    print(f"iOS Raw版本數量: {len}")

    other_percentage = 0.0
    processed_rows = []
    merged_percentage = 0.0
    versions_to_merge = []

    for row in sorted_rows:
        market_share = float(row[market_share_key])
        version = row['iOS Version']
        pattern = r'iOS (\d+\.?\d*)'
        version_number_match = re.search(pattern, version)
        
        if version_number_match:
            version_number = float(version_number_match.group(1))
            if 19.0 <= version_number <= 26.0:
                merged_percentage += market_share
                versions_to_merge.append(version)
                continue

        processed_rows.append([version, version_number_match.group(1) if version_number_match else "-1", str(market_share)])

    if versions_to_merge:
        processed_rows.insert(0, ["iOS 26.0", "26.0", formatFloat(merged_percentage)])

    # 計算累積分佈
    cumulative_percentage = 0.0
    cumulative_rows = []
    for row in processed_rows:
        row = row.copy()  # 複製 row，避免修改原始資料
        cumulative_percentage += float(row[2])
        row[2] = formatFloat(cumulative_percentage)  # 更新累積市佔率
        cumulative_rows.append(row)  # 將修改後的 row 加入 cumulative_rows

    len = cumulative_rows.__len__()
    print(f"iOS 累積分佈版本數量: {len}")
    
    process_outer_array_final(processed_rows)
    process_outer_cumulative_array_final(cumulative_rows)

    result = [
        {'最後更新': queryMonthLongName},
        {'版本分佈': processed_rows},
        {'累積分佈': cumulative_rows}
    ]
    return result

# 產生 Android 和 iOS 的 CSV 網址
iOSCsvUrl = f"https://gs.statcounter.com/ios-version-market-share/mobile-tablet/worldwide/chart.php?bar=1&device=Mobile%20%26%20Tablet&device_hidden=mobile%2Btablet&multi-device=true&statType_hidden=ios_version&region_hidden=ww&granularity=monthly&statType=iOS%20Version&region=Worldwide&fromInt={queryMonthInt}&toInt={queryMonthInt}&fromMonthYear={queryMonth}&toMonthYear={queryMonth}&csv=1"
androidCsvUrl = f"https://gs.statcounter.com/android-version-market-share/mobile-tablet/worldwide/chart.php?bar=1&device=Mobile%20%26%20Tablet&device_hidden=mobile%2Btablet&multi-device=true&statType_hidden=android_version&region_hidden=ww&granularity=monthly&statType=Android%20Version&region=Worldwide&fromInt={queryMonthInt}&toInt={queryMonthInt}&fromMonthYear={queryMonth}&toMonthYear={queryMonth}&csv=1"

# 抓取和處理 Android 資料
android_result = fetch_and_process_android_data(androidCsvUrl)
if android_result:
    # 將資料轉換為 JSON
    android_json_data = json.dumps(android_result, ensure_ascii=False, indent=4)
    try:
        # 儲存 JSON 檔案到輸出目錄
        output_path = os.path.join(outputDir, 'android-distribution.json')
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(android_json_data)
        print(f'Android 資料已儲存至: {output_path}')
    except ValueError as e:
        print(f'invalid json: {e}')

# 抓取和處理 iOS 資料
ios_result = fetch_and_process_ios_data(iOSCsvUrl)
if ios_result:
    # 將資料轉換為 JSON
    ios_json_data = json.dumps(ios_result, ensure_ascii=False, indent=4)
    try:
        # 儲存 JSON 檔案到輸出目錄
        output_path = os.path.join(outputDir, 'ios-distribution.json')
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(ios_json_data)
        print(f'iOS 資料已儲存至: {output_path}')
    except ValueError as e:
        print(f'invalid json: {e}')