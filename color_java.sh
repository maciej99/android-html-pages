#!/bin/sh
# Format JAVA file as a <pre>..</pre> block for html page.
# Apply CSS style tags for color coding.
if [ -z "$1" ]; then
	echo `basename $0`" : Missing argument [file.java]"
	exit 1
elif [ ! -f "$1" ]; then
	echo `basename $0`" : File \"$1\" not found."
	exit 1
fi
# tags for colors referring to CSS styles
TAGJ="<span class=\"java_keyword\">"
TAGC="<span class=\"java_comment\">"
TAGL="<span class=\"java_string_literal\">"
TAGBC="<span class=\"java_block_comment\">"
TAGSTOP='<\/span>'

java_regex="abstract\|assert\|boolean\|break\|byte\|case\|catch\|char\|class\|const\|continue\|default\|do\|double\|else\|enum\|extends\|final\|finally\|float\|for\|goto\|if\|implements\|import\|instanceof\|int\|interface\|long\|native\|new\|package\|private\|protected\|public\|return\|short\|static\|strictfp\|super\|switch\|synchronized\|this\|throw\|throws\|transient\|try\|void\|volatile\|while";
echo "<pre class=\"java\">";
sed -e 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g;' $1 | awk '
BEGIN{mode=0;FS="";OFS="";}
# mode: 0-code, 1-literal, 2-one-line comment, 3-block comment
# mask text inside comments and literals by inserting "r>b"
# FS is empty, reading single chars
# OFS output separator is also empty
{
for(i=1; i<=NF; i++){
	switch (mode) {
		case "0":
			# reading code
			if($i=="\"") {$i="<LIT>\"";mode=1}
			else if($i=="/" && $(i+1)=="/")
				{$i="<OLC>/";mode=2}
			else if($i=="/" && $(i+1)=="*")
				{$i="<BLK>/";mode=3}
		        break
		case "1":
			# reading literal, mask and look for "
			if($i=="\"")
				{$i="\"<END>";mode=0}
			else {gsub(/[a-z ]/,"&r>b",$i)};
			break	    
		case "2":
			# reading one-line comment
			# mask till the end of the line
			gsub(/[a-z ]/,"&r>b",$i);
			break
		case "3":
			# reading block comment
			# mask and look for */
			if($i=="*" && $(i+1)=="/")
				{$(i+1)="/<END>";mode=0}
			else {gsub(/[a-z ]/,"&r>b",$i)};
			break
		default: mode=0; break
		}
	}
	if(mode==2)
		{print $0,"<END>"; mode=0;}
	else {print $0};
}' | sed -e 's/\(^\|[^a-zA-Z0-9_]*\)\('$java_regex'\)\([^a-zA-Z0-9_]\)/\1'"$TAGJ"'\2'"$TAGSTOP"'\3/g' \
	-e 's/'"$TAGSTOP"'\([ ^I]\)'"$TAGJ"'/\1/g;' \
	-e 's/<LIT>/'"$TAGL"'/g; s/<OLC>/'"$TAGC"'/g; s/<BLK>/'"$TAGBC"'/g; s/<END>/'"$TAGSTOP"'/g; s/r>b//g;';
echo "</pre>";
