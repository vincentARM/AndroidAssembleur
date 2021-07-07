### Affichage décimal et opérations arithmétiques.

Maintenant, il ne nous reste plus qu « à écrire une routine d’affichage d’un registre en décimal (base10) et nous nous en servirons pour voir les opérations arithmétiques autorisées avec les registres.

Dans le programme affdecimal64.s nous trouvons la routine conversion10 qui va convertir le contenu du registre r0 en une chaîne de caractères ascii représentant sa valeur en base 10 (décimale).

Pour cela nous divisons successivement la valeur à convertir par 10 et nous calculons le reste, reste que nous transformons en caractère ascii en ajoutant 48.

Il y a un petit problème, les restes successifs des divisions donnent les chiffres décimaux en partant de la droite. Il nous faut donc ensuite recopier les chiffres du résultat dans la partie gauche de la zone de conversion pour avoir un affichage correct.

Dans le corps du programme,nous appelons cette nouvelle routine pour afficher le nombre 100 puis le nombre le plus grand contenu dans un registre et nous affichons la longueur retournée pour vérification.

Nous affichons aussi pour vérification l’adresse de la pile avant l’appel et l’adresse après l’appel pour vérifier que tous ces appels ne dégradent pas la pile.
Vous remarquerez que nous pouvons alimenter un registre soit en notation décimale soit en notation hexadécimale. Nous pouvons aussi l'alimenter en notation binaire et en notation octal.

Dans ce dernier cas c'est le 0 du début qui le distingue d'un nombre décimal : 020 n'est donc pas égal à 20 !!!

### Additions

Ensuite nous trouvons un exemple d’utilisation de l’addition sur des petits nombres puis un exemple d’addition sur un grand nombre proche de la valeur maximale. Et dans ce cas nous voyons que le résultat est faux car il y a un dépassement de la valeur maximum du registre.

Heureusement, l’assembleur propose une solution pour signaler ce dépassement. Si nous utilisons l’instruction adds (avec un s final), le processeur mettra un 1 dans l’indicateur de retenue (carry) du registre d’état et il nous suffit de tester cette retenue avec les instructions bcs ou bcc pour déterminer s’il y a dépassement et prendre les mesures qui s’imposent.

Donc dans un programme assembleur qui effectue des calculs, vous pouvez utiliser add quand vous savez que les nombres utilisés sont petits et s’ils sont grands ou s’il y a un doute il faudra utiliser adds et programmer une gestion de ce dépassement (message et ou arrêt du traitement).

Au passage, remarquez comment est programmée une alternative mais j’y reviendrais dans un prochain chapitre.

Vous pouvez modifier l’addition pour tester les 2 cas.

Enfin la retenue peut être récupérée pour être additionnée à une autre addition avec l’instruction adc.

Par exemple nous voulons additionner 2 nombres de 128 bits, le registre x1 contient les 64 bits de la partie basse du 1er nombre, le registre x2 la partie haute, le registre x3 la partie basse du 2ième nombre et rx la partie haute.

Il nous suffit d'effectuer l’addition comme ceci :
```asm
adds x5,x1,x3
adc   x6,x2,x5
```
Attention à l’interprétation des résultats car quelle addition avons nous fait exactement ? 

La partie basse du 1er nombre correspond à 18 446 744 073 709 551 610 et la partie haute correspond à 5 * (2 puissance 64) soit : 92 233 720 368 547 758 080.
au total, le premier nombre est égal à 110 680 464 442 257 309 690

la partie basse du 2ième nombre correspond à 20 et la partie haute est egale à 2 * (2 puissance 64) soit : 36 893 488 147 419 103 232 et au total le 2ième nombre est égal à 36 893 488 147 419 103 252

La somme des 2 est égale à : 147 573 952 589 676 412 942

Le résultat du programme donne 14 pour la partie basse et 8 * (2 puissance 64) soit 147 573 952 589 676 412 928 pour la partie haute soit au total :

147 573 952 589 676 412 942 ce qui correspond bien au calcul précédent.

