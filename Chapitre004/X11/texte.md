### Créer des graphismes avec X11.

En assembleur, il n’y a a aucune instruction pour gérer des graphismes. Nous somme obligés d ‘ appeler des fonctions de librairies externes.

Pour afficher des dessins sous android, il existe plusieurs solutions : une consiste à écrire une interface en C entre le programme assembleur et les fonctions Java propres à Android pour créer une application Android. Le problème est qu’il faut installer tout le kit de développement Android sur un ordinateur !!

Vous trouverez la démarche de cette solution sur le site :

https://www.eggwall.com/2011/09/android-arm-assembly-calling-assembly.html?m=1

et aussi :

https://community.arm.com/developer/tools-software/oss-platforms/b/android-blog/posts/example-of-calling-java-methods-through-the-jni-in-arm-assembly-on-android

Une autre solution est d’utiliser X11 bibliothèque lourde d’utilisation mais c’est un standard sous Unix et donc sous Linux. Il s’agit d’une solution client-serveur et donc il faudra installer une application serveur X11 sur Android. J’en ai essayé plusieurs mais la seule que j’ai réussi à faire fonctionner correctement est Android X11 X-Server disponible sur google playstore.

Pour utiliser la librairie X11, je vous conseille de trouver et de lire la documentation. 

Voir déjà en français : http://pficheux.free.fr/articles/lmf/xlib/

Vous trouverez la documentation en anglais de chaque fonction sur ce site :

https://tronche.com/gui/x/xlib/

Pour pouvoir utiliser X11 il faut charger dans la console Termux le package x11-repo
```shell
pkg install x11-repo
```
Il faut aussi installer la librairie X11 avec la commande :
```shell
pkg install libx11
```
Il faut adapter le script de compilation  pour appeler la librairie x11 et charger la librairie dynamiquement :
```shell
#compilation assembleur X11
echo "Compilation 64 bits de "$1".s"
#pour la liste de compilation ajouter -a >$1"list.txt"
as -o $1".o"   $1".s" 
#pour la liste du linker ajouter --print-map >$1"map.txt"
ld -o $1 $1".o"  -e main -lX11 -L/data/data/com.termux/files/usr/lib -dynamic-linker /system/bin/linker64 -pie
ls -l $1* 
echo "Fin de compilation."
```
Pour préparer l’exécution il faut mettre dans le fichier .bashrc :
```shell
export PATH=$PATH:~/scripts:/data/data/com.termux/files/usr/lib:.
export LD_LIBRARY_PATH=$PREFIX/lib
export DISPLAY=192.168.1.15:0   en remplaçant l’adresse IP par celle de votre smartphone
```
Remarque : si vous préférez afficher les fenêtres sur votre PC avec un serveur X11 windows, ou linux, il faudra mettre l’adresse IP de votre PC.

Le programme d’affichage doit avoir les variables relogeables comme nous l’avons vu dans le chapitre d’accès au fonction C et doit respecter toutes les conventions.

Comme exemple, nous allons nous servir du programme fen1X1164.s qui affiche une fenêtre avec un rectangle gris.

Le programme reprend la routine d’affichage des messages et la macro d’affichage d’un libellé.

Le programme commence par appeler la fonction XopenDisplay qui va ouvrir la communication avec le serveur X.  Si le message serveur X non trouvé il faut vérifier si vous avez bien ouvert l’application Xserver sur votre smartphone puis vérifier les exports ci dessus.

C’est l ‘étape la plus cruciale !!!

Si le serveur X est trouvé, la fonction retourne dans le registre x0, l’adresse d’une structure appelée Display qui contient de nombreuses informations que nous verrons plus tard. Nous conservons cette adresse en mémoire et dans le registre x28 (Rappel les registres x0 à x18 ne sont pas sauvegardés lors des appels de fonctions externes).

Au déplacement 232 de cette structure, nous trouvons l’adresse d’une autre structure qui contient les informations sur l’écran  (screen). Pour l’exemple nous récupérons les informations de la valeur du pixel blanc, du pixel noir, du nombre de bits par pixels et l’adresse de la fenêtre racine.

Ces informations nous serviront dans d’autres programmes.

Puis nous passons à l’étape de création de notre propre fenêtre  avec la fonction XcreateSimpleWindow qui nécessite 9 paramètres :

* L’adresse du Display contenue dans x28
* l'adresse de la fenêtre parent récupérée dans x1 
* La position X de la fenêtre sur l’écran
* La position Y de la fenêtre sur l’écran
* la largeur
* la hauteur
* l’épaisseur de la bordure
* la couleur de la bordure
* et la couleur du fond 

Ce dernier paramètre doit être passé par la pile pour respecter les conventions d’appel.

