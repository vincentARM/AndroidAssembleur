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

C’est le compilateur qui effectuera le travail et il vous signalera une erreur si la valeur à stocker n’est pas possible. Dans ce cas il faudra soit utiliser des additions ou d’autres méthode pour y arriver.
 
