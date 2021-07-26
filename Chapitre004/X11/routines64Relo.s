/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM              */
/* programme routines64.s */
/* routines générales  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

.equ NBCARLIBEL, 40      // longueur du titre
.equ LGZONEADR,  55
/*********************************/
/* Données initialisées              */
/*********************************/
.data
szRetourLigne:       .asciz "\n"
szMessAffHexa:       .asciz "Affichage  hexadécimal : "
szMessAffDec:        .asciz "Affichage décimal : "

/*  donnees pour vidage mémoire */
szVidregistreMem: .ascii "Aff mémoire "
sadr1: .ascii " adresse : "
sAdresseMem : .fill 17,1,' '
sSuiteMem: .fill NBCARLIBEL,1,' '
            .asciz "\n"
sDebmem: .fill 13, 1, ' '
s1mem: .ascii " "
sZone1: .fill 47, 1, ' '
s2mem: .ascii " "
sZone2: .fill 16, 1, ' '
s3mem: .asciz "\n"

/* données pour l'affichage des indicateurs d'état */
szLigneEtat:         .ascii "Etats "
adresseLibEtat:      .fill LGZONEADR, 1, ' '
szValeursEtat:       .asciz  "\nZ=   N=   C=   V=       \n"
/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
szZoneConvHexa:         .skip 17
szZoneConvDec:          .skip 22
szZoneConv:             .skip 20
/*********************************/
/*  code section                 */
/*********************************/
.text
.global afficherHexa,afficherDecimal,afficherDecimalS,conversion16,conversion2,conversion10,conversion10S,afficherMess
.global affmemoireTit,insererChaineCar,comparerChaines,afficherEtat

/******************************************************************/
/*     affichage registre en hexadécimal                     */ 
/******************************************************************/
/* r0 contient la valeur   */
afficherHexa:                  // afficherHexa
    stp x1,lr,[sp,-16]!        // save  registres
    stp x0,x2,[sp,-16]!           // save 1 registre
    adr x1,qOfszZoneConvHexa
    ldr x2,[x1]
    add x1,x1,x2
    bl conversion16            // conversion hexa de x0
    adr x0,qOfszMessAffHexa
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // affiche le titre
    adr x0,qOfszZoneConvHexa
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // affiche la zone de conversion
    adr x0,qOfszRetourLigne
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // et un retour à la ligne
    ldp x0,x2,[sp],16
    ldp x1,lr,[sp],16          // restaur registres
    ret
qOfszMessAffHexa:            .quad szMessAffHexa - .
qOfszRetourLigne:            .quad szRetourLigne - .
qOfszZoneConvHexa:           .quad szZoneConvHexa - .
/******************************************************************/
/*     affichage registre en décimal                     */ 
/******************************************************************/
/* r0 contient la valeur   */
afficherDecimal:               // afficherDecimal
    stp x1,lr,[sp,-16]!        // save  registres
    stp x0,x2,[sp,-16]!           // save 1 registre
    adr x1,qOfszZoneConvDec
    ldr x2,[x1]
    add x1,x1,x2
    bl conversion10            // conversion hexa de x0
    adr x0,qOfszMessAffDec
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // affiche le titre
    adr x0,qOfszZoneConvDec
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // affiche la zone de conversion
    adr x0,qOfszRetourLigne
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // et un retour à la ligne
    ldp x0,x2,[sp],16
    ldp x1,lr,[sp],16          // restaur registres
    ret
qOfszMessAffDec:            .quad szMessAffDec - .
qOfszZoneConvDec:           .quad szZoneConvDec - .
/******************************************************************/
/*     affichage registre en décimal                     */ 
/******************************************************************/
/* r0 contient la valeur   */
afficherDecimalS:                  // afficherDecimal
    stp x1,lr,[sp,-16]!        // save  registres
    stp x0,x2,[sp,-16]!           // save 1 registre
    adr x1,qOfszZoneConvDec
    ldr x2,[x1]
    add x1,x1,x2
    bl conversion10S            // conversion hexa de x0
    adr x0,qOfszMessAffDec
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // affiche le titre
    adr x0,qOfszZoneConvDec
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // affiche la zone de conversion
    adr x0,qOfszRetourLigne
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess            // et un retour à la ligne
    ldp x0,x2,[sp],16
    ldp x1,lr,[sp],16          // restaur registres
    ret
