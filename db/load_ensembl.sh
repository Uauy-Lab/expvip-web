#!/bin/bash
folder=/Users/ramirezr/Documents/ensembl_compara_plants_27_80

for  f in `ls $folder | grep -v peptide | grep gz` ; do 
#	echo $f 
	filename="${f%.*}"
	echo $filename
	mkfifo $filename
	echo "Fifo done"
	gunzip -c $f > $filename &
	echo "About to import" 
	mysqlimport -utgac -ptgac_bioinf -htgac-db1 --fields_escaped_by=\\ ramirezr_ensembl_compara_plants_27_80 -L $filename
	echo "DONE $f"
	rm $filename
done 