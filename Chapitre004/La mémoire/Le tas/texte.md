### le tas 
Le tas (heap en anglais) est la partie de la mémoire comprise entre la fin de la dernière section de données et la pile.

Il est possible de stocker des données de manière dynamique mais aucun mécanisme ne permet de l’effectuer automatiquement. C’est à notre programme de gérer avec des pointeurs les réservations de zones nécessaires.

Attention : le tas n’est sans doute pas initialisé par le système  !!

Dans le programme tas64.s, nous allons utiliser le tas pour stocker quelques données. Nous utilisons l’étiquette __end__ calculée par le linker et qui donne l’adresse de fin de toutes les données du programme (voir la liste de sortie du linker). Cette adresse nous sert à initialisée le pointeur de début du tas ptZoneTas.

Nous créons une fonction reserverPlace qui prend comme paramètre dans le registre x0, la taille en octet de la place à réserver. Nous chargeons l’adresse du pointeur de début du tas libre puis le pointeur lui même et nous lui ajoutons la taille. 

Comme la taille peut être quelconque, nous ajustons la nouvelle adresse sur une frontière de 8 octets . Ainsi la prochaine réservation s’effectuera sur une adresse toujours alignée sur 8 octets.

Cette adresse est stockée dans le pointeur de début de tas et la fonction retourne dans le registre x0, l’adresse du début de la zone réservée.
Dans le corps du programme, nous affichons l’adresse de départ du début du tas puis nous réservons des zones dans laquelle nous stockons des données et puis nous terminons en affichant le tas.

Voici un exemple de l’exécution.
```
Début programme.
Adresse départ :
Affichage  hexadécimal : 0000000000410C40
 retour adresse
Affichage  hexadécimal : 0000000000410C40
Nouvelle adresse
Affichage  hexadécimal : 0000000000410C58
Retour adresse 2
Affichage  hexadécimal : 0000000000410C58
Nouvelle adresse 2
Affichage  hexadécimal : 0000000000410C90
Aff mémoire  adresse : 0000000000410C40 Tas 1
0000000410C40*77 77 00 00 00 00 00 00 88 88 00 00 00 00 00 00 ww..............
0000000410C50 00 00 00 00 00 00 00 00 FF FF 00 00 00 00 00 00 ................
0000000410C60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410C70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410C80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410C90 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
Fin normale du programme.
```
Cette solution appelle quelques remarques : Il n’est pas vérifié que l’adresse de départ soit bien alignée sur une frontière de 8 octets, ce qui peut poser problème si la première valeur est un double.

Il n’est pas aussi vérifié que pour de grosses réservations, l’adresse finale du tas atteigne l’adresse de la pile et ce télescopage peut être néfaste.

Enfin, il peut y avoir un risque avec l’appel de fonctions de bibliothèques externes et qui réservent de la place sur le tas car rien n’indique la plage de mémoire que nos réservations occupent.

Une autre solution exploitée dans le programme tas64_1.s utilise une zone de la section .bss. Cette zone très grande nous servira de tas et comme cela nous pouvons vérifier les alignements et le dépassement éventuel de la fin. Il restera à définir la taille de cette zone en fonction des besoins du programme. Ici comme exemple nous avons pris 1 000 000 d’octets.

Le programme est identique au précédent sauf que l’adresse de début du tas est l’adresse de début de la zone définie dans la .bss. Cette zone est alignée sur 8 octets avec l’instruction .align 8

Et dans la fonction reserverPlace, nous avons ajouté un contrôle de dépassement de la fin de zone.

Ces 2 programmes ne gèrent pas la libération de la place lorsque celle ci n’est plus utile. Si c’est nécessaire il faut écrire une fonction qui attend l’adresse de la dernière zone réservée en paramètre pour remettre à jour le pointeur de début du tas. Mais attention, il faut effectuer cette libération dans l’ordre inverse des réservations. 