/******************************************************************/
/*     Conversion registre en hexadecimal                      */ 
/******************************************************************/
/* x0 contient la valeur et x1 l'adresse de la zone de conversion (longueur >= 17)  */
/* x0 retourne la longueur donc 16     */
conversion16:                  // INFO: conversion16
    str x1,[sp,-16]!
    stp x2,lr,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    mov x2,#60                 // position de départ
    mov x4,#0xF000000000000000 // masque
    mov x3,x0                  // save valeur d'entrée
1:                             // début de boucle
    and x0,x3,x4               // valeur du registre et du masque
    lsr x0,x0,x2               // deplacement droite
    cmp x0,#10                 // >= 10 ?
    bge 2f                     // oui
    add x0,x0,#48              // non c'est un chiffre
    b 3f
2:
    add x0,x0,#55              // sinon c'est une lettre A-F
3:
    strb w0,[x1],#1            // stocke le chiffre  et + 1 dans la pointeur
    lsr x4,x4,#4               // deplace le masque de  4 positions
    subs x2,x2,#4              // decrement compteur de 4 bits <= zero  ?
    bge 1b                     // non -> boucle
    mov x0,16                  // longueur 
    strb wzr,[x1]              // 0 final
100:                           // fin standard de la fonction
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x2,lr,[sp],16          // restaur des  2 registres
    ldr x1,[sp],16 
    ret    
/******************************************************************/
/*     conversion d'un registre 64 bits en binaire                 */ 
/******************************************************************/
/* x0 contient la valeur à afficher */
/* x1 contient l'adresse de la zone de conversion (longueur >= 65 )*/
/* x0 retourne la longueur donc 64 + 7 blancs  */
conversion2:                   // INFO: conversion2
    stp x2,lr,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    stp x5,x6,[sp,-16]!        // save  registres
    mov x2,63                  // position bit de départ
    mov x3,0                   // position écriture caractère
    mov x5,1                   // valeur pour tester un bit

1:                             // debut boucle
    lsl x6,x5,x2               // déplacement valeur de test à la position à tester
    tst x0,x6                  // test du bit à cette position
    bne 2f                     
    mov w4,#48                 // bit egal à zero -> caractère ascii '0'
    b 3f
2:
    mov w4,#49                 // bit egal à un -> caractère ascii '1'
3:
    strb w4,[x1,x3]            // caractère ascii ->  zone d'affichage
    sub x2,x2,#1               // decrement pour bit suivant
    add x3,x3,#1               // + 1 position affichage caractère
    and x4,x2,#7               // extraction 3 derniers bits du compteur
    cmp x4,#7                  // egaux à 111 ?
    bne 4f
    add x3,x3,#1               // oui on ajoute un blanc 
4:
    cmp x2,#0                  // 64 bits analysés ?
    bge 1b                     // non -> boucle
    mov x0,71                  // retourne la longueur (sans le 0 final)
    strb wzr,[x1,x0]           // met le 0 final
100:                           // fin standard de la fonction
    ldp x5,x6,[sp],16          // restaur des  2 registres
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x2,lr,[sp],16          // restaur des  2 registres
    ret    
