yt-dlp 'https://www.tiktok.com/@username' \
  --cookies-from-browser opera \
  --retries infinite \
  --fragment-retries infinite \
  --sleep-requests 10 \
  --sleep-interval 5 --max-sleep-interval 10 \
  --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36" \
  --add-header "Referer: https://www.tiktok.com/" \
  -o "%(upload_date>%Y-%m-%d)s - %(title).80s [%(id)s].%(ext)s"

