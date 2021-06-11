Commençons par voir les possibilités des 32 bits d’un registre.

Tout d’abord il faut disposer d’un affichage de ces 32 bits sous la forme de 0 et de 1. Nous avons vu dans le premier programme comment afficher une chaine de caractère située en mémoire.

Mais il n’existe aucune instruction pour afficher le contenu d’un registre. Il nous faut donc écrire une fonction de conversion de chaque bit (0 ou 1) en caractère ascii de valeur 38 (0) ou 39 (1) et les stocker dans une zone en mémoire pour ensuite afficher cette chaîne par notre précédente fonction.

Dans le programme affbinaire32.s nous déclarons dans la .data différents messages qui vont nous servir et nous déclarons une zone de 40 octets remplie de blancs avec l’instruction 
```asm
szZoneBin:         .space 40,' '
```
Derrière nous trouvons l’instruction 
```asm
.asciz « \n »
```
qui termine la chaine avec un retour ligne plus le caractère zéro de fin de chaîne (le z de .asciz).

Dans la partie code, nous trouvons la fonction afficherBinaire qui va convertir le contenu du registre r0. Nous initialisons 3 registres qui vont nous servir à la conversion puis nous avons le début d’une boucle avec l’instruction 
```asm
lsl r6,r5,r2.
```

Cette instruction déplace vers la gauche (left) le contenu du registre r5 du nombre de positions contenu dans r2 et met le résultat dans le registre r6. Ici nous avons r5 qui contient 1 et r2 qui contient 31 ce qui veut dire que r6 contiendra après exécution de l’instruction à la position 32 un 1. (Position 32 car la 1ère position est notée 0).

Ensuite nous trouvons l’instruction 
```asm 
test r0,r6
``` 
Cette instruction va effectuer un test logique entre les 2 registres et comme r6 contient un 1 en position 32, elle permet de tester si le 32 bit de r0 est un 0 ou un 1.

Si le bit est égal à 0, l’instruction
```asm
moveq r4,#48 
```
va mettre le caractère ascii 48 dans le registre r4 sinon ce sera l’instruction
```asm
movne r4,#49
```
qui mettra le caractère 49 dans r4.
Et nous stockons ce caractère dans la zone mémoire réservée à la position contenue dans le registre r3.

Maintenant il nous reste qu’à décrementer le registre r2, et à incrementer la position r3 pour traiter le bit suivant.

Mais pour faciliter la lecture du résultat nous allons tous les 8 bits ajouter un espace dans la chaîne stockée en mémoire. 

Puis nous bouclons à l’étiquette 1 pour analyser tous les bits du registre. Et en fin nous affichons toute la chaîne trouvée.

Dans le programme principal, nous affchons les messages de guidage puis nous mettons la valeur 13 (1101 en binaire) dans le registre r2 avec l’instruction mov r2,0b1101, nous la recopions dans le registre r0 et nous appelons la routine de conversion.

Nous aurions pu mettre la valeur décimale 13 directement dans r2 avec l’instruction mov r2,#13.

 Le programme se poursuit en montrant l’addition de 2 registres dans r0 avec l’instruction add r0,r2,r1.
 
Voici un exemple d’exécution :
```
Début du programme 32 bits.
Affichage binaire :
00000000 00000000 00000000 00001101
Après addition :
00000000 00000000 00000000 00010110
```
Quelques remarques : les bits les plus à droite et qui représentent de faibles valeurs sont appelés bits de poids faibles. 

Les bits les plus à gauche sont les bits de poids forts.

