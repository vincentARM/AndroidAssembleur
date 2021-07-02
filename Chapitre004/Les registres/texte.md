### Les registres.

Les registres sont une partie très importante de tout processeur. La plupart des instructions assembleur vont concerner un ou plusieurs registres.

Un registre est un minuscule composant électronique qui comporte 64 minuscules interrupteurs qui peuvent prendre les valeurs 0 ou 1.

La taille des registres indique donc le type d'assembleur (32 ou 64 bits), les instructions ont toujours une taille de 32 bits mais elle vous autorisent à manipuler des données de la taille d'un bit, d'un ou 2 ou 4 ou 8 octets. 

Pour un processeur ARM 64 bits, nous disposons de 31 registres de 64 bits chacun :
* 29 registres généraux  de x0 à x28
* un registre de cadre fp ou x29
* un registre de lien contenant l’adresse de retour d’une routine lr ou x30
* 
et des registres spéciaux :
* le registre de pile sp
* le registre de compteur d’instruction pc
* un registre particulier qui ne contient que 0 : xzr
* le registre d'état 

et d'autres registres concernant les nombres en virgule flottante.

Les registres d'usages généraux peuvent être utilisés pour toutes les opérations.

Le registre de pile sp peut être modifié, le registre lr ne doit l'être qu'avec prudence !!. Le registre pc ne peut être modifié que par l'instruction pop.

Dans les 29 registres généraux, certains servent aux passages des paramètres lors d’appel de fonctions de bibliothèques externes : il s’agit des registres x0 à x7, le code fonction est passé dans le registre x8.

Les registres x0 à x17 ne sont pas sauvegardés par ces fonctions (y compris lors des appels à Linux).

Les registres x18 à x28 et le registre lr sont sauvegardés.

La partie basse de chaque registre cad les 32 bits de poids faible peuvent être utilisés avec les noms w0 à w29.

Le registre spécial contenant 0 peut être manipulé en 32 bits avec le nom wzr.
