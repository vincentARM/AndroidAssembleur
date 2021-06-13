/* ARM assembleur Android termux  32 bits */
/*  program testRoutines32.s   */
/* tests des routines   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ EXIT,         1      @ code appel système Linux

/**************************************/
/* Données initialisées               */
/**************************************/
.data
szMessDebPgm:         .asciz "Début du programme 32 bits. \n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szMessAffHexa:        .asciz "Valeur du registre en hexa : "
szMessAffBinaire:     .asciz "Valeur du registre base 2  : "
szRetourLigne:        .asciz "\n"
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneHexa:        .skip  9                    @ reserve 9 octets à zéro pour zone de conversion
szZoneBin:         .skip 40
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage

    mov r2,#15
    mov r0,r2
    ldr r1,iAdrszZoneBin
    bl conversion2
    ldr r0,iAdrszMessAffBinaire       @ affichage du titre
    bl afficherMess
    ldr r0,iAdrszZoneBin          @ affichage de la zone de conversion
    bl afficherMess
    ldr r0,iAdrszRetourLigne       @ affichage du retour ligne
    bl afficherMess
    
    mov r0,r2                      @ conversion hexa du registre
    ldr r1,iAdrszZoneHexa
    bl conversion16
    ldr r0,iAdrszMessAffHexa       @ affichage du titre
    bl afficherMess
    ldr r0,iAdrszZoneHexa          @ affichage de la zone de conversion
    bl afficherMess
    ldr r0,iAdrszRetourLigne       @ affichage du retour ligne
    bl afficherMess




    ldr r0,iAdrszMessFinPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
                                   @ fin du programme
    mov r0, #0                     @ code retour OK
    mov r7, #EXIT                  @ code fin LINUX 
    svc 0                          @ appel système LINUX

iAdrszMessDebPgm:       .int szMessDebPgm
iAdrszMessFinPgm:       .int szMessFinPgm
iAdrszMessAffHexa:      .int szMessAffHexa
iAdrszMessAffBinaire:   .int szMessAffBinaire
iAdrszZoneHexa:         .int szZoneHexa
iAdrszZoneBin:          .int szZoneBin
iAdrszRetourLigne:      .int szRetourLigne

