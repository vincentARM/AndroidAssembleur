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
/*********************************/
/* Données initialisées              */
/*********************************/
.data
szRetourLigne:       .asciz "\n"
szMessAffHexa:       .asciz "Affichage  hexadécimal : "
szMessAffDec:        .asciz "Affichage décimal : "
/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
szZoneConvHexa:         .skip 17
szZoneConvDec:          .skip 22
/*********************************/
/*  code section                 */
/*********************************/
.text
.global afficherHexa,afficherDecimal,afficherDecimalS,conversion16,conversion2,conversion10,conversion10S,afficherMess

/******************************************************************/
/*     affichage registre en hexadécimal                     */ 
/******************************************************************/
/* r0 contient la valeur   */
afficherHexa:                  // afficherHexa
    stp x1,lr,[sp,-16]!        // save  registres
    str x0,[sp,-16]!           // save 1 registre
    ldr x1,qAdrszZoneConvHexa
    bl conversion16            // conversion hexa de x0
    ldr x0,qAdrszMessAffHexa
    bl afficherMess            // affiche le titre
    ldr x0,qAdrszZoneConvHexa
    bl afficherMess            // affiche la zone de conversion
    ldr x0,qAdrszRetourLigne
    bl afficherMess            // et un retour à la ligne
    ldr x0,[sp],16
    ldp x1,lr,[sp],16          // restaur registres
    ret
qAdrszMessAffHexa:            .quad szMessAffHexa
qAdrszRetourLigne:            .quad szRetourLigne
qAdrszZoneConvHexa:           .quad szZoneConvHexa
/******************************************************************/
/*     affichage registre en décimal                     */ 
/******************************************************************/
/* r0 contient la valeur   */
afficherDecimal:                  // afficherDecimal
    stp x1,lr,[sp,-16]!        // save  registres
    str x0,[sp,-16]!           // save 1 registre
    ldr x1,qAdrszZoneConvDec
    bl conversion10            // conversion hexa de x0
    ldr x0,qAdrszMessAffDec
    bl afficherMess            // affiche le titre
    ldr x0,qAdrszZoneConvDec
    bl afficherMess            // affiche la zone de conversion
    ldr x0,qAdrszRetourLigne
    bl afficherMess            // et un retour à la ligne
    ldr x0,[sp],16
    ldp x1,lr,[sp],16          // restaur registres
    ret
qAdrszMessAffDec:            .quad szMessAffDec
qAdrszZoneConvDec:           .quad szZoneConvDec
/******************************************************************/
/*     affichage registre en décimal                     */ 
/******************************************************************/
/* r0 contient la valeur   */
afficherDecimalS:                  // afficherDecimal
    stp x1,lr,[sp,-16]!        // save  registres
    str x0,[sp,-16]!           // save 1 registre
    ldr x1,qAdrszZoneConvDec
    bl conversion10S            // conversion hexa de x0
    ldr x0,qAdrszMessAffDec
    bl afficherMess            // affiche le titre
    ldr x0,qAdrszZoneConvDec
    bl afficherMess            // affiche la zone de conversion
    ldr x0,qAdrszRetourLigne
    bl afficherMess            // et un retour à la ligne
    ldr x0,[sp],16
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
    