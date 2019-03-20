# Project: android-html-pages

This is a set of bash scripts and html components, that allows to export an Android project to html page.
If you use Android Studio on linux, now you can make a quick and simple html page showing the most vital source code files
for each Android project.

## Prerequisites

The linux command **tree** will be used to create a section with local links.
If it's not installed on your system, you can install it with `apt install tree` or `yum install tree`, depending on distribution.   
The scripts also use *sed* and *awk*, which are most likely available in every linux distribution.
Copy this set of files in a preferred directory, then make sure that `*.sh` scripts have permissions to be executable.  
The scripts have been tested on Centos 7 and Xubuntu 18.04.

## Usage

Although the scripts have been tested, it is always recommended to make a *backup* of your projects before you start.
To create html page for a selected project, run `make_page.sh` with the path to that project as an argument.
For example:

```
$./make_page.sh ~/AndroidStudioProjects/MyApp/
```

Then open `index.html` in your browser to view the output.
Running the same script with another project creates another page, and adds another section in the contents page.
Running the script *on the same project again*, will *overwrite* its page and *replace* its section with links.  

## Authors

Maciej Wojdak

## License

GPL-3.0
