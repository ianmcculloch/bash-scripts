# Delete the first two lines in every .vtt file and the append it to the .srt file
for f in *.vtt; do
    tail -n +3 "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    cat "$f" >> "XYZ.srt"
#   mv -- "$f" "${f%.vtt}.srt"
done