Résultat de l'exécution :
```
Début programme.
Affichage  hexadécimal : 0000007FD13F3C90
Affichage décimal :
Affichage  hexadécimal : 0000000000000003
100
Affichage  hexadécimal : 0000007FD13F3C90
affectation et affichage grand nombre !

Affichage  hexadécimal : 0000000000000014
18446744073709551615
Affectation nombre octal :
16
Addition nombres :
17618
Addition valeur maxi :
4
Addition valeur maxi et test retenue:
Retenue
Addition sur 128 bits
parties basses :
14
parties hautes :
8
Fin normale du programme.
```
### Soustractions :

Maintenant nous allons utiliser l’instruction sub pour effectuer des soustractions dans le programme soustraction64.s.

Nous effectuons une soustraction simple puis une soustraction dont le résultat est manifestement faux.

La aussi comme pour l’addition, si nous utilisons l’instruction subs, l’indicateur carry du registre d’état est positionné mais attention il est mis à zéro s’il faut une retenue et sinon il est mis à 1.

Comme pour l’addition, nous pouvons utiliser l’instruction sbc pour tenir compte de la retenue lors de soustractions successives.

Mais la soustraction pose un problème intéressant : comment gérer les nombres négatifs ?

En effet jusqu’à maintenant, nous n’avons traité que des nombres positifs et rien n’indique dans un registre si un nombre est positif ou négatif.

Les ingénieurs ont trouvé une solution pour distinguer les nombres négatifs.

Les nombres compris entre 1 et 2 puissance 63 -1 sont considérés comme positifs et les nombres de 2 puissance 63 à 2 puissance 64 – 1 sont considérés comme négatifs. De plus leur valeur est calculée par complément à 2 puissance 64.

Par exemple prenons le cas de -1 : dans ce système il est calculé comme le complément à 2 puissance 64 soit :

18 446 744 073 709 551 616 - 1 = 18 446 744 073 709 551 615 ou en hexadécimal 0xFFFFFFFFFFFFFFFF 

Ce nombre vous rappelle quelque chose ? Et oui c’est la valeur maximale d’un registre.

Continuons la valeur – 10 sera indiquée par
18 446 744 073 709 551 616 - 10 = 18 446 744 073 709 551 606 

Et la plus grande valeur négative sera
2 puissance 63 soit 9 223 372 036 854 775 808

Et la plus grande valeur positive : 9 223 372 036 854 775 807

Mais comment le processeur sait-il que le registre contient une valeur non signée entre 0 et 18 446 744 073 709 551 616  ou une valeur signée positive entre 0 et 9 223 372 036 854 775 807 ou une valeur négative entre -1 et - 9 223 372 036 854 775 808.

Et bien, il ne le sait pas !! c’est vous qui en choisissant les instructions et les tests détermineront si la valeur doit être dans l’un ou l’autre cas.
Il nous faut donc dupliquer la routine d’affichage en base 10, l’ancienne qui affichera les valeurs de 0 à 18 446 744 073 709 551 616 et une nouvelle qui affichera les valeurs avec le signe + ou le signe – suivant leur plage et c’est vous qui déciderez s’il faut appeler l’une ou l’autre routine.

Heureusement, l’assembleur propose un indicateur du registre d’état N (pour Négatif) qui sera mis à 1 si le résultat d’une opération peut être considérée comme une valeur négative.

Voyons déjà la nouvelle routine de conversion conversion10S (S pour signée).

Il nous faut un caractère de plus dans la zone de conversion pour y insérer le signe + ou -.

Le signe est initialisé à + dans le registre x3 puis nous testons la valeur du registre x0 et si elle est plus petite que zéro, nous mettons le signe - dans le registre x3 et nous inversons la valeur avec l’instruction neg x0,x0.

Puis nous effectuons la conversion comme dans la routine de conversion non signée.

A la fin, nous déplaçons les chiffres du résultat à partir de l’octet 1 de la zone de conversion et nous mettons le signe (registre x3) dans l’octet 0 de la zone.

Dans le corps du programme soustraction64.s nous mettons les valeurs 10 et -10 pour tester cette nouvelle routine. Puis nous mettons la valeur maximum négative puis la valeur maximum positive. La routine donne bien les valeurs indiquées précédemment.

Mais cette solution pose de nouveaux problèmes :