/***************************************************/
/*   Conversion d'un registre en décimal non signé  */
/***************************************************/
/* x0 contient le registre   */
/* x1 contient l'adresse de la zone de conversion longueur >= 21 octets */
.equ LGZONE, 20
conversion10:                  // INFO: conversion10
    stp x2,lr,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    mov x3,#0
    strb w3,[x1,#LGZONE+1]     // stocke le 0 final
    mov x4,#LGZONE
    mov x3,#10                 // conversion decimale
1:                             // debut de boucle de conversion
    mov x2,x0                  // copie nombre départ ou quotients successifs
    udiv x0,x2,x3              // division par le facteur de conversion
    msub x2,x0,x3,x2            // calcul du reste de la division 
    add x2,x2,#48              // car c'est un chiffre
    strb w2,[x1,x4]            // stockage du byte au debut zone (x1) + la position (x4)
    sub x4,x4,#1               // position précedente
    cmp x0,#0                  // arret si quotient est égale à zero
    bne 1b    
                               // mais il faut déplacer le résultat en début de zone
    adds x4,x4,#1              // début du résultat
    beq 90f                    // donc fin 
    mov x2,#0                  // indice début zone
2:                             // boucle de déplacement
    ldrb w3,[x1,x4]            // charge un octet du résultat
    strb w3,[x1,x2]            // et le stocke au début
    add x2,x2,#1                  // incremente la position de stockage
    add x4,x4,#1               // incremente la position de chargement
    cmp x4,#LGZONE + 1         // c'est la fin ??
    ble 2b                     // boucle si x4 <= longueur zone (y compris le 0 final)
    sub x0,x2,#1               // retourne la longueur du résultat (sans le zéro final)
    b 100f
90:
    mov x0,#LGZONE           // si début = 0 la zone est compléte
100:
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x2,lr,[sp],16          // restaur des  2 registres
    ret

/******************************************************************/
/*     conversion décimale signée                             */ 
/******************************************************************/
/* x0 contient la valeur à convertir  */
/* x1 contient la zone receptrice  longueur >= 21 */
/* la zone recptrice contiendra la chaine ascii cadrée à gauche */
/* et avec un zero final */
/* x0 retourne la longueur de la chaine sans le zero */
.equ LGZONECONV,   21
conversion10S:
    stp x5,lr,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    cmp x0,0
    bge 11f
    mov x3,'-'
    neg x0,x0                  // inverse le nombre si négatif
    b 12f
11:
    mov x3,'+'
12:
    strb w3,[x1]
    mov x4,#LGZONECONV         // position dernier chiffre
    mov x5,#10                 // conversion decimale
1:                             // debut de boucle de conversion
    mov x2,x0                  // copie nombre départ ou quotients successifs
    udiv x0,x2,x5              // division par le facteur de conversion
    msub x3,x0,x5,x2           //calcul reste
    add x3,x3,#48              // car c'est un chiffre
    sub x4,x4,#1               // position précedente
    strb w3,[x1,x4]            // stockage du chiffre
    cbnz x0,1b                 // arret si quotient est égale à zero
    mov x2,LGZONECONV          // calcul longueur de la chaine (21 - dernière position)
    sub x0,x2,x4               // car pas d'instruction rsb en 64 bits
                               // mais il faut déplacer la zone au début
    cmp x4,1
    beq 3f                     // si pas complète
    mov x2,1                   // position début  
2:    
    ldrb w3,[x1,x4]            // chargement d'un chiffre
    strb w3,[x1,x2]            // et stockage au debut
    add x4,x4,#1               // position suivante
    add x2,x2,#1               // et postion suivante début
    cmp x4,LGZONECONV - 1      // fin ?
    ble 2b                     // sinon boucle
3: 
    mov w3,0
    strb w3,[x1,x2]            // zero final
    add x0,x0,1                // longueur chaine doit tenir compte du signe
100:
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x5,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30
    
/*******************************************/    
/* affichage zone memoire                  */
/*******************************************/    
/* x0  adresse memoire  x1 nombre de bloc x2 titre */
affmemoireTit:
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    stp x5,x6,[sp,-16]!        // save  registres
    stp x7,x8,[sp,-16]!        // save  registres
    mov x4,x0                  // save adresse mémoire
    mov x6,x1                  // save nombre de bloc
    adr x1,qOfsAdresseMem     //adresse de stockage du resultat
    ldr x3,[x1]
    add x1,x1,x3
    bl conversion16            // conversion en base 16
    mov x3,' '                 // remplacer le 0 final par un blanc
    strb w3,[x1,x0]
                               // recup libelle dans x2
    mov x7,#0
    adr x5,qOfsAdresse_suiteMem // adresse de stockage du resultat
    ldr x3,[x5]
    add x5,x5,x3
1:                               // boucle copie
    ldrb w3,[x2,x7]
    cbz w3,2f
    beq 2f
    strb w3,[x5,x7]
    add x7,x7,#1
    cmp x7,NBCARLIBEL
    ble 1b
2:
    mov w3,#' '                 // on met des blancs en fin de libellé 
3:                              // pour effacer libellé précédent si plus grand
    cmp x7,#NBCARLIBEL
    bge 4f
    strb w3,[x5,x7]
    add x7,x7,#1
    b 3b                         // et boucle
4:
    mov x2,x4                        //récuperation debut memoire a afficher
    adr x0,qOfsAdresse_chaineMem    // affichage entete
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
                                     //calcul du debut du bloc de 16 octets
    mov x1, x2, LSR #4               // x1 ← (x2/16)
    mov x1, x1, LSL #4               // x1 ← (x2*16)
    /* mettre une étoile à la position de l'adresse demandée*/
    mov x8,#3                       // 3 caractères pour chaque octet affichée 
    sub x0,x2,x1                    // calcul du deplacement dans le bloc de 16 octets
    mul x5,x0,x8                    // deplacement * par le nombre de caractères
    adr x0,qOfsAdresse_zone1       // adresse de stockage
    ldr x7,[x0]
    add x0,x0,x7
    add x7,x0,x5                    // calcul de la position
    sub x7,x7,#1                    // on enleve 1 pour se mettre avant le caractère
    mov w0,#'*'           
    strb w0,[x7]                    // stockage de l'étoile
    
5:              // 3                    // debut boucle affichage des blocs
    mov x5,x1                       // afficher le debut  soit x1
    mov x0,x1
    adr x1,qOfszZoneConv           // conversion adresse du bloc en hexa
    ldr x2,[x1]
    add x1,x1,x2
    bl conversion16                 // conversion en base 16
    mov x8,' '
    strb w8,[x1,x0]
                                    // recopie de 12 caractères de l'adresse
    mov x8,#3                       // pour supprimer les 4 premiers zeros
    mov x0,#0
    adr x1,qOfszZoneConv
    ldr x2,[x1]
    add x1,x1,x2
    adr x2,qOfsAdresse_debmem     // et mettre le résultat dans la zone d'affichage
    ldr x4,[x2]
    add x2,x2,x4
6:
    ldrb w4,[x1,x8]
    strb w4,[x2,x0]
    add x0,x0,#1
    add x8,x8,#1
    cmp x8,#15                     // arrêt au 15ième caractère
    ble 6b
                                   // balayer 16 octets de la memoire
    mov x8,#3
    mov x2,#0
    mov x1,x5
    
7:          //4                       // debut de boucle de vidage par bloc de 16 octets
    ldrb w4,[x1,x2]                // recuperation du byte à l'adresse début + le compteur
                                   // conversion byte pour affichage
    adr x0,qOfsAdresse_zone1      // adresse de stockage du resultat
    ldr x3,[x0]
    add x0,x0,x3
    mul x5,x2,x8                   // calcul position x5 <- x2 * 3 
    add x0,x0,x5
    mov x3, x4, ASR #4             // x3 ← (x4/16)
    cmp x3,#9                      // inferieur a 10 ?
    bgt 8f
    add x5,x3,#48                  // oui
    b 9f
8:
    add x5,x3,#55                  // c'est une lettre en hexa
9:
    strb w5,[x0]                  // on le stocke au premier caractères de la position 
    add x0,x0,#1                  // 2ième caractere
    mov x5,x3,LSL #4              // x5 <- (x4*16)
    sub x3,x4,x5                  // pour calculer le reste de la division par 16
    cmp x3,#9                     // inferieur a 10 ?
    bgt 10f
    add x5,x3,#48
    b 11f
10:
    add x5,x3,#55
11:
    strb w5,[x0]                  // stockage du deuxieme caractere
    add x2,x2,#1                  // +1 dans le compteur
    cmp x2,#16                    // fin du bloc de 16 caractères ?
    blt 7b
                  /* affichage en caractères */
    mov x2,#0                     // compteur
12:                                // debut de boucle
    ldrb w4,[x1,x2]               // recuperation du byte à l'adresse début + le compteur
    cmp w4,#31                    // compris dans la zone des caractères imprimables ?
    ble 13f                        // non
    cmp w4,#125
    ble 14f
13:
    mov w4,#46                    // on force le caractere .
14:
    adr x0,qOfsAdresse_zone2     // adresse de stockage du resultat
    ldr x3,[x0]
    add x0,x0,x3
    add x0,x0,x2
    strb w4,[x0]
    add x2,x2,#1
    cmp x2,#16                    // fin de bloc ?
    blt 12b    

    /* affichage resultats */
    adr x0,qOfsAdresse_debmem
    ldr x3,[x0]
    add x0,x0,x3
    bl afficherMess
    mov w0,#' '
    strb w0,[x7]                 // on enleve l'étoile pour les autres lignes
    add x1,x1,#16                // adresse du bloc suivant de 16 caractères
    subs x6,x6,#1                // moins 1 au compteur de blocs
    bgt 5b                       // boucle si reste des bloc à afficher
100:                           // fin de la fonction
    ldp x7,x8,[sp],16          // restaur des  2 registres
    ldp x5,x6,[sp],16          // restaur des  2 registres
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30

qOfsAdresse_chaineMem:        .quad szVidregistreMem - .
qOfsAdresse_debmem:           .quad sDebmem - .
qOfsAdresse_suiteMem:         .quad sSuiteMem - .
qOfsAdresse_zone1:            .quad sZone1 - .
qOfsAdresse_zone2:            .quad sZone2 - .
qOfsAdresseMem:               .quad sAdresseMem - .
qOfszZoneConv:                .quad szZoneConv - .

/******************************************************************/
/*     affichage texte avec calcul de la longueur                */ 
/******************************************************************/
/* x0 contient l' adresse du message */
afficherMess:                  // INFO: afficherMess
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    str x8,[sp,-16]!           // save registre
    mov x2,#0                  // compteur taille
1:                             // boucle calcul longueur chaine
    ldrb w1,[x0,x2]            // lecture un octet
    cmp w1,#0                  // fin de chaine si zéro
    beq 2f
    add x2,x2,#1               // incremente compteur
    b 1b
2:
    mov x1,x0                  // adresse du texte
    mov x0,#STDOUT             // sortie Linux standard
    mov x8,#WRITE              // code call system "write"
    svc #0                     // call systeme Linux
    ldr x8,[sp],16             // restaur registre
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30
/************************************/       
/* comparaison de chaines           */
/************************************/      
/* x0 et x1 contiennent les adresses des chaines */
/* retour 0 dans x0 si egalite */
/* retour -1 si chaine x0 < chaine x1 */
/* retour 1  si chaine x0> chaine x1 */
comparerChaines:              // INFO: comparaison
    stp x2,lr,[sp,-16]!   // save registres
    stp x3,x4,[sp,-16]!   // save registres
    mov x2,#0             // indice
1:    
    ldrb w3,[x0,x2]       // octet chaine 1
    ldrb w4,[x1,x2]       // octet chaine 2
    cmp w3,w4
    blt 3f                // plus petite
    bgt 4f                // plus grande
    cbz w3,2f             // si egalite test si fin de chaine
    add x2,x2,#1          // sinon plus 1 dans indice
    b 1b                  // et boucle
2:
    mov x0,#0             // egalite
    b 100f
3:
    mov x0,#-1            // plus petite
    b 100f
4:
    mov x0,#1             // plus grande
100:
    ldp x3,x4,[sp],16     // restaur registres
    ldp x2,lr,[sp],16     // restaur registres
    ret
/******************************************************************/
/*   insertion d'une sous chaine à la place du caractère //        */ 
/******************************************************************/
/* x0 contient adresse de la chaine maitre */
/* x1 contient l'adresse de la chaine à insérer  */
/* x2 contient l'adresse d'un buffer de taille suffisante  */
/* x3 contient la taille de ce buffer   */
.equ CHARPOS,     '@'
insererChaineCar:
    stp x2,lr,[sp,-16]!   // save registres
    stp x3,x4,[sp,-16]!   // save registres
    stp x5,x6,[sp,-16]!   // save registres
    mov x6,#0                   // compteur de longueur chaine 1
1:                              // calcule la longueur de la chaine 1
    ldrb w4,[x0,x6]
    cmp w4,#0
    cinc  x6,x6,ne              // incremente le compteur si pas fini
    bne 1b                      // boucle si pas fini
    cmp x6,#0                   // chaine nulle ?
    beq 99f                     // erreur
    mov x5,#0                   // compteur de longueur chaine à inserer 
2:                              // calcul de la longueur
    ldrb w4,[x1,x5]
    cmp w4,#0
    cinc  x5,x5,ne              // incremente le compteur si pas fini
    bne 2b                      // boucle si pas fini
    cmp x5,#0                   // chaine vide ?
    beq 98f
    add x5,x5,x6                // addition des 2 longueurs
    add x5,x5,#1                // + 1 pour le zéro final
    cmp x5,x3                   // plus grande que la taille du buffer ?
    bgt 97f

 
    mov x5,#0
    mov x4,#0
3:                              // boucle de copie du début de la chaine
    ldrb w3,[x0,x5] 
    cmp w3,#0                   // fin de la chaine 1 ?
    beq 96f
    cmp w3,#CHARPOS             // caractère d'insertion ?
    beq 5f                      // oui
    strb w3,[x2,x4]             // sinon stocke le caractère dans le buffer
    add x5,x5,#1
    add x4,x4,#1
    b 3b                        // et boucle
5:                              // x4 contient la position du caractère d'insertion
    add x5,x4,#1                // init indice position insertion buffer + 1
    mov x3,#0                   // indice de chargement de la chaine d'insertion
6:
    ldrb w6,[x1,x3]             // charge un caractère de la chaine d'insertion
    cbz w6,7f                   // fin de chaine ?
    strb w6,[x2,x4]             // sinon stocke le caractère à la bonne position dans le buffer 
    add x3,x3,#1                // incremente l'indice
    add x4,x4,#1                // incremente l'indice du buffer
    b 6b                        // et boucle 
7:                              // boucle de copie de la fin de la chaine maitre 
    ldrb w6,[x0,x5]             // charge un caractère de la chaine maitre
    strb w6,[x2,x4]             // et le stocke dans le buffer
    cbz w6,8f                   // fin de la chaine maitre ?
    add x4,x4,#1                // incremente l'indice du buffer
    add x5,x5,#1                // incremente l'indice
    b 7b                        // et boucle
8:
    mov x0,x2                   // retourne l'adresse de début du buffer
    b 100f
96:
    mov x0,-4                   // erreur détectée : pas de caractère d'insertion
    b 100f
97:
    mov x0,-3                   // erreur détectée : buffer trop petit
    b 100f
98:
    mov x0,-2                   // erreur détectée : chaine 2 nulle
    b 100f
99:
    mov x0,-1                   // erreur détectée : chaine 1 nulle
100:
    ldp x5,x6,[sp],16     // restaur registres
    ldp x3,x4,[sp],16     // restaur registres
    ldp x2,lr,[sp],16     // restaur registres
    ret
/***************************************************/
/*   affichage des indicateurs du registre d'état     */
/***************************************************/
/* x0 contient l'adresse du titre à afficher */
afficherEtat:
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    mrs x4,nzcv                // save du registre d'état
    adr x3,qOfadresseLibEtat  // adresse de stockage du resultat
    ldr x2,[x3]
    add x3,x3,x2
    mov x2,#0
1:                             // boucle copie
    ldrb w1,[x0,x2]            // charge un octet
    cbz  w1,2f                 // zéro ?
    strb w1,[x3,x2]            // stocke dans zone affichage
    add x2,x2,#1               // increment indice
    cmp x2,#LGZONEADR          // longueur maxi ?
    ble 1b                     // non -> boucle
    b 4f
2:
    mov w1,#' '                 // on met des blancs en fin de libellé 
3:                              // pour effacer libellé précédent si plus grand
    cmp x2,#LGZONEADR
    bge 4f
    strb w1,[x3,x2]
    add x2,x2,#1
    b 3b                         // et boucle
4:
    adr x1,qOfszValeursEtat
    ldr x2,[x1]
    add x1,x1,x2
    mov x2,49                   // 1
    mov x3,48                   // 0
    msr nzcv,x4                 // restaur registre d'état
    csel x0,x2,x3,eq            // si indicateur Z = 0 alors x0 = 49 sinon 48
    strb w0,[x1,#3]
    csel x0,x2,x3,mi            // indicateur négatif 
    strb w0,[x1,#8]
    csel x0,x2,x3,vs            // indicateur overflow
    strb w0,[x1,#18]
    csel x0,x2,x3,cs            // indicateur carry
    strb w0,[x1,#13]

    adr x0,qOfszLigneEtat     // affiche le résultat
    ldr x2,[x0]
    add x0,x0,x2
    bl afficherMess
 
100:
    msr nzcv,x4                // restaur registre d'état
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret    
qOfszLigneEtat:       .quad szLigneEtat - .
qOfadresseLibEtat:    .quad adresseLibEtat - .
qOfszValeursEtat:     .quad szValeursEtat - .
    