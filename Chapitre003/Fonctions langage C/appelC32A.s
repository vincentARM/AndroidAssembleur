/* ARM assembleur Android termux  32 bits */
/*  program appelC32A.s   */
/*  appel de l'instruction C printf 32 bits   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ STDOUT,       1      @ Linux console de sortie
.equ EXIT,         1      @ code appel système Linux
.equ WRITE,        4      @ code appel système Linux
/****************************************************/
/* fichier des macros                   */
/****************************************************/
.include "../ficmacros32.inc"

/**************************************/
/* Données initialisées               */
/**************************************/
.data
szMessDebPgm:         .asciz "Début du programme 32 bits. \n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szRetourLigne:        .asciz "\n"
szMessAppelC:         .asciz "valeur = %d \n"
szMessAppelC1:        .asciz "valeur = %d %d %d %d %d\n"
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
    adr r0,iOfszMessDebPgm        @ adresse du message 
    ldr r1,[r0]
    add r0,r1
    bl afficherMess                @ appel fonction d'affichage
    
    adr r0,iOfszMessAppelC
    ldr r1,[r0]
    add r0,r1
    mov r1,#5
    mov r2,#0
    bl printf 
    
    adr r0,iOfszMessAppelC1
    ldr r1,[r0]
    add r0,r1
    mov r1,#1
    mov r2,#2
    mov r3,#3
    mov r4,#4
    mov r5,#5
    bl printf 
    

    adr r0,iOfszMessAppelC1
    ldr r1,[r0]
    add r0,r1
    mov r1,#1
    mov r2,#2
    mov r3,#3
    mov r4,#4
    push {r4}
    mov r5,#5
    push {r5}
    bl printf 
    add sp,#8
 
    mov r0,sp
    affreghexa "Pile avant ="
    adr r0,iOfszMessAppelC1
    ldr r1,[r0]
    add r0,r1
    mov r1,#1
    mov r2,#2
    mov r3,#3
    mov r4,#4
    mov r5,#5
    push {r5}
    push {r4}
    bl printf 
    add sp,#8
    mov r0,sp
    affreghexa "Pile après ="

100:                               @ fin standard du programme
    adr r0,iOfszMessFinPgm        @ adresse du message 
    ldr r1,[r0]
    add r0,r1
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iOfszMessDebPgm:       .int szMessDebPgm - .
iOfszMessFinPgm:       .int szMessFinPgm - .
iOfszRetourLigne:      .int szRetourLigne - .
iOfszMessAppelC:       .int szMessAppelC - .
iOfszMessAppelC1:      .int szMessAppelC1 - .

/******************************************************************/
/*     affichage des messages   avec calcul longueur              */ 
/******************************************************************/
/* r0 contient l adresse du message */
afficherMess:                    @ INFO: afficherMess
    push {r0,r1,r2,r7,lr}        @ save des registres
    mov r2,#0                    @ compteur longueur
1:                               @ calcul de la longueur
    ldrb r1,[r0,r2]              @ recup octet position debut + indice
    cmp r1,#0                    @ si 0 c est fini
    beq 2f
    add r2,r2,#1                 @ sinon on ajoute 1
    b 1b
2:                               @ donc ici r2 contient la longueur du message
    mov r1,r0                    @ adresse du message en r1 
    mov r0,#STDOUT               @ code pour écrire sur la sortie standard Linux */
    mov r7,#WRITE                @ code de l appel systeme 'write' 
    svc #0                       @ appel systeme Linux
    pop {r0,r1,r2,r7,lr}         @ restaur des registres
    bx lr                        @ retour procedure

