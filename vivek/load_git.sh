#!/bin/bash
status1=404
day_count=0
while [ $status1 -eq 404 ]; do
	month=$(date --date "$day_count day" +%b | awk '{print toupper($0)}')
	nse_path=https://www.nseindia.com/content/historical/DERIVATIVES/$(date --date "$day_count day" +%Y)/$month/fo$(date --date "$day_count day" +%d)$month$(date --date "$day_count day" +%Y)bhav.csv.zip
	file=fo$(date --date "$day_count day" +%d)$month$(date --date "$day_count day" +%Y)bhav.csv
	echo 'File to be read is ' $nse_path
	status1=$(wget -U 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.6) Gecko/20070802 SeaMonkey/1.1.4' $nse_path -O fo_bhav.zip --server-response 2>&1 | awk '/^  HTTP/{print $2}')
	echo 'Returned status is ' $status1
	if [ $status1 -eq 200 ]; then
   		echo 'Successfully read the bhavcopy file'
   		unzip -o fo_bhav.zip
   		cp $file ./nitrohub/data/fo_bhav.csv
   		rm fo*
	else
    		echo 'Error in reading the bhavcopy'
	fi
	let "day_count=day_count - 1"
done

lotfile=https://www.nseindia.com/content/fo/fo_mktlots.csv
status2=$(wget --server-response -U 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.6) Gecko/20070802 SeaMonkey/1.1.4' $lotfile -O fo_mktlots.csv 2>&1 | awk '/^  HTTP/{print $2}')
echo 'Returned status is ' $status2
if [ $status2 -eq 200 ]; then
   echo 'Successfully read the lot file'
   cp fo_mktlots.csv ./nitrohub/data/fo_mktlots.csv
   rm *csv
else
    echo 'Error in reading the lot size file'
fi

if [ $status2 -eq 200 -a $status1 -eq 200 ]; then
	echo 'Successfully read both bhavcopy and market lot files'
	echo 'Uploading files to firebase'
	firebase deploy
else
	echo 'Either of the file reading failed'
fi
