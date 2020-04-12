# Rename all *.vtt to *.srt
for f in *.vtt; do
    tail -n +3 "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    mv -- "$f" "${f%.vtt}.srt"
done
