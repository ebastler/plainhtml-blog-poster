#!/bin/bash

# grab content to be blogged from a properly formatted textfile,
# resize a picture at a specified path accordingly,
# then insert it into my webserver structure (directly editing the html file)

# reading a few paths and the ssh usernamename/domain from $configPath file
configPath=variables

localDir=(`cat $configPath | awk -F"[ ]+" '/localDir /{printf $2 " "}'`)
sshCon=(`cat $configPath | awk -F"[ ]+" '/sshCon /{printf $2 " "}'`)
remoteDir=(`cat $configPath | awk -F"[ ]+" '/remoteDir /{printf $2 " "}'`)
textPath=(`cat $configPath | awk -F"[ ]+" '/textPath /{printf $2 " "}'`)
previewSize=(`cat $configPath | awk -F"[ ]+" '/previewSize /{printf $2 " "}'`)
fullSize=(`cat $configPath | awk -F"[ ]+" '/fullSize /{printf $2 " "}'`)

# If localDir has not been assigned in $configPath, use the current working directory instead as default
if [ -z "$localDir" ]
then
      localDir=`pwd`
fi


# get the current date to be used in the post
postDate=`date +%d.%m.%Y`
# the current year is used to enter the post into the right file
postYear=`date +%Y`

# poll the $textPath file for the information needed to create the post
imageName=`awk -F: '/write the filename for the image into the next line/ { getline; print $0 }' $localDir/$textPath`
imageAlt=`awk -F: '/write the alternative text for the image into the next line/ { getline; print $0 }' $localDir/$textPath`
blogText=`awk -F: '/write the text for the blog post into the next line/ { getline; print $0 }' $localDir/$textPath`

# combine the polled values with some html syntax
blogPost="<\!-- marker for auto-generated content insertion -->\n\n<div class=\"blog_post\">\n<p><a href=\"$postYear\/$imageName\"><img class=\"preview\" alt=\"$imageAlt\" src=\"$postYear\/preview\/$imageName\">\n$postDate<\/a><br>\n$blogText<\/div>"

# copy the html file from the server to a local temp file
scp $sshCon:$remoteDir/blog_$postYear.html $localDir/blog_"$postYear"_temp.html && echo "html file has been copied to the local machine"
# edit the temp file by adding the new post in the old marker's place
sed -i "s/<\!-- marker for auto-generated content insertion -->/$blogPost/g" $localDir/blog_"$postYear"_temp.html && echo "html file has been edited successfully"
# copy the file back onto the server
scp $localDir/blog_"$postYear"_temp.html $sshCon:$remoteDir/blog_$postYear.html && echo "html file has been copied to the server"

# rename the local image to the desired name
mv $localDir/*.jpg $localDir/$imageName

# resize the picture for both preview and full view resolution
mogrify -path $localDir/full -resize $fullSize -quality 100 $localDir/*.jpg && echo "fullSize image has been created"
mogrify -path $localDir/preview -resize $previewSize -quality 100 $localDir/*.jpg && echo "preview image has been created"

# copy the images from the local directories to the server over ssh
scp $localDir/full/* $sshCon:$remoteDir/$postYear && echo "fullSize image has been copied" && scp $localDir/preview/* $sshCon:$remoteDir/$postYear/preview && echo "preview image has been copied"

# clean up local files
rm $localDir/*.jpg
rm $localDir/full/*
rm $localDir/preview/*
rm $localDir/blog_"$postYear"_temp.html
