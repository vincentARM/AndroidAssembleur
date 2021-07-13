### La pile
La pile est une zone mémoire située en fin de la mémoire allouée au programme par le système d’exploitation. Elle sert à stocker des données temporairement. Les données sont stockées successivement à des adresses décroissantes c’est pourquoi elle est située en fond de mémoire.

L’adresse de la pile est gérée par un registre particulier sp et contrairement à d’autres assembleurs , il n’existe pas d’instructions push et pop. 

Il n’est possible d’ajouter que des valeurs contenues dans des registres donc de longueur 8 octets.

Pour ajouter la valeur d’un registre dans la pile, nous utilisons l’instruction
```asm
str  x1,[sp,-16]! 
```
Celle ci va décrémenter l’adresse contenue dans sp de 16 octets puis va stocker la valeur de r0 à l’adresse contenue dans le registre sp. La nouvelle adresse est misa à jour dans sp grâce à l’indicateur !.

Mais pourquoi décrémenter l’adresse de 16 octets alors que l’on ne stocke qu’un double de 8 octets. Il s’agit d’une contrainte de ce type de processeur, la pile doit toujours être alignée sur 16 octets.
(Rechercher l’explication plus précise)

Il est possible de stocker 2 registres sur la pile avec l’instruction 
```asm
stp  x1,x2,[sp,-16]! 
```
Pour récupérer les valeurs de la pile, nous utilisons l’instruction
```asm
ldr  x1,[sp],16 
ou dans le cas de 2 registres
ldp x1,x2,[sp],16
```
Celle ci charge la valeur se trouvant à l’adresse du registre sp dans le registre x1 et incrémente de 16 octets l’adresse contenue dans le registre sp.

Le registre peut bien sur être différent du registre qui a mis la valeur sur la pile mais il faut toujours en fin de routine avoir enlevé autant de valeurs que nous en avions mis.

Dans le cas où vous empilez plusieurs registres avec plusieurs instructions, il faut dépiler les registres dans l’ordre inverse à leur empilement.

Dans le programme pile64.s nous allons voir 2 utilisations de la pile.

La première est le passage de paramètres à une routine. Au lieu de les passer par les registres (x0 à x7) nous les stockons sur la pile, et c’est la routine qui va les récupérer pour les traiter.

La routine lireValeur va extraire d’un tableau la nième valeur de ce tableau.

L’adresse du tableau et la valeur N seront passés par la pile avec l’instruction
```asm
stp x0,x19,[sp,-16]!
```
Dans la routine, nous commençons par sauvegarder 4 registres qui seront utilisés. Puis nous mettons dans le registre fp, la somme de l’adresse de la pile contenue dans le registre sp et 8 * 4 octets.

Le registre fp (frame pointer) est en fait le registre r11 qui est utilisé habituellement pour stocker l’adresse de la pile en un instant donné.

Ici comme nous venons de mettre sur la pile 4 registres, nous positionnons dans fp l’adresse de la pile avant ces 4 insertions.

Comme cela nous nous retrouvons au niveau de la 1ere valeur stockée par l’instruction d’insertion des paramètres cad le N° du poste demandé.

A l’adresse fp + 8 nous trouvons la 2ième valeur stockée cad l’adresse du tableau et il ne nous reste plus qu’à faire une instruction de chargement ldr x0,[x0,x1,lsl #3] pour retourner la valeur du poste.

Remarque : nous ne vérifions pas que le numéro de poste demandé est inférieur au nombre de poste total du tableau  ce qui n’est pas bien !!!

En fin de routine, nous restaurons les 4 registres. Mais il manque quelque chose !! En effet, nous avons fait une insertion de 2 registres sur la pile dans le programme appelant ce qui a diminué l’adresse de la pile de 16 octets et donc il nous faut la remettre en l’état avec l’instruction
```asm
add sp,sp,16
```
Puis nous allons voir la possibilité d’utiliser la pile comme stockage de valeurs temporaires à l’intérieur de la routine extractSousTableau.
Dans cette routine ,nous allons extraire les 5 premiers postes du tableau et les stocker sur la pile. Cette fois ci, nous passons l’adresse du tableau dans le registre x0.

Dans la routine, nous sauvegardons les registres puis nous reservons sur la pile le nombre d’octets nécessaires au stockage de 5 postes par l’instruction sub sp,#8 * 6 et nous conservons cette nouvelle adresse dans le registre fp.
Attention, bien que nous n’avons besoin de place que pour 5 postes, nous reservons 6 fois 8 octets car la pile doit toujours être alignée sur une frontière de 16 octets. Si vous l’oubliez, vous aurez l’erreur bus error.
Puis nous trouvons une boucle qui charge 5 entiers du tableau d’origine et les charge dans la zone réservée de la pile.
Nous effectuons un affichage de la mémoire à partir de l’adresse contenue dans fp pour vérification. Vous voyez bien les entiers 1 à 5 qui occupent chacun 8 octets. Nous pouvons nous demander à quoi correspondent les autres valeurs. Il faut se rappeler que ce sont toutes les valeurs qui ont été stockées sur la pile préalablement à la réservation de la place de 48 octets. Donc on y trouve le contenu des registres x1, lr, x2,fp  puis il faudrait remonter dans les appels précédents pour identifier l’usage de la pile.
Voici l’exécution complète du programme :
```
Début programme.
Appel 1
Aff mémoire  adresse : 0000007FC228BAC0 fp =
0007FC228BAC0*05 00 00 00 00 00 00 00 00 0B 41 00 00 00 00 00 ..........A.....
0007FC228BAD0 01 00 00 00 00 00 00 00 10 C5 28 C2 7F 00 00 00 ..........(.....
0007FC228BAE0 00 00 00 00 00 00 00 00 17 C5 28 C2 7F 00 00 00 ..........(.....
0007FC228BAF0 46 C5 28 C2 7F 00 00 00 5D C5 28 C2 7F 00 00 00 F.(.....].(.....
param 2 =
Affichage  hexadécimal : 0000000000410B00
retour =
Affichage  hexadécimal : 0000000000000006
Utilisation pile :
Aff mémoire  adresse : 0000007FC228BA80 fp =
0007FC228BA80*01 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 ................
0007FC228BA90 03 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 ................
0007FC228BAA0 05 00 00 00 00 00 00 00 54 01 40 00 00 00 00 00 ........T.@.....
0007FC228BAB0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
valeur  =
Affichage  hexadécimal : 0000000000000003
Fin normale du programme.
```