Additionnons les nombres 9 223 372 036 854 775 800 et 20.

En arithmétique non signée, nous trouvons un résultat correct 9223372036854775820 mais en signée nous trouvons  -9223372036854775796.

Heureusement la aussi l’assembleur à prévu un indicateur dans le registre d’état il s’agit de l’indicateur v comme overflow. Il nous suffit de tester cet indicateur avec les instructions bvs (branch if overflow set) et bvc (branch if overflow clear) pour gérer les 2 cas.

C’est la même chose pour la soustraction : le processeur positionne l’indicateur overflow si le résultat est inférieur à 9 223 372 036 854 775 808.

Après une opération arithmétique dont on a demandé la mise à jour des indicateurs il est possible de savoir si un résultat est négatif ou positif en testant l’indicateur de signe s du registre d’état avec les instructions bmi (branch if negative) ou bpl (branch if positive ou zéro).

Remarque en 64 bits il n’y a pas l’instruction rsb qui en 32 bits inversait l’opération.

Voici le résultat de l’exécution :
```
Début programme.
Soustraction :
Affichage décimal : 688
Soustraction fausse :
Affichage décimal : 18446744073709551606
Soustraction avec retenue :
Retenue
Affichage décimal : -10
Affichage décimal : +10
Affichage décimal : -9223372036854775808
Affichage décimal : +9223372036854775807
 Addition non signée :
Affichage décimal : 9223372036854775820
 Addition signée avec erreur :
Affichage décimal : -9223372036854775796
Retenue
Fin normale du programme.
```
### Multiplications

Dans le programme multiplication64.s, nous allons explorer les instructions de multiplication mais tout d’abord nous déplaçons les 2 routines conversion10 et conversion10S dans le fichier des routines que nous recompilons pour avoir un fichier objet complet.

Dans le premier exemple nous effectuons une multiplication simple avec 2 facteurs positifs puis une multiplication avec 1 facteur négatif avec l’instruction mul x0,x1,x2.
Vous remarquerez que la multiplication ne peut être faite qu’à partir de registres. Il n’est pas possible d’utiliser une valeur immédiate. 

Curieusement aucun indicateur d’état ne peut être positionné lors des multiplications ce qui est gênant pour détecter les dépassements.

Heureusement il existe les instructions umulh (multiplication non signée) et smulh (multiplication signée) qui permettent d’avoir la partie haute (cad les 64 -127 bits) du résultat et il nous suffit de tester si cette partie haute est différente de zéro pour détecter le dépassement. Bien sûr, il est possible de se servir de ces instructions pour avoir des résultats en 128 bits mais il faut dans ce cas, gérer les autres opérations et l’affichage en 128 bits.

Reste à détecter les dépassements sur des multiplications signées lorsque le résultat d’une multiplication positive ( ou 2 opérateurs négatifs) tombe dans la tranche des valeurs négatives. 

Dans ce cas, l’instruction smulh donne un résultat à 0 mais la multiplication est fausse.

Je n’ai pas de solution à ce problème !!!

Il doit y avoir une astuce mais je n’ai rien trouvé encore sur internet.

Ensuite nous testons les instructions qui ajoute ou retranche le résultat de la multiplication de la valeur d’un 3ième registre. Ces instructions seront très utilisées lors des accès mémoire pour calculer l’adresse d’un poste d’ un tableau.

Nous terminons avec l’instruction mneg qui inverse le signe du résultat de la multiplication . 

Le reste des instructions non testées ici, concerne des multiplications de registres de 32 bits avec les noms de registre en w.

Voici le résultat de l'exécution :
```
Début programme.
multiplication :
Affichage décimal : 177600
multiplication signée :
Affichage décimal : -500
Erreur multiplication non signée :
Affichage décimal : 0
Affichage décimal : 25
Erreur multiplication signée :
Affichage décimal : -9223372036854775808
Affichage décimal : +12
Erreur multiplication signée :
Affichage décimal : -4611686018427387904
Affichage décimal : +0
multiplication avec ajout :
Affichage décimal : +5020
multiplication avec soustraction :
Affichage décimal : +4980
multiplication avec inversion :
Affichage décimal : -20
Fin normale du programme.
```
