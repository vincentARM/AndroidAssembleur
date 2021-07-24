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
