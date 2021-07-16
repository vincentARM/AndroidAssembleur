/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme appelFonctC64.s */
/* appel à des fonctions du langage C */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

/****************************************************/
/* fichier des macros                               */
/****************************************************/
.include "../ficmacros64.inc"


/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

szFormat1:           .asciz "Valeur = %d \n"

szFormat2:           .asciz "Valeur = %d %d %d %d %d %d %d %d %d\n"

szFormat3:           .asciz "Valeur = %d %d %d %d %d %d %d %d \n"

szFormat4:           .asciz "Valeur = %d %d %d %d %d %d %d %d %d %d %d\n"

.align 8


/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    adr x0,qOfszMessDebutPgm
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    
    afficherLib "Appel 1 "
    adr x0,qOfszFormat1
    ldr x1,[x0]
    add x0,x0,x1
    mov x1,#5
    bl printf

    afficherLib "Appel 2 "
    adr x0,qOfszFormat2
    ldr x1,[x0]
    add x0,x0,x1
    mov x1,#1
    mov x2,#2
    mov x3,#3
    mov x4,#4
    mov x5,#5
    mov x6,#6
    mov x7,#7
    mov x8,#8
    bl printf
    
    afficherLib "Appel 3 "
    adr x0,qOfszFormat2
    ldr x1,[x0]
    add x0,x0,x1
    mov x1,#1
    mov x2,#2
    mov x3,#3
    mov x4,#4
    mov x5,#5
    mov x6,#6
    mov x7,#7
    mov x8,#8
    mov x9,#9
    stp x8,x9,[sp,-16]!
    bl printf
    add sp,sp,16
    
    afficherLib "Appel 4 "
    adr x0,qOfszFormat3
    ldr x1,[x0]
    add x0,x0,x1
    mov x1,#1
    mov x2,#2
    mov x3,#3
    mov x4,#4
    mov x5,#5
    mov x6,#6
    mov x7,#7
    mov x8,#10
    mov x9,#11
    str x8,[sp,-16]!
    bl printf
    add sp,sp,16
    
    afficherLib "Appel 5 "
    adr x0,qOfszFormat4
    ldr x1,[x0]
    add x0,x0,x1
    mov x1,#1
    mov x2,#2
    mov x3,#3
    mov x4,#4
    mov x5,#5
    mov x6,#6
    mov x7,#7
    mov x8,#8
    mov x9,#9
    mov x10,#10
    mov x11,#11
    stp x8,x9,[sp,-16]!
    stp x10,x11,[sp,-16]!
    bl printf
    add sp,sp,16
    
    adr x0,qOfszMessFinPgm
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0

qOfszFormat1:          .quad szFormat1 - .
qOfszFormat2:          .quad szFormat2 - .
qOfszFormat3:          .quad szFormat3 - .
qOfszFormat4:          .quad szFormat4 - .
qOfszMessDebutPgm:     .quad szMessDebutPgm - .
qOfszMessFinPgm:       .quad szMessFinPgm - .
qOfszRetourLigne:      .quad szRetourLigne - .

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


    
 