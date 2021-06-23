### Les tableaux.
Dans le programme Tableaux32.s nous allons voir comment décrire et utiliser un tableau d’entiers.

Dans la .data, nous déclarons un tableau de 8 entiers (donc de longueur égale à 4 octets chacun) avec l’instruction :
```asm
tbValeurs:            .int 1,2,3,4,5,6,7,8
```
Pour avoir le nombre d’élément du tableau nous aurions pu déclarer une constante avec :
```asm
.equ NBELEMENTS,  8
```
mais nous allons utiliser une astuce qui nous facilite les ajouts futurs. Nous utilisons la pseudo instruction :
```asm
.equ NBELEMENTS,  (. - tbValeurs) / 4
```
qui calcule la différence entre l’adresse courante de cette pseudo instruction indiquer par le . Et l’adresse du début du tableau  donnée par son étiquette. Ceci donne en fait la taille en octet de la totalité du tableau. Comme il s’agit d’entiers de 4 octets nous divisons par 4 pour avoir le nombre d’éléments du tableau.

Il est donc par la suite facile d’ajouter un élément à la suite du 8 et le nombre d’élements sera recalculé automatiquement.

Remarque : Il s’agit d’une pseudo instruction car c’est le compilateur qui effectue la soustraction et la division. Cela n’a rien à voir avec les opérations du processeur (sub et udiv).

Dans la partie .bss, nous réservons la place pour un second tableau en utilisant l’instruction :
```asm
tbValeursCopie:        .skip 4 * NBELEMENTS
```
NBELEMENTS étant la constante calculée précédemment.
 
Dans le corps du programme, nous chargeons dans le registre r4 l’adresse du tableau. Pourquoi le registre r4 ? C’est le premier registre qui est sauvegardé par n’importe quelle routine et comme nous allons utiliser cette adresse nous sommes sûr qu’elle ne sera pas détruite (si vos routines respectent bien les conventions !!)

Nous chargeons le premier poste (rang 0) et nous l’affichons en hexa pour faire simple.

Ensuite nous affichons le 2ième poste (rang 1) en mettant un déplacement de 4 puisque la longueur du premier entier est de 4.

Puis nous affichons le 6ième poste de rang 5. Nous aurions pu mettre un déplacement de 4 * 5 = 20 mais nous allons plutôt mettre dans le registre r2 le rang 5 et dans l’instruction de chargement indiquer que ce registre doit être multiplié par 4 avec la multiplication rapide lsl #2 vue avec les opérations arithmétique. Astucieux non ?

Puis nous créons une routine de copie d’un tableau dans un autre. Nous passons à la routine les 2 adresses des tableaux origine et destination dans les registres r0 et r1.

Dans la routine, il nous suffit de déclarer un compteur r2 à zéro puis de charger un entier dans le registre r3 et de le stocker au même N° de poste dans le tableau destinataire.

Nous incrementons le compteur de 1 et le comparons à la constante NBELEMENTS. 

Si celui ci est inférieur nous bouclons sur une nouvelle copie.

L’assembleur c’est pas compliqué !!!

L’affichage memoire montre que le nouveau tableau contient bien les 8 entiers de départ.

Remarque : dans cette routine nous ne sauvegardons aucun registre puisque nous n’utilisons que les
 registres r0 à r3.

Nous terminons en effectuant une recherche séquentielle d’une valeur dans le tableau.

Cette fois ci nous ne sauvegardons que le registre lr qui contient l’adresse de retour. Pourquoi ? Et bien dans cette routine nous appelons une macro qui appelle une autre routine et donc qui utilise le même registre lr pour revenir.

Et donc nous devons sauvegarder la propre adresse de retour au programme appelant de cette routine.

Les commentaires de la routine suffisent à comprendre son fonctionnement.

A la fin de la routine, nous restaurons le contenu de lr directement dans le compteur d’instruction ce qui permet le gain d’une instruction (bx lr) : ouaf ouaf !!
