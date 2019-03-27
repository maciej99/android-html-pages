#!/bin/bash
# ---------------------------------------------------------
# This script reads source files from an Android Project,
# and creates a HTML page.
# Prerequisites:
# - you need command "tree" installed
# - other files of this set should be in the same folder:
# 	color_java.sh, color_xml.sh, toc.html,
# 	index.html, style.css 
# ---------------------------------------------------------
usage() {
	s=$(basename $0)
	echo "Usage: $s [path_to_android_project]"
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
# argument path must be an absolute path, with no slash tail
cd $1
PROJECTDIR=$(pwd)
cd $OLDPWD
# extract project name and set SRCDIR path
PROJECTNAME=$(echo "$PROJECTDIR"  | sed -e 's/\/..*\//''/')
SRCDIR="$PROJECTDIR/app/src/main"
# if SRCDIR doesn't exist - probably not an Android Project
if [ ! -d "$SRCDIR" ]; then		
	echo -n "This path doesn't contain src directory"
	echo -n " $SRCDIR "
	echo "(Is it Android Project?)";
	usage;
	exit 1
fi

fileheading() {
# crop the full path, so it starts with [ProjectName].
ref=$(echo $1 | sed -e 's/^\/.*\/\('"$PROJECTNAME"'\/\)/\1/');
echo "<p id=\"$ref\">"
echo "<br>"
echo "File: <span class=\"filepath\">$ref</span>:"
echo "</p>"
}
contentshead() {
# heading of contents div; use Projectname as an arg 
echo "<!--begin:$1-->"
echo "<div class=\"container\"id=\"heading_$1\">"
echo -n "<div class=\"heading\" "
echo -n "onclick=\"show('$1','heading_$1')\">"
echo "$PROJECTNAME</div>"
echo "<div class=\"hidenDiv\" id=\"$1\">"
echo "<p class=\"hidenPar\">"
echo "<div class=\"contents\">"
echo -n "<a href=\"$1.html#top\" "
echo "target=\"main\">$1 (page top)</a><br>"
}
contentstail() {
# end of contents part; use Projectname as an arg
echo -e "</pre>\n</div>\n</p>\n</div>\n</div>\n<!--end:$1-->"
}
pagehead() {
# heading of project page; use Projectname as an arg
echo '<html>'; echo '<head>'
echo -n '<meta http-equiv="Content-Type" content="text/html"'
echo 'charset="utf-8">'
echo -n '<link rel="stylesheet" type="text/css"'
echo ' href="style.css">'
echo -e "<title>"$1"</title>\n</head>\n<body>\n<h1>"$1"</h1>" 
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
# files from directories with with -ldpi, -mdpi, -hdpi, etc.
# to avoid listing files of the same names multiple times.
# Removing also empty lines and tree files info.
dir_regex='\(mipmap\|drawable\)-x\{0,2\}[lmh]dpi'
tree $SRCDIR -f |
sed -e '/\/'"$dir_regex"'\/.*$/d;' \
	-e 's/\/'"$dir_regex"'$/& [omitted]/;' \
	-e '/^$/d;' \
	-e '/^[0-9]\+ directories/d;' > tmp_tree;

# write the beginig of contents block
contentshead $PROJECTNAME > tmp_contents
# changing some tree filenames into links <a href=...>.
r1="\/.*\/\($PROJECTNAME\/.*\/\)\([a-zA-Z0-9_]*\.\)"
r2="\(java\|kt\|xml\)$"
reg=$r1""$r2
# parts of link: lead, middle, tail
L="<a href=\"$PROJECTNAME.html#";
M="\" target=\"main\">";
T="<\/a>";
echo "<pre class=\"tree\">" >> tmp_contents;
sed -e 's/'"$reg"'/'"$L"'\1\2\3'"$M"'\2\3'"$T"'/' \
	-e '/'"$L"'/ !{s/\/.*\///;}' <tmp_tree >> tmp_contents;
# write the end of contents block
contentstail $PROJECTNAME >> tmp_contents;

# write the begining of [ProjectName].html
pagehead $PROJECTNAME > $page;
# minimalist sed command to put src text into <pre>...<pre>
preregex='s/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g;'
# read files as listed in contents
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
	sed -e "$preregex" $f >>$page
	echo "</pre>" >> $page;;
      xml)
	fileheading $f >> $page;
	./color_xml.sh $f >> $page;;
    esac;
done;
# write the end of [ProjectName].html
echo -e "</body>\n</html>" >> $page;
echo "Page $page has been created."; 

# ---- inserting the contents block into toc.html ----
# if the script is run to overwrite existing page,
# remove also old contents block, the new one goes at the top
if [ "$overwriteflag" == "Y" ]; then
	s1="<\!--begin:$PROJECTNAME-->"
	s2="<\!--end:$PROJECTNAME-->"
	sed -i '/'"$s1"'/,/'"$s2"'/{d}' toc.html
fi
# insert contents below marker <!--NEXT_PROJECT-->
sed -i '/<\!--NEXT_PROJECT-->/ {
	r tmp_contents
}' toc.html
# cleanup
rm tmp_tree tmp_contents;
echo "Contents for $PROJECTNAME has been added to toc.html."
echo -e "Complete!\nPlease open index.html in your browser."
