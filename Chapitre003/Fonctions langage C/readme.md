### Appel à des routines C

Il est possible d’utiliser des fonctions du langage C ou d’appeler des fonctions de bibliothèques externes depuis l’assembleur.

Pour cela dans le programme appelC32.s nous allons nous contenter d’appeler la fonction printf du langage C.

La fonction  utilise dans l’ordre une chaine de formatage et des valeurs qui seront affichées en fonction de leur type (identificateur%c%d%s etc.)

Dans le programme , nous préparons une chaîne de formatage identique à celle du langage C et nous passons son adresse à la fonction dans le registre r0 puis nous passons la valeur à afficher dans le registre r1.

Et pour avoir accès aux librairies du C, nous devons modifier notre script de compilation pour remplacer l’éditeur de lien ld par l’éditeur de lien intégré au compilateur C : gcc.
Exemple :

```shell
#compilation assembleur
#compil avec linker gcc
echo "Compilation 32 bits de "$1".s avec linker gcc"
as -o $1".o"   $1".s" -a >$1"list.txt"
gcc -o $1 $1".o"   ~/asm32/routines32And.o -e main
#ld -o $1 $1".o" ~/asm32/routines32And.o -e main --print-map >$1"map.txt"
ls -l $1*
echo "Fin de compilation."
```
La compilation s’effectue correctement et le linker signale un avertissement indiquant que le point d’entrée main ne sera pas pris en compte.

En effet le linker gcc ajoute des instructions en début du programme sous l’étiquette start:  qui deviendra le nouveau point d’entrée : rien de grave.

L’exécution se termine anormalement avec l’erreur :

CANNOT LINK EXECUTABLE "appelC32": "/data/data/com.termux/files/home/asm32/debut3/appelC32" has text relocations

Une recherche sur Internet explique que le système Android lors d’appel de fonctions dynamiques n’accepte pas les définitions des données comme nous l’avons fait jusqu’à maintenant mais exige que les adresses puissent être relogeables, c’est à dire que les données puissent être stockées à des adresses autres que celle définies par le linker.

Toujours grâce à internet, j’ai pu trouvé comment procéder dans le cas de l’assembleur ARM. Il faut   d’abord déclarer un déplacement  entre la donnée et cette déclaration avec l’instruction
```asm
iOfszMessDebPgm:       .int szMessDebPgm - .
```
Puis charger ce déplacement dans un registre par les instructions :
```asm
adr r0,iOfszMessDebPgm
ldr r1,[r0]
```
puis calculer l’adresse à utilisera avec l’instruction :
```asm
add r0,r1
```
Et il faut faire cela pour toutes les données déclarées en mémoire.

C’est un peu compliqué mais cela fonctionne, la fonction printf du programme appelCA32.s dans le programme affiche bien la valeur passée dans le registre r1

Il faut donc aussi modifier toutes nos routines précédentes pour éviter cette anomalie !!

Nous continuons en affichant 5 valeurs passées dans les registres r1 à r5 avec le formatage « valeur=%d %d %d %d%d« 

Le résultat est bon pour les 3 premières valeurs mais erroné pour la 4 ième et la 5ième ! Pourquoi ?

La convention d’appel de fonctions pour le langage C indique que les 4 premiers paramètres sont passés dans les registres r0 à r3 et que les autres doivent être passés sur la pile.

De plus elle indique que les registres r0 à r3 ne sont pas sauvegardés par les fonctions !!

Nous refaisons un test avec le passage des registres r4 et r5 sur la pile. L’affichage semble correct mais les valeurs des registres r4 et r5 sont inversées.
Mais c’est bien sûr !! c’est normal, puisque les valeurs sur la pile sont depilées dans l’ordre inverse de leur empilement. Il faut donc inverser les 2 push.

L’affichage est maintenant correct.

Reste un dernier petit problème : nous avons effectué 2 push pour passer les 2 derniers paramètres et la fonction printf ne réaligne pas la pile lorqu(elle se termine. Il faut donc ajouter une instruction add sp,#8  pour réaligner la pile correctement.

Voici le résultat complet du programme :
```
Début du programme 32 bits.
valeur = 5
valeur = 1 2 3 -203521072 0
valeur = 1 2 3 5 4
Pile avant = : Valeur hexa du registre : FFEF1B80
valeur = 1 2 3 4 5
Pile après = : Valeur hexa du registre : FFEF1B80
Fin normale du programme.
```
