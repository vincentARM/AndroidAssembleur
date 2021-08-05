### Les tableaux.
Dans le programme tableau64.s nous allons voir comment décrire et utiliser un tableau d’entiers.
Dans la .data, nous déclarons un tableau de 8 doubles (donc de longueur égale à 8 octets chacun) avec l’instruction :
```asm
tbValeurs:            .quad 1,2,3,4,5,6,7,8
```
Pour avoir le nombre d’élément du tableau nous aurions pu déclarer une constante avec :
```asm
.equ NBELEMENTS,  8
```
mais nous allons utiliser une astuce qui nous facilite les ajouts futurs. Nous utilisons la pseudo instruction :
```asm
.equ NBELEMENTS,  (. - tbValeurs) / 8
```
qui calcule la différence entre l’adresse courante de cette pseudo instruction indiquée par le . et l’adresse du début du tableau donnée par son étiquette. Ceci donne en fait la taille en octets de la totalité du tableau. Comme il s’agit de doubles de 8 octets nous divisons par 8 pour avoir le nombre d’éléments du tableau.
Il est donc par la suite facile d’ajouter un élément à la suite du 8 et le nombre d’éléments sera recalculé automatiquement.

Remarque : Il s’agit d’une pseudo instruction car c’est le compilateur qui effectue la soustraction et la division. Cela n’a rien à voir avec les opérations du processeur (sub et udiv).

Dans la partie .bss, nous réservons la place pour un second tableau en utilisant l’instruction :
```asm
tbValeursCopie:        .skip 8 * NBELEMENTS
```
NBELEMENTS étant la constante calculée précédemment.

Dans le corps du programme, nous chargeons dans le registre x19 l’adresse du tableau. Pourquoi le registre x19 ? C’est le premier registre qui est sauvegardé par n’importe quelle routine et comme nous allons utiliser cette adresse nous sommes sûr qu’elle ne sera pas détruite (si vos routines respectent bien les conventions !!).

Nous chargeons le premier poste (rang 0) et nous l’affichons en hexa pour faire simple.

Ensuite nous affichons le 2ième poste (rang 1) en mettant un déplacement de 8 puisque la longueur du premier entier est de 8.

Puis nous affichons le 6ième poste de rang 5. Nous aurions pu mettre un déplacement de 8 * 5 = 40 mais nous allons plutôt mettre dans le registre x2 le rang 5 et dans l’instruction de chargement indiquer que ce registre doit être multiplié par 8 avec la multiplication rapide lsl #3 vue avec les opérations arithmétique. Astucieux non ?

Puis nous créons une routine de copie d’un tableau dans un autre. Nous passons à la routine les 2 adresses des tableaux origine et destination dans les registres x0 et x1.
Dans la routine, il nous suffit de déclarer un compteur x2 à zéro puis de charger un entier dans le registre x3 et de le stocker au même N° de poste dans le tableau destinataire.

Nous incrémentons le compteur de 1 et le comparons à la constante NBELEMENTS.

Si celui ci est inférieur nous bouclons sur une nouvelle copie.

L’assembleur c’est pas compliqué !!!

L’affichage mémoire montre que le nouveau tableau contient bien les 8 entiers de départ.

Remarque : dans cette routine nous ne sauvegardons aucun registre puisque nous n’utilisons que les registres x0 à x3.

Nous terminons en effectuant une recherche séquentielle d’une valeur dans le tableau.

Cette fois ci nous ne sauvegardons que le registre lr qui contient l’adresse de retour. Pourquoi ? Et bien dans cette routine nous appelons une macro qui appelle une autre routine et donc qui utilise le même registre lr pour revenir.

Et donc nous devons sauvegarder la propre adresse de retour au programme appelant de cette routine.

Les commentaires de la routine suffisent à comprendre son fonctionnement.

Voici le résultat de l’exécution :
```
Début programme.
Affichage  poste 0
Poste 0 :
Affichage  hexadécimal : 0000000000000001
Affichage poste 1
Poste 1 :
Affichage  hexadécimal : 0000000000000002
Affichage  poste 5
Poste 5 :
Affichage  hexadécimal : 0000000000000006
Aff mémoire  adresse : 0000000000410C00 Copie du tableau
0000000410C00*01 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 ................
0000000410C10 03 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 ................
0000000410C20 05 00 00 00 00 00 00 00 06 00 00 00 00 00 00 00 ................
0000000410C30 07 00 00 00 00 00 00 00 08 00 00 00 00 00 00 00 ................
0000000410C40 30 30 30 30 30 30 30 30 30 30 30 30 30 30 30 36 0000000000000006
Valeur trouvée
poste N°
Affichage  hexadécimal : 0000000000000002
Valeur non trouvée !!
Fin normale du programme.
```
