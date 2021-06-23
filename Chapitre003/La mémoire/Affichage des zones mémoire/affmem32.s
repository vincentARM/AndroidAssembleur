/* ARM assembleur Android termux  32 bits */
/*  program affmem32.s   */
/* affichage des zones mémoire   */
/**************************************/
/* Constantes                         */
/**************************************/
.equ EXIT,         1      @ code appel système Linux
/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé     */
.macro afficherLib str 
    push {r0}               @ save r0
    mrs r0,cpsr             @ save du registre d'état  dans r0
    push {r0}               @ puis sur la pile
    adr r0,libaff1\@        @ recup adresse libellé passé dans str
    bl afficherMess
    pop {r0}
    msr cpsr,r0             @ restaur registre d'état
    pop {r0}                @ on restaure R0 pour avoir une pile réalignée
    b smacroafficheMess\@   @ pour sauter le stockage de la chaine.
libaff1\@:     .ascii "\str"
               .asciz "\n"
.align 4
smacroafficheMess\@:     
.endm   @ fin de la macro
/****************************************************/
/* macro de vidage memoire                          */
/****************************************************/
/* affiche que les adresses ou le registre r0       */
.macro affichageMemoire str, adr, nb 
    push {r0-r3}           @ save registres
    mrs r3,cpsr            @ save du registre d'état  dans r3
    adr r2,lib1\@          @ recup libellé passé dans str
    .ifnc \adr,r0
    ldr r0,zon1\@
    .endif
    mov r1,#\nb            @ nombre de bloc a afficher
    bl afficherMemoire
    msr cpsr,r3            @ restaure registre d'état
    pop {r0-r3}            @ restaure des registres
    b smacro1vidregtit\@   @ pour sauter le stockage de la chaine.
.ifnc \adr,r0
zon1\@:  .int \adr
.endif
lib1\@:  .asciz "\str"
.align 4
smacro1vidregtit\@:     
.endm                      @ fin de la macro
/**************************************/
/* Données initialisées               */
/**************************************/
.data
szMessDebPgm:         .asciz "Début du programme 32 bits. \n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szRetourLigne:        .asciz "\n"
szLib:                .asciz "Exemple1"
                                        @ donnees pour vidage mémoire
szAffMem:      .ascii "Aff mémoire "
sAdr1:         .ascii " adresse : "
sAdresseMem :  .ascii "          "
sSuiteMem:     .fill NBCARLIBEL,1,' '
               .asciz "\n"
sDebmem: .fill 9, 1, ' '
s1mem: .ascii " "
sZone1: .fill 48, 1, ' '
s2mem: .ascii " "
sZone2: .fill 16, 1, ' '
s3mem: .asciz "\n"

szChaine:             .asciz "ABCDEFG"         @ chaine de caractère
bOctet1:              .byte 0x12               @ octet
.align 2
hDemiMot1:            .hword 0x1234            @ demi mot  de 16 bits ( 2 octets)

.align 4
iValeur1:             .int 0x12345678          @ entier de 4 octets ou 32 bits
iValeur2:             .int 0x1000
iValeur3:             .word 0x2222             @ idem

.align 8
qValeur1:              .quad 0x1234567866666666 @ double mot de 8 octets ou 64 bits
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneConv:           .skip 11
szZoneConvS:          .skip 12
szZoneConvHexa:       .skip 9
.align 4
iValeurstk1:             .int 0
hValeurstk2:             .skip 2
bValeurstk3:             .skip 1
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
    
    
    afficherLib "Adresse chaine :"
    ldr r0,iAdrszChaine            @ charge l'adresse
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    ldr r0,iAdrszChaine            @ adresse de départ
    mov r1,#4                      @ 4 blocs
    ldr r2,iAdrszLib               @ libelle titre
    bl afficherMemoire

    
    
    afficherLib "Stockage valeurs"
    ldr r2,iAdriValeurstk1         @ charge l'adresse de stockage 
    mov r1,#100                    @ valeur à stocker
    str r1,[r2]                    @ stocke l'entier 
    
    ldr r2,iAdrhValeurstk2         @ charge l'adresse de stockage 
    mov r1,#0x4567                 @ valeur à stocker
    strh r1,[r2]                   @ stocke un demi mot
    
    ldr r2,iAdrbValeurstk3        @ charge l'adresse de stockage 
    mov r1,#0b1010                @ valeur à stocker
    strb r1,[r2]                  @ stocke un octet
    
    ldr r0,iAdriValeurstk1
    affichageMemoire Exemple2 r0 2
    

                                   @ exemple macro
    affichageMemoire Exemple3 .data 2

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
iAdriValeur1:           .int iValeur1
iAdriValeur2:           .int iValeur2
iAdrszChaine:           .int szChaine
iAdriValeurstk1:        .int iValeurstk1
iAdrhValeurstk2:        .int hValeurstk2
iAdrbValeurstk3:        .int bValeurstk3
iAdrqValeur1:           .int qValeur1
iAdrszLib:              .int szLib
/*******************************************/    
/* affichage zone memoire                  */
/*******************************************/    
/*   r0  adresse memoire  r1 nombre de bloc r2 titre */
.equ NBCARLIBEL, 45              @ taille de la zone libellé
afficherMemoire:                 @ INFO: afficherMemoire
    push {r0-r8,lr}
    mov r4,r0                    @ début adresse mémoire
    mov r6,r1                    @ nombre de blocs
    ldr r1,iAdrsAdresseMem       @ adresse de stockage du resultat

    bl conversion16
    add r1,r0
    mov r0,#' '                  @ espace dans 0 final
    strb r0,[r1]
                                 @ recup libelle dans r2
    mov r0,#0
    ldr r5,iAdrSuiteMem          @ adresse de stockage du resultat
