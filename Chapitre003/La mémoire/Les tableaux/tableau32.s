/* ARM assembleur Android termux  32 bits */
/*  program tableau32.s   */
/* utilisation des tableaux 32 bits   */
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

@ déclaration tableaux
tbValeurs:            .int 1,2,3,4,5,6,7,8
                      .equ NBELEMENTS,  (. - tbValeurs) / 4
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneConv:           .skip 11
szZoneConvS:          .skip 12
.align 4 
tbValeursCopie:        .skip 4 * NBELEMENTS
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
    
    afficherLib "Affichage  poste 0"
    ldr r4,iAdrtbValeurs           @ charge l'adresse du tableau32
    ldr r0,[r4]                    @ charge le premier entier du tableau 
    affreghexa "Poste 0 :"
    
    afficherLib "Affichage poste 1"
    ldr r0,[r4,#4]                 @ charge le deuxieme entier du tableau 
    affreghexa "Poste 1 :"
        
    afficherLib "Affichage  poste 5"
    ldr r4,iAdrtbValeurs           @ charge l'adresse du tableau32
    mov r2,#5
    ldr r0,[r4,r2, lsl #2]         @ calcule le déplacement (5 postes * 4 octets ) et charge le 6 ième entier
    affreghexa "Poste 5 :"
    
    mov r0,r4
    ldr r1,iAdrtbValeursCopie
    bl copierTableau
    
    mov r0,r1
    affichageMemoire "Copie du tableau" r0 5
    
    mov r0,r4
    mov r1,#3                     @ valeur dans tableau
    bl rechercherValeur
    
    mov r0,r4
    mov r1,#10                    @ valeur non dans le tableau 
    bl rechercherValeur

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
iAdrtbValeurs:          .int tbValeurs
iAdrtbValeursCopie:     .int tbValeursCopie
/***************************************************/
/*   copie de tableau d'entiers                     */
/***************************************************/
/* r0 contient l'adresse du tableau origine   */
/* r1 contient l'adresse de destination      */
/* Attention les registres ne sont pas sauvegardés !! */
copierTableau:                   @ INFO: copierTableau
    mov r2,#0                    @ init indice
1:
    ldr r3,[r0,r2,lsl #2]        @ charge un poste du tableau d'origine
    str r3,[r1,r2,lsl #2]        @ le stocke dans le tableau destination 
    add r2,#1                    @ incremente l'indice
    cmp r2,#NBELEMENTS           @ maxi atteint ?
    blt 1b                       @ non -> boucle

100:
    bx lr                        @ retour au programme appelant
/***************************************************/
/*   Recherche dans un tableau d'entiers            */
/***************************************************/
/* r0 contient l'adresse du tableau    */
/* r1 contient la valeur à rechercher      */
/* Attention les registres ne sont pas sauvegardés !! */
rechercherValeur:                   @ INFO: copierTableau  
    push {lr}                       @ save registre de retour uniquement
    mov r2,#0                       @ init indice
1:
    ldr r3,[r0,r2,lsl #2]           @ charge un poste
    cmp r3,r1                       @ égal à la valeur cherchée ?
    beq 2f                          @ oui -> fin
    add r2,#1                       @ non -> incremente l'indice
    cmp r2,#NBELEMENTS              @ maxi atteint ?
    blt 1b                          @ non -> boucle 
    afficherLib "Valeur non trouvée !!"
    b 100f
2:                                  @ valeur trouvée affichage du N° de poste 
    afficherLib "Valeur trouvée"
    mov r0,r2
    affreghexa "poste N° "
100:
    pop {pc}                        @ l'adresse de retour est restaurée directement dans le compteur d'instruction

