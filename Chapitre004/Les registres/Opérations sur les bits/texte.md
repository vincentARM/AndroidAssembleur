### Opérations sur les bits.

Nous allons regarder les possibilités de l’assembleur pour manipuler les bits d’un registre. Pour cela, il nous faut une routine d’affichage des 64 bits sous la forme de 0 et 1.

Dans le programme affBinaire64.s, nous trouvons la routine afficherBinaire qui affichera la valeur du registre x0.

La routine commence par sauvegarder les registres utilisés de x0 à x7 avec les instructions comme :
```asm
stp x0,lr,[sp,-16] ! 
```
Nous verrons plus tard ce que fait cette instruction exactement. Pour l’instant il nous suffit de savoir que cette instruction sauve les registres x0 et lr sur la pile. Elle remplace l’instruction push d’autres assembleurs car cette dernière n’existe pas en 64 bits ARM !!!
Ensuite nous initialisons les registres nécessaires et nous commençons une boucle qui va tester chaque bit du registre. 

Suivant sa valeur nous stockons dans la zone de conversion la valeur ascii 48 (0) ou 49 (1).

Tous les 8 bits, nous ajoutons dans la zone de conversion un espace pour faciliter la lecture.

Puis nous affichone la zone de conversion avec la routine afficherMess que nous avons vu dans le 1er programme.

Dans le corps du programme nous mettons la valeur binaire 0b111 (soit 7 en décimal) et nous l’affichons avec la routine.

Puis nous mettons 1 dans le registre x1 et nous faisons l’addition des 2 registres. Le résultat donne 1000 en binaire ce qui correspond à 8 décimal.

Remarque : en 64 bits, le # n'est pas obligatoire devant une valeur immédiate.

Voici le résultat de l’exécution :
```
Début programme.
Affichage binaire :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000111
Après addition :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00001000
```
Les bits à droite représentent de faibles valeurs et sont dit bits de poids faible. Les bits de gauche représentent des valeurs importantes et sont dits bits de poids fort.

Comme les instructions ne font que 4 octets de long, il n’est pas possible avec une seule instruction mov de stocker toutes les valeurs possibles. Il n’est possible de stocker que les valeurs de 0 à 65535 soit en binaire 0b1111111111111111.

### Opérations logiques 

L’assembleur permet d’effectuer les opérations logiques ET, OU, OU exclusif, négation et l’opération de remise à zéro d’un seul bit.

Dans le programme operBin64.s nous continuons d’utiliser les 2 routines d’affichage vues dans le programme précédent pour afficher le résultat de ces opérations logiques.

Nous commençons par mettre dans le registre x1 la valeur 0b0011 et dans le registre x2 la valeur 0b0101 puis nous effectuons l’opération logique ET avec l’opérateur and.

Voici le résultat.
```
Affichage binaire :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000011
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00001010
Résultat opération ET :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000010
```
Vous voyez que seul le deuxième bit passe à 1 puisque les 2 registres ont seulement ce bit à 1 simultanément.

Le programme continue avec les opérateur OU, OU exclusif, NON et la remise à zéro d’un ou plusieurs bits.
En 64 bits il y a aussi 2 opérateurs supplémentaires orn qui combine le OU et le NON et eon qui combine le OU exclusif et le NON
Voici le résultat complet :
```
Début programme.
Affichage binaire :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000011
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00001010
Résultat opération ET :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000010
Résultat opération OU :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00001011
Résultat opération OU et NON :
11111111 11111111 11111111 11111111 11111111 11111111 11111111 11110111
Résultat opération OU exclusif :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00001001
Résultat opération OU exclusif et NON :
11111111 11111111 11111111 11111111 11111111 11111111 11111111 11110110
Résultat opération NON  :
11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111100
Résultat opération RAZ bit  :
11111111 11111111 11111111 11111111 11111111 11111111 11111111 11100111
```
Si vous avez programmé en ARM 32 bits, vous remarquez quelques petites différences dans les instructions 64 bits : par exemple l’assembleur 64 bits n’accepte pas l’instruction bic x0,0b11000, il faut écrire bic x0,x0,0b11000

### Déplacements de bits

Maintenant nous allons voir une autre série d’opérations autorisées : les déplacements :

Dans le programme deplBits64.s Nous mettons la valeur 0b1110011 dans le registre x1 pour suivre les différents déplacements.

Nous commençons par déplacer tous les bits du registre de 5 positions sur la gauche avec l’ instruction :
```asm
lsl x0,x1,5
```
Voici le résultat : 
```
Début programme.
00000000 00000000 00000000 00000000 00000000 00000000 00000000 01110011
Résultat déplacement gauche :
00000000 00000000 00000000 00000000 00000000 00000000 00001110 01100000
```
Les bits les plus à gauche sont perdus et les nouveaux bits à droite sont mis à 0.
Puis nous déplaçons toujours les bits du registre x1 de 3 positions sur la droite : positions contenues dans le registre x2 :
```asm
    mov x2,#3
    lsr x0,x1,x2                   // déplacement de 3 positions sur la droite
```
Dans ce cas, les bits à droite sont perdus et les nouveaux bits à gauche sont mis à 0. Puis nous effectuons une rotation à droite de 3 positions avec l’instruction : 
```asm
    ror x0,x1,#3    
```
Dans ce cas les bits qui sortent de la droite sont mis à gauche.

Particularité : avec l’opérateur asr, un déplacement sur la droite met un ou des 1 à gauche si le dernier bit (bit 63) est un 1 sinon il met des zéros. Nous verrons son utilité plus tard.

