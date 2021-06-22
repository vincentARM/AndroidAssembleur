/* ARM assembleur Android termux  32 bits */
/*  program operPar32.s   */
/* squelette de programme assembleur 32 bits   */
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
/* macro d'enrobage affichage hexa d'un registre  avec étiquette */
.macro affreghexa str 
    push {r0}              @ save r0
    mrs r0,cpsr            @ save du registre d'état  dans r0
    push {r0}
    adr r0,libhex1\@       @ utilisation de adr suite pb gros programme
    bl afficherMess
    ldr r0,[sp,#4]         @ on remet en etat r0 pour l'afficher correctement
    bl afficherUnRegistre  @ affichage registre
    pop {r0}
    msr cpsr,r0            @restaur registre d'état
    pop {r0}               @ on restaure r0 pour avoir une pile réalignée
    b smacro1affhextit\@   @ pour sauter le stockage de la chaine.
libhex1\@:  .ascii "\str"
            .asciz " : "
.align 4
smacro1affhextit\@:
.endm   @ fin de la macro
/**************************************/
/* Données initialisées               */
/**************************************/
.data
szMessDebPgm:         .asciz "Début du programme 32 bits. \n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szRetourLigne:        .asciz "\n"

szMessAffReg:         .ascii "Valeur hexa du registre : "
sZoneConvHexaReg:     .skip 9
                      .asciz "\n"
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
    
    afficherLib "Nombre pair/impair"
    #movs r0,#19
    movs r0,#20
    tst r0,#1
    beq pair
    afficherLib impair
    b suite
pair:
    afficherLib pair
suite:
    afficherLib "Multiplication par 2 : "
    mov r0,#10
    lsl r0,#1
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Multiplication par 4 : "
    mov r0,#10
    lsl r0,#2
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Division par 8 : "
    mov r0,#80
    lsr r0,#3
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Division par 4 signé : "
    mov r0,#-80
    asr r0,#2
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Valeur absolue : "
    movs r0,#-80                  @ met à jour les indicateurs
    negmi r0,r0                   @ conversion si négatif
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    
    mov r0,#0x1234                 @ utilisation macro affichage hexa
    affreghexa Exemple1
    

100:                               @ fin standard du programme
    ldr r0,iAdrszMessFinPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iAdrszMessDebPgm:       .int szMessDebPgm
iAdrszMessFinPgm:       .int szMessFinPgm
iAdrszRetourLigne:      .int szRetourLigne
iAdrszZoneConvS:        .int szZoneConvS
iAdrszZoneConv:        .int szZoneConv
/***************************************************/
/*   Affichage d'un registre en hexa  */
/***************************************************/
/* r0 contient la valeur à afficher   */
.equ LGZONE, 9
afficherUnRegistre:
    push {r0-r2,lr}            @ save des registres
    ldr r1,iAdrsZoneConvHexaReg
    bl conversion16
    mov r2,#' '                @ caractère espace
    strb r2,[r1,r0]            @ efface le 0 final avec un espace
    ldr r0,iAdrszMessAffReg
    bl afficherMess
    pop {r0-r2,lr}             @ restaur des registres
    bx lr
iAdrszMessAffReg:           .int szMessAffReg
iAdrsZoneConvHexaReg:       .int sZoneConvHexaReg
