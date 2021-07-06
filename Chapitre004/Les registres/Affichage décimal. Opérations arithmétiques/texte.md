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
