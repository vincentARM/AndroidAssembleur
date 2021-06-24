### Les structures.

Jusqu’à maintenant, nous avons vu des types de données simples mais en assembleur il est possible d’avoir des données de différent type rassemblées dans une structure.

Dans le programme struct32.s, nous définissons une structure client composé de 2 entiers de 4 octets, valeur1 et valeur2 et d’un seul octet octet1.

Nous terminons la définition avec l’étiquette client_fin :

Attention, cette structure ne réserve aucun octet dans la mémoire. Elle permet simplement d’avoir le déplacement de chaque zone par rapport au début sans avoir à le calculer nous même.

Ainsi valeur1 aura un déplacement de 0, valeur2 un déplacement de 4, octet1 un déplacement de 8 et l’étiquette client_fin un déplacement de 9 qui correspond à la taille de la structure.

Puis dans la .bss nous définissons un tableau de 10 enregistrements de type client  qui aura donc une taille de client_fin 10 = 9 * 10 = 90 octets.
Dans le corps du programme, nous allons initialiser le poste de rang 5.

nous mettons dans le registre r4 l’adresse du début du tableau, dans r1, le rang du poste et dans r2 la taille de l’enregistrement. 

Nous calculons l’adresse de l’enregistrement en multipliant la taille par le rang et en l’ajoutant à l’adresse de début du tableau avec la seule instruction mla.

En effet ici nous ne pouvons pas utiliser l’instruction lsl pour calcul le déplacement car la taille du poste n’est pas une puissance de 2.

Ensuite nous stockons chaque valeur en utilisant comme base l’adresse calculé et comme déplacement, le nom que nous avons défini dans la structure !!

C’est beau !!

Il faut quand même faire attention de bien utiliser l’instruction str en fonction du type (par exemple strb pour stocker un octet sinon gare au dégât).

Nous affichons le contenu de la .bss contenant le tableau pour vérifier l’emplacement des données stockées. Sur mon système l’adresse du tableau est 0x206EB auquel il faut ajouter 9 * 5 = 45 octets soit 2D en hexa ce qui donne l’adresse 0x20718 et nous trouvons bien les données à cette adresse.

Nous continuons maintenant en affichant la valeur2 de ce poste.

Les structures seront souvent utilisées pour passer des paramètres complexes ou récupérer des données lors d’appels de fonctions de bibliothèques externes.

Voici un exemple de l’exécution :
```
Début du programme 32 bits.
stockage du rang 5
Aff mémoire  adresse : 000206EB  Tableau client
000206E0  20 20 20 20 20 20 20 20 20 0A 00*00 00 00 00 00           .......
000206F0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00020700  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00020710  00 00 00 00 00 00 00 00 23 01 00 00 56 04 00 00  ........#...V...
00020720  01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00020730  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00020740  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00020750  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00020760  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00020770  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
Chargement valeur du rang 5
Valeur2= : Valeur hexa du registre : 00000456
Fin normale du programme.
```
