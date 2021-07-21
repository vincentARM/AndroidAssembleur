### Registre d’état, comparaisons.
Nous avons vu plusieurs indicateurs (flags) se trouvant dans le registre d’état. Il s’agit d’un registre supplémentaire appelé NZCV et dont plusieurs bits servent à enregistrer des informations sur le fonctionnement du processeur.

Parmi ces indicateurs (voir la documentation arm en fonction de votre processeur), il y a 4 indicateurs qui nous intéressent  particulièrement :

   * l’indicateur de zéro (Z)  qui prend la valeur 1 si le registre destinataire est égal à 0
   
   * l’indicateur de signe (N) qui prend la valeur 1 si le registre contient une valeur négative
   
   * l’indicateur de retenue (carry C)
   
   * l’indicateur d’overflow (V)
   * 
Ces indicateurs ne sont mis à jour que si l’on ajoute le suffixe s à certaines opérations binaires(and, bic) et certaines opérations arithmétiques (add, adc, sub, sbc,neg). Ils sont toujours mis à jour par les instructions tst et cmp.

Attention c’est une erreur fréquente d’oublier le s à l’instruction dont nous voulons avoir l’état.

Pour voir ces mises à jour, dans le programme affRegEtat64.s, nous écrivons une routine qui affiche l’état (0 ou 1) de ces indicateurs.

Dans cette routine, nous commençons par sauvegarder le registre d’état dans le registre x4 grâce à l’instruction spéciale
```asm
mrs x4,nzcv
```

Puis nous effectuons des branchements conditionnels pour mettre en place la valeur 0 ou 1 en fonction de l’état de chaque indicateur. Puis nous affichons le message ainsi composé et nous terminons en restaurant le registre d’état avec une autre instruction spéciale
```asm
msr nzcv,x4
```
Pour utiliser cette routine, nous commençons dans le corps du programme par mettre la valeur 0 dans le registre x0 avec ands x0,x0,xzr puis la valeur 0 ce qui permet de vérifier le positionnement des indicateurs.

Nous voyons que le seul indicateur Z est positionné.

Puis nous continuons avec des additions et soustractions qui permettent de vérifier les indicateurs C et V.

Enfin nous utilisons l’instruction de comparaison de registres cmp sur des valeurs signées et non signées.

La aussi c’est une erreur fréquente de ne pas utiliser le bon test pour des valeurs non signées car rappelez-vous de quelle façon sont codées les valeurs négatives : ce sont les valeurs comprises entre 2 puis 63 et 2 puis 64 – 1 et donc plus grandes que des valeurs positives si vous utilisez les comparaisons hi et ls.

L’instruction cmp effectue une soustraction entre les 2 opérandes mais sans mettre à jour le résultat. Elle ne met à jour que les indicateurs.

Pour afficher les résultats, nous utilisons l’instruction cset x0,code comparaison  qui met 1 dans x0 si le résultat du test est vrai pour ce code comparaison et 0 si le test est faux.

Voici la liste des codes comparaisons possibles :

    • eq : égal 
    • ne : différent 
    • cs / hs : carry mis / supérieur ou égal non signé 
    • cc / lo : carry à zéro / inférieur non signé 
    • mi : négatif 
    • pl : positif ou zéro 
    • vs : overflow 
    • vc : pas d’overflow 
    • hi : supérieur non signé 
    • ls ; inférieur ou égal non signé 
    • ge : supérieur ou égal signé 
    • lt : inférieur signé 
    • gt : supérieur signé 
    • le : inférieur ou égal signé 
    • al : toujours (n’est jamais renseigné) 
    
Voici le résultat complet de l’exécution :
```
Début programme.
Etats zero
Z=1  N=0  C=0  V=0
Etats Addition ok
Z=0  N=0  C=0  V=0
Etats depassement addition
Z=0  N=0  C=1  V=0
Etats overflow addition
Z=0  N=1  C=0  V=1
Etats Soustraction OK
Z=0  N=0  C=1  V=0
Etats depassement soustraction
Z=0  N=1  C=0  V=0
Etats overflow soustraction
Z=0  N=0  C=1  V=1
Etats test égalité
Z=1  N=0  C=1  V=0
Affichage décimal : 1
Etats test inégalité
Z=0  N=1  C=0  V=0
Affichage décimal : 1
Etats erreur test superieur
Z=0  N=1  C=1  V=0
Affichage décimal : 0
Etats test superieur OK
Z=0  N=1  C=1  V=0
Affichage décimal : 1
Etats erreur test inférieur signé
Z=0  N=1  C=1  V=0
Affichage décimal : 0
Etats test inférieur signé OK
Z=0  N=1  C=1  V=0
Affichage décimal : 1
Fin normale du programme.
```

Et les chaînes de caractères ? : nous verrons cela plus tard car c’est à nous d’écrire une routine de comparaison.
