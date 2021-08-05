### Les structures.
Jusqu’à maintenant, nous avons vu des types de données simples mais en assembleur il est possible d’avoir des données de différent type rassemblées dans une structure.

Dans le programme struct64.s, nous définissons une structure client composé de 2 doubles de 8 octets, valeur1 et valeur2, d’un entier de 4 octets entier1 et d’un seul octet octet1.

Nous terminons la définition avec l’étiquette client_fin.

Attention, cette structure ne réserve aucun octet dans la mémoire. Elle permet simplement d’avoir le déplacement de chaque zone par rapport au début sans avoir à le calculer nous même.

Ainsi valeur1 aura un déplacement de 0, valeur2 un déplacement de 8, entier1 un déplacement de 16, octet1 un déplacement de 20 et l’étiquette client_fin un déplacement de 21 qui correspond à la taille de la structure.

Puis dans la .bss nous définissons un tableau de 10 enregistrements de type client qui aura donc une taille de client_fin 10 = 21 * 10 = 210 octets. Dans le corps du programme, nous allons initialiser le poste de rang 5.

nous mettons dans le registre x4 l’adresse du début du tableau, dans x1, le rang du poste et dans x2 la taille de l’enregistrement.
Nous calculons l’adresse de l’enregistrement en multipliant la taille par le rang et en l’ajoutant à l’adresse de début du tableau avec la seule instruction madd.

En effet ici nous ne pouvons pas utiliser l’instruction lsl pour calcul le déplacement car la taille du poste n’est pas une puissance de 2.
Ensuite nous stockons chaque valeur en utilisant comme base l’adresse calculé et comme déplacement, le nom que nous avons défini dans la structure !!

C’est beau !!

Il faut quand même faire attention de bien utiliser l’instruction str en fonction du type (par exemple strb pour stocker un octet sinon gare aux dégâts).

Nous affichons le contenu de la .bss contenant le tableau pour vérifier l’emplacement des données stockées. Sur mon système l’adresse du tableau est 0x410B00 auquel il faut ajouter 21 * 5 = 105 octets soit 69 en hexa ce qui donne l’adresse 0x410B69 et nous trouvons bien les données à cette adresse.

Remarque importante : dans cet exemple la structure a une longueur qui n’est pas un multiple de 8, ce qui fait que les données ne sont pas alignées ce qui peut entraîner des anomalies ou une baisse de performance. Il est donc nécessaire d’ajouter des octets de remplissage en fin de structure. 

Ici nous devrions ajouter 3 octets pour avoir une longueur de 24.
 
Nous continuons maintenant en affichant la valeur2 de ce poste.

Les structures seront souvent utilisées pour passer des paramètres complexes ou récupérer des données lors d’appels de fonctions de bibliothèques externes.

Voici un exemple de l’exécution :
```
Début programme.
stockage du rang 5
Aff mémoire  adresse : 0000000000410B00 Tableau client
0000000410B00*00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B60 00 00 00 00 00 00 00 00 00 23 01 00 00 00 00 00 .........#......
0000000410B70 00 56 04 00 00 00 00 00 00 FF FF FF FF 01 00 00 .V..............
0000000410B80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
0000000410B90 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
Chargement valeur du rang 5
Valeur2=
Affichage  hexadécimal : 0000000000000456
Fin normale du programme.
```
