#!/bin/sh
echo `date +%s` "! started RPxCamera"

cd /home/pi
mkdir -p Video

# Arguments:
diskLimitInBytes=4000000000
durationMS=60000

echo "record" > RPxCamera.mode
echo "false" > RPxCamera.event
mode=$(cat RPxCamera.mode)
currentFileName="dummy.h264"

while [ true ]; do 
	# Calculate the disk space used
	used=$(du Video | tail -1 | awk '{print $1}')
	
	# Free up the disk space if needed
	while [ $diskLimitInBytes -le $used ]
	do
		fileToRemove=$(ls -1tr Video | grep .h264 | head -n 1)
		echo `date +%s` "-" $fileToRemove
		rm Video/$fileToRemove

		# Calculate the disk space used
		used=$(du Video | tail -1 | awk '{print $1}')
	done

	# Check for new commands
	mode=$(cat RPxCamera.mode)
	if [ "$mode" = "exit" ]
		then
			echo `date +%s` "! stopped RPxCamera"			
			
			#sudo shutdown -h now
			exit
	fi
	if [ "$mode" = "record" ] || [ "$mode" = "parked" ]
		then
			# New file name
			currentFileName=$(date +"%Y-%m-%d___%H_%M_%S")
			echo `date +%s` "+" $currentFileName

			#   | tea "Video/$currentFileName-HD.h264"
			raspivid -n -w 1136 -h 640 -b 1000000 -fps 45 -t $durationMS -o -  | gst-launch-1.0 -v fdsrc ! h264parse ! rtph264pay config-interval=10 pt=96 ! udpsink host=10.0.1.12 port=9000
	fi
done
