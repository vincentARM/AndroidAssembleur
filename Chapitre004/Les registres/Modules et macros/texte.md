### Modules et macros.

Dans les dernières programmes, vous avez constaté que les programmes contiennent les mêmes routines d’affichage. Il serait donc intéressant de les déporter dans un autre module unique qui serait placé dans un répertoire supérieur et appelé lors de l’édition de liens par le linker.

Pour cela, nous allons créer un programme source appelé routines64.s et qui contiendra les 4 routines afficherHexa,conversion16, conversion2 et afficherMess. Ces 4 routines doivent être déclarées globales pour être visibles par l’éditeur de lien et donc pour être appelées par les programmes.

Ce programme est compilé pour créer un programme objet routines64.o. Comme il n'y a pas d’étiquette main, et si vous utilisez le script précédent le signalement suivant :

ld: warning: cannot find entry symbol main; defaulting to 00000000004000b0
n'est pas critique.

Il nous faut modifier le script de compilation pour indiquer au linker l’emplacement de ce programme objet. Voici le nouveau script :
```shell
#compilation assembleur
#echo $0,$1
echo "Compilation 64 bits de "$1".s"
#pour la liste de compilation ajouter -a >$1"list.txt"
as -o $1".o"   $1".s" 
#pour la liste du linker ajouter --print-map >$1"map.txt"
ld -o $1 $1".o" ../routines64.o  -e main 
ls -l $1*  
echo "Fin de compilation."
```
Remarque : dans ce script j’ai supprimé les options pour sortir les listes de compilation et d’édition des liens.

Puis dans le programme testRoutines64.s nous écrivons quelques appels aux 3 routines pour vérifier si tout fonctionne. Ok ? Par la suite il nous suffira d’ajouter dans le fichier des routines les nouvelles routines puis à le recompiler, cela simplifiera les programmes.

Nous voyons aussi que nous écrivons les mêmes instructions pour déclarer et afficher différents titres. 

Nous pouvons alléger cela en écrivant une macro instruction. Par exemple nous allons afficher un libellé en tapant seulement afficherLib Bonjour grâce à la macro suivante :

```asm
.macro afficherLib str 
    str x0,[sp,-16]!        // save x0
    mrs x0,nzcv             // save du registre d'état  dans x0
    str x0,[sp,-16]!        // puis sur la pile
    adr x0,libaff1\@        // recup adresse libellé passé dans str
    bl afficherMess
    ldr x0,[sp],16
    msr nzcv,x0             // restaur registre d'état
    ldr x0,[sp],16          // restaur x0
    b smacroafficheMess\@   // pour sauter le stockage de la chaine.  
libaff1\@:     .ascii "\str"
               .asciz "\n"
.align 4
smacroafficheMess\@:     
.endm                       // fin de la macro
```
La macro est délimitée par les pseudo instructions .macro et .endm. afficherLib est le nom de la macro qui servira à l’insérer et str est le nom du seul paramètre à passer à la macro.
Pour insérer la macro n’importe où dans la section code d’un programme, il suffira de taper afficherLib Bonjour.

Dans le corps de la macro, nous commençons par sauvegarder sur la pile le registre x0 et le registre d’état pour être le plus transparent possible.

Ensuite nous récupérons l’adresse du libellé à afficher. Cette adresse est indexée par un n° donné par le compilateur grâce au code @ . Si cette macro est insérée plusieurs fois, l’adresse de la zone sera donc différente. Le contenu du libellé est défini par .ascii "\str" et \str sera remplacé lors de l’insertion par le texte qui sera mis après le nom de la macro.

Ce libellé sera affiché par notre routine d’affichage et il nous reste à restaurer les registres pour continuer.

Nous insérons cette macro dans le programme testMacro.s pour afficher différents libellés.

Nous en profitons pour vérifier que le registre x0 est bien sauvegardé et que l’adresse de la pile reste identique.

Nous effectuons aussi un test d’un libellé entre guillemets et un test d’« ecriture en rouge en utilisant les codes d’échappement des terminaux Linux. 

 Voici le résultat :
 ```
Début programme.
Affichage  hexadécimal : 0000007FE545B030
Bonjour
Affichage  hexadécimal : 00000000000000FF
Affichage  hexadécimal : 0000007FE545B030
Bonjour le monde !

 Erreur!!
Fin normale du programme.
```

Erreur !! doit s’afficher en rouge.
