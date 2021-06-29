### Contrôle du flot d’instructions.

Tout au long des programmes d’exemples des chapitres précédents, nous avons vu comment effectuer des sauts et des boucles.
Dans ce chapitre je vais rappeler brièvement les possibilités de l’assembleur ARM.

Un bloc d’instruction peut être défini par une étiquette (ou label) : un mot suivi des 2 points (:) comme 
main :
debut :
afficherMess :

Mais il est aussi possible de définir des étiquettes numérique 1 :  2 : 100 :.  Attention avec l’assembleur as, il n’y a pas d’étiquette locale, chaque étiquette est visible de l’ensemble du programme.
Et pour qu’une étiquette soit visible de l’extérieur d’un programme il faut qu’elle soit déclarée global avec la pseudo instruction .global.

Les sauts  inconditionnels utilise l’instruction b etiquette. Dans le cas des étiquettes numériques nous pouvons avoir un saut vers  l’étiquette suivante par b 1f   (forward) ou une étiquette précédente b 1b  (before).

Les sauts conditionnels utilise le code condition vu dans le chapitre registre d’état. Nous pouvons donc avoir beq 2f   (saut vers étiquette suivante si égal)  ou bge 3b  (saut vers étiquette précédente si plus grand).
Si l’étiquette n’existe pas le compilateur signale une erreur mais si l’étiquette existe dans une autre fonction, vous pouvez avoir un saut erroné !!

Exemple d’alternative si  alors sinon :
```asm
    cmp r0,#5
    bgt  1f
    @ instructions a exécuter si r0 <= 5
    b 2f
1 :
     @ instructions a exécuter si r0 > 5

2 :     @ suite des instructions
```
Exemple de boucle for next :
```asm
    mov r4,#0       @ init compteur
1 :
    @ instructions de la boucle
    add r4,#1        @ incremente le compteur
    cmp r4,#MAXI  @ maxi atteint ?
    blt 1b                @ non alors boucle
```
exemple boucle while :
```asm
     mov r0,#0    @ init indice
1 :
     cmp r0,r5        @ test de fin de boucle
     bgt 2f              @ si ok alors fin de boucle
    @ instructions de boucle
     b 1b     @ boucle
2 :   @ suite des instructions.
```
Les fonctions ou routines ou procédures internes sont identifiées avec une étiquette. Rien ne les distingue d’un autre bloc d’instructions.

Elles sont appelées avec l’instruction bl etiquette et l’adresse de retour est stockée dans le registre lr (r14).
Elles doivent donc se terminer par une instruction bx lr qui renvoie l’exécution au programme appelant.

Si la routine appelle une sous routine, alors il est obligatoire de sauvegarder le registre lr au début et de le restaurer avant la fin de la routine. Dans ce cas il est possible de restaurer le registre lr directement dans le registre du compteur d’instruction cp et d’eviter le bx lr.
Exemple
```asm
appelRoutine :
    push {r4,lr}
    @ suite instructions routines
    pop {r4,cp}
```
Remarque : l’oubli du bx lr ou la non restauration des registres en fin de routine entraîne le plus souvent un arrêt de l’exécution avec l’erreur Memory fault.


L’instruction bx registre peut être utilisée pour appeler une routine dont l’adresse est contenue dans un des registres généraux. Ainsi il est possible d’effectuer des appels dynamiques.

