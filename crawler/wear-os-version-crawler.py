# 抓取 Android Wear OS 版本歷史，更新 resources/wear-os-versions.json。
# 來源：Wikipedia「Wear OS」的 Version history 表格。
#
# 設計原則（與 android-os-version-crawler.py 一致、但更保守）：
#   1. 採「錨定既有最後一筆、只往後追加」：在來源表格中找到目前資料的最後一個
#      Wear OS 版本，只追加它之後的新版本。找不到錨點就不動資料。
#   2. android-os 欄位（例如 "14.0 UpsideDownCake"）優先用本專案
#      resources/android-os-versions.json 的代號補齊，保持命名一致。
#   3. 任何解析失敗 / 沒有新版本，都保持既有 JSON 不變。
import requests
import os
import re
import json
from datetime import datetime
from bs4 import BeautifulSoup

SOURCE_URL = "https://en.wikipedia.org/wiki/Wear_OS"
OUTPUT_PATH = "resources/wear-os-versions.json"
ANDROID_OS_PATH = "resources/android-os-versions.json"

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0 Safari/537.36"
    )
}

MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


def normalize_release_date(raw):
    """正規化成既有格式 "YYYY Mon"（例如 "2024 Oct"），失敗回傳原字串去空白。"""
    if not raw:
        return ""
    raw = raw.strip()
    for fmt in ("%B %d, %Y", "%b %d, %Y", "%d %B %Y", "%B %Y", "%b %Y",
                "%Y-%m-%d"):
        try:
            dt = datetime.strptime(raw, fmt)
            return f"{dt.year} {MONTHS[dt.month - 1]}"
        except ValueError:
            continue
    # 例如 "2024 October" / "October 2024" 混合
    year = re.search(r"\b(20\d{2})\b", raw)
    month = None
    for idx, m in enumerate(MONTHS):
        if m.lower() in raw.lower() or datetime(2000, idx + 1, 1).strftime(
                "%B").lower() in raw.lower():
            month = m
            break
    if year and month:
        return f"{year.group(1)} {month}"
    if year:
        return year.group(1)
    return raw


def load_android_codenames():
    """major 版本字串 -> 代號，例如 "14" -> "UpsideDownCake"。"""
    codenames = {}
    if not os.path.exists(ANDROID_OS_PATH):
        return codenames
    with open(ANDROID_OS_PATH, "r", encoding="utf-8") as f:
        for item in json.load(f):
            version = str(item.get("version", "")).strip()
            name = str(item.get("code_name", "")).strip()
            # 只收主版號（例如 "14"），忽略 "5.0.1" 這種細分版本
            if version.isdigit() and name and version not in codenames:
                codenames[version] = name
    return codenames


def format_android_os(raw_cell, codenames):
    """把「based on Android」欄位轉成既有格式 "14.0 UpsideDownCake"。"""
    if not raw_cell:
        return ""
    major_match = re.search(r"\d+", raw_cell)
    if not major_match:
        return raw_cell.strip()
    major = major_match.group(0)
    name = codenames.get(major)
    if not name:
        # 退而求其次：取括號或數字後面的文字當代號
        leftover = re.sub(r"android", "", raw_cell, flags=re.IGNORECASE)
        leftover = re.sub(r"[\d.()]", " ", leftover).strip()
        name = leftover.split("  ")[0].strip() if leftover else ""
    return f"{major}.0 {name}".strip()


def find_column_index(headers, include, exclude=()):
    for idx, text in enumerate(headers):
        low = text.lower()
        if any(k in low for k in include) and not any(k in low for k in exclude):
            return idx
    return None


def parse_table(table):
    """回傳 [{version, android_raw, release_raw}, ...]，依表格順序。"""
    header_cells = table.find_all("th")
    headers = [c.get_text(" ", strip=True) for c in header_cells]
    if not headers:
        return []

    # Wear OS 版本欄：含 version 但不含 android
    version_idx = find_column_index(headers, ["version"], exclude=["android"])
    if version_idx is None:
        return []
    android_idx = find_column_index(headers, ["android", "based"])
    date_idx = find_column_index(headers, ["release", "date"])

    rows = []
    for tr in table.find_all("tr"):
        cols = tr.find_all(["td", "th"])
        cells = [c.get_text(" ", strip=True) for c in cols]
        if len(cells) <= version_idx or not cells[version_idx]:
            continue
        vmatch = re.search(r"\d+(?:\.\d+)*", cells[version_idx])
        if not vmatch:
            continue
        rows.append({
            "version": vmatch.group(0),
            "android_raw": cells[android_idx]
            if android_idx is not None and android_idx < len(cells) else "",
            "release_raw": cells[date_idx]
            if date_idx is not None and date_idx < len(cells) else "",
        })
    return rows


def fetch_source_rows():
    response = requests.get(SOURCE_URL, headers=HEADERS, timeout=30)
    response.raise_for_status()
    soup = BeautifulSoup(response.text, "html.parser")
    # 選出含最多 Wear OS 版本列的表格，避免選錯
    best = []
    for table in soup.find_all("table"):
        parsed = parse_table(table)
        if len(parsed) > len(best):
            best = parsed
    return best


def main():
    if not os.path.exists(OUTPUT_PATH):
        print(f"找不到既有檔案 {OUTPUT_PATH}，略過。")
        return

    with open(OUTPUT_PATH, "r", encoding="utf-8") as f:
        existing = json.load(f)
    if not existing:
        print("既有資料為空，無法錨定，略過。")
        return

    last = existing[-1]
    last_version = str(last.get("version", "")).strip()
    max_order = max((int(re.search(r"\d+", str(i.get("order", "0"))).group(0))
                     for i in existing), default=0)

    try:
        source_rows = fetch_source_rows()
    except Exception as error:
        print(f"抓取來源失敗，保持既有資料不變：{error}")
        return

    if not source_rows:
        print("來源沒有解析到版本（可能網站結構改變），保持既有資料不變。")
        return

    # 在來源中找到「目前最後一個版本」當錨點，只追加其後的版本
    anchor = next((i for i, r in enumerate(source_rows)
                   if r["version"] == last_version), None)
    if anchor is None:
        print(f"來源中找不到目前最後版本 {last_version} 作為錨點，"
              f"為避免重複保持不變。")
        return

    new_rows = source_rows[anchor + 1:]
    if not new_rows:
        print(f"沒有比 Wear OS {last_version} 更新的版本，無需更新。")
        return

    codenames = load_android_codenames()
    additions = []
    order = max_order
    for row in new_rows:
        order += 1
        additions.append({
            "version": row["version"],
            "os-name": "Wear OS",
            "android-os": format_android_os(row["android_raw"], codenames),
            "release-date": normalize_release_date(row["release_raw"]),
            "order": str(order),
        })

    existing.extend(additions)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(existing, f, ensure_ascii=False, indent=2)
        f.write("\n")

    for row in additions:
        print(f"新增 Wear OS 版本：{row['version']} "
              f"(based on {row['android-os']}, {row['release-date']})")


if __name__ == "__main__":
    main()
