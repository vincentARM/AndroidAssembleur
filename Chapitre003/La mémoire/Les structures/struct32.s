/* ARM assembleur Android termux  32 bits */
/*  program struct32.s   */
/* exemple de structure   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ EXIT,         1      @ code appel système Linux
/****************************************************/
/* fichier des macros                   */
/****************************************************/
.include "../ficmacros32.inc"

/*************************************************/
/* Définitions des structures                   */
/*********************************************/
/* exemple de définition */
    .struct  0
Client_valeur1:	                  @ premier entier
    .struct  Client_valeur1 + 4   
Client_valeur2:	                  @ deuxieme entier
    .struct  Client_valeur2 + 4 
Client_octet1:	                  @ premier octet
    .struct  Client_octet1 + 1 
Client_fin:                       @ donne la longueur de la structure
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
tbClients:            .skip Client_fin * 10
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
    
    ldr r4,iAdrtbClients
    afficherLib "stockage du rang 5"
    mov r1,#5                    @ rang
    mov r2,#Client_fin           @ taille d'un enregistrement client
    mla r3,r2,r1,r4              @ calcul de l'adresse du rang 5
    mov r0,#0x123                @ première valeur
    str r0,[r3,#Client_valeur1]  @ stocke la première valeur
    mov r0,#0x456
    str r0,[r3,#Client_valeur2]  @ stocke la deuxième valeur
    mov r0,#1
    strb r0,[r3,#Client_octet1]  @ stocke la valeur de l'octet

    affichageMemoire "Tableau client" tbClients 10

    ldr r4,iAdrtbClients
    afficherLib "Chargement valeur du rang 5"
    mov r1,#5                    @ rang
    mov r2,#Client_fin           @ taille d'un enregistrement client
    mla r3,r2,r1,r4              @ calcul de l'adresse du rang 25
    ldr r0,[r3,#Client_valeur2]  @ charge la deuxième valeur
    affreghexa "Valeur2="        @ et affichage

    

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
iAdrszZoneConv:         .int szZoneConv
iAdrszZoneConvS:        .int szZoneConvS
iAdrszZoneConvHexa:     .int szZoneConvHexa
iAdrtbClients:          .int tbClients



