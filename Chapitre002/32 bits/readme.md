Reprenons le programme précédent qui a servi à effectuer le test des outils.Pour commencer à programmer en assembleur, il faut appréhender plusieurs concepts qui sont indissociables.

C’est pourquoi dans ce petit programme qui n’affiche qu’un simple message, nous allons aborder les différentes parties d’un programme : les registres, la mémoire, le système d’exploitation etc.

Les premières lignes du programmes sont des commentaires limités par les caractères * et * . les commentaires en fin de ligne sont signalés par les caractères @ ou ·
Ensuite nous trouvons la définitions des constantes à l’aide de la pseudo instructions .equ. Une pseudo instruction est une instruction uniquement utilisé par le compilateur, ce n’est donc pas une instruction executable par le processeur.

Ici le compilateur se contentera de remplacer toutes les mots EXIT par la valeur 1 avant l’assemblage des autres instructions.

Remarque : les pseudo instructions sont précédés d’un point mais quelque unes ne le sont pas.

Puis nous trouvons la pseudo instructions .data qui définit une zone de la mémoire ou section.

Un programme assembleur décompose la place mémoire que lui attribue le système d’exploitation en zones ou sections dont l’usage et les accès sont différents. 
Nous trouvons la .data qui contient toutes les variables initialisées par le programmeur puis une section .bss dont les variables sont initialisées à zéro par le système d’exploitation. Ces 2 sections peuvent être lues et écrites.

Puis la section .text qui contiendra le code exécutable par le processeur. Cette section ne peut être que lue et exécutée. Si vous voulez avoir une partie du code modifiable par votre propre programme, il vous faudra créer une section particulière accessible en écriture.
En fin de la mémoire autorisée, nous trouverons la zone réservée à la pile (stack), celle ci voit ces adresses décroitrent lors de son utilisation et c’est pour cela qu’elle est située en fond de mémoire. 

Enfin le reste de la mémoire comprise entre la fin de la dernière section et la pile est le tas (heap).

Revenons à la section .data. Elle sert à décrire les variables à utiliser et leur contenu. Chaque variable se compose d’un label ou étiquette (ici szMessage) d’une pseudo instruction qui indique le type et sa valeur. Ici nous déclarons une chaîne de caractères en ascii se terminant par zéro (le z de .asciz) et dont la valeur est « Pgm1 : Bonjour le monde. \n ». Le caractère \n indique comme en C le retour à la ligne suivante.

Si vous regardez la liste de compilation dans le fichier  pgm32_1list.txt vous verrez que la chaîne commence par les caractères  50676D31 .
Le label ou étiquette représentera l’adresse de la variable en mémoire dans la suite du programme.

Nous pouvons déclarer en mémoire des chaînes de caractères sans le 0 final avec .ascii, des valeurs entières sur 4 octets par .int ou .word, des octets par .byte, des valeurs sur 2 octets par .hword, des valeurs sur 8 octets par .dword.


Dans notre programme, la section suivante .bss est vide.

Puis nous trouvons la section .text avec un label main : qui indique le début du code ou plus exactement l’adresse en mémoire de la première instruction exécutable. Ce label est d éclarée global pour être visible soit par d’autres modules soit par l’éditeur de liens. En effet dans le script de compilation donné au chapitre précédent, vous avez pour le linker ld la directive -e main qui lui indique que main est l’adresse de la première instruction à exécuter. 

Vous pouvez dans le programme changer ce label mais il vous faudra aussi modifier le script pour indiquer au linker la nouvelle étiquette.
Cette première instruction est ldr r0,iAdrszMessage qui charge dans le registre r0, l’adresse de la variable szMessage.

L’instruction se compose d’un mnémonique  le code opération ldr, du nom d’un registre r0 comme destinataire et d’une étiquette comme source.

Un registre est un composant électronique élémentaire du processeur dont la taille est de 32 bits soit 4 octets. Il peut donc contenir les valeurs de 0 à 2 puissance 32 - 1 soit 4 294 967 295. Ces valeurs représentent ce que vous voulez : un nombre, une adresse, une couleur, un code ascii etc. Nous verrons plus en détail les registres au chapitre suivant.

Ici nous mettons dans ce registre l’adresse du message en mémoire, adresse qui est donnée par l’instruction iAdrszMessage .int szMessage située après cette partie du code. Pourquoi cette complication alors que nous aurions pu écrire ldr r0,szMessage directement ? Cela n’est pas possible car l’instruction et le message sont stockés dans 2 sections différentes, et il n’est pas autorisé d’accéder à une autre section depuis la section code.

Mais vous allez me dire : «  ce n’est pas vrai !! j’ai vu dans des exemples de programmes arm que nous pouvions accéder directement à la variable avec l’instruction ldr r0,=szMessage ».

