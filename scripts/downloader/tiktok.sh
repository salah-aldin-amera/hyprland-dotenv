yt-dlp 'https://www.tiktok.com/@username' \
  --retries infinite \
  --fragment-retries infinite \
  --sleep-interval 5 --max-sleep-interval 10 \
  --sleep-requests 5 \
  --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0 Safari/537.36" \
  --add-header "Referer: https://www.tiktok.com/" \
  -o '%(upload_date)s - %(title)s.%(ext)s'
