# Chapitre  1 : installation des outils.

Préalables : 

Avoir un smartphone ou une tablette avec au minimum la version 7 d'Android (ou supérieure).

il vous faut connaître le minimum d’un environnement linux pour pouvoir travailler correctement :

```
      Créer et naviguer dans les répertoires.
      Gérer les fichiers et leurs droits d’accès.
      Saisir et modifier des fichiers textes.
      Gérer les connexions entre 2 ordinateurs.
      Installer des packages  linux.
      Un plus serait aussi la connaissance des appels système Linux.
      Etc Etc 
```

Il faut commencer par installer l’application Termux sur le smarphone ou la tablette disponible sur le Play Store ou sur le site https://termux.com/

(remarque 2021 : termux indique qu'il n'y aura pas de maj de la version sur le Play Store et qu'il faut télécharger l'application sur FDroid).

Sur le site (en anglais) récupérer et ou lire la documentation.

Lancer l’application, vous devez retrouver un environnement Linux avec les commandes linux habituelles (ls, cd, more etc.) et commencer par vérifier la version de Linux installée sur votre téléphone avec les commandes :
```
    uname -a 
    lscpu 
```
    
Suivant la version, vous pourrez programmer en assembleur 32 (armv6, v7, v8) ou 64 bits (aarch64) (attention les instructions sont sensiblement différentes).

Maintenant vérifier si le compilateur as et le linker ld sont bien installés en tapant simplement as ou ld. Si le compilateur ou le linker ne sont pas installés, installez le package binutils avec la commande :
```
   pkg install binutils 
```
Vous pouvez aussi installer d’autres packages pour disposer d’autres outils qui vous sont familiers.

Comme ce n’est pas facile de saisir un programme sur un téléphone, je vous conseille d’installer une connexion ssh pour vous connecter depuis windows (avec putty par exemple) ou depuis Linux.

Vous pouvez suivre la démarche expliquée sur ce [site :](https://glow.li/posts/run-an-ssh-server-on-your-android-with-termux/)

Attention, la connexion se fera exclusivement avec des clés privées et publiques (pas de saisie de mot de passe). Et sur putty par exemple un appui sur la touche entrée après l’établissement de la connexion, vous mettra dans le répertoire de travail de termux.

Comme éditeur, vous pouvez utiliser celui dont vous avez l’habitude.  En ce qui me concerne, j’utilise notepad++ avec la coloration syntaxique pour l’assembleur Arm et le greffon NppFTP qui permet après paramétrage de transférer les sources directement sur le téléphone.


Créer un répertoire pour les sources et utiliser ou créer un répertoire pour les scripts de compilation.

Voici un exemple du script de compilation à créer et à lancer par compil32 <nomdusource>  (sans l’extension .s). Ce script va créer un objet et un exécutable dans le même répertoire,  à lancer directement.

```shell
#compilation assembleur
echo "Compilation 32 bits de "$1".s"
as -o $1".o"   $1".s" -a >$1"list.txt"
ld -o $1 $1".o"  -e main --print-map >$1"map.txt"
ls -l $1*
echo "Fin de compilation."
```

Et c’est le même script pour le 64 bits :
      
```shell
#compilation assembleur
echo "Compilation 64 bits de "$1".s"
as -o $1".o"   $1".s" -a >$1"list.txt"
ld -o $1 $1".o"   -e main --print-map >$1"map.txt"
ls -l $1*  
echo "Fin de compilation."
```

Saisissez le petit programme pgm32_1.s (ou affText64.s pour le 64 bits) avec votre éditeur, sauvez le avec le nom pgm32_1.s, puis transférez le dans le répertoire que vous avez prévu sur le téléphone. Puis lancer la compilation en vous mettant dans le même répertoire par compil32 pgm32_1 ou compil64 affText64.

Corriger les erreurs de saisie éventuelles et lancer l’exécutable par pgm32_1 ou affText64.

Tout est ok ?  Vous êtes prêt pour la suite.

Rien ne fonctionne !! alors vous devez vérifier toutes les étapes précédentes.
      
Rappel des étapes de création d'un programme exécutable en assembleur :
      
      Saisir le programme source avec un éditeur de texte. Remarque : vérifier l'encodage du programme pour éviter des problèmes d'affichage des caractères accentués.
      
      Sauvegarder ce source avec l'extention .s
      
      Compiler le programme avec l'outil as. Vous pouvez vérifier le résultat de la compilation dans le fichier $1"list.txt" du script ci dessus.
       
          Cette étape tranforme chaque instruction du programme source en un code sur 4 octets (32 bits) compréhensible par le processeur
      
          Cette étape crée un programme objet : $1.o
      
          Vous pouvez aussi supprimer l'affichage de cette liste.

      Linker l'objet avec le linker ld. Vous pouvez vérifier le résultat dans le fichier $1"map.txt".
      
         Cette étape effectue tous les liens des différents modules et affecte des adresses mémoires aux sections .data .bss et .text.
      
         Elle crée un programme directement exécutable $1
      
         Vous pouvez aussi supprimer l'affichage de cette liste.

Si vous maîtrisez, les chaînes de compilation vous pouvez installer sur votre ordinateur préféré tout l’environnement ARM et transférer seulement l’exécutable sur le téléphone avec par exemple filezilla. (attention pensez à mettre les droits à 777 pour rendre le fichier exécutable).

Maintenant, il ne vous reste plus qu’à lire la documentation Termux, celle du compilateur as, du linker ld et la documentation de l’assembleur 32 bits Arm (ou 64 bits) disponible sur le site 
https://developer.arm.com/documentation/#sort=relevancy en fonction du processeur dont vous disposez sur votre téléphone.

La programmation sur Android est identique à celle utilisée pour les raspberry pi et donc vous pouvez vous inspirer soit de mon expérience :
      
https://assembleurarmpi.blogspot.com/2017/10/introduction.html
      
soit des sites comme celui ci :
      
https://thinkingeek.com/arm-assembler-raspberry-pi/


Ah !! mais vous voulez aussi utiliser une interface graphique pour afficher de belles images issues de vos programmes assembleur.
      
Alors il y a plusieurs solutions : soit vous voulez utiliser l’environnement graphique Android comme toutes les applications mais il faudra installer tout l’environnement de développement Android sur un ordinateur puis créer une application d’affichage java avec une interface en C avec votre programme Asm.
      
Je n’ai pas essayé cette solution mais voir sur internet un exemple :
      
https://www.eggwall.com/2011/09/android-arm-assembly-calling-assembly.html?m=1

Une autre solution consiste à utiliser l’environnement graphique X11 et à installer sur le téléphone une application serveur X11.  C’est ce que j’ai fait et je détaillerais les problèmes rencontrés.
      
Remarque : je pensais arrêter cette présentation au seul premier programme, mais emporté par mon élan, j'ai ecris un semblant de cours de programmation sur l'assembleur ARM. Ce cours écrit presqu'en temps réel est donc plein d'approximations ou même d'erreurs !! 
N 'hésitez pas à me les signaler.

 La partie 64 bits est plus complète que la partie 32 bits car je suppose que beaucoup de smatphones actuels disposent de processeurs arm 64 bits.

Chaque chapitre est accompagné de petits programmes, n'hesitez pas à les modifier (améliorer) pour vous perfectionner en assembleur.
      
