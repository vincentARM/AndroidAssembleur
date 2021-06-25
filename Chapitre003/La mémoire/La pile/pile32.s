/* ARM assembleur Android termux  32 bits */
/*  program pile32.s   */
/* exemples d'utilisation de la pile  32 bits   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ EXIT,         1      @ code appel système Linux
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

tbValeur1:            .int 1,2,3,4,5,6,7,8,9
                       .equ NBELEMENTS, (. - tbValeur1) / 4
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
    
    afficherLib "Appel 1 "
    ldr r4,iAdrtbValeur1
    mov r0,#5
    push {r0,r4}                   @ les registres doivent être dans l'ordre
    bl lireValeur
    affreghexa "retour = " 
    
    afficherLib "Appel 2 "
    mov r0,#3
    push {r4}
    push {r0}                      @ avec des push unitaires, l'ordre des registres doit être inversé
    bl lireValeur
    affreghexa "retour = " 
    
    afficherLib "Utilisation pile : "
    mov r0,r4                      @ cette fois ci on passe l'adresse du tableau par le registre r0
    bl extractSousTableau

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
iAdrtbValeur1:          .int tbValeur1

/***************************************************/
/*   lecture valeur d'un tableau              */
/***************************************************/
/* les paramètres sont passées sur la pile : adresse du tableau et N   */
lireValeur:                    @ INFO: lireValeur
    push {r1,fp,lr}            @ save des registres
    add fp,sp,#4 * 3           @ 4 octets * nb registres sauvés
    mov r0,fp                  @ affichage de la pile
    affichageMemoire "fp = " r0 4
    
    ldr r1,[fp]
    ldr r0,[fp,#4]
    affreghexa "param 2 = " 
    ldr r0,[r0,r1,lsl #2]
 
100:
    pop {r1,fp,lr}             @ restaur des registres et retour main
    add sp,#8                  @ il faut realigner la pile car il y a 2 pushs (ou 2 registres) pour les paramètres
    bx lr 

/***************************************************/
/*   utilisation données internes              */
/***************************************************/
/* r0 contient l'adresse du tableau  */
extractSousTableau:            @ INFO: extractSousTableau
    push {r0-r2,fp,lr}         @ save des registres
    sub sp,#4 * 5              @ reserve 20 octets sur la pile
    mov fp,sp                  @ garde l'adresse du début de la zone
    mov r1,#0                  @ indice
    
1:
    ldr r2,[r0,r1,lsl #2]      @ charge un entier du tableau
    str r2,[fp,r1,lsl #2]      @ et le stocke dans la zone rservée de la pile
    add r1,#1                  @ poste suivant
    cmp r1,#5                  @ ne stocke que les 5 premiers
    blt 1b 
                               @ verification du stockage
                               
    mov r0,fp
    affichageMemoire "fp = " r0 4
    
    ldr r0,[fp,#8]             @ charge le 3ième poste de la zone reservée
    affreghexa "valeur  = " 
 
100:
    add sp,#4 * 5              @ reàlignement de la pile
    pop {r0-r2,fp,pc}          @ restaur des registres et retour main
 
    