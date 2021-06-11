/* ARM assembleur Android termux  32 bits */
/*  program deplBits32.s   */
/* déplacement des bits  */
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
szMessDebPgm:         .asciz "Début du programme 32 bits. \n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szMessAffDeplGau:     .asciz "Résultat déplacement gauche :\n"
szMessAffDeplDro:     .asciz "Résultat déplacement droit :\n"
szMessAffDeplAri:     .asciz "Résultat déplacement droit arithmétique :\n"
szMessAffBinRot:      .asciz "Résultat rotation droite :\n"
szMessAffBinRrx:      .asciz "Résultat rotation avec retenue  :\n"
szMessAffDeplR:       .asciz "Résultat deplacement droit avec récupération bit : \n"
szMessAffBit0:        .asciz "Bit extrait = 0  :\n"
szMessAffBit1:        .asciz "Bit extrait = 1  :\n"

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

    mov r1,#0b1110011
    mov r0,r1                      @ affichage des 2 registres 
    bl afficherBinaire
    
    ldr r0,iAdrszMessAffDeplGau    @ titre
    bl afficherMess
    lsl r0,r1,#5                   @ déplacement de 5 positions à gauche
    bl afficherBinaire
    ldr r0,iAdrszMessAffDeplDro    @ titre
    bl afficherMess
    mov r2,#3
    lsr r0,r1,r2                   @ déplacement de 3 positions sur la droite
    bl afficherBinaire
    ldr r0,iAdrszMessAffBinRot     @ titre
    bl afficherMess
    ror r0,r1,#3                   @ rotation sur la droite de 3 positions 
    bl afficherBinaire
    ldr r0,iAdrszMessAffDeplAri     @ titre
    bl afficherMess
    lsl r2,r1,#25
    mov r0,r2
    bl afficherBinaire
    asr r0,r2,#4                  @ opérateur asr
    bl afficherBinaire
    ldr r0,iAdrszMessAffDeplR     @ titre
    bl afficherMess
    
    lsrs r0,r1,#1                  @ déplacement de 1 position sur la droite
    bcs 1f                         @ saut si retenue est mise (Branch if Carry Set)
    ldr r0,iAdrszMessAffBit0       @  carry = 0
    bl afficherMess
    b 2f
1:
    ldr r0,iAdrszMessAffBit1       @  carry = 1
    bl afficherMess
2:
    lsrs r0,r1,#3                  @ déplacement de 3 positions sur la droite
    bcc 3f                         @ saut si retenue n'est pas mise (Branch if Carry Clear)
    ldr r0,iAdrszMessAffBit1       @  carry = 1
    bl afficherMess
    b 4f
3:
    ldr r0,iAdrszMessAffBit0       @  carry = 0
    bl afficherMess 
4:
    ldr r0,iAdrszMessAffBinRrx     @ titre
    bl afficherMess
    lsrs r0,r1,#3                  @ déplacement de 3 positions sur la droite
    rrx r0,r1                      @ opérateur rrx
    bl afficherBinaire
    lsrs r0,r1,#1                  @ déplacement de 1 position sur la droite
    rrx r0,r1
    bl afficherBinaire
    
    
    ldr r0,iAdrszMessAffDeplGau
    bl afficherMess
    mov r2,#0b11                   @ maj r2 
    mov r0,r2,lsl #8               @ copie dans r0 après déplacement à gauche de 8 bits
    bl afficherBinaire
    
    ldr r0,iAdrszMessFinPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iAdrszMessDebPgm:       .int szMessDebPgm
iAdrszMessFinPgm:       .int szMessFinPgm
iAdrszMessAffDeplGau:   .int szMessAffDeplGau
iAdrszMessAffDeplDro:   .int szMessAffDeplDro
iAdrszMessAffBinRot:    .int szMessAffBinRot
iAdrszMessAffDeplAri:   .int szMessAffDeplAri
iAdrszMessAffBinRrx:    .int szMessAffBinRrx
iAdrszMessAffBit0:      .int szMessAffBit0
iAdrszMessAffBit1:      .int szMessAffBit1
iAdrszMessAffDeplR:     .int szMessAffDeplR
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
