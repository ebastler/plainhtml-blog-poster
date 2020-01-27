## plainhtml-blog-poster 
This is a bash script to semi-automatically publish content to a plain-html blog-like website. It polls it's content from a local directory, downloads the current html file from the remote dir, adds the content and re-uploads it through scp.

### Localdir
The script expects a local directory with the following content:
- folder: "full" (fullsize images will temporarily be placed here)
- folder: "preview" (preview images will temporarily be placed here)
- file: "blogpost.txt"
- file: "*.jpg"

The textfile has three lines, where the desired image name, image alt text and image description can be written in plain text.

The picture can have any name, as long as the ending is correct. It will then be changed to the name specified in "blogpost.txt".

Pictures will be deleted once the upload to the server was successful.

### Remotedir
The scripts expects a remote directory with the following contents:
- folder: "$year" (fullsize images will be placed here)
    - folder: "preview" (preview images will be placed here)
- file: "blog_$year.html" (html file where the blog post is supposed to be)

The folders are not automatically created - I was too lazy to automate a task that takes 30 seconds once a year. The "blog_$year.html" file can have any contents, as long as a specific marker (see included example file) is included. All submissions will be inserted after it.

### Variables that have to be conatined in "configPath" file
- localDir - as long as the script lies in the same directory as "*.jpg", "blogpost.txt" and the "full"/"preview" folders, no changes are required.
- sshCon - obviously, the place-holder username and domain have to be replaced by some that work on the webserver.
- remoteDir - path to the folder where the "blog_$year.html" is supposed to be - presumably somewhere in the webserver directory.
- textPath - as long as "blogpost.txt" lies in localdir, no changes are required.
- previewSize / fullsize - sizes for the pictures in px. Default values work fine for my application.

Example for "configPath" file:
```bash
localDir pwd
sshCon user@domain
remoteDir /path/to/folder
textPath blogpost.txt
previewSize "300"
fullSize "1280x1280"
```

Example for "blogpost.txt" file:
```bash
# write the filename for the image into the next line:
image_name.jpg

# write the alternative text for the image into the next line:
image_alt_text

# write the text for the blog post into the next line:
image_description
```