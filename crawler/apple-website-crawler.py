import requests
import os
from datetime import datetime
from bs4 import BeautifulSoup
import json
from time import strptime


baseDir = 'crawler/resources'

def parseWatchOS(data):
    try:
        # 解析版本
        versionSplit = data[0].split(" ")
        platforms = [versionSplit[0]]
        version = versionSplit[1].split("\n")[0]
            
        # 解析发布日期
        release_date_parts = data[2].split(" ")
        release_date = f"{release_date_parts[2]}-{strptime(release_date_parts[1],'%b').tm_mon:02d}-{release_date_parts[0]}"

        # 构建JSON结构
        json_data = {
            "platform": platforms,
            "version": version,
            "release_date": release_date
        }
        # 转换为JSON字符串
        json_str = json.dumps(json_data, ensure_ascii=False)
        print(json_str)

        return json_data
    except Exception as error:
        print(f'something error on {data}, error={error}')

def parseTvOS(data):
    try:
        # 解析版本
        versionSplit = data[0].split(" ")
        platforms = [versionSplit[0]]
        version = versionSplit[1].split("\n")[0]
            
        # 解析发布日期
        release_date_parts = data[2].split(" ")
        release_date = f"{release_date_parts[2]}-{strptime(release_date_parts[1],'%b').tm_mon:02d}-{release_date_parts[0]}"

        # 构建JSON结构
        json_data = {
            "platform": platforms,
            "version": version,
            "release_date": release_date
        }
        # 转换为JSON字符串
        json_str = json.dumps(json_data, ensure_ascii=False)
        print(json_str)

        return json_data
    except Exception as error:
        print(f'something error on {data}, error={error}')

def parseMacOS(data):
    try:
        # 解析版本
        versionSplit = data[0].split(" ")
        platforms = [versionSplit[0] + " " + versionSplit[1]]
        version = versionSplit[2].split("\n")[0]
        if '.' in version == False:
            version = versionSplit[3].split("\n")[0]
            
        # 解析发布日期
        release_date_parts = data[2].split(" ")
        release_date = f"{release_date_parts[2]}-{strptime(release_date_parts[1],'%b').tm_mon:02d}-{release_date_parts[0]}"

        # 构建JSON结构
        json_data = {
            "platform": platforms,
            "version": version,
            "release_date": release_date
        }
        # 转换为JSON字符串
        json_str = json.dumps(json_data, ensure_ascii=False)
        print(json_str)

        return json_data
    except Exception as error:
        print(f'something error on {data}, error={error}')

def parseiOS(data): 
    try: 
        # 解析平台和版本
        platforms_versions = data[0].split(" and ")
        platforms = [pv.split(" ")[0] for pv in platforms_versions]

        version = platforms_versions[0].split(" ")[1]
        
        # 解析发布日期
        release_date_parts = data[2].split(" ")
        release_date = f"{release_date_parts[2]}-{strptime(release_date_parts[1],'%b').tm_mon:02d}-{release_date_parts[0]}"

        # 构建JSON结构
        json_data = {
            "platform": platforms,
            "version": version,
            "release_date": release_date
        }
        # 转换为JSON字符串
        json_str = json.dumps(json_data, ensure_ascii=False)
        print(json_str)

        return json_data
    except Exception as error:
        print(f'something error on {data}, error={error}')


# Apple security releases網站爬蟲，確認iOS相關平台是否有新的版本
iPadOS = "iPadOS"
iOS = "iOS"
macOS = "macOS"
tvOS = "tvOS"
watchOS = "watchOS"

response = requests.get('https://support.apple.com/en-us/HT201222')


with open(f'{baseDir}/apple_support_response.html', 'w', encoding='utf-8') as f:
    f.write(response.text)


soup = BeautifulSoup(response.text, 'html.parser')

# 找到所有的表格行
rows = soup.find_all('tr')

# 初始化一个列表来存储每行的数据
data_list = []

# 遍历每一行
for row in rows:
    # 获取当前行的所有列
    cols = row.find_all('td')
    # 如果当前行有列（即非标题行）
    if cols:
        # 提取每列的文本并存储到列表中
        row_data = [col.text.strip() for col in cols]
        # 将当前行的数据添加到数据列表中

        try:
            if iOS in row_data[0] and " and " in row_data[0]:
                data = parseiOS(row_data)
                data_list.append(data)
            elif macOS in row_data[0]:
                data = parseMacOS(row_data)
                data_list.append(data)
            elif tvOS in row_data[0]:
                data = parseTvOS(row_data)
                data_list.append(data)  
            elif watchOS in row_data[0]:
                data = parseWatchOS(row_data)
                data_list.append(data)      
            
        except error as error:
            print("{row_data} error={error}")


# 將列表轉換成JSON格式
data_json = json.dumps(data_list, ensure_ascii=False, indent=4)

with open(f'{baseDir}/apple_support_response.json', 'w', encoding='utf-8') as f:
    f.write(data_json)    


# Load the data from the JSON file
with open('crawler/resources/apple_support_response.json', 'r') as file:
    data = json.load(file)

# Filter out only the latest version for each major version
filtered_data = []

filtered_ios_list = [item for item in data if item is not None and item['platform'][0] == iOS]

latest_versions = {}
for item in filtered_ios_list:
    try:
        version_major = item['version'].split('.')[0] # Get the major version number
        if version_major not in latest_versions:
            latest_versions[version_major] = item
        else:
            existing_version = latest_versions[version_major]['version']
            if item['version'] > existing_version:
                latest_versions[version_major] = item
    except:
        print("error item = {item}")                
filtered_data.append(list(latest_versions.values()))

filtered_mac_list = [item for item in data if item is not None and macOS in item['platform'][0]]
latest_versions = {}
for item in filtered_mac_list:
    try:
        version_major = item['version'].split('.')[0]   # Get the major version number
        if version_major not in latest_versions:
            latest_versions[version_major] = item
        else:
            existing_version = latest_versions[version_major]['version']
            if item['version'] > existing_version:
                latest_versions[version_major] = item
    except:
        print("error item = {item}") 
filtered_data.append(list(latest_versions.values()))


filtered_tv_os_list = [item for item in data if item is not None and tvOS in item['platform'][0]]
latest_versions = {}
for item in filtered_tv_os_list:
    try:
        version_major = item['version'].split('.')[0]   # Get the major version number
        if version_major not in latest_versions:
            latest_versions[version_major] = item
        else:
            existing_version = latest_versions[version_major]['version']
            if item['version'] > existing_version:
                latest_versions[version_major] = item
    except:
        print("error item = {item}") 
filtered_data.append(list(latest_versions.values()))

filtered_watch_os_list = [item for item in data if item is not None and watchOS in item['platform'][0]]
latest_versions = {}
for item in filtered_watch_os_list:
    try:
        version_major = item['version'].split('.')[0]   # Get the major version number
        if version_major not in latest_versions:
            latest_versions[version_major] = item
        else:
            existing_version = latest_versions[version_major]['version']
            if item['version'] > existing_version:
                latest_versions[version_major] = item
    except:
        print("error item = {item}") 
filtered_data.append(list(latest_versions.values()))


# Save the filtered data back to the file (or another file if preferred)
with open('crawler/resources/apple_support_response_filtered.json', 'w') as file:
    json.dump(filtered_data, file, indent=4)

print("Filtered data saved.")    