Exemple :
```asm
    lsl x2,x1,#57
    mov x0,x2
    bl afficherBinaire
    asr x0,x2,#4                  // opérateur asr
    bl afficherBinaire
```
Remarque : en 64 bits il n’est pas possible de récupérer le bit perdu lors des déplacements. L’instruction rrx n’existe pas non plus.


Enfin il est possible gràce à un mécanisme (barrel shifter ) d'effectuer un déplacement de bits avant de copier le résultat dans un registre dans une même instruction : Par exemple, déplacement de 8 positions des bits de rx et copie du résultat dans x0 : 
```asm
    mov x2,#0b11                   // maj x2 
    mov x0,x2,lsl #8               // copie dans x0 après déplacement à gauche de 8 bits
    bl afficherBinaire
```
Remarque : x2 n'est pas affecté par cette opération, le déplacement est fait en interne. Il est possible d'utiliser aussi lsr, asr et ror.
Voici le résultat complet de l'exécution :
```
Début programme.
00000000 00000000 00000000 00000000 00000000 00000000 00000000 01110011
Résultat déplacement gauche :
00000000 00000000 00000000 00000000 00000000 00000000 00001110 01100000
Résultat déplacement droit :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00001110
Résultat rotation droite :
01100000 00000000 00000000 00000000 00000000 00000000 00000000 00001110
Résultat déplacement droit arithmétique :
11100110 00000000 00000000 00000000 00000000 00000000 00000000 00000000
11111110 01100000 00000000 00000000 00000000 00000000 00000000 00000000
Résultat déplacement gauche :
00000000 00000000 00000000 00000000 00000000 00000000 00000011 00000000
Fin normale du programme.
```
### Autres instructions de manipulation des bits 

Dans le programme manipBits64.s nous allons voir d’autres instructions de manipulation de bits.

Avec l’instruction clz, nous pouvons compter le nombre de bits à 0 se trouvant dans les positions gauche d’ un registre. Dans l’exemple nous trouvons 0b111001 ce qui correspond en décimal à 57

Avec l’instruction cls, nous pouvons compter le nombre de 1 se trouvant à gauche. Curieusement, le comptage indique 1 de moins que le nombre de 1 !! Il doit y avoir une explication.
Dans l’exemple le programme trouve 0b111000 ce qui correspond à 56 et il y a 57 1 !!

Ensuite nous testons l’instruction :
```asm
bfi x0,x1,#20,#3
```
Elle copie 3 bits se trouvant à la position 0 de x1 à la position 20 de x0. Dans ce cas les autres bits de x0 ne sont pas remis à zéro.
Cette instruction peut être intéressante pour remplacer un octet complet dans un registre 
```asm
mov x1,0b11111111
bfi  x0,x1,24,8          @ met le premier octet de x1 dans le 3ième octet de x0
```
L’instruction suivante 
```asm
bfxil x0,x1,#4,#3
```
fait l’inverse. Elle met 4 bits se trouvant à la position 3 de x1 à la position 0 de x0. Elle permet donc d’extraire un octet quelconque d’un registre.

L’instruction extr extrait n bits d’un registre et les mets à gauche des bits d’un autre registre. Les n bits à droite sont perdus.

L’instruction rbit permet d’inverser les 64 bits d’un registre, l’instruction rec inverse l’ordre des 8 octets d’un registre, rev16 inverse les 2 octets d’un demi mot et rev32 inverse les 4 octets d’un mot (voir les exemples).

Les instructions ubfiz et sbfiz font la même chose que bfi mais initialise d’abord le registre de destination.

Enfin l’instruction sxtw  etend les bits d’un registre 32 bits dans un registre 64 bits. Remarquez l’utilisation de la notation w2 pour indiquer la partie basse de 32 bits du registre x0.
Voici le résultat complet de l’éxécution :
```
Début programme.
00000000 00000000 00000000 00000000 00000000 00000000 00000000 01110011
Comptage des zéros à gauche :
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00111001
comptage des 1 à gauche  :
11111111 11111111 11111111 11111111 11111111 11111111 11111111 10001100
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00111000
Copie de n bits à la position p :
00000000 00000000 00000000 00000000 00000000 00110000 00000000 00000000
Copie de p bits à la position n :
00000000 00000000 00000000 00000000 00000000 01000001 00010001 01100001
00000000 00000000 00000000 00000000 00000000 01000001 00010001 01100111
Ajout à gauche de p bits :
00110000 00000000 00000000 00000000 00000000 00000000 00000000 00111100
Inversion des 64 bits du registre :
11001110 00000000 00000000 00000000 00000000 00000000 00000000 00000000
Inversion ordre octets  :
00000000 00000000 00000000 00000000 00000000 01000001 00010001 11000111
11001100 11110000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 11110000 11001100
Inversion ordre demi mots  :
00000000 00000000 00000000 00000000 00000000 01000001 00010001 11100010
00000000 00000000 00000000 00000000 00000000 00000000 11001100 11110000
00000000 00000000 00000000 00000000 00000000 00000000 11110000 11001100
Inversion ordre des mots  :
00000000 00000000 00000000 00000000 00000000 01000001 00010010 00000000
00000000 00000000 00000000 00000000 11001100 11110000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 11110000 11001100
Raz registre puis copie bits  :
00000000 00000000 00000000 00000000 00000000 01000001 00010010 00011101
00000000 00000000 00000000 00000000 00000000 00000000 00000000 01100000
Raz registre avec signe puis copie bits  :
11111111 11111111 11111111 11111111 11111111 10111110 11101101 11000001
11111111 11111111 11111111 11111111 11111111 11111111 11111111 11100000
Extension 32 bits :
00000000 00000000 00000000 00000000 11111111 11111111 11111111 10001100
11111111 11111111 11111111 11111111 11111111 11111111 11111111 10001100
Fin normale du programme.
```
