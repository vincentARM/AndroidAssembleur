Dans les dernières programmes, vous avez constaté que les programmes contiennent les mêmes routines d’affichage. 
Il serait donc intéressant de les déporter dans un autre module unique qui serait placé dans un répertoire supérieur et appelé lors de l’édition de liens par le linker.

Pour cela, nous allons créer un programme source appelé routines32.s et qui contiendra les 3 routines conversion16, conversion2 et afficherMess.
Ces 3 routines doivent être déclarées globales pour être visibles par l’éditeur de lien et donc pour être appelées par les programmes.

Ce programme est compilé pour créer un programme objet routines32.o. 
Comme il n'y a pas d'etiquette main, et si vous utilisez le script précedent le signalement suivant :
**ld: warning: cannot find entry symbol main; defaulting to 00010054**

n'est pas critique. 

Il nous faut modifier le script de compilation pour indiquer au linker l’emplacement de ce programme objet.
Voici le nouveau script :
```shell
#compilation assembleur
#link avec fichier des routines
echo "Compilation 32 bits de "$1".s"
as -o $1".o"   $1".s" -a >$1"list.txt"
#gcc -o $1 $1".o"  -e main
ld -o $1 $1".o" ~/asm32/routines32And.o -e main --print-map >$1"map.txt"
ls -l $1*
echo "Fin de compilation."
```

Puis dans le programme testRoutines32.s nous écrivons quelques appels aux 3 routines pour vérifier si tout fonctionne.
Ok ? Par la suite il nous suffira d’ajouter dans le fichier des routines les nouvelles routines puis à le recompiler, cela simplifiera les programmes.

Nous voyons aussi que nous écrivons les mêmes instructions pour déclarer et afficher différents titres. Nous pouvons alléger cela en écrivant une macro instruction. Par exemple nous allons afficher un libellé en tapant seulement afficherLib Bonjour grâce à la macro suivante :

```asm
/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé     */
.macro afficherLib str 
    push {r0}               @ save r0
    mrs r0,cpsr             @ save du registre d'état  dans r0
    push {r0}               @ puis sur la pile
    adr r0,libaff1\@        @ recup adresse libellé passé dans str
    bl afficherMess
    pop {r0}
    msr cpsr,r0             @ restaur registre d'état
    pop {r0}                @ on restaure R0 pour avoir une pile réalignée
    b smacroafficheMess\@   @ pour sauter le stockage de la chaine.
libaff1\@:     .ascii "\str"
               .asciz "\n"
.align 4
smacroafficheMess\@:     
.endm   @ fin de la macro
```
La macro est délimitée par les pseudo instructions .macro et .endm. AfficherLib est le nom de la macro qui servira à l’insérer et str est le nom du seul paramètre à passer à la macro. 

Pour insérer la macro n’importe où dans la section code d’un programme, il suffira de taper afficherLib Bonjour.

Dans le corps de la macro, nous commençons par sauvegarder sur la pile le registre r0 et le registre d’état pour être le plus transparent possible.

Ensuite nous récupérons l’adresse du libellé à afficher. Cette adresse est indéxée par un n° donné par le compilateur gràace au code \@ . Si cette macro est insérée plusieurs fois, l’adresse de la zoe sera donc différent.  Le contenu du libellé est défini par .ascii "\str" et \str sera remplacé lors de l’insertion par le texte qui sera mis après le nom de la macro.

Ce libellé sera affiché par notre routine d’affichage et il nous reste à restaurer les registres pour continuer.

Nous insérons cette macro dans le programme testMacro.s pour afficher différents libellés.
Voici le résultat :
```
Début du programme 32 bits.
bonjour
Bonjour le monde
Fin normale du programme.
```

Il est intéressant de regarder la liste de compilation pour comprendre comment fonctionne l’insertion.

Vous remarquerez que le texte peut être composé de plusieurs mots s’il est mis entre quotes.
