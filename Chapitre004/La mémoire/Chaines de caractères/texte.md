### Chaînes de caractères 
Nous avons vu depuis le premier programme, des messages sous la forme de chaînes de caractères.

Et en fait une chaîne de caractères n’est qu’un tableau d’octets (donc chaque poste a une longueur de 1) terminé ou non par un zéro binaire.

Dans le premier programme, dans la routine d’affichage, vous avez un exemple de routine de balayage d’une chaîne pour calculer sa longueur.

Dans la routine d’affichage des zones mémoire, vous avez un exemple de copie d’un libellé dans une zone mémoire.

Donc il ne reste plus qu’à écrire toutes les autres routines concernant les chaînes de caractères : recherche d’un caractère, recherche d’une sous chaîne, concaténation, insertion d’un caractère insertion d’une sous chaîne, conversion minuscule, majuscule etc etc.

Dans le programme expchaine64.s, nous allons seulement voir la comparaison de 2 chaînes et l’insertion d’une sous chaîne à l’emplacement d’un caractère d’insertion.

Cette dernière routine sera utilisée pour insérer dans un message le résultat des conversions ce qui simplifiera l’affichage.

Commençons par la routine de comparaison :

Les adresses des 2 chaînes à comparer sont transmises à la routine dans les registres x0 et x1. Nous commençons par initialiser à zéro le registre x2 qui servira d’indice pour accéder à chaque octet des 2 chaînes.

Puis nous chargeons dans les registres x3 et x4 l’octet de même indice de chaque chaîne et nous les comparons.

Si l’un est plus petit ou plus grand nous positionnons dans x0 les valeurs -1 ou + 1 et nous allons à la fin de la routine.

S ‘ils sont égaux, nous testons si l’un est égal à zéro et si oui nous mettons 0 dans le registre x0 et allons à la fin de la routine sinon nous incrémentons l’indice et nous bouclons. 

Remarquez l’utilisation de l’instruction cbz w3,2f qui remplace les 2 instructions classiques :
```asm
cmp w3,#0
beq 2f
```
Cela économise une instruction !!!

Cette routine pouvant être utilisée ultérieurement par de nombreux programmes, nous sauvegardons les registres utilisés.

La routine insererChaineCar est un peu plus compliquée. En plus des 2 adresses des 2 chaînes concernées, nous devons lui passer un buffer pouvant contenir la totalité des 2 chaînes. Pour vérifier si l’insertion de la 2ième chaîne est possible il faut donc passer la longueur de ce buffer .

Dans la routine, nous commençons à calculer la longueur de chaque chaîne puis leur somme et à comparer à la longueur du buffer.

Remarquez ici aussi, l’utilisation de l’instruction cinc x6,x6,ne qui incrémente de 1 le registre x6 si le test précédent est différent de zéro (ne).

Si une des chaîne est nulle ou si leur somme est supérieure à la taille, nous terminons la routine avec une erreur (code négatif renvoyé dans le registre x0).

Ensuite nous recopions le début de la chaîne maître jusqu’à trouver le caractère d’insertion ; ici c’est un @ donné par la constante CHARPOS. Si nous ne le trouvons pas, nous retournons une erreur.

Puis à partir de la position de ce caractère, nous recopions dans le buffer la totalité de la chaîne à insérer et nous terminons en insérant dans le buffer la fin de la chaîne maître.

Dans le corps du programme, nous testons la routine de comparaison et différents cas de la routine d’insertion.

Nous terminons avec un exemple d’affichage du résultat d’une conversion. Comme nous sommes sûr que le buffer est plus grand que le résultat, nous ne testons pas le code erreur en retour ( c’est pas bien!!) et comme la routine retourne dans x0 l’adresse du buffer, nous appelons tout de suite la routine d’affichage.

Voici un exemple d’exécution :
```
Début programme.
Comparaison 1
Les chaines sont égales.
Comparaison 2
Les chaines ne sont pas égales.
Comparaison 3
Les chaines ne sont pas égales.
Exemple insertion :
Insertion chaine ici : AbcdE
Cas des chaines nulles :
Erreur :
Affichage  hexadécimal : FFFFFFFFFFFFFFFF
Erreur :
Affichage  hexadécimal : FFFFFFFFFFFFFFFE
Buffer trop petit :
Erreur :
Affichage  hexadécimal : FFFFFFFFFFFFFFFD
Cas conversion registre :
Valeur décimale du registre : 100
Fin normale du programme.
```
