#compilation assembleur
#echo $0,$1
echo "Compilation 64 bits de "$1".s"
#pour la liste de compilation ajouter -a >$1"list.txt"
as -o $1".o"   $1".s" 
#pour la liste du linker ajouter --print-map >$1"map.txt"
clang -o $1 $1".o" 
#ld -o $1 $1".o" ../routines64.o  -e main 
ls -l $1*  
echo "Fin de compilation."
