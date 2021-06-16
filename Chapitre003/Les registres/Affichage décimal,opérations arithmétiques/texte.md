### Opérations arithmétiques et base 10.
Maintenant, il ne nous reste plus qu « à écrire une routine d’affichage d’un registre en décimal (base10) et nous nous en servirons pour voir les opérations arithmétiques autorisées avec les registres.

Dans le programme affDecimal32.s nous trouvons la routine conversion10 qui va convertir le contenu du registre r0 en une chaîne de caractères ascii représentant sa valeur en base 10 (décimale).

Pour cela nous divisons successivement la valeur à convertir par 10 et nous calculons le reste, reste que nous transformons en caractère ascii en ajoutant 48. 

Il y a un petit problème, les restes successifs des divisions donnent les chiffres décimaux en partant de la droite. Il nous faut donc ensuite recopier les chiffres du résultat dans la partie gauche de la zone de conversion pour avoir un affichage correct.

Remarque : nous utilisons l’instruction de division udiv qui n’est pas disponible sur tous les processeurs arm. Dans ce cas, il faut programmer une division entière. Vous trouverez un exemple sur le site : 

Dans le corps du programme,nous appelons cette nouvelle routine pour afficher le nombre 100 puis le nombre le plus grand contenu dans un registre et nous affichons la longueur retournée pour vérification.

### Additions
Ensuite nous trouvons un exemple d’utilisation de l’addition sur des petits nombres puis un exemple d’addition sur un grand nombre proche de la valeur maximale. Et dans ce cas nous voyons que le résultat est faux car il y a un dépassement de la valeur maximum du registre. 

Heureusement, l’assembleur propose une solution pour signaler ce dépassement. Si nous utilisons l’instruction adds (avec un s final), le processeur mettra un 1 dans l’indicateur de retenue (carry) du registre d’état et il nous suffit de tester cette retenue avec les instructions bcs ou bcc pour déterminer s’il y a dépassement et prendre les mesures qui s’imposent.

Donc dans un programme assembleur qui effectue des calculs, vous pouvez utiliser add quand vous savez que les nombres utilisés sont petits et s’ils sont grands ou s’il y a un doute il faudra utiliser adds et programmer une gestion de ce dépassement (message et ou arrêt du traitement).

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
 
La aussi comme pour l’addition, si nous utilisons l’instruction subs, l’indicateur carry du registre d’état est positionne mais attention il est mis à zéro s «’il faut une retenue et sinon il est mis à 1.

Comme pour l’addition, nous pouvons utiliser l’instruction sbc pour tenir compte de la retenue lors de soustractions successives.

Mais la soustraction pose un problème intéressant : comment gérer les nombres negatifs ?

En effet jusqu’à à maintenant, nous n’avons traiter que des nombres positifs et rien n’indique dans un registre si un nombre est positif ou négatif.

Les ingénieurs ont trouvé une solution pour distinguer les nombres négatifs. 

Les nombres compris entre 1 et 2 puis 31 -1 sont considérés comme positifs et les nombres de 2 puis 31 à 2 puis 32 – 1 sont considérés comme négatifs. De plus leur valeur est calculée par complément à 2 puis 32.

Par exemple prenons le cas de -1 : dans ce système il est calculé comme le complément à 2 puis 32 soit :

4 294 967 296   - 1 = 4 294 967 295 ou en hexadécimal 0xFFFFFFFF 

Ce nombre vous rappelle quelque chose ? Et oui c’est la valeur maximale d’un registre.

Continuons la valeur – 10 sera indiquée par 

4 294 967 296   - 10   = 4 294 967 286

Et la plus grande valeur négative sera 

2 puis 31 soit 2 147 483 648

Et la plus grande valeur positive 
2 147 483 647

Mais comment le processeur sait-il que le registre contient une valeur non signée entre 0 et  4 294 967 295 ou une valeur signée positive entre 0 et 2 147 483 647 ou unr valeur négative entre -1 et - 2 147 483 648. 

Et bien, il ne le sait pas !! c’est vous qui en choisissant les instructions et les tests détermineront si la valeur doit être dans l’un ou l’autre cas.

Et déjà il faut dupliquer la routine d’affichage en base 10 l’ancienne qui affichera les valeurs de 0 à 4 294 967 295 et une nouvelle qui affichera les valeurs avec le signe + ou le signe – suivant leur plage et c’est vous qui déciderez s’il faut appeler l’une ou l’autre routine.

Heureusement, l’assembleur propose un indicateur du registre d’état s (pour signe) qui sera mis à 1 si le résultat d’une opération est une valeur négative.

Voyons déjà la nouvelle routine de conversion conversion10S  (s pour signée) :

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
