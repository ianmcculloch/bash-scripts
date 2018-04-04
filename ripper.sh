#!/bin/bash
# /usr/local/bin/rip-audio-cd
DEVICE="/dev/sr0"
COPIES="3"

DISCID="`cd-discid $DEVICE 2>&1 | egrep -o '^[0-9a-z]{8}'`"
if [ "$?" != "0" ]; then
  echo "Failed to retrieve disc ID."
  exit 1
fi

echo -e "\033[1;32mDisc ID: $DISCID\033[0;0m"
rm -f "$DISCID".*

echo -e "\033[1;32mExtracting a cue sheet:\033[0;0m"

cdrdao read-toc --device "$DEVICE" --datafile "$DISCID.wav" "$DISCID.toc" || exit 2
cueconvert -i toc -o cue "$DISCID.toc" | grep -vP '^ISRC "' > "$DISCID.cue" || exit 2

CHECKSUM=''
I=0
for ((I=0; I < $COPIES; I++)); do

  echo
  echo -e "\033[1;32mPass $((I+1)) of $COPIES\033[0;0m:"

  if [[ $I -eq 0 ]]; then
    OUT="$DISCID.wav"
  else
    OUT="$DISCID.new.wav"
  fi
  rm -f "$OUT"

  cdparanoia -zX '1-' "$OUT"
  if [ "$?" != "0" ]; then
    rm -f "$DISCID".*
    echo "Failed to rip a disc."
    exit 3
  fi

  C="`sha1sum "$OUT" | cut -f1 -d' '`"
  if [[ "x$CHECKSUM" = 'x' ]]; then
    echo "Checksum: $C"
    CHECKSUM=$C
  else
    rm -f "$OUT"
    if [[ "$CHECKSUM" != "$C" ]]; then
      echo "Mismatching checksum: $C"
      exit 4
    else
      echo "Matching checksum: $C"
    fi
  fi
done

eject "$DEVICE" &

echo
echo -en "\033[1;32mCompressing...\033[0;0m"
flac -f -V --replay-gain --best --cuesheet="$DISCID.cue" "$DISCID.wav"
if [ "$?" != "0" ]; then
  echo "Failed to encode the ripped tracks."
  exit 5
fi

rm -f "$DISCID.wav" "$DISCID.cue" "$DISCID.toc"

echo
echo -e "\033[1;32mAll done: $DISCID.flac\033[0;0m"
