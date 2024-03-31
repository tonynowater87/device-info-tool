import requests
import os
from datetime import datetime
from bs4 import BeautifulSoup
import json
from time import strptime

baseDir = 'crawler/resources'
url = "https://www.composables.com/tools/distribution-chart"
response = requests.get(url)
soup = BeautifulSoup(response.text, 'html.parser')

tables = soup.find_all('table')

data = []

sections = soup.find_all('section')
lastUpdated = sections[0].find_all('div')[1].text.strip().split(": ")
# October 1, 2023
data.append({"最後更新": lastUpdated[1]})


for table in tables:
    titleDiv = table.find_previous_sibling('div').find_previous_sibling('div')
    
    if titleDiv.text.strip() == "API Distribution":
        titleDiv = "版本分佈"
    elif titleDiv.text.strip() == "Cumulative Distribution":        
        titleDiv = "累積分佈"
    else :
        titleDiv = "未知"            
    
    # 找到所有的表格行
    rows = table.find_all('tr')
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
            data_list.append(row_data)
            
    data.append({titleDiv: data_list})     
    

# 將列表轉換成JSON格式
data_json = json.dumps(data, ensure_ascii=False, indent=4)

try:
    json.loads(data_json)
    with open(f'{baseDir}/android-distribution.json', 'w', encoding='utf-8') as f:
        f.write(data_json) 
    os.system(f'mv {baseDir}/android-distribution.json ./resources/android-distribution.json')        
except ValueError as e:   
    print(f'invalid json: {e}')
    pass