### Opérations sur le nombres en virgule flottante.

Jusqu’à maintenant, nous n »avons traité que des valeurs entières contenues dans les registre r0 à r12. Mais l’assembleur ARM permet de travailler sur des nombres décimaux avec une virgule flottante comme -1000,25 ou 3,14159.

Ces nombres peuvent être de 2 formats : .float de longueur 32 bits (simple précision) .double de 64 bits(double précision).

Ils sont définis par la norme IEE et seront manipulés par l’assembleur dans des registres spéciaux et des instructions particulières.

Nous trouvons 16 registres doubles de 64 bits : d0 à d15 mais qui peuvent être utilisés en 32 bits ce qui fait 32 registres s0 à s31. Par exemple, les registres s0 et s1 sont équivalent au registre d0.

Il est possible de copier les registres rx dans les registres sx mais attention, il faudra convertir les valeurs dans le bon format.

Par exemple :
```asm
    mov r0,#100                   @ entier dans r0
    vmov s2,r0                      @ copie 
    vcvt.f32.s32 s2,s2            @ conversion en float signé
```
L’affichage des valeurs pose un problème car le décodage est assez complexe. Pour la facilité nous utiliserons l’appel à la fonction printf du langage C en utilisant l’indicateur %f.

Si vous tenez à rester en full assembleur, vous trouverez au chapitre 90 du site 
https://assembleurarmpi.blogspot.com/2020/09/chapitre-90-assembleur-arm-32-bits.html
une routine en assembleur qui utilise l’algorithme grisu de Florian Loitsch.

Lors de la compilation d’un programme assembleur qui utilise ces nombres, vous pouvez avoir une erreur qui signale que le processeur ne gére pas ce type de nombre. Dans ce cas il faut ajouter dans le script de compilation les directives ci après :
 ```shell
-mfpu=vfp -mfloat-abi=hard
```
Dans le programme nombFloat32.s nous décrivons dans la .data les 2 types de nombres :

.float  pour simple précision 32 bits

.double pour double précision 64 bits.

Remarque : il faut mettre un point à la place de la virgule.

Dans le corps du programme, nous chargeons une valeur de type float dans le registre s0 avec l’instruction 
```asm
vldr.f32 s0,[r2]  
```
r2 contenant l’adresse du nombre dans la .data.

f32 précise le format : ici 32 bits non signé

Pour l’affichage, nous sommes obligés de le convertir en double dans le registre d0 avec l’instruction
```asm
vcvt.f64.f32  d0,s0
```
Remarque : cette opération est dangereuse puisque s0 est une partie de d0, sa valeur est donc détruite après cette opération.

Puis il nous faut copier le registre d0 dans les registres r2 et r3 avant d’appeler la fonction printf.

Et il ne faut pas oublier de mettre l’adresse de la chaîne de formatage dans r0.

Ensuite, nous faisons la même chose pour afficher un double de 64 bits.
Donc sauf impératif, il vaut mieux effectuer les calculs avec des doubles !!

Puis nous effectuons la conversion d’un entier contenu dans le registre r0 et nous affichons le résultat.
Puis nous trouvons des exemples d’addition, soustraction et division.
Vous trouverez la liste des instructions sur la carte de référence en téléchargeant le pdf sur ce site :
https://developer.arm.com/documentation/qrc0007/e/

Nous terminons en extrayant la partie entière d’un double et en l’affichant puis par la comparaison de 2 doubles. Il faut après transférer les indicateurs dans le registre d’état pour pouvoir utiliser les résultats de la comparaison avec l’instruction :
vmrs apsr_nzcv,fpscr

Voici le résultat de l’exécution :
```
Début du programme 32 bits.
valeur = -10.543210029602051
valeur = 3.141592653589793
valeur = 100.000000000000000
valeur = 510003.141592653584667
valeur = 509996.858407346415333
valeur = -1287240.000000000000000
valeur = -202060.221870047535049
Entier  : Valeur hexa du registre : 00000009
d1 est plus grand ou égal que d2.
Fin normale du programme.
```
