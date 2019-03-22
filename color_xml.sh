#!/bin/sh
# Format XML file as a <pre>...</pre> part of html page.
if [ -z "$1" ]; then
	s=$(basename $0)
	echo "$s : Missing argument [file.xml]"
	exit 1 
elif [ ! -f "$1" ]; then
	s=$(basename $0)
	echo "$s : File \"$1\" not found."
	exit 1
fi
# tags for formatting pattern android:attr=
T1="<span class=\"xml_android\">android<END>:"
T2="<span class=\"xml_android_attr\">"
# write output
echo "<pre class=\"xml\">";
sed -e 's/&/\&amp;/g;s/</\&lt;/g;s/>/\&gt;/g;' < $1 |
awk 'BEGIN{mode=0;FS="";OFS="";}
# mode: 0-xml code, 1-string literal 2-block comment
# mask text inside by inserting "x>x"
{
for(i=1; i<=NF; i++){ switch (mode) {
	case "0":
		# looking for comments and string literals
		txt=$i$(i+1)$(i+2)$(i+3)$(i+4)$(i+5)$(i+6)
		if(txt=="&lt;!--") 
			{$i="<BLK>&";i=i+6;mode=2}
		else if($i=="\"") {$i="<LIT>\"";mode=1}			
	        break
	case "1":
		if($i=="\"") {$i="\"<END>";mode=0}
		else {gsub(/[a-z ]/,"&x>x",$i)};
		break
	case "2":
		txt=$i$(i+1)$(i+2)$(i+3)$(i+4)$(i+5)
		if(txt=="--&gt;")
			{$(i+5)=";<END>";i=i+5;mode=0}
		else {gsub(/[a-z ]/,"&x>x",$i)};
		break			
	default: mode=0; break
	}
} print $0;
}' |
sed -e 's/android\:\(.*\)\=/'"$T1""$T2"'\1<END>\=/;' \
	-e 's/<LIT>/<span class=\"xml_string_literal\">/g;' \
	-e 's/<BLK>/<span class=\"xml_block_comment\">/g;' \
	-e 's/<END>/<\/span>/g;' \
	-e 's/x>x//g;';
echo "</pre>"
