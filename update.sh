#!/usr/bin/env bash
# 本機手動更新 resources/ 底下的 OS 版本與市佔資料。
# （CI 上的自動排程見 .github/workflows/update-os-versions.yml）
set -e

# 切換到此腳本所在的專案根目錄，不再寫死任何人的本機路徑。
cd "$(dirname "$0")"

PYTHON="${PYTHON:-python3}"

"$PYTHON" crawler/apple-website-crawler.py
"$PYTHON" crawler/update-version.py
"$PYTHON" crawler/mobile-distribution-crawler.py
"$PYTHON" crawler/android-os-version-crawler.py
"$PYTHON" crawler/wear-os-version-crawler.py

git add resources/
if git diff --cached --quiet; then
  echo "資料沒有變動，不需要 commit。"
else
  git commit -m "update versions.json"
  git push -u origin main
fi

date +"%Y-%m-%d %H:%M:%S" >> log.txt
