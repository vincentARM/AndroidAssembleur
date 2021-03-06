### Définitions des données.

Nous avons déjà vue dans les programmes précédents, la définition de chaîne de caractères suivi d’un zéro avec la pseudo instruction .asciz. Pour définir une chaîne sans le caractère zéro final, il faut utiliser la pseudo instruction .ascii. Vous avez remarqué qu’il est possible d’indiquer des caractères spéciaux comme le retour ligne \n.

Pour définir un seul octet, il faut utiliser .byte, pour définir 2 octets (un demi mot de 16 bits) c’est .hword, 4 octets soit un mot de 32 bits c’est .word ou .int et enfin un double mot de 8 octets c’est .quad.

Les octets peuvent avoir une adresse quelconque mais les demi mots doivent être alignés sur une frontière de 2 octets avec l’instruction .align 2, les entiers sur une frontière de 4 octets avec .align 4 et les double mots sur une frontière de 8 octets.

Suivant le processeur, le non alignement peut entraîner soit une erreur (bus error) soit une baisse de performance (il faudra plus de cycles machines pour accéder à un entier désaligné).

Il est possible d’initialiser les données en utilisant la codification binaire (0byyy), hexa (0xyyy, octale (0yyy) et décimale (yyy). Il est possible de définir plusieurs données du même type en les séparant par des virgules  exemple :
```asm
qValeurs :      .quad 1,2,3,4
```
Dans la .bss, il est possible de définir les données avec ces pseudo instructions mais il faut mettre les valeurs à 0 car comme elles sont initialisées d’office si vous mettez d’autres valeurs, le compilateur signalera une anomalie.

Dans ce cas il est préférable d’utiliser l’instruction .skip n qui réserve n octets dans la mémoire.

Vous remarquez que j’ai nommé les variables avec une première lettre minuscule qui reprend le type (hélas en anglais) de la variable. C’est une bonne pratique pour s’y retrouver et détecter des erreurs éventuelles. Donc nous trouvons :

    b pour une variable d’un octet : exemple bCode

    h pour un demi mot

    i pour un entier

    q pour un double mot

    s pour une chaîne de caractères sans le 0 final

    sz pour une chaîne avec le 0 final

    t pour les tableaux

    pt pour les pointeurs vers des structures

Bon, c’est pas toujours respecté !!!

Dans la section .text, nous trouvons les instructions à exécuter, instructions qui ont une longueur de 4 octets soit 32 bits (oui oui même en 64 bits les instructions ont une longueur de 32 bits),et toujours alignées sur une frontière de 4 octets.

Nous avons vu qu’il est possible de définir des données comme des adresses dans la partie code. Nous pouvons aussi définir des constantes comme dans la .data mais attention il n’est possible que de lire ces données. Si vous essayer de mettre à jour ces données vous aurez l’erreur segmentation fault car la section code est interdite d’écriture. Et heureusement, car votre programme pourrait malencontreusement écraser des instructions avec des données.

Un autre point important est que si vous définissez une chaîne de caractères ou un octet ou un demi mot, il faudra ajouter la pseudo instruction .align 4 pour que la routine suivante éventuelle ait bien ses instructions alignées sur 4 octets.

Reprenons le programme accesmem64.s dans lequel nous avons des exemples de définitions des données. Puis dans la partie code, nous commençons par charger l’adresse de la donnée qValeur1 dans le registre x1 puis dans x0 pour l’afficher en hexadécimal avec l'instruction :
```asm
ldr x1,qAdriValeur1
mov x0,x1
```
Cette adresse est définie à la fin du corps du programme avec l’instruction :
```asm
qAdriValeur1:           .quad qValeur1
```
Vous remarquerez que l'adresse est définie avec .quad cad sur 8 octets ou 64 bits.

Puis nous chargeons la valeur contenue à cette adresse dans le registre x0 avec l’instruction
```asm
ldr x0,[x1]
```
valeur que nous affichons en hexadécimal. Notez bien la différence entre les 2 instructions : la première charge dans un registre l’adresse, la deuxième avec le registre entre crochets charge la valeur contenue à cette adresse mémoire.

Dans notre exemple, vous trouvez une valeur dans les 0x410000 pour l'adresse et la valeur 0x1234567890123456 pour le contenu, ce qui est bien la valeur définie dans notre .data .

Il existe une autre façon de charger l’adresse d’une donnée c’est d’utiliser l’instruction
```asm
ldr x1,=qValeur1
```
Et cette fois ci, nul besoin de déclarer une instruction
```asm
qAdrqValeur1:           .quad iValeur1
```
pour que cela fonctionne. En effet c’est le compilateur qui va effectuer cette déclaration à la fin du programme : déclaration transparente pour vous.

Mais attention, pour de gros programmes assembleur (plus de 1000 instruction de 4 octets), le compilateur générera une erreur bizarre car l’écart entre l’instruction ldr et la définition dépassera 4096 caractères.

C’est pourquoi je conseille de prendre l’habitude de déclarer soit même les adresses (et de mettre comme préfixe qAdr).

Ensuite nous trouvons un exemple pour charger le premier octet de l’entier qValeur1 avec l’instruction
```asm
ldrb w0,[x1]
```
En 64 bits, pour charger des données de longueur inférieure à 64 bits il faut utiliser le nom des registres 32 bits (w). Pour les données en 64 bits, il faut utiliser les noms en x.

Mais c’est curieux c’est la valeur hexa 56 qui est affichée et pas la valeur 12 !! Ceci est normal car il y a 2 façons de stocker un entier dans la mémoire : les octets de poids fort en premier c’est le gros-boutiste ou big-endian

ou les octets de poids faible en premier : petit-boutiste ou little-endian

Voir sur wikipédia les précisions et les explications amusantes de ces termes.

La manière de stocker les entiers peut être modifiée mais je vous déconseille de le faire !!!

Maintenant nous chargeons le deuxième octet qui se trouve en position 1 (le premier étant en position 0) avec l’instruction :
```asm
ldr w0,[x1,#1]
```
x1 contenant l’adresse de notre entier et 1 est le déplacement (offset) à effectuer pour charger le 2ième octet.

Suivant le type de processeur, le déplacement peut varier de -255 à + 255 ou -4095 à +4095 octets. Pour aller au delà, il faut utiliser un autre registre comme ceci :
```asm
ldr x0,[x1,x2]
```
Ensuite nous avons le chargement du 2ième demi mot de notre entier qui commence à l’octet 2 avec l’instruction
```asm
ldrh x0,[x1,#2]
```
Puis nous avons l’exemple du chargement du 5ième octet d’une chaîne de caractères en utilisant un registre comme déplacement.

Puis nous montrons un exemple où après avoir chargé un octet, le registre de base est incrémenté de 1 pour charger l’octet suivant.

Ensuite un autre exemple où cette fois, l ‘adresse est incrémentée de 1 avant d’effectuer le chargement dans le registre avec l’instruction :
```asm
ldrb w0,[x2,#1] !
```
Notez le ! à la fin de l’instruction.

Puis encore un exemple où cette fois ci, l’adresse est incrémentée de la valeur d’un registre avec les instructions :
```asm
mov x3,#3
ldrb w0,[x2],x3
```
Enfin nous effectuons un chargement multiple de 2 registres avec l’instruction
```asm
ldp x0,x1,{x2}
```
Il existe aussi une instruction ldr particulière lorsque nous voulons charger une valeur négative de 4 octets dans un registre.
Il est necessaire de compléter cette valeur pour qu'elle repprésente bien une valeur négative dans un registre 64 bits. Dans ce cas nous utilisons l'instruction suivante :
```asm
    ldr x1,qAdrqValeurNeg
    ldrsw x0,[x1]
 ```

Enfin le programme se termine par un exemple du stockage d’un double mot en mémoire avec l’instruction
```asm
str x0 ,[x1]
```
Remarque : c’est bien le contenu de x0 qui est stocké à l’adresse contenue dans x1.

Tout ce que l’on a vu pour l’instruction ldr est applicable à l’instruction str.

Par exemple pour stocker un octet à la position 4 d’une chaîne, nous utiliserons ceci :
```asm
ldr x1,qAdrszChaine
mov x2,#x3
mov x0,#’A’       @ caractère A
strb w0,[x1xr2]
```
Résultat de l"exécution :
```
Début programme.
Accès valeur 8 octets :
Affichage  hexadécimal : 0000000000410A00
Affichage  hexadécimal : 1234567890123456
accès valeur 1 octet :
Affichage  hexadécimal : 0000000000000056
accès valeur 2 octets :
Affichage  hexadécimal : 0000000000005678
accès valeur 4 octets :
Affichage  hexadécimal : 0000000090123456
accès valeur 2 registres :
Affichage  hexadécimal : 0000000000000001
Affichage  hexadécimal : 0000000000000002
accès valeur negative :
Affichage  hexadécimal : 00000000FFFFFFFF
accès valeur negative avec report du signe:
Affichage  hexadécimal : FFFFFFFFFFFFFFFF
accès valeur avec offset dans registre:
Affichage  hexadécimal : 0000000000000003
accès valeur avec offset immediat et maj:
Affichage  hexadécimal : 0000000000410A0C
Affichage  hexadécimal : 0000000000000003
Affichage  hexadécimal : 0000000000000005
Affichage  hexadécimal : 0000000000410A2C
accès valeur avec offset post et maj:
Affichage  hexadécimal : 0000000000410A0C
Affichage  hexadécimal : 0000000000000001
Affichage  hexadécimal : 0000000000000003
Affichage  hexadécimal : 0000000000410A2C
stockage et destokage sur la pile:
Affichage  hexadécimal : 0000000000000004
Affichage  hexadécimal : 000000000000000A
Stockage 8 octets en mémoire :
Affichage  hexadécimal : 0000000000006666
Stockage 1 octet en mémoire :
Affichage  hexadécimal : 0000000012006666
Fin normale du programme.
```
