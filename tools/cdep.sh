#!/bin/bash -e
# -e: Exit immediately when one of these commands exits with an error.

set -x

TEMP="/work/tmp/cdep"

# Get the pages with the votes.
/usr/bin/python ./python/src/ro/vivi/cdep_crawler/1_get_votes_pages.py $TEMP

# Parse them. They will be deposited in the file as the third param.
/usr/bin/python ./python/src/ro/vivi/cdep_crawler/2_parse_votes.py \
  $TEMP \
  $TEMP/cdep_2008_agg.txt

# Transform the big file with all votes into a database, plus aggregate stuff.

# We store the binary in /tmp
CP="$TEMP"
CP="$CP:`pwd`/java/src"
CP="$CP:`pwd`/java/lib/mysql-connector-java-5.1.7-bin.jar"
CP="$CP:`pwd`/java/lib/HTTPClient.zip"

# Delete the previous compile
rm -rf $TEMP/ro

# Compile the java parser.
/usr/bin/javac -cp $CP -d $TEMP ./java/src/ro/vivi/pistruiatul/Main.java

# Run it against the cdep file.
/usr/bin/java -cp $CP -Xmx1024m ro/vivi/pistruiatul/Main \
  cdep_2008 $TEMP/cdep_2008_agg.txt


# TODO(vivi): Add some sanity checks here to make sure that we're not writing
# something totally stupid.
# And now dump the tables we have just modified.
mysqldump -u root -proot -v --port=3306 \
  --add-drop-table \
  hartapoliticii_pistruiatul \
    cdep_2008_belong \
    cdep_2008_belong_agg \
    cdep_2008_laws \
    cdep_2008_votes \
    cdep_2008_votes_agg \
    cdep_2008_votes_details \
    people \
    people_history \
  > $TEMP/cdep_data.sql


set +x

read -s -p "Enter Password: " PASS

# And push them online.
mysql -C \
  --host=mysql.s701.sureserver.com --port=3307 \
  -u vivi -p$PASS \
  hartapoliticii_pistruiatul \
  < $TEMP/cdep_data.sql

