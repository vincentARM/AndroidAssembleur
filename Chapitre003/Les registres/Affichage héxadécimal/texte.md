### Affichage de registre en hexadécimal.

L’affichage en binaire c’est bien mais un peu difficile à lire et peu adapté à l’affichage des adresses mémoire qui sont le plus souvent exprimées en hexadécimal (base 16).

Je vous laisse le soin de chercher sur Internet les explications sur cette base.

Comme il faut afficher les chiffres de 0 à 15, les chiffres 10 à 15 sont remplacés par les lettres A à F.

Dans le programme affHexa32.s, nous trouvons une routine pour convertir le contenu du registre r0 en une chaîne hexadécimale qui pourra être affichée par notre première routine d’affichage.

Un chiffre en hexadécimal correspond à un nombre binaire de 4 bits de 0000 à 1111 et donc dans la routine nous allons extraire les 32 bits du registre par groupe de 4 à l’aide d’un masque.

Pour extraire 4 bits nous effectuons l’opération logique ET avec l’opérateur and entre le registre de départ et le masque. Puis nous décalons ces 4 bits vers la droite pour effectuer la comparaison avec 10 et déterminer s’il s’agit de chiffres (0 à 9) ou de lettres (A à F) à afficher.

Ensuite il ne reste plus qu’à déplacer le masque de 4 octets vers la droite et de réduire le compteur de bits de 4 pour boucler.

Dans la procédure maître, nous mettons la valeur 15 dans le registre r2 puis nous appelons la procédure de conversion en lui passant dans r0 la valeur à convertir et dans r1, l’adresse de la zone de conversion.

 Cette fois ci, cette zone est déclarée dans la section .bss et avec une longueur de 9 octets : 8 octets pour la conversion et 1 octet pour le zéro final avec la macro instruction .skip 9.

C’est le chargeur de programme qui initialisera cette zone avec des zéros lors du chargement du programme en mémoire il est donc inutile de déclarer  cette zone comme des zones de la .data.

Après la conversion, nous affichons un message titre puis la zone de conversion puis un retour ligne pour passer à la ligne suivante.

Remarque : nous faisons donc 3 appels à la routine d’affichage pour afficher un seul message. Cela est très coûteux et il nous faudra améliorer cela pour faire un seul appel à cette routine.

Ensuite nous affichons l’adresse de la .data et vous pouvez voir qu »elle est bien égale à l’adresse indiquée dans la liste résultat du linker.

Le programme se termine en montrant comment alimenter les 32 bits d’un registre à partir du contenu de 2 registres, le premier contenant les 4 octets de la partie haute et le second les 4 octets de la partie basse.

Une seule instruction suffit :
```asm
add r0,r2,r1, lsl #16  
```

Elle commence par décaler de 16 positions à gauche le contenu du registre r1 puis elle additionne le contenu du registre r2 et le tout est placé dans le registre r0.

Voici le résultat complet de l’exécution :

Début du programme 32 bits.
```
Valeur du registre en hexa : 0000000F
Valeur du registre en hexa : 000201E4
Valeur du registre en hexa : FFFF1111
Fin normale du programme.
```
