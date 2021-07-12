/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme testmacromen64.s */
/* test macro affichage des zones mémoire 64 bits  */

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
szTitre1:            .asciz "Affichage zones"



bOctet1:              .byte 5            // définit un octet de valeur 5
.align 2
hDemiMot1:            .hword 0x1234      // définit un demi mot (2 octets)
.align 4
iEntier1:             .int  0x12345678   // définit un entier de 4 octets

.align 8
qValeur1:            .quad 0x1234567890123456  // définit un double mot de 8 octets
qValeurNeg:          .int -1
tabValeurs:          .quad 1,2,3,4,5,6,7,8     // définit une table de double mots
/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
qValeur2:           .skip 8       // réserve la place pour un double mot
szChaine2:          .skip 10
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

 
    afficherLib "Test macro :"
    affichageMemoire "zones  1"  bOctet1  3
    
    ldr x1,qAdrszChaine2
    mov x0,'A'
    strb w0,[x1,2]
    mov x0,'B'
    strb w0,[x1,3]

    affichageMemoire "Stockage"  x1  2  // affichage de la zone adresse qui est dans x1
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrqValeur1:          .quad qValeur1
qAdrqValeur2:          .quad qValeur2
qAdrszChaine2:         .quad szChaine2
qConst1:               .quad 0x1111222233334444
