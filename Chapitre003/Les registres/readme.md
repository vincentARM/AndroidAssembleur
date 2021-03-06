Les registres sont une partie très importante d’un processeur car c’est avec eux que nous allons effectuer la plupart des instructions.

Comme je l’ai déjà dit un registre est un minuscule composant électronique composé de 32 micro interrupteurs qui peuvent prendre les valeurs 0 ou 1.

Pour un processeur ARM 32 bits, nous avons 16 registres de ce type : 

```
         13 dit d’usage général r0 à r12
          le registre de pile r13 ou sp
          le registre de link  r14 ou lr
          le pointeur d’instruction r15 ou pc
 ```
Les Registres d'usages généraux peuvent être utilisés pour toutes les opérations.

Le registre de pile sp peut être modifié, le registre lr ne doit l'être qu'avec prudence !!. Le registre pc ne peut être modifié directement que par l'instruction pop. Il est modifié indirectement par les instructions de saut et de branchement.

Dans les 13 registres généraux, certains servent aux passages des paramètres lors d’appel de fonctions de bibliothèques externes : il s’agit des registres r0 à r3 : ces registres ne sont pas sauvegardés par ces fonctions (y compris lors des appels à Linux).

Le registre r12 est utilisé par certaines fonctions de langage évolué (C C++) pour des appels longs et n’est pas toujours sauvegardé donc prudence.

Les autres registres généraux et lr sont sauvegardés par les fonctions appelées.