Au retour de la fonction il nous faut réaligner la pile avec l’instruction
```asm
add sp,sp,16
```
et vérifier le code retour dans x0

S’il est différent de zéro, il contient l’identificateur de la fenêtre que nous conservons dans le registre x27

Ensuite nous affichons la fenêtre avec la fonction XmapWindow et nous autorisons les saisies dans cette fenêtre avec la fonction XSelectImput.

Le paramètre 5 est en fait la valeur binaire 0b101 soit les valeurs  keyPressedMask et buttonPressedMask qui autorisent la prise en compte des événements appui sur une touche et click de la souris.

Puis nous trouvons une boucle d’écoute des évènements qui touchent la fenêtre avec la fonction XnextEvent. Pour les 2 événements autorisés plus haut, nous affichons simplement le libellé « Evenement ».

Si vous avez respecté toutes les consignes précédentes, la compilation doit être ok et l’exécution aussi. Vous devez voir apparaître une fenêtre plus claire dans l’écran de l’application Xserver et si vous taper du doigt dans cette fenêtre vous devez voir le libellé apparaître dans la console.

Remarque : la barre système n’apparaît pas en haut de la fenêtre comme sur un Raspberry Pi. Je n’ai pas encore découvert pourquoi !! Donc il n’est pas possible de fermer la fenêtre, il faut donc faire un ctrl-C dans la console pour arrêter le programme.
 

Remarque : le linker n’utilise pas le fichier objet des routines précédentes  car il faut récrire les routines avec une gestion des adresses relogeables.

Image de l'écran xServer :

![xServer](https://github.com/vincentARM/AndroidAssembleur/blob/main/Chapitre004/X11/Screenshot_X%20Server1.jpg)

Le programme suivant pgm2X1164.s va afficher dans une fenêtre un pixel, une ligne, un rectangle, du texte et un bouton. L’appui sur ce bouton fera apparaître un texte dans la fenêtre.

Pour faire tout cela, nous rajoutons les constantes X11 nécessaires ainsi qu’un fichier contenant les structures (defStruct64.inc). Attention, jr ne vous garantit pas l’exactitude de toutes ces définitions car je les ai recréées à partir des descriptions pour le langage C.

J’ai récrit les routines du fichier routines64 pour qu’elles fonctionnent correctement avec les librairies dynamiques. J’ai appelé le fichier routines64Relo.s.


Après les habituelles descriptions des messages dans la .data et la réservation de places pour nos variables et structures, nous reprenons l’ouverture de la connexion au serveur x11 et la création de la fenêtre du programme précédent. 

Pour nous permettre des affichages différents, nous créons deux contextes graphiques dans la routine création GC. Un simple et un avec une police de caractère différente et de couleur différente.
Le chargement de la police ne semble pas exact. Je n’ai pas encore trouvé dans Termux comment avoir la liste des polices valides. Pour l’instant, la taille est trop petite pour être bien lisible.


Le dessin de pixel, ligne, rectangle et ne pose pas de difficulté car il suffit de respecter les paramètres à passer aux fonctions X11 de dessin.

L’écriture de texte fait appel à un calcul de la longueur préalable à l’aide de l’instruction 
```asm
 .equ LGTEXTEAFF, . -  szTexteAff
 ```
Vous remarquerez qu’il ne faut pas passer le 0 final à la fonction X11.

La création du bouton est un peu plus complexe. En effet, tout bouton est considéré comme une fenêtre et la création doit donc s’effectuer de la même façon : création, affichage, création d’un contexte graphique associé, autorisation des saisies écriture du titre du bouton.

Il nous faut aussi ajouter une action à exécuter lors de l ‘appui sur le bouton. Pour faciliter la gestion du bouton, toutes les informations le concernant sont stockées dans une structure.

Vous remarquerez que nous utilisons les registres x19,x20 x21 pour stocker les données principales car les fonctions X11 appelées respectent la norme et ne sauvegardent pas les registres x0 à x17 ce qui peut poser problème.

Ensuite nous modifions la gestion des événements car nous avons plusieurs événements à traiter : passage de la souris sur le bouton, sortie de la souris du bouton, clic sur le bouton, appui sur la touche q pour terminer proprement le programme.

Cette gestion fait appel à une structure événement qui est différente pour chaque événement.
Ici, nous utilisons le minimum des informations de la structure.

La gestion de la touche nécessite l’appel à la fonction XlookupString pour déterminer si la touche est un caractère ou une autre clé du clavier.
Pour terminer le programme, vous devez faire apparaître le clavier en cliquant sur le – en haut de la fenêtre du Xserver et en choisissant l’option keyboard. Dès que le clavier apparaît vous tapez sur q et sur <Entrée> et le programme doit se terminer.

