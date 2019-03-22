# Project: android-html-pages

If you use Android Studio on linux, this set of scripts will help you to make a simple html page, that shows source code files of each Android project.

## Prerequisites

The main script will use command **tree**. If it is not installed on your system yet, you can install it with `apt install tree` or `yum install tree`, depending which linux distribution you use. The scripts also use *sed* and *awk*, which are most likely available in every distribution. Copy the whole set of files in a preferred directory and make sure that `*.sh` scripts have permissions to be executable.

## Usage

Although the scripts have been tested, it is always recommended to make a *backup* of your projects before you start.

To create html page for a selected project, run `make_page.sh` with the path to that project as an argument.

For example:

```
$./make_page.sh ~/AndroidStudioProjects/MyApp/
```

Then open `index.html` in your browser to view the output. The contents block will be visible on the left side, and from here you can navigate on the newly created project page.
* Running the script on another project creates another page, and adds another contents block.
* Running the script **on the same project again** will overwrite its page and replace its contents block.  

## Author

Maciej Wojdak

## License

GPL-3.0
