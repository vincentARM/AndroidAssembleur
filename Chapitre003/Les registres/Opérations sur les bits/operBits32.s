/* ARM assembleur Android termux  32 bits */
/*  program operBits32.s   */
/* opérations logiques sur les bits  */
/**************************************/
/* Constantes                         */
/**************************************/
.equ STDOUT,       1      @ Linux console de sortie
.equ EXIT,         1      @ code appel système Linux
.equ WRITE,        4      @ code appel système Linux
/**************************************/
/* Données initialisées               */
/**************************************/
.data
szMessDebPgm:      .asciz "Début du programme 32 bits. \n"
szMessFinPgm:      .asciz "Fin normale du programme. \n"
szMessAffBinET:      .asciz "Résultat opération ET :\n"
szMessAffBinOU:      .asciz "Résultat opération OU :\n"
szMessAffBinXOR:      .asciz "Résultat opération OU exclusif :\n"
szMessAffBinNON:      .asciz "Résultat opération NON  :\n"
szMessAffBinCLR:      .asciz "Résultat opération RAZ bit  :\n"

szZoneBin:         .space 40,' '                        @ définit 40 octets à blanc
                   .asciz "\n"                          @ fin de chaine
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage

    mov r1,#0b0011
    mov r2,#0b1010
    mov r0,r1                      @ affichage des 2 registres 
    bl afficherBinaire
    mov r0,r2
    bl afficherBinaire
    
    ldr r0,iAdrszMessAffBinET      @ titre
    bl afficherMess
    and r0,r1,r2                   @ opérateur ET
    bl afficherBinaire
    ldr r0,iAdrszMessAffBinOU      @ titre
    bl afficherMess
    orr r0,r1,r2                   @ opérateur OU
    bl afficherBinaire
    ldr r0,iAdrszMessAffBinXOR     @ titre
    bl afficherMess
    eor r0,r1,r2                   @ opérateur OU exclusif
    bl afficherBinaire
    ldr r0,iAdrszMessAffBinNON     @ titre
    bl afficherMess
    mvn r0,r1                      @ opérateur NON
    bl afficherBinaire
    ldr r0,iAdrszMessAffBinCLR     @ titre
    bl afficherMess
    mov r0,#0
    mvn r0,r0
    bic r0,#0b11000                @ opérateur RAZ 4 et 5ième bits
    bl afficherBinaire
    
    ldr r0,iAdrszMessFinPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iAdrszMessDebPgm:      .int szMessDebPgm
iAdrszMessFinPgm:      .int szMessFinPgm
iAdrszMessAffBinET:    .int szMessAffBinET
iAdrszMessAffBinOU:    .int szMessAffBinOU
iAdrszMessAffBinXOR:   .int szMessAffBinXOR
iAdrszMessAffBinNON:   .int szMessAffBinNON
iAdrszMessAffBinCLR:   .int szMessAffBinCLR
/******************************************************************/
/*     affichage d'un registre 32 bits en binaire                 */ 
/******************************************************************/
/* r0 contient la valeur à afficher */
afficherBinaire:  
    push {r0-r6,lr}            @ save des registres
    ldr r1,iAdrszZoneBin       @ zone réception
    mov r2,#31                 @ position bit de départ
    mov r3,#0                  @ position écriture caractère
    mov r5,#1                  @ valeur pour tester un bit

1:                             @ debut boucle
    lsl r6,r5,r2               @ déplacement valeur de test à la position à tester
    tst r0,r6                  @ test du bit à cette position
    moveq r4,#48               @ bit egal à zero -> caractère ascii '0'
    movne r4,#49               @ bit egal à un -> caractère ascii '1'
    strb r4,[r1,r3]            @ caractère ascii ->  zone d'affichage
    sub r2,r2,#1               @ decrement pour bit suivant
    add r3,r3,#1               @ + 1 position affichage caractère
    and r4,r2,#0b111           @ extraction 3 derniers bits du compteur
    cmp r4,#0b111              @ egaux à 0b111 ?
    addeq r3,r3,#1             @ si égaux à 0b111 alors on ajoute un blanc 
    cmp r2,#0                  @ 32 bits analysés ?
    bge 1b                     @ non -> boucle
    ldr r0,iAdrszZoneBin       @ adresse du message résultat
    bl afficherMess            @ affichage message
    pop {r0-r6,lr}             @ restaur des registres
    bx lr                      @ retour procedure
100:
iAdrszZoneBin:            .int szZoneBin
/******************************************************************/
/*     affichage des messages   avec calcul longueur              */ 
/******************************************************************/
/* r0 contient l adresse du message */
afficherMess:
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
