### Opérations arithmétiques et base 10.
Maintenant, il ne nous reste plus qu « à écrire une routine d’affichage d’un registre en décimal (base10) et nous nous en servirons pour voir les opérations arithmétiques autorisées avec les registres.

Dans le programme affDecimal32.s nous trouvons la routine conversion10 qui va convertir le contenu du registre r0 en une chaîne de caractères ascii représentant sa valeur en base 10 (décimale).

Pour cela nous divisons successivement la valeur à convertir par 10 et nous calculons le reste, reste que nous transformons en caractère ascii en ajoutant 48. 

Il y a un petit problème, les restes successifs des divisions donnent les chiffres décimaux en partant de la droite. Il nous faut donc ensuite recopier les chiffres du résultat dans la partie gauche de la zone de conversion pour avoir un affichage correct.

Remarque : nous utilisons l’instruction de division udiv qui n’est pas disponible sur tous les processeurs arm. Dans ce cas, il faut programmer une division entière. Vous trouverez un exemple sur le site : 

Dans le corps du programme,nous appelons cette nouvelle routine pour afficher le nombre 100 puis le nombre le plus grand contenu dans un registre et nous affichons la longueur retournée pour vérification.

Ensuite nous trouvons un exemple d’utilisation de l’addition sur des petits nombres puis un exemple d’addition sur un grand nombre proche de la valeur maximale. Et dans ce cas nous voyons que le résultat est faux car il y a un dépassement de la valeur maximum du registre. 

Heureusement, l’assembleur propose une solution pour signaler ce dépassement. Si nous utilisons l’instruction adds (avec un s final), le processeur mettra un 1 dans l’indicateur de retenue (carry) du registre d’état et il nous suffit de tester cette retenue avec les instructions bcs ou bcc pour déterminer s’il y a dépassement et prendre les mesures qui s’imposent.

Donc dans un programme assembleur qui effectue des calculs, vous pouvez utiliser add quand vous savez que les nombres utilisés sont petits et s’ils sont grands ou s’il y a un doute il faudra utiliser adds et programmer une gestion de ce dépassement (message et ou arrêt du traitement).

Vous remarquerez que l’indicateur utilisé (carry) est le même que celui qui récupère les bits lors des déplacement et que là aussi il faut ajouter un s aux instructions lsl ou lsr.

Vous pouvez modifier l’addition pour tester les 2 cas.

Enfin la retenue peut être récupérée pour être additionnée à une autre addition avec l’instruction adc.

Par exemple nous voulons additionner 2 nombres de 64 bits, le registre r1 contient les 32 bits de la partie basse du 1er nombre, le registre r2 la partie haute, le registre r3 la partie basse du 2ième nombre et r4 la partie haute.

Il nous suffit d(effectuer l’addition comme ceci 
```asm
adds r5,r1,r3      @ additionne les parties basses
adc  r6,r2,r5      @ additionne les parties hautes et la retenue.

```

Attention à l’interprétation des résultats car quelle addition avons nous fait exactement ?

Le registre r1 contient 4 294 967 290, le registre r2 contient 5 mais attention c’est la partie haute donc cela correspond à 5 * (2 puis 32) = 21 474 836 480

le 1er nombre correspond à 21 474 836 480 +  4 294 967 290 = 25 769 803 770

Le registre r3 contient 20 et le registre r4 contient 10 mais comme c’est la partie haute cela correspond à 10 * (2 puis 32) = 42 949 672 960.

Le 2ieme nombre correspond donc à 42 949 672 960 + 20 = 42 949 672 980

et la somme des 2 = 25 769 803 770 + 42 949 672 980 = 68 719 476 750

L’affichage du résultat nous donne 14 pour la partie basse et 16 pour la partie haute ce qui correspond à 16 * (2 puis 32) = 68 719 476 736.
Le résultat est donc : 68 719 476 736 + 14 = 68 719 476 750
Banco c’est le même que calculé plus haut. 


Vous pouvez remarquer que dans ce programme nous avons utilisé des zones de la .data initialisées à blanc comme zones de conversion à la place de zones de la section bss. Cela nous permet de vérifier que les zéros finaux des conversions sont bien à la bonne place.

Voici le résultat complet :
```
Début du programme 32 bits.
Vérification affichage décimal :
Longueur :
00000003
100
Grand nombre :
Longueur :
00000009
4294967295
Addition
210
Addition grand nombre
14
Addition grand nombre 2
Pas de retenue.

Addition sur 64 bits
14
16

Fin normale du programme.
``` 