1:                               @ boucle copie du libellé 
    ldrb r3,[r2,r0]
    cmp r3,#0
    strneb r3,[r5,r0]
    addne r0,#1
    bne 1b        
    mov r3,#' '                  @ et complément de la zone avec des blancs
2:                               @ pour effacer un éventuel libellé plus long
    cmp r0,#NBCARLIBEL
    strltb r3,[r5,r0]
    addlt r0,#1
    blt 2b
    
    ldr r0,iAdrszAffMem          @ affichage entete
    bl afficherMess

                                 @ calculer debut du bloc de 16 octets
    mov r1, r4, LSR #4           @ r1 ← (r4/16)
    mov r3, r1, LSL #4           @ r3 ← (r1*16)
                                 @ mettre une étoile à la position de l'adresse demandée
    mov r8,#3                    @ 3 caractères pour chaque octet affiché
    sub r0,r4,r3                 @ calcul du deplacement dans le bloc de 16 octets
    mul r5,r0,r8                 @ deplacement * par le nombre de caractères
    ldr r0,iAdrsZone1            @ adresse de stockage
    add r7,r0,r5                 @ calcul de la position
    sub r7,r7,#1                 @ on enleve 1 pour se mettre avant le caractère
    mov r0,#'*'           
    strb r0,[r7]                 @ stockage de l'étoile
3:
                                 @ afficher le debut  soit r3
    mov r0,r3
    ldr r1,iAdrsDebmem
    bl conversion16
    add r1,r0                    @ pour mettre un blanc à la place du zéro final
    mov r0,#' '
    strb r0,[r1]
                                 @ balayer 16 octets de la memoire
    mov r8,#3
    mov r2,#0
4:                               @ debut de boucle de vidage par bloc de 16 octets
    ldrb r4,[r3,r2]              @ recuperation du byte à l'adresse début + le compteur
                                 @ conversion byte pour affichage
    ldr r0,iAdrsZone1            @ adresse de stockage
    mul r5,r2,r8                 @ calcul position r5 <- r2 * 3 
    add r0,r5
    mov r1, r4, LSR #4           @ r1 ← (r4/16)
    cmp r1,#9                    @ inferieur a 10 ?
    addle r5,r1,#48              @ oui
    addgt r5,r1,#55              @ c'est une lettre en hexa
    strb r5,[r0]                 @ on le stocke au premier caractère de la position
    add r0,#1                    @ 2ième caractere
    mov r5,r1,LSL #4             @ r5 <- (r1*16)
    sub r1,r4,r5                 @ pour calculer le reste de la division par 16
    cmp r1,#9                    @ inferieur a 10 ?
    addle r5,r1,#48
    addgt r5,r1,#55
    strb r5,[r0]                 @ stockage du deuxieme caractere
    add r2,r2,#1                 @ +1 dans le compteur
    cmp r2,#16                   @ fin du bloc de 16 caractères ? 
    blt 4b
                                 @ vidage en caractères
    mov r2,#0                    @ compteur
5:                               @ debut de boucle
    ldrb r4,[r3,r2]              @ recuperation du byte à l'adresse début + le compteur
    cmp r4,#31                   @ compris dans la zone des caractères imprimables ?
    ble 6f                       @ non
    cmp r4,#125
    ble 7f
6:
    mov r4,#46                   @ on force le caractere .
7:
    ldr r0,iAdrsZone2            @ adresse de stockage du resultat
    add r0,r2
    strb r4,[r0]
    add r2,r2,#1
    cmp r2,#16                   @ fin de bloc ?
    blt 5b    
                                 @ affichage resultats */
    ldr r0,iAdrsDebmem
    bl afficherMess
    mov r0,#' '
    strb r0,[r7]                 @ on enleve l'étoile pour les autres lignes
    
    add r3,r3,#16                @ adresse du bloc suivant de 16 caractères
    subs r6,#1                   @ moins 1 au compteur de blocs
    bgt 3b                       @ boucle si reste des bloc à afficher
    
                                 @ fin de la fonction 
    pop {r0-r8,lr}               @ restaur des registres
    bx lr
iAdrszAffMem:     .int szAffMem
iAdrsAdresseMem:  .int sAdresseMem
iAdrsDebmem:      .int sDebmem 
iAdrSuiteMem:     .int sSuiteMem
iAdrsZone1:       .int sZone1
iAdrsZone2:       .int sZone2
