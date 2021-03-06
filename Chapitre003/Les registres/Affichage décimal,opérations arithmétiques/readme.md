### Opérations arithmétiques et base 10.
Maintenant, il ne nous reste plus qu' à écrire une routine d’affichage d’un registre en décimal (base10) et nous en servir pour voir les opérations arithmétiques autorisées avec les registres.

Dans le programme affDecimal32.s nous trouvons la routine conversion10 qui va convertir le contenu du registre r0 en une chaîne de caractères ascii représentant sa valeur en base 10 (décimale).

Pour cela nous divisons successivement la valeur à convertir par 10 et nous calculons le reste, reste que nous transformons en caractère ascii en ajoutant 48. 

Il y a un petit problème, les restes successifs des divisions donnent les chiffres décimaux en partant de la droite. Il nous faut donc ensuite recopier les chiffres du résultat dans la partie gauche de la zone de conversion pour avoir un affichage correct.

Remarque : nous utilisons l’instruction de division udiv qui n’est pas disponible sur tous les processeurs arm. Dans ce cas, il faut programmer une division entière. Vous trouverez un exemple sur le site : https://thinkingeek.com/arm-assembler-raspberry-pi/

Dans le corps du programme,nous appelons cette nouvelle routine pour afficher le nombre 100 puis le nombre le plus grand contenu dans un registre et nous affichons la longueur retournée pour vérification.

Vous remarquerez que nous pouvons alimenter un registre soit en notation decimale soit en notation hexadécimale. Nous pouvons aussi l'alimenter en notation binaire et en notation octal. 

Dans ce dernier cas c'est le 0 du début qui le distingue d'un nombre décimal : 020 n'est donc pas égal à 20 !!!

Sur mon téléphone, il est aussi possible d'utiliser l'instruction movt pour inserer la partie haute d'un registre. Mais attention dans ce cas il vaut mieux utiliser la notation hexa car si vous faites :
```asm
mov r0,#5678
movt r0,#1234
```
cela ne vous donnera pas le nombre décimal 12345678 

### Additions
Ensuite nous trouvons un exemple d’utilisation de l’addition sur des petits nombres puis un exemple d’addition sur un grand nombre proche de la valeur maximale. Et dans ce cas nous voyons que le résultat est faux car il y a un dépassement de la valeur maximum du registre. 

Heureusement, l’assembleur propose une solution pour signaler ce dépassement. Si nous utilisons l’instruction adds (avec un s final), le processeur mettra un 1 dans l’indicateur de retenue (carry) du registre d’état et il nous suffit de tester cette retenue avec les instructions bcs ou bcc pour déterminer s’il y a dépassement et prendre les mesures qui s’imposent.

Donc dans un programme assembleur qui effectue des calculs, vous pouvez utiliser add quand vous savez que les nombres utilisés sont petits. S’ils sont grands ou s’il y a un doute il faudra utiliser adds et programmer une gestion de ce dépassement (message et ou arrêt du traitement).

Vous remarquerez que l’indicateur utilisé (carry) est le même que celui qui récupère les bits lors des déplacement et que là aussi il faut ajouter un s aux instructions lsl ou lsr.

Vous pouvez modifier l’addition pour tester les 2 cas.

Enfin la retenue peut être récupérée pour être additionnée à une autre addition avec l’instruction adc.

Par exemple nous voulons additionner 2 nombres de 64 bits, le registre r1 contient les 32 bits de la partie basse du 1er nombre, le registre r2 la partie haute, le registre r3 la partie basse du 2ième nombre et r4 la partie haute.

Il nous suffit d'effectuer l’addition comme ceci :
```asm
adds r5,r1,r3      @ additionne les parties basses
adc  r6,r2,r5      @ additionne les parties hautes et la retenue.

```

Attention à l’interprétation des résultats car quelle addition avons nous fait exactement ?

Le registre r1 contient 4 294 967 290, le registre r2 contient 5 mais attention c’est la partie haute donc cela correspond à 5 * (2 puis 32) = 21 474 836 480

le 1er nombre correspond à 21 474 836 480 +  4 294 967 290 = 25 769 803 770

Le registre r3 contient 20 et le registre r4 contient 10 mais comme c’est la partie haute cela correspond à 10 * (2 puis 32) = 42 949 672 960.

