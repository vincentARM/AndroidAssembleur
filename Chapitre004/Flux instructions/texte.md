### Flot d’instructions

Tout au long des chapitres précédents, dans les exemples de programmes, nous avons utilisé diverses structures d’instructions.

Dans le programme instruct64.s, nous trouvons pour rappel quelques exemples de structures.

Nous commençons par la structure alternative SI ALORS SINON en utilisant comme étiquette des nombres. 

Suivant le résultat des tests nous pouvons faire des sauts en avant en mettant un f derrière l’étiquette à laquelle il faut sauter. Par exemple
```asm
blt 1f
```
Pour les cas simples, il existe des instructions qui évite les branchements et donc qui n’entraîne pas de rupture de la séquence d’exécution (voir dans la documentation arl la notion de pipeline).
Les plus utilisées sont l’alimentation d’un registre à partir de 2 autres registres qui sont choisis suivant le résultat du test. Exemple
```asm
cmp x0,10
csel x0,x1,x2,lt 
```
si x0 est inférieur (lt) à 10, l’instruction y mettra la valeur du registre x1 sinon elle mettra la valeur de x2.

Ne pas oublier que si x1 ou x2 sont initialisés à zéro, nous pouvons utiliser xzr ce qui économise un registre général.

Il existe aussi l’instruction 
```asm
cset x0,gt
```
si le résultat du test est plus grand (gt), l’instruction mettra 1 dans  x0 sinon elle mettra 0.

Ensuite nous trouvons un exemple de boucle de recherche. Cette fois ci nous utilisons des étiquettes sous forme de mots.

Pour éviter le test de fin de chaîne caractère = zéro, nous utilisons l’instruction 
```asm
cbz w0,nontrouve
```
qui saute à l’adresse nontrouve si le registre wo est égal à zéro.

Nous trouvons une autre boucle qui utilise des chiffres comme étiquettes. La boucle se fait en utilisant l’instruction 
bne 3b 

Le petit b derrière le 3 indiquant que nous voulons un saut arrière (before).

Cette fois ci pour incrementer l’indice, nous utilisons l’instruction conditionnelle :
```asm
cinc x0,x0,ne
```
Le registre x0 est incrementé de 1 si le comparaison précédente rend un résultat différent (ne).

Remarque : il existe d’autres instructions conditionnelles qui peuvent être utilisées à la place de saut pour les cas simples (voir la table des instructions arm 64).

En fin nous terminons par un exemple d’appel de routine : la première avec l’instruction bl nom de routine, la deuxiéme en mettant d’abord l’adresse de la routine dans le registre x5 puis en utilisant l’instruction blr x5.
L’adresse de la routine utilise l’instruction adr à la place de ldr puisque nous voulons dans ce cas l’adresse de l’étiquette et pas sa valeur (qui serait le code de la première instruction de la routine).

Je rappelle que ces instructions passent le contrôle de l’exécution à la routine et stocke l’adresse de retour dans le registre bl (x30). Si la routine appelle d’autres routines, il est nécessaire de sauvegarder le registre lr.
Le retour au programme appelant s’effectue avec l’instruction ret après avoir éventuellement restauré le registre lr et les autres registres.
La sauvegarde et la restauration des autres registres dépend entièrement de vos choix de programmation sauf si vous avez l’intention d’écrire des routines pour publier une bibliothèque particulière. Dans ce cas, il vous faudra respecter la convention d’appel standard.

Vous remarquerez que rien ne distingue une étiquette de nom de routine d’une quelconque autre étiquette. Ceci implique que seule l’instruction ret terminera proprement l’exécution de la routine.

Si vous l’oubliez, l’exécution continuera avec la routine suivante et les résultats seront imprévus ou trouvera du vide et vous aurez l’erreur segmentation fault.