Une instruction en langage machine ne fait que 4 octets de longueur donc il n’est pas possible de stocker toutes les valeurs en une seule instruction. Il est possible de stocker chaque valeur de 0 à 65536 mais il n’est possible de ne stocker que certaines valeurs au delà grâce à un mécanisme particulier (voir https://alisdair.mcdiarmid.org/arm-immediate-value-encoding/). 

C’est le compilateur qui effectuera le travail et il vous signalera une erreur si la valeur à stocker n’est pas possible. Dans ce cas il faudra soit utiliser des additions ou d’autres méthodes pour y arriver.
 
### Opérations logiques sur les bits.
L’assembleur permet d’effectuer les opérations logiques ET, OU, OU exclusif, négation et l’opération de remise à zéro d’un seul bit.

Dans le programme operBits32.s  nous continuons d’utiliser les 2 routines d’affichage vues dans le programme précédent pour afficher le résultat de ces opérations logiques.

Nous commençons par mettre dans le registre r1 la valeur 0b0011 et dans le registre r2 la valeur 0b0101 puis nous effectuons l’opération logique ET avec l’opérateur and.
Voici le résultat.
```
Début du programme 32 bits.
00000000 00000000 00000000 00000011
00000000 00000000 00000000 00001010
Résultat opération ET :
00000000 00000000 00000000 00000010
```

Vous voyez que seul le deuxième bit passe à 1 puisque les 2 registres ont seulement ce bit à 1 simultanément.

Le programme continue avec les opérateur OU, OU exclusif, NON et la remise à zéro d’un ou plusieurs bits.

Voici le résultat complet :
```
Début du programme 32 bits.
00000000 00000000 00000000 00000011
00000000 00000000 00000000 00001010
Résultat opération ET :
00000000 00000000 00000000 00000010
Résultat opération OU :
00000000 00000000 00000000 00001011
Résultat opération OU exclusif :
00000000 00000000 00000000 00001001
Résultat opération NON  :
11111111 11111111 11111111 11111100
Résultat opération RAZ bit  :
11111111 11111111 11111111 11100111
Fin normale du programme.
```
### Deplacements de bits

Maintenant nous allons voir une autre série d’opérations autorisées : les déplacements :

Dans le programme deplBits32.s Nous mettons la valeur 0b1110011 dans le registre r1 pour suivre les différents déplacements.

Nous commençons par déplacer tous les bits du registre de 5 positions sur la gauche avec l’ instruction :
```asm
lsl r0,r1,#5
```
Voici le résultat :
```
Début du programme 32 bits.
00000000 00000000 00000000 01110011
Résultat déplacement gauche :
00000000 00000000 00001110 01100000
```

Les bits les plus à gauche sont perdus et les nouveauc bits à droite sont mis à 0.

Puis nous déplaçons toujours les bits du registre r1 de 3 positions sur la droite : positions contenues dans le registre r2 :
```asm
    mov r2,#3
    lsr r0,r1,r2    
 ```
 
Dans ce cas, les bits à droite sont perdus et les nouveaux bits à gauche sont mis à 0.
Puis nous effectuons une rotation à droite de 3 positions avec l’instruction :
```asm
ror r0,r1,#3  
```

Dans ce cas les bits qui sortent de la droite sont mis à gauche.

Particularité : avec l’opérateur asr, un déplacement sur la droite met un ou des 1 à gauche si le dernier bit  (bit 31) est un 1 sinon il met des zéros. Nous verrons son utilité plus tard.

Exemple :
```asm
    lsl r2,r1,#25
    mov r0,r2
    bl afficherBinaire
    asr r0,r2,#4                  @ opérateur asr
    bl afficherBinaire
```

Il est aussi possible de tester la valeur du dernier bit exclus lors des déplacements en ajoutant un au mnémonique de l’instruction (lsls ou lsrs ou asrs). Dans ce cas le bit est mis dans un bit d’un registre particulier : bit de retenue (ou carry) du registre d’état.

Il est possible de tester la valeur de ce bit avec les conditions cs (Carry Set = 1) et cc (Carry clear = 0).

Suivant ces conditions, le programme effectue un saut pour afficher le message indiquant la valeur du bit.

Enfin le programme utilise l’opérateur rrx. Celui ci effectue une rotation d’une position sur la droite et le bit qui était dans le carry est mis dans le bit 31. Et le bit exclus par la droite vient le remplacer dans le carry. Amusant !! mais je n’ai pas encore trouvé l’utilité !!

Enfin il est possible gràce à un mécanisme (barrel shifter ) d'effectuer un déplacement de bits avant de copier le résultat dans un registre dans une même instruction :
Par exemple, déplacement de 8 positions des bits de r2 et copie du résultat dans r0 :
```asm
    mov r2,#0b11                   @ maj r2 
    mov r0,r2,lsl #8               @ copie dans r0 après déplacement à gauche de 8 bits
    bl afficherBinaire
```
Remarque : r2 n'est pas affecté par cette opération, le déplacement est fait en interne.
           Il est possible d'utiliser aussi lsr, asr et ror.

Voici le résultat complet de l'exécution :
```
Début du programme 32 bits.
00000000 00000000 00000000 01110011
Résultat déplacement gauche :
00000000 00000000 00001110 01100000
Résultat déplacement droit :
00000000 00000000 00000000 00001110
Résultat rotation droite :
01100000 00000000 00000000 00001110
Résultat déplacement droit arithmétique :
11100110 00000000 00000000 00000000
11111110 01100000 00000000 00000000
Résultat deplacement droit avec récupération bit :
Bit extrait = 1  :
Bit extrait = 0  :
Résultat rotation avec retenue  :
00000000 00000000 00000000 00111001
10000000 00000000 00000000 00111001
Résultat déplacement gauche :
00000000 00000000 00000011 00000000
Fin normale du programme.
```


Avec l’instruction lsls, nous pouvons simplifier la routine d’affichage d’un registre en décimal.

En effet il nous suffit d’effectuer ceci :
```asm
lsls r0,#1           @ déplace les bits de 1 vers la gauche et met le 31 dans le carry
movcc  r4,#48   @ carry à 0   Code ascii 48
movcs r4,#49     @ carry à 1  Code ascii 49.
```

Le programme suivant utilisera cette nouvelle routine.

### comptage et tests de bits

Dans le programme testsBits32.s, nous modifions la routine d’affichage pour utiliser l’instruction de déplacement gauche, ce qui nous permet d’économiser 2 registres.

Ensuite nous utilisons l’instruction 
```asm
clz r0,r1
```

pour compter le nombre de bits à zero en partant de la gauche du registre r1. Le résultat est mis dans le registre r0 que nous affichons avec notre routine.
Voici le résultat :
```
Début du programme 32 bits.
00000000 00000000 00000000 01110011
Nombre de zéros à gauche :
00000000 00000000 00000000 00011001
```

Évidement le résultat est affiché en base 2 et donc en attendant mieux, il nous faut le convertir en un nombre en base 10 soit 1 + 0 * 2 + 0 * 4 + 1 * 8 + 1 * 16  = 1 + 8 + 16 = 25 
et en effet il y a 25 zéros à gauche.

Puis nous utilisons l’instruction tst pour tester la valeur d’un bit particulier et nous terminons en utilisant l’instruction teq pour déterminer si 2 valeurs sont égales ( remarque : l’instruction cmp fait la même chose ) ? 

Voici le résultat complet :
```
Début du programme 32 bits.
00000000 00000000 00000000 01110011
Nombre de zéros à gauche :
00000000 00000000 00000000 00011001
Le bit testé est à 1
Le bit testé est à 0
Valeurs inégales
Valeurs égales
Fin normale du programme.
```
Dans ces petits programmes vous avez remarqué les 2 manières de programmer le IF THEN ELSE :
Soit en utilisant des instructions conditionnelles comme movcc et movcs dans les cas simples 
soit en utilsant des sauts comme beq 1f pour les cas plus compliqués ( plusieurs instructions ou appel à une routine 
car à son retour, l'état des drapeaux est inconnu).
