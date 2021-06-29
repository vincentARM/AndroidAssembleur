### Dessiner avec X11

En assembleur, il n’y a a aucune instruction pour gérer des graphismes. Nous somme obligés d »appeler des fonctions de librairies externes.

Pour afficher des dessins sous andoid, il existe plusieurs solutions : une consiste à écrire une interface en C entre le programme assembleur et les fonctions Java propores à Android pour créer une application Android.
Le problème est qu’il faut installer tout le kit de développement Android sur un ordinateur !!

Vous trouverez la démarche de cette solution sur le site :

Une autre solution est d’utiliser X11 bibliothèque lourde d’utilisation mais c’est un standard sous Unix et donc sous Linux. Il s’agit d’une solution client-serveur et donc il faudra installer une application serveur X11 sur Android. 
J’en ai essayé plusieurs mais la seule que j’ai réussi à faire fonctionner correctement est .Xserver disponible sur playstore..

Pour pouvoir utiliser X11 il faut charger dans la console Termux le package x11-repo
```
pkg install x11-repo
```

Il faut adapter le script de compilation  pour appeler la librairie x11 et charger la librairie dynamique :
```shell
#compilation assembleur
#echo $0,$1
echo "Compilation 32 bits de "$1".s"
as -o $1".o"   $1".s"  -mfpu=vfp -mfloat-abi=hard  -a >listing.txt
#gcc -o $1 $1".o"  -e main
ld -o $1 $1".o"~/asm32/routines32And.o -e main -lX11 -L/data/data/com.termux/files/usr/lib -ldl -lc -dynamic-linker /system/bin/linker -pie /data/data/com.termux/files/usr/lib/libX11.so
ls -l $1*  
echo "Fin de compilation."
```
Pour préparer l’exécution il faut mettre dans le fichier .bashrc :
```shell
export PATH=$PATH:~/scripts:/data/data/com.termux/files/usr/lib:.
export LD_LIBRARY_PATH=$PREFIX/lib
export DISPLAY=192.168.1.15:0   en remplaçant l’adresse IP par celle de votre smarphone
```
Remarque : si vous préférez afficher les fenêtres sur votre PC avec un serveur X11 windows, ou linux, il faudra mettre l’adresse IP de votre PC.

Le programme d’affichage doit avoir les variables relogeables comme nous l’avons vu dans le chapitre d’accès au fonction C et doit respecter toutes les conventions.

Comme exemple, nous allons nous servir du programme Fen1X1132 qui affiche une fenêtre avec un rectangle gris. Je ne détaillerai pas les instructions du programme. Vous pouvez lire les commentaires et lire aussi en premier la documentation X11.

Mettre le fichier constantesARM.inc et descStruct.inc dans un répertoire de niveau supérieur à celui du programme. Vérifier que votre fichier objet des routines soit aussi à ce niveau.

Si la compilation est bonne, vous devez lancer l’application Xserver (ou une autre) sur Android et lancer l’exécution du programme.

Si vous avez le message Serveur X non trouvé. Vous devez vérifier que l’application serveur X11 est bien lancée et bien paramétrée si necessaire. Vérifiez si vous avez bien fait l’export avec la bonne adresse IP de votre smartphone Android.

Pour fermer la fenêtre, vous devez passer en mode clavier et saisir q pour quitter.
Vous pouvez aussi faire un ctrl-C dans la console !!

Bon courage.
