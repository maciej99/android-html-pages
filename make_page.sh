#!/bin/bash
# ------------------------------------------------------------
# This script reads source files from an Android Project,
# and creates a HTML page
# Prerequisites:
# - you need command "tree" installed
# - other files of this set should be in the same folder:
# color_java.sh, color_xml.sh, toc.html, index.html, style.css 
# ------------------------------------------------------------
usage() {
  echo "Usage: `basename $0` [path_to_android_project]"
}
# validate argument: cannot be empty, nor non-existing path 
if [ -z "$1" ]; then
	echo "Missing argument."
	usage
	exit 1
elif [ ! -d "$1" ]; then
	echo "Path: \"$1\" not found."
	usage
	exit 1
fi
# check other components...
for f in color_java.sh color_xml.sh index.html style.css toc.html
do
	if [ ! -f "$f" ]; then
		echo "File $f is missing."; exit 1;
	fi
done
# make sure that argument path is an absolute path
# it also cannot have a slash at the end
cd $1
PROJECTDIR=$(pwd)
cd $OLDPWD
# extract project name and set SRCDIR path
PROJECTNAME=$(echo "$PROJECTDIR"  | sed -e 's/\/..*\//''/')
SRCDIR="$PROJECTDIR/app/src/main"
# if SRCDIR desn't exist - probably not an Android Project
if [ ! -d "$SRCDIR" ]; then		
	echo -n "This path doesn't contain source directory"
	echo -n " $SRCDIR "
	echo "(Is it Android Project?)";
	usage;
	exit 1
fi

fileheading() {
  # crop the full path, so it starts with [ProjectName].
  ref=$(echo $1 | sed -e 's/^\/.*\/\('"$PROJECTNAME"'\)/\1/');
  echo "<p id=\"$ref\">"
  echo "<br>"
  echo "File: <span class=\"filepath\">$ref</span>:"
  echo "</p>"
}
# ---- CREATING A HTML PAGE: [ProjectName].html ---
page=$PROJECTNAME'.html';
# check if such page already exists
if [ -f "$page" ];
then
echo "The page $page already exists!"
echo -n "The script will overwrite this page"
echo " and replace contents block."
echo -n "Continue? (Y/n)"
read overwriteflag
	if [ "$overwriteflag" != "Y" ]; then
		echo "No output written. Exit."; exit 0;
	fi
fi
echo "Reading files..."
# Writing output of "tree" command to temporary file.
# Note: for directories drawable- and mipmap- we will omit
# files from directories with with
# -ldpi, -mdpi, -hdpi, -xhdpi, -xxhdpi
# to avoid listing files of the same names multiple times.
# These files won't be included on the page.
# From the tree listing, we also remove empty lines,
# and the line with directories and files count.
dir_regex='\(mipmap\|drawable\)-x\{0,2\}[lmh]dpi'
tree $SRCDIR -f | sed -e '/\/'"$dir_regex"'\/.*$/d; s/\/'"$dir_regex"'$/& [omitted]/; /^$/d; /^[0-9]\+ directories/d;' > tmp_tree;

# write the beginig of contents block
echo "<!--begin:$PROJECTNAME-->" > tmp_contents;
echo "<div class=\"container\" id=\"heading_$PROJECTNAME\">" >> tmp_contents;
echo "<div class=\"heading\" onclick=\"show('$PROJECTNAME','heading_$PROJECTNAME')\">$PROJECTNAME</div>" >> tmp_contents
echo "<div class=\"hidenDiv\" id=\"$PROJECTNAME\">" >> tmp_contents
echo "<p class=\"hidenPar\">" >> tmp_contents
echo "<div class=\"contents\">" >> tmp_contents
echo "<a href=\"$PROJECTNAME.html#top\" target=\"main\">$PROJECTNAME (page top)</a><br>" >> tmp_contents;
# Changing some tree filenames into links <a href=...>.
# As references we crop the full paths,
# so they start with [ProjectName].
# (they will be shorter, but still unique in the project)
# The second sed command removes fullpath notation
# from all the other lines (not converted to links).
lead="<a href=\"$PROJECTNAME.html#";
mid="\" target=\"main\">";
tail="<\/a>";
echo "<pre class=\"tree\">" >> tmp_contents;
sed -e 's/\/.*\/\('"$PROJECTNAME"'\/.*\/\)\([a-zA-Z0-9_]*\.\)\(java\|kt\|xml\)$/'"$lead"'\1\2\3'"$mid"'\2\3'"$tail"'/' \
	-e '/'"$lead"'/ !{s/\/.*\///;}' <tmp_tree >> tmp_contents;
# write the end of contents block
echo -e "</pre>\n</div>\n</p>\n</div>\n</div>\n<!--end:$PROJECTNAME-->" >> tmp_contents;

# write the beginig of [ProjectName].html
echo -e "<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html\" charset=\"utf-8\">\n<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">
<title>"$PROJECTNAME"</title>\n</head>\n<body>\n<h1>"$PROJECTNAME"</h1>" > $page;
cat tmp_tree | while read line;
do
  f=$(echo $line | sed -e 's/^[^\/]*\(\/.*\)$/\1/');
  ext=$(echo $f | sed -e 's/^.*\.\([a-z]*\)$/\1/');
    case $ext in
      java)
	fileheading $f >> $page;
	./color_java.sh $f >> $page;;
      kt)
	fileheading $f >> $page;
	echo "<pre class=\"kotlin\">" >> $page;
	sed -e 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g;' $f >>$page
	echo "</pre>" >> $page;;
      xml)
	fileheading $f >> $page;
	./color_xml.sh $f >> $page;;
    esac;
done;
# write the end of [ProjectName].html
echo -e "</body>\n</html>" >> $page;
echo "Page $page has been created."; 

# ---- INSERT THE CONTENTS BLOCK ----
# if the script is run to overwrite existing page,
# remove also old contents block, the new one goes at the top
if [ "$overwriteflag" == "Y" ]; then
	sed -i '/'"<\!--begin:$PROJECTNAME-->"'/,/'"<\!--end:$PROJECTNAME-->"'/{d}' toc.html
fi
# insert contents block into toc.html
# below a marker <!--NEXT_PROJECT_HERE-->
# note: sed with -i option writes changes directly to the file
sed -i '/<\!--NEXT_PROJECT_HERE-->/ {
	r tmp_contents
}' toc.html
# cleanup
rm tmp_tree tmp_contents;
echo "Contents for $PROJECTNAME has been added to toc.html."
echo -e "Complete!\nPlease open index.html in your browser."
