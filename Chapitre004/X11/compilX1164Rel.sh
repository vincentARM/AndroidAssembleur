#compilation assembleur X11
#avec objrt des routines relogeables
echo "Compilation 64 bits X11 relogeables de "$1".s"
#pour la liste de compilation ajouter -a >$1"list.txt"
as -o $1".o"   $1".s" 
#pour la liste du linker ajouter --print-map >$1"map.txt"
ld -o $1 $1".o" ../routines64Relo.o -e main -lX11 -L/data/data/com.termux/files/usr/lib -dynamic-linker /system/bin/linker64 -pie
ls -l $1*  
echo "Fin de compilation."
