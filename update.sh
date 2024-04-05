cd /Users/tonynowater/Documents/my-project/front-end-app/flutter/mobile-os-versions

/Users/tonynowater/.pyenv/versions/3.11.1/bin/python /Users/tonynowater/Documents/my-project/front-end-app/flutter/mobile-os-versions/crawler/apple-website-crawler.py && /Users/tonynowater/.pyenv/versions/3.11.1/bin/python /Users/tonynowater/Documents/my-project/front-end-app/flutter/mobile-os-versions/crawler/update-version.py && /Users/tonynowater/.pyenv/versions/3.11.1/bin/python /Users/tonynowater/Documents/my-project/front-end-app/flutter/mobile-os-versions/crawler/mobile-distribution-crawler.py


git add resources/ios-os-versions.json
git add resources/ipad-os-versions.json
git add resources/mac-os-versions.json
git add resources/tv-os-versions.json
git add resources/watch-os-versions.json
git add resources/android-distribution.json
git add resources/ios-distribution.json
git commit -m "update versions.json"
git push -u origin main

date +"%Y-%m-%d %H:%M:%S" >> log.txt
