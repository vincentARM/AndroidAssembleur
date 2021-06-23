### Affichage des zones mémoire.

Dans le programme affmem32.s, nous allons écrire une routine pour afficher des zones mémoire par bloc de 16 octets. 

Tout d’abord, nous afficherons chaque octet en hexadécimal puis nous afficherons chaque octet en caractère ascii pour ceux qui peuvent l’être sinon nous afficherons un point.

A l »entrée de la routine afficherMemoire, nous passons dans le registre r0, l ‘adresse du début de la zone mémoire à afficher, dans r1 le nombre de bloc et dans r2 l’adresse d’un libellé qui servira de titre.

Puis nous commençons par préparer la ligne d’entête en y insérant la conversion hexa de l’adresse demandée contenue dans r0. Comme nous utilisons la routine de conversion se trouvant dans le fichier des routines, celle ci termine la chaine de conversion avec un zéro binaire. Il nous faut remplacer ce zéro par un blanc pour que la routine d’affichage affiche la ligne compète.

Ensuite nous recopions le libellé dont l’adresse est passée dans le registre r2 dans la ligne d’entête. Nous complétons cette copie par des blancs pour effacer un éventuel libellé précédent plus long.

Puis nous préparons l’affichage d’une étoile devant le premier octet de l’adresse demandée puisque l’affichage commence à une frontière de  bloc de 16 octets.

Puis nous entrons dans une boucle qui va préparer l’affichage d’une ligne d ‘un bloc de 16 octets. 

Nous trouvons une première boucle interne qui pour chaque octet composant le bloc va le convertir en 2 caractère hexa.

La deuxième boucle va pour chaque même octet, le convertir en caractère ascii affichable ou mettre un point.

Voici un exemple de résultat pour que vous compreniez ces explications (lire aussi les commentaires du programme) :
```
Aff mémoire  adresse : 00020694  Exemple1
00020690  20 20 0A 00*41 42 43 44 45 46 47 00 12 00 34 12    ..ABCDEFG...4.
000206A0  78 56 34 12 00 10 00 00 22 22 00 00 00 00 00 00  xV4.....""...…
```
Sur la première ligne titre, vous trouvez l’adresse du début en hexa donc 0x00020694 et le libellé Exemple1.

Ensuite vous trouvez la ligne d’un bloc de 16 octets avec au début l’adresse du début du bloc en hexa 00020690  puis les 16 octets convertis en hexa. Vous remarquerez qu’une étoile figure devant l’octet 41 qui se trouve à l’adresse 20694.

Dans la deuxième partie de la ligne vous trouvez les mêmes octets mais convertis en caractères asci ou en un point.

Tiens je viens de me rendre compte que le caractère hexa 20 est le caractère espace et qu’il est traduit par un point. Donc exercice à faire :  améliorer cette routine pour afficher un espace à la place du point.

Pour faciliter l’utilisation de cette routine, nous écrivons une macro instruction affichageMemoire qui effectuera l’alimentation des registres paramètre. 

Exemple d’appel :
```
affichageMemoire Exemple1 szChaine 4
ou
affichageMemoire Exemple2 r0 2
```
Dans ce cas, r0 devra contenir une adresse mémoire valide.

Remarque : la macro n’accepte que le registre r0 mais vous pouvez essayer de la modifier pour qu'elle accepte le registre r1 (ou un autre registre).


Dans le corps du programme, vous trouverez quelques exemples d’utilisation. 

Le premier affiche la mémoire à partir de la donnée szChaine en utilisant la routine.

Vous pouvez comparer l’affichage avec les données de la .data du source pour examiner chaque donnée.

Les autres exemples font appel à la macro pour visualiser les données stockées dans la .bss et dans la .data.


Il nous reste à insérer cette routine dans le fichier des routines et à créer un fichier des macros (ficmacros32.inc) dans un répertoire supérieur à celui des programmes. Nous allons insérer ce fichier dans nos sources avec une pseudo instruction .include "../ficmacros32.inc"
Dans le programme testMacros32.s nous effectuons quelques test pour vérifier le bon fonctionnement.

