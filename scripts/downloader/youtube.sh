yt-dlp 'https://www.youtube.com/@CHANNEL_USERNAME/videos' \
  --cookies-from-browser chrome \
  --retries infinite \
  --fragment-retries infinite \
  --sleep-interval 5 --max-sleep-interval 10 \
  --throttled-rate 500K \
  --concurrent-fragments 1 \
  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/125.0.0.0 Safari/537.36" \
  --add-header "Referer: https://www.youtube.com/" \
  -o "%(upload_date>%Y-%m-%d)s - %(title).100s [%(id)s].%(ext)s"

