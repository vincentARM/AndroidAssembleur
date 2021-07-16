### Appel à des routines C
Il est possible d’utiliser des fonctions du langage C ou d’appeler des fonctions de bibliothèques externes depuis l’assembleur.

Pour cela dans le programme appelFonctC64.s nous allons nous contenter d’appeler la fonction printf du langage C.

La fonction utilise dans l’ordre une chaîne de formatage et des valeurs qui seront affichées en fonction de leur type (identificateur %c %d %s etc.)

Dans le programme , nous préparons une chaîne de formatage identique à celle du langage C et nous passons son adresse à la fonction dans le registre x0 puis nous passons la valeur à afficher dans le registre x1.
Et pour avoir accès aux librairies du C, nous devons modifier notre script de compilation pour remplacer l’éditeur de lien ld par l’éditeur de lien intégré au compilateur C. 
Je voulais utiliser gcc mais curieusement il n’est pas présent sur mon smartphone. Mais je vois qu’il peut être remplacé par le compilateur clang en installant le package avec la commande ;
```shell
 pkg install clang
 ```
Il nous faut crer un autre script de compilation pour appeler clang. 
. Exemple :
```shell
#compilation assembleur
echo "Compilation 64 bits de "$1".s"
#pour la liste de compilation ajouter -a >$1"list.txt"
as -o $1".o"   $1".s" 
#pour la liste du linker ajouter --print-map >$1"map.txt"
clang -o $1 $1".o" 
#ld -o $1 $1".o" ../routines64.o  -e main 
ls -l $1*  
echo "Fin de compilation."
```
La compilation s’effectue correctement et le linker signale un avertissement :
```
/data/data/com.termux/files/usr/bin/ld: warning: creating DT_TEXTREL in a PIE.
```
L’exécution se termine anormalement avec l’erreur :
```
CANNOT LINK EXECUTABLE "appelFonctC64": "/data/data/com.termux/files/home/asm64/cours/debut3/appelFonctC64" has text relocations
```
Une recherche sur Internet explique que le système Android lors d’appel de fonctions dynamiques n’accepte pas les définitions des données comme nous l’avons fait jusqu’à maintenant mais exige que les adresses puissent être relogeables, c’est à dire que les données puissent être stockées à des adresses autres que celle définies par le linker.

Toujours grâce à internet, j’ai pu trouvé comment procéder dans le cas de l’assembleur ARM. Il faut d’abord déclarer un déplacement entre la donnée et cette déclaration avec l’instruction :
```asm
qOfszMessDebPgm:       .quad szMessDebutPgm - .
```
Puis charger ce déplacement dans un registre par les instructions :
```asm
adr x0,qOfszMessDebutPgm
ldr x1,[x0]
puis calculer l’adresse à utilisera avec l’instruction :
add x0,x0,x1
```
Et il faut faire cela pour toutes les données déclarées en mémoire.

C’est un peu compliqué mais cela fonctionne, la fonction printf  affiche bien la valeur passée dans le registre x1.

Il faut donc aussi modifier toutes nos routines précédentes pour éviter cette anomalie !!

Nous continuons en affichant 5 valeurs passées dans les registres x1 à x9 avec le formatage "valeur=%d %d %d %d %d %d %d %d %d".

Le résultat est bon pour les 7 premières valeurs mais erroné pour la 8 ième et la 9ième ! Pourquoi ?

La convention d’appel de fonctions pour le langage C indique que les 8 premiers paramètres sont passés dans les registres x0 à x7 et que les autres doivent être passés sur la pile.

De plus elle indique que les registres x0 à x17 ne sont pas sauvegardés par les fonctions !!

Nous refaisons un test avec le passage des registres x8 et x9 sur la pile. 

L’affichage est maintenant correct.

Reste un dernier petit problème : nous avons effectué 2 insertions sur la pile pour passer les 2 derniers paramètres et la fonction printf ne réaligne pas la pile lorsqu’elle se termine. Il faut donc ajouter une instruction add sp,sp,#16 pour réaligner la pile correctement.

Enfin nous effectuons un dernier test en stockant 4 registres sur la pile et vous constatez qu’il faut inverser les insertions pour que l’affichage soit correct. Ceci est normal puisque le dépilage s ‘effectuer en sens inverse de l’empilement.

Voici le résultat complet du programme :
```
Début programme.
Appel 1
Valeur = 5
Appel 2
Valeur = 1 2 3 4 5 6 7 0 0
Appel 3
Valeur = 1 2 3 4 5 6 7 8 9
Appel 4
Valeur = 1 2 3 4 5 6 7 10
Appel 5
Valeur = 1 2 3 4 5 6 7 10 11 8 9
Fin normale du programme.
```
