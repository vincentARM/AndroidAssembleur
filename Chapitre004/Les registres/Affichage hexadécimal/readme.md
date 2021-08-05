### Affichage en hexadécimale

Quelquefois il est nécessaire d’utiliser la base 16 pour faciliter la lecture de certaines instructions et surtout pour afficher des adresses de la mémoire. En effet il est habituel d’afficher les adresses en hexadécimal.

Dans le programme affhexa64.s, nous allons écrire 2 routines : une qui va effectuer la conversion de la valeur d’un registre en hexadécimal, l’autre qui va afficher un titre, appeler la routine de conversion et afficher le résultat.

Pour afficher les 64 bits en hexadécimal, il faut les extraire 4 par 4 et les convertir en chiffre de 0 à 9 et en lettre de A à F (voir la notation hexadécimale sur wikipedia).

Dans la routine conversion16, nous allons apppliquer un masque qui va extraire les 4 bits avec l’instruction and puis convertir ces 4 bits en chiffres et lettres. Il nous suffit ensuite de déplacer le masque de 4 bits vers la droite et de recommencer les opérations.

Nous testons la routine en mettant dans x0, la valeur immédiate 0xFF  , le préfixe 0x désaignant une valeur hexadécimale.

Comme les instructions ont une longueur constante de 4 octets, il n’est pas possible d’initialiser un registre avec toutes les valeurs possibles. Nous somme limités à la valeur hexa 0xFFFF soit 16 bits de long.

Mais nous avons une solution avec  l’instruction movk qui nous permet en déplaçant chaque valeur immédiate de 16 bits sur la gauche d’alimenter la totalité du registre.

Il existe aussi l’instruction movz qui permet d’initialiser le registre à zéro et de mettre les 2 premiers octets.

Enfin le programme montre l(affichage de l’adresse du chaîne. Sur mon smartphone, l’adresse affichée est 411000 ce qui correspond bien à l’adresse de la .data donnée par la liste issue du linker.

Exemple d’exécution :
```
Début programme.
Affichage  hexadécimal : 00000000000000FF
Affichage  hexadécimal : 3456901256781234
Affichage  hexadécimal : 0000123400000000
Affichage  hexadécimal : 0000000000411000
Fin normale du programme.
```
