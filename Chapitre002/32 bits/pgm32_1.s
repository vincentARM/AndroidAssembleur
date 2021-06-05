/* ARM assembleur Android termux  32 bits */
/*  program pgm32_1.s   */
/* affichage d'un texte simple */
/**************************************/
/* Constantes                         */
/**************************************/
.equ STDOUT,       1      @ Linux console de sortie
.equ EXIT,         1      @ code appel syst�me Linux
.equ WRITE,        4      @ code appel syst�me Linux
/**************************************/
/* Donn�es initialis�es               */
/**************************************/
.data
szMessage:      .asciz "Pgm1 : Bonjour le monde. \n"       @ message
/**************************************/
/* Donn�es non initialis�es               */
/**************************************/
.bss
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessage         @ adresse du message 
    bl afficherMess              @ appel fonction d'affichage

                                 @ fin du programme
    mov r0, #0                   @ code retour OK
    mov r7, #EXIT                @ code fin LINUX 
    svc 0                        @ appel syst�me LINUX

iAdrszMessage: .int szMessage
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
    mov r0,#STDOUT               @ code pour �crire sur la sortie standard Linux */
    mov r7,#WRITE                @ code de l appel systeme 'write' 
    svc #0                       @ appel systeme Linux
    pop {r0,r1,r2,r7,lr}         @ restaur des registres
    bx lr                        @ retour procedure
