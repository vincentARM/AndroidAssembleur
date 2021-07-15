/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme tas64.s */
/* gestion du tas 64 bits  */

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

.align 8
ptZoneTas:           .quad __end__    // adresse de la fin des données calculée par le linker
                                      // et qui va servir de pointeur de début de notre tas
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
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess
    
    
    ldr x19,qAdrptZoneTas        // adresse du pointeur 
    ldr x0,[x19]                 // adresse du début du tas
    affreghexa "Adresse départ :"
    
    mov x0,20                    // réserve 20 octets
    bl reserverPlace
    mov x20,x0
    affreghexa " retour adresse"
    ldr x0,[x19]
    affreghexa "Nouvelle adresse"
    mov x0,0x7777                // stocke des valeurs dans le tas
    str x0,[x20]
    mov x0,0x8888
    str x0,[x20,8]
    
    mov x0,50                    // réserve 50 octets
    bl reserverPlace
    mov x21,x0
    affreghexa "Retour adresse 2"
    ldr x0,[x19]
    affreghexa "Nouvelle adresse 2"
    mov x0,0xFFFF                // stocke une valeur sur le tas
    str x0,[x21]
    
    
    affichageMemoire "Tas 1" __end__ 6   // affichage du tas
    
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
/*   réservation de place sur le tas              */
/***************************************************/
/* x0 contient la taille à réserver */
reserverPlace:                  // INFO: reserverPlace
    stp x1,lr,[sp,-16]!         // save  registres
    stp x2,fp,[sp,-16]!         // save  registres
    ldr x1,qAdrptZoneTas
    ldr x2,[x1]                 // charge le pointeur de début du tas libre
    add x0,x0,x2                // ajoute la taille
    lsr x0,x0,3                 
    lsl x0,x0,3                 // calcule la frontière d'un double mot (8 octets)
    add x0,x0,8                 // ajoute 8 octets pour que la nouvelle adresse du tas
    str x0,[x1]                 // soit alignée sur une frontière de 8 octets
    mov x0,x2                   // retourne le début de la zone réservée
 
100:
    ldp x2,fp,[sp],16           // restaur  registres
    ldp x1,lr,[sp],16           // restaur registres
    ret
qAdrptZoneTas:       .quad ptZoneTas

    
 