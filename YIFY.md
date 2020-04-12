# ffmpeg with YIFY settings
```
ffmpeg -i input.mkv -c:v libx264 -crf 27 -x264-params cabac=1:ref=5:analyse=0x133:me=umh:subme=9:chroma-me=1:deadzone-inter=21:deadzone-intra=11:b-adapt=2:rc-lookahead=60:vbv-maxrate=10000:vbv-bufsize=10000:qpmax=69:bframes=5:b-adapt=2:direct=auto:crf-max=51:weightp=2:merange=24:chroma-qp-offset=-1:sync-lookahead=2:psy-rd=1.00,0.15:trellis=2:min-keyint=23:partitions=all -c:a aac -ar 44100 -b:a 128k -map 0 output.mkv
```
