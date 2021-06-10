/* ARM assembleur Android termux  32 bits */
/*  program testsBits32.s   */
/* comptage et tests des bits  */
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
szMessAffNBzeros:     .asciz "Nombre de zéros à gauche :\n"
szMessAffTestA1:       .asciz "Le bit testé est à 1 \n"
szMessAffTestA0:       .asciz "Le bit testé est à 0 \n"
szMessAffTestNE:       .asciz "Valeurs inégales\n"
szMessAffTestEQ:       .asciz "Valeurs égales\n"

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
    
    ldr r0,iAdrszMessAffNBzeros    @ titre
    bl afficherMess
    clz r0,r1                      @ compte le nombre de zéros à gauche de r1
    bl afficherBinaire
    
    tst r1,#0b10
    beq 1f
    
   ldr r0,iAdrszMessAffTestA1    @ titre
   bl afficherMess
   b 2f
1:
   ldr r0,iAdrszMessAffTestA0    @ titre
   bl afficherMess
2:
    mov r2,#0b1000
    tst r1,r2
    beq 3f
    
   ldr r0,iAdrszMessAffTestA1    @ titre
   bl afficherMess
   b 4f
3:
   ldr r0,iAdrszMessAffTestA0    @ titre
   bl afficherMess
4:

    teq r1,#0b10
    beq 5f
    
   ldr r0,iAdrszMessAffTestNE    @ titre
   bl afficherMess
   b 6f
5:
   ldr r0,iAdrszMessAffTestEQ    @ titre
   bl afficherMess
6:
    mov r2,#0b1110011
    teq r1,r2
    beq 7f
    
   ldr r0,iAdrszMessAffTestNE    @ titre
   bl afficherMess
   b 8f
7:
   ldr r0,iAdrszMessAffTestEQ    @ titre
   bl afficherMess
8:
    ldr r0,iAdrszMessFinPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iAdrszMessDebPgm:       .int szMessDebPgm
iAdrszMessFinPgm:       .int szMessFinPgm
iAdrszMessAffNBzeros:   .int szMessAffNBzeros
iAdrszMessAffTestA0:    .int szMessAffTestA0
iAdrszMessAffTestA1:    .int szMessAffTestA1
iAdrszMessAffTestNE:    .int szMessAffTestNE
iAdrszMessAffTestEQ:    .int szMessAffTestEQ
/******************************************************************/
/*     affichage d'un registre 32 bits en binaire                 */ 
/*     nouvelle routine utilsant lsls et le carry                 */
/******************************************************************/
/* r0 contient la valeur à afficher */
afficherBinaire:  
    push {r0-r4,lr}            @ save des registres
    ldr r1,iAdrszZoneBin       @ zone réception
    mov r2,#31                 @ position bit de départ
    mov r3,#0                  @ position écriture caractère

1:                             @ debut boucle
    lsls r0,#1                 @ déplacement gauche 1 position et mise à jour du carry
    movcc r4,#48               @ carry egal à zero -> caractère ascii '0'
    movcs r4,#49               @ carry egal à un -> caractère ascii '1'
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
    pop {r0-r4,lr}             @ restaur des registres
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
