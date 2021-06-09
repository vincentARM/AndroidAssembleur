/* ARM assembleur Android termux  32 bits */
/*  program affbinaire32.s   */
/* affichage d'un registre en binaire  */
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
szMessAffBin:      .asciz "Affichage binaire :\n"
szMessAddition:    .asciz "Après addition :\n"
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
    ldr r0,iAdrszMessDebPgm      @ adresse du message 
    bl afficherMess              @ appel fonction d'affichage
    ldr r0,iAdrszMessAffBin      @ titre
    bl afficherMess
    mov r2,#0b1101               @ met dans le registre r2 le nombre 13
    mov r0,r2
    bl afficherBinaire
    ldr r0,iAdrszMessAddition
    bl afficherMess
    mov r1,#0b1001              @ met dans le registre r1 le nombre 9
    add r0,r2,r1
    bl afficherBinaire
                                 @ fin du programme
    mov r0, #0                   @ code retour OK
    mov r7, #EXIT                @ code fin LINUX 
    svc 0                        @ appel système LINUX

iAdrszMessDebPgm:    .int szMessDebPgm
iAdrszMessAffBin:    .int szMessAffBin
iAdrszMessAddition:  .int szMessAddition
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