Le 2ieme nombre correspond donc à 42 949 672 960 + 20 = 42 949 672 980

et la somme des 2 = 25 769 803 770 + 42 949 672 980 = 68 719 476 750

L’affichage du résultat nous donne 14 pour la partie basse et 16 pour la partie haute ce qui correspond à 16 * (2 puis 32) = 68 719 476 736.

Le résultat est donc : 68 719 476 736 + 14 = 68 719 476 750

Banco c’est le même que calculé plus haut. 


Vous pouvez remarquer que dans ce programme nous avons utilisé des zones de la .data initialisées à blanc comme zones de conversion à la place de zones de la section bss. Cela nous permet de vérifier que les zéros finaux des conversions sont bien à la bonne place.

Voici le résultat complet :
```
Début du programme 32 bits.
Vérification affichage décimal :
Longueur :
00000003
100
Grand nombre :
Longueur :
00000009
4294967295
Autre affectation grand nombre :
4294967295
Affectation nombre en octal:
16
Erreur affectation :
80877102

Addition
210
Addition grand nombre
14
Addition grand nombre 2
Pas de retenue.

Addition sur 64 bits
14
16

Fin normale du programme.
``` 
### Soustractions :
Maintenant nous allons utiliser l’instruction sub pour effectuer des soustractions dans le programme soustraction32.s.

Nous effectuons une soustraction simple puis une soustraction dont le résultat est manifestement faux.
 
La aussi comme pour l’addition, si nous utilisons l’instruction subs, l’indicateur carry du registre d’état est positionné mais attention il est mis à zéro s’il faut une retenue et sinon il est mis à 1.

Comme pour l’addition, nous pouvons utiliser l’instruction sbc pour tenir compte de la retenue lors de soustractions successives.

Mais la soustraction pose un problème intéressant : comment gérer les nombres negatifs ?

En effet jusqu’à maintenant, nous n’avons traité que des nombres positifs et rien n’indique dans un registre si un nombre est positif ou négatif.

Les ingénieurs ont trouvé une solution pour distinguer les nombres négatifs. 

Les nombres compris entre 1 et 2 puissance 31 -1 sont considérés comme positifs et les nombres de 2 puissance 31 à 2 puisssance 32 – 1 sont considérés comme négatifs. De plus leur valeur est calculée par complément à 2 puissance 32.

Par exemple prenons le cas de -1 : dans ce système il est calculé comme le complément à 2 puissance 32 soit :

4 294 967 296   - 1 = 4 294 967 295 ou en hexadécimal 0xFFFFFFFF 

Ce nombre vous rappelle quelque chose ? Et oui c’est la valeur maximale d’un registre.

Continuons la valeur – 10 sera indiquée par 

4 294 967 296   - 10   = 4 294 967 286

Et la plus grande valeur négative sera 

2 puis 31 soit 2 147 483 648

Et la plus grande valeur positive : 2 147 483 647

Mais comment le processeur sait-il que le registre contient une valeur non signée entre 0 et  4 294 967 295 ou une valeur signée positive entre 0 et 2 147 483 647 ou une valeur négative entre -1 et - 2 147 483 648. 

Et bien, il ne le sait pas !! c’est vous qui en choisissant les instructions et les tests détermineront si la valeur doit être dans l’un ou l’autre cas.

Il nous faut donc dupliquer la routine d’affichage en base 10, l’ancienne qui affichera les valeurs de 0 à 4 294 967 295 et une nouvelle qui affichera les valeurs avec le signe + ou le signe – suivant leur plage et c’est vous qui déciderez s’il faut appeler l’une ou l’autre routine.

Heureusement, l’assembleur propose un indicateur du registre d’état N (pour Négatif) qui sera mis à 1 si le résultat d’une opération est une valeur négative.

Voyons déjà la nouvelle routine de conversion conversion10S  (S pour signée).

Il nous faut un caractère de plus dans la zone de conversion pour y insérer le signe + ou -. 

Le signe est initialisé à + dans le registre r6 puis nous testons la valeur du registre r0 et si elle est plus petite que zéro, nous mettons le signe - dans le registre r6 et nous inversons la valeur avec l’instruction neglt r0,r0.

Puis nous effectuons la conversion comme dans la routine de conversion non signée.

