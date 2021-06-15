/* ARM assembleur Android termux  32 bits */
/*  program soustraction32.s   */
/* soustractions   */
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
 
    
    afficherLib "\nSoustraction"
    mov r1,#200
    sub r0,r1,#10
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess 
    
    afficherLib "\nSoustraction négative "
    mov r1,#10
    mov r2,#20
    
    sub r0,r1,r2               @ 
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv      @ le résultat est faux !!!
    bl afficherMess 
    
    afficherLib "\nSoustraction avec indicateur d'état"
    mov r1,#10
    subs r0,r1,#20                  @ enleve 2   et il n'y a pas de retenue
    //subs r0,r1,#20               @ enleve 20 et il y a retenue
    bcs 1f                          @ attention c'est l'inverse de l'addition 
    afficherLib "Retenue positionnée. \n"
    b 2f
1:
   afficherLib "Pas de retenue. \n"
2:

    AfficherLib "Valeur positive " 
    mov r0,#10
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    AfficherLib "Valeur negative " 
    mov r0,#-10
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Valeur maxi négative " 
    mov r0,#0x8000   
    lsl r0,#16               @ charge 0x80000000 soit 2 puis 31 soit 2 147 483 648
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Valeur maxi positive " 
    mov r0,#0x8000
    lsl r0,#16              @ charge 0x80000000 soit 2 puis 31 soit 2 147 483 648
    sub r0,#1               @ et enleve 1 pour faire 2 147 483 647
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Soustraction inverse : "
    mov r1,#20
    rsb r0,r1,#15               @ calcule 15 - 20 
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS      @ 
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
/***************************************************/
/*   Conversion d'un registre en décimal non signé  */
/***************************************************/
/* r0 contient le registre   */
/* r1 contient l'adresse de la zone de conversion longueur >= 11 octets */
.equ LGZONE, 9
conversion10:
    push {r1-r4,lr}            @ save des registres
    mov r3,#0
    strb r3,[r1,#LGZONE+1]     @ stocke le 0 final
    mov r4,#LGZONE
    mov r3,#10                 @ conversion decimale
1:                             @ debut de boucle de conversion
    mov r2,r0                  @ copie nombre départ ou quotients successifs
    udiv r0,r2,r3              @ division par le facteur de conversion
    mls r2,r0,r3,r2            @ calcul du reste de la division 
    add r2,#48                 @ car c'est un chiffre
    strb r2,[r1,r4]            @ stockage du byte au debut zone (r1) + la position (r4)
    sub r4,r4,#1               @ position précedente
    cmp r0,#0                  @ arret si quotient est égale à zero
    bne 1b    
                               @ mais il faut déplacer le résultat en début de zone
    adds r4,#1                 @ début du résultat
    moveq r0,#LGZONE           @ si début = 0 la zone est compléte
    beq 100f                   @ donc fin 
    mov r2,#0                  @ indice début zone
2:                             @ boucle de déplacement
    ldrb r3,[r1,r4]            @ charge un octet du résultat
    strb r3,[r1,r2]            @ et le stocke au début
    add r2,#1                  @ incremente la position de stockage
    add r4,r4,#1               @ incremente la position de chargement
    cmp r4,#LGZONE + 1         @ c'est la fin ??
    ble 2b                     @ boucle si r4 <= longueur zone (y compris le 0 final)
    sub r0,r2,#1               @ retourne la longueur du résultat (sans le zéro final)

100:
                               @ fin standard de la fonction
    pop {r1-r4,lr}             @ restaur des registres
    bx lr                      @ retour de la fonction en utilisant lr
/***************************************************/
/*   conversion registre en décimal   signé  */
/***************************************************/
/* r0 contient le registre   */
/* r1 contient l'adresse de la zone de conversion */
.equ LGZONECAL,   10
conversion10S:                       @ INFO: conversion10S
    push {r1-r6,lr}                  @ save des registres
    mov r5,r1                        @ debut zone stockage
    mov r6,#'+'                      @ par defaut le signe est +
    cmp r0,#0                        @ nombre négatif ?
    movlt r6,#'-'                    @ oui le signe est -
    neglt r0,r0                      @ et inversion valeur
    mov r4,#LGZONECAL                       @ longueur de la zone
    mov r2,r0                        @ nombre de départ des divisions successives
    mov r1,#10                       @ conversion decimale
1:                                   @ debut de boucle de conversion
    mov r0,r2                        @ copie nombre départ ou quotients successifs
    udiv r2,r0,r1
    mls  r3,r2,r1,r0                 @ calcul reste
    add r3,#48                       @ car c'est un chiffre 
    strb r3,[r5,r4]                  @ stockage du byte en début de zone r5 + la position r4
    sub r4,r4,#1                     @ position précedente
    cmp r2,#0                        @ arret si quotient est égale à zero
    bne 1b    
    
    add r4,r4,#1
    mov r2,#1                        @ deplacement en tête de zone
2:
    ldrb r1,[r5,r4]
    strb r1,[r5,r2]
    add r2,#1
    add r4,#1
    cmp r4,#LGZONECAL
    ble 2b
                                     @ stockage du signe à la première position
    strb r6,[r5] 
    mov r6,#0
    strb r6,[r5,r2]                  @ 0 final
    mov r0,r2                        @ retourne longueur
100:                                 @ fin standard de la fonction
    pop {r1-r6,lr}                   @ restaur des autres registres
    bx lr        
