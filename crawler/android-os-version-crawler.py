# 抓取 Android OS 版本對照表（API level / 版本 / 代號 / 發布日）
# 來源：https://apilevels.com/ （表格清楚、持續維護）
#
# 設計原則：
#   1. 用「表頭文字」偵測欄位位置，而不是寫死欄位順序 —— 來源改版時較不易壞。
#   2. 只「新增」比現有資料更新的 API level，不重建整份檔案 ——
#      既有的細分版本（例如 2.2 / 2.2.1 / 2.2.2）會被完整保留，
#      解析失敗時最多就是「沒新增」，不會破壞 resources/android-os-versions.json。
import requests
import os
import re
import json
from datetime import datetime
from bs4 import BeautifulSoup

SOURCE_URL = "https://apilevels.com/"
OUTPUT_PATH = "resources/android-os-versions.json"

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0 Safari/537.36"
    )
}


def normalize_date(raw):
    """把來源的發布日期正規化成 YYYY-MM-DD，失敗則回傳空字串。"""
    if not raw:
        return ""
    raw = raw.strip()
    # 已經是 ISO 格式
    if re.match(r"^\d{4}-\d{2}-\d{2}$", raw):
        return raw
    # 常見格式，例如 "October 1, 2023" / "Oct 2023" / "September 2024"
    for fmt in ("%B %d, %Y", "%b %d, %Y", "%B %Y", "%b %Y", "%Y-%m-%d"):
        try:
            dt = datetime.strptime(raw, fmt)
            return dt.strftime("%Y-%m-%d")
        except ValueError:
            continue
    # 只抓得到年份
    year = re.search(r"\b(20\d{2})\b", raw)
    if year:
        return f"{year.group(1)}-01-01"
    return ""


def find_column_index(headers, *keywords):
    """在表頭文字中找出第一個包含任一關鍵字的欄位 index。"""
    for idx, text in enumerate(headers):
        lowered = text.lower()
        for kw in keywords:
            if kw in lowered:
                return idx
    return None


def parse_table(table):
    """解析單一表格，回傳 [{api_level, version, code_name, release_date}, ...]。"""
    header_cells = table.find_all("th")
    headers = [c.get_text(strip=True) for c in header_cells]
    if not headers:
        return []

    api_idx = find_column_index(headers, "api")
    if api_idx is None:
        return []

    version_idx = find_column_index(headers, "version")
    name_idx = find_column_index(headers, "name", "code")
    date_idx = find_column_index(headers, "release", "date")

    rows = []
    for tr in table.find_all("tr"):
        cols = tr.find_all("td")
        if not cols:
            continue
        cells = [c.get_text(" ", strip=True) for c in cols]
        if api_idx >= len(cells):
            continue

        api_match = re.search(r"\d+", cells[api_idx])
        if not api_match:
            continue
        api_level = api_match.group(0)

        version = ""
        if version_idx is not None and version_idx < len(cells):
            vmatch = re.search(r"\d+(?:\.\d+)*", cells[version_idx])
            if vmatch:
                version = vmatch.group(0)

        code_name = ""
        if name_idx is not None and name_idx < len(cells):
            code_name = cells[name_idx]
        # 若沒有版本號，嘗試從名稱（例如 "Android 16"）萃取
        if not version and code_name:
            vmatch = re.search(r"\d+(?:\.\d+)*", code_name)
            if vmatch:
                version = vmatch.group(0)

        release_date = ""
        if date_idx is not None and date_idx < len(cells):
            release_date = normalize_date(cells[date_idx])

        if not version:
            continue

        rows.append({
            "api_level": api_level,
            "version": version,
            "code_name": code_name or "(no codename)",
            "release_date": release_date,
        })
    return rows


def fetch_source_rows():
    response = requests.get(SOURCE_URL, headers=HEADERS, timeout=30)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")

    parsed = []
    for table in soup.find_all("table"):
        parsed.extend(parse_table(table))
    return parsed


def main():
    if not os.path.exists(OUTPUT_PATH):
        print(f"找不到既有檔案 {OUTPUT_PATH}，略過。")
        return

    with open(OUTPUT_PATH, "r", encoding="utf-8") as f:
        existing = json.load(f)

    def to_int(value):
        m = re.search(r"\d+", str(value))
        return int(m.group(0)) if m else -1

    max_api = max((to_int(item.get("api_level")) for item in existing), default=-1)
    existing_versions = {item.get("version") for item in existing}

    try:
        source_rows = fetch_source_rows()
    except Exception as error:
        print(f"抓取來源失敗，保持既有資料不變：{error}")
        return

    if not source_rows:
        print("來源沒有解析到任何資料（可能網站結構改變），保持既有資料不變。")
        return

    # 只挑出「API level 比現有最大值更新，且版本尚未存在」的項目
    additions = []
    for row in sorted(source_rows, key=lambda r: to_int(r["api_level"])):
        if to_int(row["api_level"]) > max_api and row["version"] not in existing_versions:
            additions.append(row)
            existing_versions.add(row["version"])

    if not additions:
        print(f"沒有比 API level {max_api} 更新的版本，無需更新。")
        return

    existing.extend(additions)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(existing, f, ensure_ascii=False, indent=2)
        f.write("\n")

    for row in additions:
        print(f"新增 Android 版本：API {row['api_level']} -> {row['version']} "
              f"({row['code_name']}, {row['release_date']})")


if __name__ == "__main__":
    main()
