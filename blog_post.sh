#!/bin/bash

# grab content to be blogged from a properly formatted textfile,
# resize a picture at a specified path accordingly,
# then insert it into my webserver structure (directly editing the html file)

# setting a few paths and the ssh usernamename/domain
localdir=`pwd`
sshcon=username@yourdomain.tld
remotedir=remote/webserver/filedir
textpath=blogpost.txt
previewsize="300"
fullsize="1280x1280"

# get the current date to be used in the post
postdate=`date +%d.%m.%Y`
# the current year is used to enter the post into the right file
postyear=`date +%Y`

# poll the $textpath file for the information needed to create the post
imagename=`awk -F: '/write the filename for the image into the next line/ { getline; print $0 }' $localdir/$textpath`
imagealt=`awk -F: '/write the alternative text for the image into the next line/ { getline; print $0 }' $localdir/$textpath`
blogtext=`awk -F: '/write the text for the blog post into the next line/ { getline; print $0 }' $localdir/$textpath`

# combine the polled values with some html syntax
blogpost="<\!-- marker for auto-generated content insertion -->\n\n<div class=\"blog_post\">\n<p><a href=\"$postyear\/$imagename\"><img class=\"preview\" alt=\"$imagealt\" src=\"$postyear\/preview\/$imagename\">\n$postdate<\/a><br>\n$blogtext<\/div>"

# copy the html file from the server to a local temp file
scp $sshcon:$remotedir/blog_$postyear.html $localdir/blog_"$postyear"_temp.html && echo "html file has been copied to the local machine"
# edit the temp file by adding the new post in the old marker's place
sed -i "s/<\!-- marker for auto-generated content insertion -->/$blogpost/g" $localdir/blog_"$postyear"_temp.html && echo "html file has been edited successfully"
# copy the file back onto the server
scp $localdir/blog_"$postyear"_temp.html $sshcon:$remotedir/blog_$postyear.html && echo "html file has been copied to the server"

# rename the local image to the desired name
mv $localdir/*.jpg $localdir/$imagename

# resize the picture for both preview and full view resolution
mogrify -path $localdir/full -resize $fullsize -quality 100 $localdir/*.jpg && echo "fullsize image has been created"
mogrify -path $localdir/preview -resize $previewsize -quality 100 $localdir/*.jpg && echo "preview image has been created"

# copy the images from the local directories to the server over ssh
scp $localdir/full/* $sshcon:$remotedir/$postyear && echo "fullsize image has been copied" && scp $localdir/preview/* $sshcon:$remotedir/$postyear/preview && echo "preview image has been copied"

# clean up local files
rm $localdir/*.jpg
rm $localdir/full/*
rm $localdir/preview/*
rm $localdir/blog_"$postyear"_temp.html
