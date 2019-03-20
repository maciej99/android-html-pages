#!/bin/sh
# Format XML file as a <pre>..</pre> block for html page.
# Apply CSS style tags for color coding.
if [ -z "$1" ]; then
	echo `basename $0`" : Missing argument [file.xml]"
	exit 1 
elif [ ! -f "$1" ]; then
	echo `basename $0`" : File \"$1\" not found."
	exit 1
fi
# tags referring to CSS styles
TAGAND="<span class=\"xml_android\">"
TAGANDATR="<span class=\"xml_android_attr\">"
TAGL="<span class=\"xml_string_literal\">"
TAGBC="<span class=\"xml_block_comment\">"
TAGSTOP='<\/span>'
echo "<pre class=\"xml\">";
sed -e 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g;' < $1 | awk '
BEGIN{mode=0;FS="";OFS="";}
# mode: 0-xml code, 1-string literal 2-block comment
# mask text inside by inserting "r>x"
{
for(i=1; i<=NF; i++){ switch (mode) {
	case "0":
		# reading regular xml
		# look for comments and string literals
		if($i=="&" && $(i+1)=="l" && $(i+2)=="t" && $(i+3)==";" && $(i+4)=="!" && $(i+5)=="-" && $(i+6)=="-")
			{$i="<BLK>&";i=i+6;mode=2}
		else if($i=="\"") {$i="<LIT>\"";mode=1}			
	        break
	case "1":
		if($i=="\"") {$i="\"<END>";mode=0}
		else {gsub(/[a-z ]/,"&r>x",$i)};
		break
	case "2":
		if($i=="-" && $(i+1)=="-" && $(i+2)=="&" && $(i+3)=="g" && $(i+4)=="t" && $(i+5)==";")
			{$(i+5)=";<END>";i=i+5;mode=0}
		else {gsub(/[a-z ]/,"&r>x",$i)};
		break			
	default: mode=0; break
	}
} print $0;
}' | sed -e 's/android\:\(.*\)\=/'"$TAGAND"'android<END>\:'"$TAGANDATR"'\1<END>\=/;' \
	-e 's/<LIT>/'"$TAGL"'/g; s/<OLC>/'"$TAGC"'/g; s/<BLK>/'"$TAGBC"'/g; s/<END>/'"$TAGSTOP"'/g; s/r>x//g;';
echo "</pre>"
