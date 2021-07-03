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
szMessAffHexa:     .asciz "Affichage  hexadécimal : "

/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
szZoneConvHexa:         .skip 17
/*********************************/
/*  code section                 */
/*********************************/
.text
.global afficherHexa,conversion16,conversion2,afficherMess

/******************************************************************/
/*     affichage registre en hexadécimal                     */ 
/******************************************************************/
/* r0 contient la valeur   */
afficherHexa:
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
/*     Conversion registre en hexadecimal                      */ 
/******************************************************************/
/* x0 contient la valeur et x1 l'adresse de la zone de conversion (longueur >= 17)  */
/* x0 retourne la longueur donc 16     */
conversion16:
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
100:                           // fin standard de la fonction
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x2,lr,[sp],16          // restaur des  2 registres
    ret    
/******************************************************************/
/*     conversion d'un registre 64 bits en binaire                 */ 
/******************************************************************/
/* x0 contient la valeur à afficher */
/* x1 contient l'adresse de la zone de conversion (longueur >= 65 )*/
/* x0 retourne la longueur donc 64 + 7 blancs  */
conversion2:               
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
    strb wzr,[x1,x0]
100:                           // fin standard de la fonction
    ldp x5,x6,[sp],16          // restaur des  2 registres
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x2,lr,[sp],16          // restaur des  2 registres
    ret    

/******************************************************************/
/*     affichage texte avec calcul de la longueur                */ 
/******************************************************************/
/* x0 contient l' adresse du message */
afficherMess:
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
    