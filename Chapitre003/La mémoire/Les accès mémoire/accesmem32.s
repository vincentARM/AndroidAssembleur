/* ARM assembleur Android termux  32 bits */
/*  program accesmem32.s   */
/* squelette de programme assembleur 32 bits   */
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

/**************************************/
/* Données initialisées               */
/**************************************/
.data
szMessDebPgm:         .asciz "Début du programme 32 bits. \n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szRetourLigne:        .asciz "\n"
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
iValeurstk1:          .int 0
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage
    
    afficherLib "Chargement adresse entier 1"
    ldr r0,iAdriValeur1            @ charge l'adresse
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess

    afficherLib "Chargement entier 1"
    ldr r1,iAdriValeur1          @ charge l'adresse
    ldr r0,[r1]                  @ charge la valeur de l'adresse contenue dans r1
    ldr r1,iAdrszZoneConvHexa    @ affiche la valeur
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    ldr r1,=iValeur1              @ autre manière de charger l'adresse de l'entier
    ldr r0,[r1]                   @ et charge la valeur de l'adresse contenue  dans r1
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess

    afficherLib "Chargement byte 0"
    ldr r1,iAdriValeur1
    ldrb r0,[r1]                  @ charge le premier octet (indice 0)
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Chargement byte 1"
    ldr r1,iAdriValeur1
    ldrb r0,[r1,#1]             @ charge le 2ième octet  (indice 1)
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Chargement halfword 2"
    ldr r1,iAdriValeur1
    ldrh r0,[r1,#2]              @ charge 2 octets
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Chargement octet chaine de caractère"
    ldr r1,iAdrszChaine
    mov r2,#4                   @ prépare l'indice
    ldrb r0,[r1,r2]             @ affiche le 5 ième caractère
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
     afficherLib "Chargement octet avec post increment"
     afficherLib "Adresse départ :"
    ldr r2,iAdrszChaine
    mov r0,r2
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Valeur :"
    ldrb r0,[r2],#1              @ charge le 1er octet, et incremente r2 de 1
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Nouvelle adresse : "
    mov r0,r2
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Valeur suivante : "
    ldrb r0,[r2],#1             @ charge le 2ième octet, et incremente r2 de 1
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Chargement octet avec maj adresse calculée"
    ldr r2,iAdrszChaine        @ adresse début chaine
    ldrb r0,[r2,#1]!           @ charge l'octet 1 (qui est en 2ième position)
    ldr r1,iAdrszZoneConvHexa  @ et met à jour la nouvelle adresse dans r2
    bl conversion16
    ldr r0,iAdrszZoneConvHexa  @ affiche la valeur
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Nouvelle adresse :"
    mov r0,r2                  @ affiche la nouvelle adresse
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Valeur suivante : "
    ldrb r0,[r2,#1]!           @ et la valeur suivante
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Chargement octet avec registre post increment"
    ldr r2,iAdrszChaine        @ adresse de départ
    mov r3,#3                  @ increment
    ldrb r0,[r2],r3            @ charge le 3ième caractère et incremente r2 de 3
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Nouvelle adresse :"
    mov r0,r2                  @ affiche la nouvelle adresse
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Valeur suivante : "
    ldrb r0,[r2],r3
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Chargement multiple"
    ldr r0,iAdriValeur1           @ adresse du premier entier
    ldm r0,{r1-r3}                @ charge dans r1, r2 et r3 les 3 entiers successifs
    mov r0,r1                     @ affiche le premier
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    mov r0,r2                    @ affiche le 2ième
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    mov r0,r3                    @ affiche le 3ième
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Chargement 8 octets dans 2 registres "
    ldr r1,iAdrqValeur1
    ldrd  r2,r3,[r1]            @ registre pair en premier et successifs
    mov r0,r2
    ldr r1,iAdrszZoneConvHexa   @ affiche première partie qui est les 4 derniers octets
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    mov r0,r3                   @ affiche deuxième partie qui est les 3 premiers octets
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Stockage entier"
    ldr r2,iAdriValeurstk1     @ charge l'adresse de stockage 
    mov r1,#100                @ valeur à stocker
    str r1,[r2]                @ stocke l'entier 
    ldr r0,[r2]                @ charge l'entier pour vérification
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess

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
iAdrqValeur1:           .int qValeur1
