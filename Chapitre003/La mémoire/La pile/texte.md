### La pile

La pile est une zone mémoire située en fin de la mémoire allouée au programme par le système d’exploitation. Elle sert à stocker des données temporairement. Les données sont stockées successivement à des adresses décroissantes c’est pourquoi elle est située en fond de mémoire.

L’adresse de la pile est gérée par un registre particulier r13 ou sp et des instructions particulières existent pour ajouter ou enlever des données sur la pile. Il n’est possible d’ajouter que des valeurs contenues dans des registres donc de longueur 4 octets.

Pour ajouter la valeur d’un registre dans la pile, nous utilisons l’instruction 
```asm
push {r0} 
```
Celle ci va décrémenter l’adresse contenue dans sp de 4 octets puis va stocker la valeur de r0 à l’adresse contenue dans le registre sp.
Noter qu’il s’agit des parenthèses {} et non pas les crochets [].

Il est possible de stocker plusieurs registres sur la pile soit comme ceci 
```asm
push {r0,r2,r3,r7}
```
soit 
```asm
push {r0-r4}
```
Dans ce cas ce sont les registres r0,r1,r2,r3 et r4 qui sont stockés sur la pile.

Pour récupérer les valeurs de la pile, nous utilisons l’instruction 
pop {r0

Celle ci charge la valeur se trouvant à l’adresse du registre sp dans le registre r0 et incrémente de 4 octets  l’adresse contenue dans le registre sp.

Le registre peut bien sur être différent du registre qui a mis la valeur sur la pile mais il faut toujours en fin de routine avoir fait autant de pop que de push ou plus exactement avoir enlevé autant de valeurs que nous en avions mis. 

Vous remarquez donc que les valeurs sont dépilées dans l’ordre inverse à leur empilement.
Dans le programme pile32.s nous allons voir 2 utilisations de la pile.
La première est le passage de paramètres à une routine. Au lieu de les passer par les registres (r0 à r3) nous les stockons sur la pile, et c’est la routine qui va les récupérer pour les traiter.
La routine lireValeur va extraire d’un tableau la nième valeur de ce tableau. 
L’adresse du tableau et la valeur N seront passés par la pile avec l’instruction 
push {r0,r4} 
Les registres doivent être dans l’ordre de leur N°.

Dans la routine, nous commençons par sauvegarder les 3 registres qui seront utilisés. Puis nous mettons dans le registre fp, la somme de l’adresse de la pile contenue dans le registre sp et 12 octets.
Le registre fp (frame pointer) est en fait le registre r11 qui est utilisé habituellement pour stocker l’adresse de la pile en un instant donné. Ici comme nous venons de faire 3 pushs, nous positionnons dans fp l’adresse de la pile avant ces 3 push.
Comme cela nous nous retrouvons au niveau de la 1ere valeur stockée par le push {r0,r4} cad le N° du poste demandé.
A l’adresse fp + 4 nous trouvons la 2ième valeur stockée cad l’adresse du tableau et il ne nous reste plus qu’à faire une instruction de chargement  ldr r0,[r0,r1,lsl #2] pour retourner la valeur du poste.
Remarque : nous ne vérifions pas que le numéro de poste demandé est inférieur au nombre de poste total du tableau  ce qui n’est pas bien !!!

En fin de routine, nous restaurons les 3 registres.
Mais il manque quelque chose !! En effet, nous avons fait un push de 2 registres dans le programme appelant ce qui a diminué l’adresse de la pile de 8 octets et donc il nous faut la remettre en l’état avec l’instruction add sp,#8.

Ensuite nous effectuons un deuxième appel mais en faisant 2 push d’un seul registre. Vous remarquerez qu’il faut inverser l’ordre des  2 registres pour que la routine fonctionne. 

Puis nous allons voir la possibilité d’utiliser la pile comme stockage de valeurs temporaires à l’intérieur de la routine extractSousTableau. 

Dans cette routine ,nous allons extraire les 5 premiers postes du tableau et les stocker sur la pile. Ceet fois ci, nous passons l’adresse du tableau dans le registre r0.

Dans la routine, nous sauvegardons les registres puis nous reservons sur la pile le nombre d’octets nécessaires au stockage de 5 postes par l’instruction sub sp,#4 * 5 et nous conservons cette nouvelle adresse dans le registre fp.

Puis nous trouvons une boucle qui charge 5 entiers du tableau d’origine et le <scharge dans la zone réservée de la pile. 

Nous effectuons un affichage de la mémoire à partir de l’adresse contenue dans fp pour vérification. Vous voyez bien les entiers 1 à 5 qui occupent chacun 4 octets. 
Nous pouvons nous demander à quoi correspondent les autres valeurs. Il faut se rappeler que ce sont toutes les valeurs qui ont eté pushées préalablement à la réservation de la place de 20 octets. Donc on y trouve le contenu des registres r0 (l’adresse du tableau) r1, r2, fp (ces 3 sont à zéro) et lr (adresse de retour) puis il faudrait remonter dans les appels précédents pour identifier l’usage de la pile.

Voici l’exécution complète du programme :
```
Début du programme 32 bits.
Appel 1
Aff mémoire  adresse : FFA24A08  fp =
FFA24A00  00 00 00 00 D0 00 01 00*05 00 00 00 2D 07 02 00  ............-...
FFA24A10  01 00 00 00 67 58 A2 FF 00 00 00 00 6E 58 A2 FF  ....gX......nX..
FFA24A20  9D 58 A2 FF B4 58 A2 FF DB 58 A2 FF 0D 59 A2 FF  .X...X...X...Y..
FFA24A30  1D 59 A2 FF 36 59 A2 FF 77 59 A2 FF 9D 59 A2 FF  .Y..6Y..wY...Y..
param 2 =  : Valeur hexa du registre : 0002072D
retour =  : Valeur hexa du registre : 00000006
Appel 2
Aff mémoire  adresse : FFA24A08  fp =
FFA24A00  00 00 00 00 50 01 01 00*03 00 00 00 2D 07 02 00  ....P.......-...
FFA24A10  01 00 00 00 67 58 A2 FF 00 00 00 00 6E 58 A2 FF  ....gX......nX..
FFA24A20  9D 58 A2 FF B4 58 A2 FF DB 58 A2 FF 0D 59 A2 FF  .X...X...X...Y..
FFA24A30  1D 59 A2 FF 36 59 A2 FF 77 59 A2 FF 9D 59 A2 FF  .Y..6Y..wY...Y..
param 2 =  : Valeur hexa du registre : 0002072D
retour =  : Valeur hexa du registre : 00000004
Utilisation pile :
Aff mémoire  adresse : FFA249E8  fp =
FFA249E0  05 00 00 00 00 00 00 00*01 00 00 00 02 00 00 00  ................
FFA249F0  03 00 00 00 04 00 00 00 05 00 00 00 2D 07 02 00  ............-...
FFA24A00  00 00 00 00 00 00 00 00 00 00 00 00 D8 01 01 00  ................
FFA24A10  01 00 00 00 67 58 A2 FF 00 00 00 00 6E 58 A2 FF  ....gX......nX..
valeur  =  : Valeur hexa du registre : 00000003
Fin normale du programme.
```
