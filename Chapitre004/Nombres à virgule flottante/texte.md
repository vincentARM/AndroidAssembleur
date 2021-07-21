### Nombres à virgule flottante

Jusqu’à maintenant, nous n »avons traité que des valeurs entières contenues dans les registre x0 à x29. Mais l’assembleur ARM permet de travailler sur des nombres décimaux avec une virgule flottante comme -1000,25 ou 3,14159.

Ces nombres peuvent être de 2 formats : .float de longueur 32 bits (simple précision) .double de 64 bits(double précision).

Ils sont définis par la norme IEEE754 (voir wikipedia) et seront manipulés par l’assembleur dans des registres spéciaux et des instructions particulières.

Pour les exemples, nous n’utiliserons que des doubles de 64 bits.

Nous trouvons 32 registres doubles de 64 bits : d0 à d31.

Il est possible de copier les registres xn dans les registres dn mais attention, il faudra convertir les valeurs dans le bon format.

Par exemple :
```asm
    mov x0,#100                   @ entier dans r0
    ucvtf d0,x0                   @ copie et conversion entier non signé
```
L’affichage des valeurs pose un problème car le décodage est assez complexe. Pour la facilité nous utiliserons l’appel à la fonction printf du langage C en utilisant l’indicateur %f. Ceci nous oblige à décrire les adresses de manière relogeable comme vu lors de l’appel de fonctions en C.

Si vous tenez à rester en full assembleur, vous trouverez au chapitre 88 du site :

https://assembleurarmpi.blogspot.com/2020/09/chapitre-88-assembleur-arm-64-bits.html

une routine en assembleur qui utilise l’algorithme grisu de Florian Loitsch.

Dans le programme nombreFloat64.s nous décrivons dans la .data les nombres que nous allons manipuler :

.double pour double précision 64 bits.

Remarque : il faut mettre un point à la place de la virgule.

Dans le corps du programme, nous commençons par mettre directement une constante dans le registre d0 avec l’instruction fmov. Attention toutes les constantes ne sont pas acceptées par cette instruction.

Puis nous trouvons un exemple de conversion d’une valeur entière signée  contenue dans un registre.

Ensuite nous chargeons une valeur de type double dans le registre d0 avec l’instruction
```asm
ldr d0,[x0]  
```
Puis nous trouvons des exemples d’addition, de multiplication et d’addition et de comparaison. 

Pour toutes ces opérations, il suffit d’ajouter un f au mnémonique des opérations vues pour les entiers.

Parfois, nous avons besoin de récupérer la valeur entière d’un registre float pour la copier dans un registre xn. Pour cela il faut utiliser l’instruction fcvtns pour les valeurs signées ou fcvtnu pour des valeurs non signées.

Voici le résultat de l’exécution :
```
Début programme.
Affichage 1
Valeur = +0.156250000000000
Conversion et Affichage
Valeur = -155.000000000000000
chargement et affichage 2
Valeur = +3.141592653589793
chargement et addition
Valeur = +103.141592653589797
multiplication +  addition
Valeur = +2003.141592653589896
comparaison
Valeur = +20.000000000000000
Fin normale du programme.
```
