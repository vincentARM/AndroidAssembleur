/* ARM assembleur Android termux  32 bits */
/*  program division32.s   */
/* divisions   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ EXIT,         1      @ code appel système Linux
/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé     */
.macro afficherLib str 
    push {r0}               @ save r0
    mrs r0,cpsr             @ save du registre d'état  dans r0
    push {r0}               @ puis sur la pile
    adr r0,libaff1\@        @ recup adresse libellé passé dans str
    bl afficherMess
    pop {r0}
    msr cpsr,r0             @ restaur registre d'état
    pop {r0}                @ on restaure R0 pour avoir une pile réalignée
    b smacroafficheMess\@   @ pour sauter le stockage de la chaine.
libaff1\@:     .ascii "\str"
               .asciz "\n"
.align 4
smacroafficheMess\@:     
.endm   @ fin de la macro

/**************************************/
/* Données initialisées               */
/**************************************/
.data
szMessDebPgm:         .asciz "Début du programme 32 bits. \n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szRetourLigne:        .asciz "\n"

/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneConv:           .skip 11
szZoneConvS:          .skip 12
szZoneConvHexa:       .skip 9
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
 
    
    afficherLib "\ndivision non signée "
    mov r4,#202
    mov r2,#10
    udiv r3,r4,r2
    mov r0,r3
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess 
    
    AfficherLib "\ncalcul du reste "
    
    mls r0,r3,r2,r4
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess 
    ldr r0,iAdrszRetourLigne
    bl afficherMess 

    afficherLib "\ndivision signée "
    mov r4,#-202
    mov r2,#10
    sdiv r3,r4,r2
    mov r0,r3
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS
    bl afficherMess 
    
    AfficherLib "\ncalcul du reste "
    
    mls r0,r3,r2,r4
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS
    bl afficherMess 
    ldr r0,iAdrszRetourLigne
    bl afficherMess 
    
    ldr r0,iAdrszMessFinPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iAdrszMessDebPgm:       .int szMessDebPgm
iAdrszMessFinPgm:       .int szMessFinPgm
iAdrszRetourLigne:      .int szRetourLigne
iAdrszZoneConv:         .int szZoneConv
iAdrszZoneConvS:        .int szZoneConvS
iAdrszZoneConvHexa:     .int szZoneConvHexa
