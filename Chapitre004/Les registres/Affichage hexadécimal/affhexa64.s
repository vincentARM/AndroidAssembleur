/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme affhexa64.s */
/* conversion et affichage en hexadécimal */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits
/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"
szMessAffHexa:     .asciz "Affichage  hexadécimal : "

/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
szZoneConvHexa:         .skip 17
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entry of program 
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    mov x0,0xFF
    bl afficherHexa
    mov x0,0x1234               // maj des 2 premiers octets
    movk x0,0x5678, lsl #16     // puis les 2 suivants
    movk x0,0x9012, lsl #32     // puis les 2 suivants
    movk x0,0x3456, lsl #48     // puis les 2 suivants
    bl afficherHexa
    
    movz x0,0x1234, lsl 32      // avec raz du registre
    bl afficherHexa
    
    ldr x0,qAdrszMessDebutPgm
    bl afficherHexa             // affichage de l'adresse de la chaine
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
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
/* x0 contient la valeur et x1 l'adresse de la zone de conversion   */
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