A la fin, nous déplaçons les chiffres du résultat à partir de l’octet 1 de la zone de conversion et nous mettons le signe (registre r6) dans l’octet 0 de la zone.

Dans le corps du programme soustraction32.s nous mettons les valeurs 10 et -10 pour tester cette nouvelle routine.
Puis nous mettons la valeur maximum négative puis la valeur maximum positive. La routine donne bien les valeurs indiquées précédemment.

Mais cette solution pose de nouveaux problèmes :

Additionnons les nombres 2 147 483 640  et 20.

En arithmétique non signée, nous trouvons un résultat correct 2 147 483 660 mais en signée nous trouvons -2 147 483 636.

Heureusement la aussi l’assembleur à prévu un indicateur dans le registre d’état il s’agit de l’indicateur v comme overflow. Il nous suffit de tester cet indicateur avec les instructions bvs (branch if overflow set) et bvc (branch if overflow clear) pour gérer les 2 cas.

C’est la même chose pour la soustraction : le processeur positionne l’indicateur overflow si le résultat est inférieur à 2 147 483 648.

Après une opération arithmétique dont on a demandé la mise à jour des indicateurs il est possible de savoir si un résultat est négatif ou positif en testant l’indicateur de signe s du registre d’état avec les instructions bmi (branch if negative) ou bpl (branch if positive ou zéro).


Pour terminer, nous effectuons une utilisation de l’instruction rsb qui permet de soustraire une valeur d’un registre d’une constante. Cela permet d’économiser un registre car pour remplacer :
```asm
mov r1,#20
rsb r0,r1,#15
```

il aurait fallu faire :
```asm
mov r1,#20
mov r2,#15
sub r0,r2,r1
```

Voici le résultat complet du programme :
```
Début du programme 32 bits.

Soustraction
190
Soustraction négative
4294967286
Soustraction avec indicateur d'état
Retenue positionnée.

Valeur positive
+10
Valeur negative
-10
Valeur maxi négative
-2147483648
Valeur maxi positive
+2147483647
Depassement lors de l'addition
Affichage non signé :
2147483660
Affichage signé :
-2147483636
Soustraction inverse :
-5
Fin normale du programme.
```

### Multiplications
Dans le programme multi32.s, nous allons explorer les instructions de multiplication mais tout d’abord nous déplaçons les 2 routines conversion10 et conversion10S dans le fichier des routines que nous recompilons pour avoir un fichier objet complet.

Dans le premier exemple nous effectuons une multiplication simple avec 2 facteurs positifs puis une multiplication avec 2 facteurs négatifs avec l’instruction mul r0,r1,r2.

Vous remarquerez que la multiplication ne peut être faite qu’à partir de registres/ Il n’est pas possible d’utiliser une valeur immédiate.
La documentation précise aussi que seuls les indicateurs d’états  de signe et de zéro sont mis à jour si nous utilisons l’instruction muls. Les indicateurs carry et overflow ne sont pas mis à jour ce qui pose un problème pour détecter un dépassement de la taille d’un registre.

Heureusement il existe les instructions umull (multiplication non signée) et smull (multiplication signée) qui stocke le résultat sur 2 registres et donc il suffit de tester si le registre qui contient la partie haute est différent de 0 pour détecter le dépassement. Bien sûr, il est possible de se servir de ces instructions pour avoir des résultats en 64 bits mais il faut dans ce cas, gérer les autres opérations et l’affichage en 64 bits.

Ici nous n’avons qu’un affichage décimal en 32 bits et il nous faut donc interpréter correctement les résultats :

Le registre partie basse doit être considérée comme une valeur non signée. Le registre partie haute doit être considéré comme une valeur signée multiple de 2 puissance 32.

Dans le cas d’une multiplication non signée, nous avons multiplié 2 147 483 648 par 5 ce qui donne 10 737 418 240

L’affichage donne pour la partie basse  2 147 483 648 et pour la partie haute 2 ce qui correspond à 2 * (2 puis 32) soit 8 589 934 592 et le résultat est donc :
8 589 934 592 +  2 147 483 648 = 10 737 418 240  identique à celui qui était prévu.

Dans le 1er cas d’une multiplication signée, nous avons multiplié +  2 147 483 647 par – 5 ce qui donne - 10 737 418 235

