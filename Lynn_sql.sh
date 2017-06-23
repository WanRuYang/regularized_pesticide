#!/bin/bash

while read p; do
	#echo $p
	x=$p
done < .cred/dbcon.txt

echo $x -c Lynn_chemlist.sql

eval "$x -f Lynn_chemlist.sql"
eval "$x -f Lynn_rp_clean.sql"
eval "$x -f Lynn_rp.sql"
eval "$x -f Lynn_rp_directsum.sql" 
