### Registre d’état, comparaisons.

Nous avons vu plusieurs indicateurs (flags) se trouvant dans le registre d’état. Il s’agit d’un registre supplémentaire appelé CPSR (Current Program Status Register) et dont plusieurs bits servent à enregistrer des informations sur le fonctionnement du processeur.

Parmi ces indicateurs (voir la documentation arm en fonction de votre processeur), il y a 4 indicateurs qui nous intéressent  particulièrement :

       * l’indicateur de zéro (Z)  qui prend la valeur 1 si le registre destinataire est égal à 0
       
       * l’indicateur de signe (N) qui prend la valeur 1 si le registre contient une valeur négative
       
       * l’indicateur de retenue (carry C)
       
       * l’indicateur d’overflow (V)

Ces indicateurs ne sont mis à jour que si l’on ajoute le suffixe s aux opérations binaires et arithmétiques. Ils sont toujours mis à jour par les instructions tst,teq et cmp.

Attention c’est une erreur fréquente d’oublier le s  à l’instruction dont nous voulons avoir l’état.

Pour voir ces mises à jour, dans le programme affRegEtat32.s, nous écrivons une routine qui affiche  l’état (0 ou 1) de ces indicateurs.

Dans cette routine, nous commençons par sauvegarder le registre d’état dans le registre r2 grâce à l’instruction spéciale mrs r2,cpsr.

Puis nous effectuons des branchements conditionnels pour mettre en place la valeur 0 ou 1 en fonction de l’état de chaque indicateur. Puis nous affichons le message ainsi composé et nous terminons en restaurant le registre d’état avec une autre instruction spéciale msr cpsr,r2

Pour utiliser cette routine, nous commençons dans le corps du programme par mettre la valeur 1 dans le registre r0 avec movs r0,#-1 puis la valeur 0 ce qui permet de vérifier le positionnement des indicateurs Z et N.

Puis nous continuons avec des additions et soustractions qui permettent de vérifier les indicateurs C et V.

Enfin nous utilisons l’instruction de comparaison de registres cmp sur des valeurs signées et non signées.

La aussi c’est une erreur fréquente de ne pas utiliser le bon test pour des valeurs non signées car rappelez-vous de quelle façon sont codées les valeurs négatives : ce sont les valeurs comprises entre 2 puis 31 et 2 puis 31 – 1 et donc plus grandes que des valeurs positives si vous utilisez les comparaisons hi et ls.

L’instruction cmp effectue une soustraction entre les 2 opérandes mais sans mettre à jour le résultat. Elle ne met à jour que les indicateurs.

Remarque : si les 2 opérandes sont égaux, le résultat est zéro ce qui fait que le beq (saut si égal) est équivalent  à un saut si zéro.

Voici la liste des codes comparaisons possibles :
* eq :  égal
* ne : différent
* cs / hs : carry mis / supérieur ou égal non signé
* cc / lo : carry à zéro / inférieur non signé
* mi : négatif
* pl : positif ou zéro
* vs :  overflow
* vc : pas d’overflow
* hi :  supérieur non signé
* ls ; inférieur ou égal non signé
* ge : supérieur ou égal signé
* lt : inférieur signé
* gt : supérieur signé
* le : inférieur ou égal signé
* al : toujours (n’est jamais renseigné)

Voici le résultat complet de l’exécution :
```
Début du programme 32 bits.
Nombre négatif
Etats :  Z=0  N=1  C=1  V=0
Nombre zero
Etats :  Z=1  N=0  C=1  V=0

Addition signée non ok
Etats :  Z=0  N=1  C=0  V=1

Addition non signée non ok
Etats :  Z=0  N=0  C=1  V=0

soustraction signée non ok
Etats :  Z=0  N=0  C=1  V=1

soustraction non signée non ok
Etats :  Z=0  N=1  C=0  V=0

Test égalité :
Etats :  Z=1  N=0  C=1  V=0
2

Test inégalité non signée :
Etats :  Z=0  N=0  C=0  V=0
1

Test inégalité signée :
Etats :  Z=0  N=0  C=0  V=0
2
Fin normale du programme.
```

Et les chaînes de caractères ? : nous verrons cela plus tard car c’est à nous d’écrire une routine de comparaison.