La partie basse est  2147483653 et la partie haute est – 3 soit -3 * (2puis32) = -12 884 901 888

le résultat complet est donc -12 884 901 888 + 2147483653 = 10 737 418 235


Essayons de multiplier 2 nombres négatifs : -2 147 483 647 * - 5 = 10 737 418 235

L’affichage partie basse donne +2147483643 et la partie haute à +2 ce qui donne 2* (2 puis 32)=  8 589 934 592 et le résultat sera donc :

8 589 934 592 +  2147483643 = 10 737 418 235 ce qui bien celui attendu

Maintenant multiplions -2 147 483 647 * 5 =  - 10 737 418 235

La partie basse est  2147483653 et la partie haute est – 3 soit -3 * (2puis32) = -12 884 901 888

Et le résultat sera donc 2147483653 + -12 884 901 888 = - 10 737 418 235  égal au résultat attendu.

Nous avons aussi 2 autres instructions de multiplication : la première mla r0,r1,r2,r3  effectue la multiplication de r1 et r2 puis ajoute r3 et met le tout dans r0.   Nous verrons son utilisation dans le chapitre consacrée à la mémoire.

La seconde mls r0,r1,r2,r3 effectue la multiplication r1 par r2 et soustrat le résultat de r3 pour mettre le tout dans r0. Elle est interessant pour calculer le reste de la division de r3 par r1.

Par exemple si r3 contient 202 et r1 10, la division donne un quotient de 20 dans r1. Puis l’instruction mls fera l’opération 202 – (20 * 10) = 2.

exemple complet de l’exécution :
```
Début du programme 32 bits.

Multiplication simple
2000
Multiplication négative signée
+200Multiplication non signée avec résultat sur 64 bits
Partie basse
2147483648
Partie haute
2
Multiplication signée avec résultat sur 64 bits cas 1
Partie basse
2147483653
Partie haute
-3
Multiplication signée avec résultat sur 64 bits cas 2
Partie basse
2147483643
Partie haute
+2
Multiplication signée avec résultat sur 64 bits cas 3
Partie basse
2147483653
Partie haute
-3
instruction mla
1125
instruction mls
2
Fin normale du programme.
```

### Divisions.
Il n’y a que 2 instructions pour la division udiv pour la division non signée et sdiv pour la division signée.

De plus aucun indicateur d’état n’est positionné lors de ces divisions.

Dans le programme division32.s, nous nous contentons de tester ces 2 instructions et de calculer le reste avec l’instruction mls.

Vous remarquerez que si nous pouvons multiplier 2 registres de 32 bits pour avoir un résultat sur 64 bits, il n’y a pas de division de 64 bits par un registre 32 bits !! Il faudra écrire soit même la routine de division si elle est necessaire dans un calcul.

### Exemples particuliers
Dans le programme operPar32.s nous allons voir quelques exemples d'opérations particulières et fort utiles.

Tout d'abord, nous trouvons un test pour determiner si un nombre est pair ou impair. Il suffit de tester le bit 0 avec une instruction tst r0,#1.

Puis nous regardons quelle est l'incidence sur un nombre en base 10 du décalage d'un bit vers la gauche. Vous voyez que cette opération consiste en une multiplication par 2.

Si on déplace les bits de 2 positions vers la gauche, nous aurons une multiplication par 4. A chaque déplacement vers la gauche , nous avons donc une multiplication par une puissance de 2.

Ceci est valable pour des nombres signés ou non signés.

Maintenant si nous effectuons un déplacement de bits sur la droite avec l'instruction lsr, cela correspond à une division par des puissances de 2.
Mais attention, dans ce cas cela n'est valable que pour les divisions non signées. Sinon il faut utiliser l'instruction asr qui dupliquera le dernier bit et donc conservera le signe du nombre.

Ensuite nous calculons la valeur absolue d'un nombre. Il suffit que la première instruction (ici un movs) effectue la mise à jour des indicateurs d'état pour inverser la valeur si celle ci est négative avec l'instruction negmi.

Et pour terminer, nous écrivons une macro d'affichage du contenu du registre r0 en héxadécimal.
Il suffit d'appeler la macro affreghexa Exemple1 pour avoir le résultat :

Exemple1 : Valeur hexa du registre : 00001234



