Pour optimiser un programme en assembleur ARM, il nous faut déjà un système de mesure pour déterminer si notre dernière amélioration entraîne un résultat concluant.

Les processeurs ARM de dernière génération comportent des registres spéciaux qui comptent le nombre de cycles et le nombre d’événements (par exemple les cache miss). Hélas Linux (et Termux) n’autorise pas l’accès en assembleur à ces registres.
Remarque il est possible d’accéder en lecture aux registres   mais pas plus !! La compilation des instructions spécifiques est OK mais l’exécution entraîne un message d’erreur. Quelqu’un trouvera peut être une solution !!

 
Une autre solution consiste d’utiliser les utilitaires de mesures de performance fournis par Linux. Là aussi je n’ai pas trouvé avec Termux le package concerné (normalement c’est perfs).

Il ne me reste donc plus qu’à mesurer le temps d’exécution d’une routine avec un appel système linux avec tous les inconvénients que cela implique : mesures variables en fonction de la charge du smartphone.

Le programme chrono64.s contient 2 routines, une pour récupérer le temps de début avec l’appel système gettimeofday (debutChrono), l’autre pour récupérer le temps final, calculer la différence entre les 2 temps et imprimer le résultat (stopChrono).

L’exécution d’une simple boucle 1 342 177 279 (0x4FFFFFFF) fois donne des temps différents : 907 millisecondes puis 904 puis 905 puis 879. 
Il sera donc nécessaire de lancer plusieurs fois les tests et de voir si la moyenne s »améliore ?

Ensuite pour optimiser, il nous faut connaître quels sont les instructions les plus coûteuses afin d’en réduire le nombre ou de les remplacer par des instructions moins coûteuses. 
Dans la documentation ARM, nous trouvons pour chaque type de processeurs le nombre de cycles de chaque instruction mais attention cela est à relativiser car les processeurs ARM utilisent un pipeline pour traiter plusieurs instructions à la fois (voir ces notions sur Internet)

Donc en gros, nous pouvons avoir ce classement du plus coûteux au plus rapide :

* Les appels système (svc) 

* Les appels aux routines et fonctions de bibliothèques externes

* Les appels aux routines internes

* Le chargement d’une donnée de la mémoire dans un registre ou l’inverse

* Les divisions

* Les multiplications

* Les autres opérations sur les registres.

Plus généralement, il faut aussi commencer par programmer l’algorithme le plus performant pour le problème considéré. En effet gagner quelques cycles sur un tri à bulle n’est pas comparable au gain d’un tri rapide !!!

Puis dans le programme, il faut optimiser le contenu des boucles. En effet gagner une instruction dans une boucle effectuée des milliers de fois est plus efficace que d’optimiser des instructions exécutées qu’une seule fois.

Enfin pour fignoler l’optimisation, il faudra se préoccuper de l’enchaînement des simples instructions pour ne pas bloquer le pipeline du processeur (attente d’un registre, rupture du flot )

Voyons sur le programme d’affichage de la fougère comment optimiser la boucle effectuée 400000 fois pour afficher un pixel.
Tout d’abord dans le programme fougere64Opt.s nous insérons les routines de mesure du temps pour mesure le temps d’exécution de la boucle non optimisé et qui nous servira du temps de référence. Ne pas oublier de modifier la gestion des adresses pour que les routines soient relogeables.

Sur mon smartphone, je trouve 72 ms 65ms 65ms 69ms 69ms  soit une moyenne de 68ms.

Regardons la boucle d’affichage des pixels car il est inutile d’optimiser à fond  les autres instructions qui ne sont exécutées qu’une fois !!

L’appel de la routine X11 Xdrawpoint ne peut être optimisée car externe et essentielle ! Mais la routine interne genererAlea appelée une seule fois par tour de boucle peut être récrite et insérer dans le corps de la boucle ainsi nous gagnons les saves/restaures de registres.
Nous chargeons aussi l’adresse de la graine en dehors de la boucle dans le registre x24, registre qui contiendra aussi les modifications de la graine.

Dans le programme fougere64Opt1.s nous apportons ces améliorations et nous trouvons les temps 65ms 66ms 65ms 60ms 62 ms soit une moyenne de 63,6

En 64 bits, nous avons beaucoup de registres que nous pouvons utiliser pour éviter les chargements depuis la mémoire. Mais il y a la routine externe Xdrawpoint qui peut utiliser les registres x5 à x18 sans les sauvegarder. 
Nous pouvons modifier le programme pour vérifier l’état de ces registres avant et après l’appel. Nous trouvons que les registres x7 et x10 à x15  et x18 ne semblent pas changer mais méfiance quand même.

Dans le programme fougere64Opt1.s  nous chargeons les constantes qVal1 et qVal2 dans les registres x10 et x11. Nous déplaçons le chargement de la constante dCent hors de la boucle et nous corrigeons l’utilisation du registre x6 inutile dans le test :
 ```asm
    mov x6,#93
    cmp x0,x6
 ```
    
Puis nous remarquons que nous chargeons la constante dConst2 2 fois et donc nous modifions le programme fougere64Opt2.s pour la charger dans le registre d6 en dehors de la boucle.

Voici les nouveaux temps : 62ms 61ms 63ms 61ms 57ms soit une moyenne de 60,8

Il ne nous reste plus qu’à charger les autres constantes dans des registres hors de la boucle dans le programme fougere64Opt3.s. Voici les temps :
65ms 60ms 58ms 62ms 57ms  soit une moyenne de 60,4  donc un gain faible

Compte tenu de l’entrelacement des calculs de X et Y, il n’est pas facile d’optimiser le pipeline du processeur.
On pourrait modifier la division par 100 et le calcul du reste car il existe des méthodes plus rapides de division par une constante mais la complexité supplémentaire en vaut-elle le coût.

Nous avons au total un gain de (68 – 60,4) /68 soit 11 %
