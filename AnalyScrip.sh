#!/bin/bash


# Copy only specific files from one Folder to Another Folder. Specific files names are written in *.txt file

input="/home/meic/Desktop/OfficeWork/Analysis/AnalysisFiles.txt"
while IFS= read -r line
do
	echo $line
	cp -r /home/meic/Desktop/OfficeWork/Analysis/vent.1_out/"$line" /home/meic/Rajesh_Bajaj/Analys/$line
done < "$input"
cd /home/meic/Rajesh_Bajaj/Analys
sudo find . -type f -exec dos2unix {} \;
find . -name "*.gz" -exec bash -c 'gunzip -qvf "${0// /_}"' {} \;



# Copy files from one Folder to Another Folder

#for i in `ls -l /home/meic/Rajesh_Bajaj/Analysis/ | grep -v total | awk '{print $9}'`
#do
 #  echo $i
  # cp -r /home/meic/Rajesh_Bajaj/Analysis/"$i" /home/meic/Rajesh_Bajaj/Analys/$i
#done

# cd /home/meic/Rajesh_Bajaj/zipping/1234/ tar xzf abc.tar.gz
#tar czf abc.tar.gz *.xml

#find . -name '*.tar.gz' -execdir tar -xzvf '{}' \;

#"*.gz" -exec bash -c 'gunzip -qvf "${0// /_}"' {} \;