En effet car ces 2 instructions ldr ne sont pas véritablement des instructions de base du processeur car celui ci ne connaît qu’une seule instruction du chargement en mémoire de format ldr rx,[ry,(rz/imm]. 

C’est encore le compilateur qui va transformer ces instructions. Dans le cas de ldr r0,=szMessage , il va créer une zone mémoire en fin de code avec l’adresse de szMessage, zone qui remplace celle que j’ai déclarée iadrszMessage mais ça revient au même !!

Et ensuite le compilateur va remplacer soit l’instruction ldr r0,iAdrszMessage soit ldr r0,NouvelleAdresseSzMessage par l’instruction ldr r0,[pc,Deplacement] avec pc = le registre qui contient l’adresse de l’instruction exécutée et Deplacement = au nombre d’octets entre cette instruction et l’adresse  iAdrszMessage.

L’instruction suivante bl afficherMess est un appel à la sous routine afficherMess et est équivalente au call d’autres langages. Mais en assembleur arm, l’adresse de retour de la procédure est stockée dans le registre r14 aussi nommé  lr.

Puis nous trouvons 2 instructions d’affectation qui mettent la valeur 0 dans le registre r0 et la valeur 1 dans le registre r7 avant d’appeler le système d’exploitation Linux avec l’instruction svc. 

Ces 2 registres sont les registres standards pour passer des paramètres au système Linux. Ici r0 contiendra le code retour et r7 contiendra le code fonction que Linux doit exécuter. 

Ici c’est la fonction Exit qui termine correctement un programme. Pourquoi passer par cette fonction ? Parce que votre programme a pu dégrader certaines parties comme la pile et Linux va remettre tout d’aplomb, libérer la mémoire, fermer les fichiers restés ouverts etc 

Ensuite nous trouvons la routine afficherMess dont le nom est donné par le label afficherMess : et dont la première instruction est push {r0,r1,r2,r7,lr}.
Cette instruction copie la valeur des registres r0,r1,r2,r7 et lr dans la mémoire à l’adresse indiquée par le registre de pile r13 aussi nommé sp. Le registre r0 sera stocké à l’adresse contenue dans sp puis sp sera décrémenté de 4 octets et le registre r1 sera stocké à cette nouvelle adresse etc.

Il s ‘agit donc d’une sauvegarde des registres qui vont être utilisés dans la routine. Nous verrons plus tard la règle exacte de sauvegarde mais  pour cette routine qui va être appelée dans de nombreux programmes, je préfère sauvegarder tous les registres pour ne pas avoir de problème plus tard. 

Mais les spécialistes vont me dire que c’est au détriment de la rapidité d’exécution. Bof ! Comme nous appelons une fonction du système d’exploitation pour l’affichage, fonction qui va dérouler des centaines d’instructions nous ne sommes pas ici à quelques cycles supplémentaires !!

La fonction write utilisée nécessite de lui passer l’adresse du message en mémoire mais aussi sa longueur. 

Nous allons donc commencer par calculer cette longueur et pour cela nous initialisons le registre r2 à zéro, registre qui servira de compteur des octets de la chaîne.
Nous lisons le premier octet de la chaîne  dans le registre r1 grâce à l’instruction ldrb r1,[r0,r2], r0 contenant l’adresse du début de la chaîne , adresse que nous avons mis avant l’appel de la routine et r2 contenant l’indice de l’octet dans la chaîne et égal à  0.

Puis nous comparons la valeur du  registre r1 avec zéro et si cet égal c’est que nous avons trouvé le zero indiquant la dfin de chaîne et donc nous avons terminé le calcul donc nous sautons à l’étiquette suivante avec l’instruction beq 2f  sinon , nous augmentons le registre r2 de 1 et nous bouclons à l’étiquete précédente avec l’instruction b 1b.
L’instruction beq 2f signifie Branch if equal (saut si égal) à l’étiquette 2 forward (suivante) et l’instruction b 1b signifie Branch (saut sans condition) à l’étiquette 1 before (précédente) : c’est limpide non ?

Les étiquettes numériques avec les lettres f et b sont une astuce pour faciliter la programmation des sauts. J’aurais pu utiliser des noms classiques comme début : et fin : et les instructions auraient été : beq fin et b debut.

À L’étiquette 2 nous avons donc le registre r2 qui contient le nombre d’octets qui composent le message et il nous reste plus qu’à préparer les paramètres pour appeler la fonction write. Nous mettons dans r1, l’adresse du message contenue dans r0, puis dans r0, une constante qui indique d’écrire dans la console de sortie standard de Linux puis r2 contiendra la longueur et r7 le code fonction (ici 4) et nous appelons le système d’exploitation avec svc comme avec la fonction EXIT vue plus haut.

Nous terminons la routine en restaurant le même nombre de registres et dans le même ordre avec l’instruction pop {r0,r1,r2,r7,lr}. Ceci est très important, il faut toujours avoir une pile identique après l’appel à une routine ou fonction.

Puis nous retournons au programme principal avec l’instruction bx lr qui signifie de sauter à l’adresse indiquée dans le registre lr et en effet, je vous ai dit plus haut que l’adresse de retour était stockée dans ce registre lors de l’appel de la routine.

Ouf tout est parfait !! 

Si vous avez tout suivi, vous avez compris 90 % d’un programme assembleur. Vous pouvez donc pour vous entraîner, modifier le message, ou afficher un autre message ou plusieurs, enlever le caractère \n etc.

Vous avez encore bien sûr de nombreuses interrogations  sur ce programme !! 

Par exemple vous vous demandez comment nous connaissons les codes fonctions des appels système, et les valeurs a passer dans les paramètres. Heureusement sur Internet, nous trouvons toute la documentation nécessaire : il suffit de taper appel systeme linux write (ou system call linux write) pour trouver plein de sites (mais souvent en anglais) comme celui ci par exemple :
http://www.lxhp.in-berlin.de/lhpsysc0.html

Mais vous pouvez trouver les codes sur votre console termux avec la commande :

more /data/data/com.termux/files/usr/include/arm-linux-androideabi/asm/unistd-common.h

Si vous ne trouvez pas, chercher où se trouve le fichier unistd-common.h sur votre environnement termux.
