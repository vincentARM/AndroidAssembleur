### Appel du système d’exploitation.

Dans l »assembleur ARM, il n’existe pas d’instructions d’entrées sorties.  Pour gérér les périphériques, les processeurs ARM utilisent des accès mémoire sur des adresses réservées (voir la documentation arm).

Mais nos programmes assembleur lancés sous linux, ne peuvent pas accéder à ces adresses, ils sont obligés de passer par des appels au système d’exploitation.

Noua vons vu le cas dès le premier programme pour afficher un message où nous avons dû faire appel à la fonction Write de Linux.

Dans le programme saisie32.s nous allons voir comment lire une chaîne de caractère saisie dans le terminal quel qu’il soit. Ce peut être le clavier du smartphone ou le clavier du terminal sous lequel vous êtes connecté par ssh.

Nous définissons dans la .bss, un buffer avec une taille suffisante pour recuieullir les données saisies.

Puis dans le corps du système, nous affichons un libellé indicatif puis nous préparons l’appel système READ (code 3) qui va nous permettre de lire les données saisies. 

Nous passons un code indiquant la console standard d’entrée Linux (STDIN = 0), l’adresse du buffer de réception et sa taille puis le code fonction (toujours dans le registre r7).
Ces paramètres sont trouvés dans la documentation Linux des appels système  par exemple :
```C
ssize_t read(int fd, void *buf, size_t count);
```
En retour de l’appel, nous affichons le code retour pour vérification. Normalement il retourne le nombre de caractères saisis ou un nombre négatif s’il y a une erreur de lecture.

Nous affichons ensuite le buffer pour voir le résultat saisi : première surprise, la saisie se termine par le caractère 0xA et non pas par le caractère de fin de chaîne zéro binaire.

Cela signifie qu’il faut remplacer ce caractère par un 0 binaire si nous voulons utiliser cette chaine dans les routines précédentes.

C’est ce que fait le programme pour effectuer ensuite la comparaison avec le libellé « fin » pour terminer le programme.

Maintenant il ne vous reste plus qu’à rechercher la documentation de tous les appels système Linux pour les utiliser dans vos programmes.

Vous pouvez voir de nombreux exemples sur la programmation pour le raspberry pi sur  http://assembleurarmpi.blogspot.com/p/blog-page.html 
 ou même sur le site du projet rosetta : http://www.rosettacode.org/wiki/Rosetta_Code
