### L’affichage des zones mémoires.
Dans le programme affmem64.s, nous allons écrire une routine pour afficher des zones mémoire par bloc de 16 octets. Cette routine semble d’un abord compliqué mais la lecture des commentaires vous guidera pour la comprendre !!

Tout d’abord, nous afficherons chaque octet en hexadécimal puis nous afficherons chaque octet en caractère ascii pour ceux qui peuvent l’être sinon nous afficherons un point.
A l ‘entrée de la routine affmemoireTit, nous passons dans le registre x0, l ‘adresse du début de la zone mémoire à afficher, dans x1 le nombre de bloc et dans x2 l’adresse d’un libellé qui servira de titre.

Puis nous commençons par préparer la ligne d’entête en y insérant la conversion hexa de l’adresse demandée contenue dans x0. Comme nous utilisons la routine de conversion se trouvant dans le fichier des routines, celle ci termine la chaîne de conversion avec un zéro binaire. Il nous faut remplacer ce zéro par un blanc pour que la routine d’affichage affiche la ligne complète.

Ensuite nous recopions le libellé dont l’adresse est passée dans le registre x2 dans la ligne d’entête. Nous complétons cette copie par des blancs pour effacer un éventuel libellé précédent plus long.

Puis nous préparons l’affichage d’une étoile devant le premier octet de l’adresse demandée puisque l’affichage commence à une frontière de bloc de 16 octets.

Puis nous entrons dans une boucle qui va préparer l’affichage d’une ligne d ‘un bloc de 16 octets.

Nous convertissons l’adresse de chaque bloc en hexadécimal et pour gagner de la place sur chaque ligne, nous supprimons les 3 premiers zéros de l’adresse.

Nous trouvons une première boucle interne qui pour chaque octet composant le bloc va le convertir en 2 caractère hexa.

La deuxième boucle va pour chaque même octet, le convertir en caractère ascii affichable ou mettre un point.

Voici un exemple de résultat pour que vous compreniez ces explications (lire aussi les commentaires du programme) :
```
Aff mémoire  adresse : 0000000000410A00 Affichage zones
0000000410A00*56 34 12 90 78 56 34 12 FF FF FF FF 01 00 00 00 V4..xV4.........
0000000410A10 00 00 00 00 02 00 00 00 00 00 00 00 03 00 00 00 ................
```
Sur la première ligne titre, vous trouvez l’adresse du début en hexa donc 0x 0000000000410A00 et le libellé Affichage zones.

Ensuite vous trouvez la ligne d’un bloc de 16 octets avec au début l’adresse du début du bloc en hexa 0000000410A00 puis les 16 octets convertis en hexa. Vous remarquerez qu’une étoile figure devant l’octet 0x56 qui se trouve à l’adresse 410A00.

Dans la deuxième partie de la ligne vous trouvez les mêmes octets mais convertis en caractères ascii ou en un point.

Pour faciliter l’utilisation de cette routine, nous écrivons une macro instruction affichageMemoire qui effectuera l’alimentation des registres paramètre.

Exemple d’appel :
```
affichageMemoire "zones  1"  szMessFinPgm  5
ou
affichageMemoire « Stockage » x1 2
```
Dans ce cas, x1 devra contenir une adresse mémoire valide.

Remarque : la macro n’accepte que les registres x0 et x1 mais vous pouvez essayer de la modifier pour qu'elle accepte d’autres registres.

Dans le corps du programme, vous trouverez quelques exemples d’utilisation.

Le premier affiche la mémoire à partir de la donnée qValeur1 en utilisant la routine.

Vous pouvez comparer l’affichage avec les données de la .data du source pour examiner chaque donnée.

Les autres exemples font appel à la macro pour visualiser les données stockées dans la .bss et dans la .data.

Il nous reste à insérer cette routine dans le fichier des routines et à créer un fichier des macros (ficmacros64inc) dans un répertoire supérieur à celui des programmes. Nous allons insérer ce fichier dans nos sources avec une pseudo instruction .include "../ficmacros64.inc" Dans le programme testmacromem64.s nous effectuons quelques tests pour vérifier le bon fonctionnement.

Exemples d’exécution :
```
Début programme.
Test macro :
Aff mémoire  adresse : 0000000000410741 zones  1
0000000410740 00*05 00 00 34 12 00 00 00 00 00 00 00 00 00 00 ....4...........
0000000410750 78 56 34 12 00 00 00 00 00 00 00 00 00 00 00 00 xV4.............
0000000410760 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
Aff mémoire  adresse : 0000000000410A08 Stockage
0000000410A00 00 00 00 00 00 00 00 00*00 00 41 42 00 00 00 00 ..........AB....
0000000410A10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
Fin normale du programme.
```
Vous voyez que l’étoile est positionné devant l’octet 05 qui correspond à l’adresse demandée : 0x410471. Vous remarquerez que les autres zones sont complétées par des zéros pour respecter les alignements.

Dans le deuxième affichage, vous voyez que les octets A et B sont bien stockés à la bonne position ( A à la position 2 et B à la position 3) et que les autres octets sont à zéros car la zone fait partie de la .bss initialisée par le système d’exploitation au lancement du programme.

