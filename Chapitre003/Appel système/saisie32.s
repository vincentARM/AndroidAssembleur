/* ARM assembleur Android termux  32 bits */
/*  program saisie32.s   */
/*  saisie texte dans la console 32 bits   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ EXIT,         1      @ code appel système Linux
.equ READ,         3      @ code appel système Linux
.equ TAILLEBUF,  100      @ taille du buffer
.equ STDIN, 0             @ console d'entrée linux standard

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
szLibFin:             .asciz "fin"
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneConv:           .skip 11
szZoneConvS:          .skip 12
szZoneConvHexa:       .skip 9
sBuffer:              .skip TAILLEBUF
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
    ldr r4,iAdrsBuffer
1:
    afficherLib "Veuillez saisir une chaîne de caractères ou fin :"
    
    mov r0,#STDIN                  @ console entrée standard Linux
    mov r1,r4                      @ adresse du buffer de lecture
    mov r2,#TAILLEBUF              @ taille buffer
    mov r7, #READ                  @ code appel systeme Linux
    svc 0 
    
    affreghexa "Code retour = "
    
    affichageMemoire "Saisie : " sBuffer 3
    
    mov r1,#0
    sub r0,#1                      @ longueur - 1 = déplacement
    strb r1,[r4,r0]                @ remplace le 0xA final par 0x0
   
      
    mov r0,r4
    ldr r1,iAdrszLibFin
    bl comparaison                 @ la saisie = fin ?
    bne 1b                         @ non -> boucle

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
iAdrsBuffer:            .int sBuffer
iAdrszLibFin:           .int szLibFin
