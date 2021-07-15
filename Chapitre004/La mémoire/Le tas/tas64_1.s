/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme tas64_1.s */
/* gestion du tas (zone de la section .bss)  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

.equ  TAILLETAS,     1000000
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

.align 8
ptZoneTas:           .quad ZoneTas
/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
ZoneTas:                  .skip TAILLETAS

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    
    ldr x19,qAdrptZoneTas
    ldr x0,[x19]
    affreghexa "Adresse départ :"
    
    mov x0,20                // réserve 20 octets
    bl reserverPlace
    mov x20,x0
    affreghexa " retour adresse"
    ldr x0,[x19]
    affreghexa "Nouvelle adresse"
    mov x0,0x7777
    str x0,[x20]
    mov x0,0x8888
    str x0,[x20,8]
    
    mov x0,50                // réserve 50 octets
    bl reserverPlace
    mov x21,x0
    affreghexa "Retour adresse 2"
    ldr x0,[x19]
    affreghexa "Nouvelle adresse 2"
    mov x0,0xFFFF
    str x0,[x21]
    
    
    affichageMemoire "Tas 2" ZoneTas 6
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
/***************************************************/
/*   execution routine              */
/***************************************************/
/* x0 contient la taille à réserver */
reserverPlace:                  // INFO: reserverPlace
    stp x1,lr,[sp,-16]!         // save  registres
    stp x2,fp,[sp,-16]!         // save  registres
    ldr x1,qAdrptZoneTas
    ldr x2,[x1]
    add x0,x0,x2
    lsr x0,x0,3
    lsl x0,x0,3
    add x0,x0,8
    str x0,[x1]
    mov x0,x2
    ldr x1,ptFinTas             // vérification fin du tas
    cmp x0,x1
    blt 100f
    afficherLib "\033[31mErreur : tas trop petit !!\033[0m"
    mov x0,-1
 
100:
    ldp x2,fp,[sp],16           // restaur  registres
    ldp x1,lr,[sp],16           // restaur registres
    ret
qAdrptZoneTas:       .quad ptZoneTas
ptFinTas:            .quad ZoneTas + TAILLETAS   // calcule la fin du tas

    
 