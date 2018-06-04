OUTPUT=$1
export LANG=en_US.UTF-8
export LC_ALL="$LANG"
export LANGUAGE="$LANG"
[ -f $OUTPUT ] && rm $OUTPUT $OUTPUT.final
sed -re '/.+ --> .+/d;/^$/d;' | \
    tr '\n' ' ' | \
    sed -re 's/,/ /g;s/\.+/\./g;s/\$+//g;s/\;//g' |\
    tr -d '"()[]%?!*+&/<>=:”#@$~^°";[0-9]{}_' | tr -d -- '-$' | \
    tr '.?!' '\n' | tr -s ' ' >> $OUTPUT;

python3 <<EOF
import codecs
f = codecs.open('$OUTPUT', 'r', encoding='utf-8', errors='ignore')
for line in f:
    of=open('$OUTPUT.final', 'a')
    of.write(line.upper())
    of.close()
f.close()
EOF

cat $OUTPUT.final | tr -d '$' | tr -d ';' | sed -e 's/Ş//g;s/˛//g'
