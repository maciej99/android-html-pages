#!/bin/sh
# Format Java file as a <pre>...</pre> part of html page.
if [ -z "$1" ]; then
	s=$(basename $0)
	echo "$s : Missing argument [file.java]"
	exit 1
elif [ ! -f "$1" ]; then
	s=$(basename $0)
	echo "$s : File \"$1\" not found."
	exit 1
fi
# css tag and regex for java keywords
TAGJ="<span class=\"java_keyword\">"
j1="abstract\|assert\|boolean\|break\|byte\|case"
j2="\|catch\|char\|class\|const\|continue\|default\|do"
j3="\|double\|else\|enum\|extends\|final\|finally\|float"
j4="\|for\|goto\|if\|implements\|import\|instanceof\|int"
j5="\|interface\|long\|native\|new\|package\|private"
j6="\|protected\|public\|return\|short\|static\|strictfp"
j7="\|super\|switch\|synchronized\|this\|throw\|throws"
j8="\|transient\|try\|void\|volatile\|while"
jx=$j1""$j2""$j3""$j4""$j5""$j6""$j7""$j8
jregex="\(^\|[^a-zA-Z0-9_]*\)\($jx\)\([^a-zA-Z0-9_]\)"

echo "<pre class=\"java\">";
sed -e 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g;' $1 |
awk 'BEGIN{mode=0;FS="";OFS="";}
# mode:0-code,1-literal,2-one-line comment,3-block comment
# mask text in comments and literals by inserting "x>x"
# FS is empty, reading single chars, OFS empty too
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
			# reading literal, mask, look for "
			if($i=="\"")
				{$i="\"<END>";mode=0}
			else {gsub(/[a-z ]/,"&x>x",$i)};
			break	    
		case "2":
			# reading one-line comment
			# mask till the end of the line
			gsub(/[a-z ]/,"&x>x",$i);
			break
		case "3":
			# reading block comment
			# mask and look for */
			if($i=="*" && $(i+1)=="/")
				{$(i+1)="/<END>";mode=0}
			else {gsub(/[a-z ]/,"&x>x",$i)};
			break
		default: mode=0; break
		}
	}
	if(mode==2)
		{print $0,"<END>"; mode=0;}
	else {print $0};
}' |
sed -e 's/'"$jregex"'/\1'"$TAGJ"'\2<\/span>\3/g' \
	-e 's/<\/span>\([ ^I]\)'"$TAGJ"'/\1/g;' \
	-e 's/<LIT>/<span class=\"java_string_literal\">/g;' \
	-e 's/<OLC>/<span class=\"java_comment\">/g;' \
	-e 's/<BLK>/<span class=\"java_block_comment\">/g;' \
	-e 's/<END>/<\/span>/g;' \
	-e 's/x>x//g;';
echo "</pre>";
