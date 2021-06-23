/* routines assembleur Android 32 bits */

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
szMessAffReg:         .ascii "Valeur hexa du registre : "
sZoneConvHexaReg:     .skip 9
                      .asciz "\n"
                      
/* pour affichage du registre d'état   */
szLigneEtat: .asciz "Etats :  Z=   N=   C=   V=       \n"

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
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global conversion16,conversion2,afficherMess,conversion10,conversion10S,afficherEtat, afficherMemoire
.global afficherUnRegistre

/******************************************************************/
/*     Conversion registre 32 bits en hexadécimal                        */ 
/******************************************************************/
/* r0 contient la valeur et r1 contient l'adresse de la zone de conversion   */
/* r0 retourne la longueur utile de la zone  */
conversion16:                                          @ INFO: conversion16
    push {r1-r4,lr}                                    @ save registres
    mov r2,#28                                         @ position du bit de dépat (32 - 4)
    mov r4,#0xF0000000                                 @ masque
    mov r3,r0                                          @ sauve la valeur d'entrée
1:                                                     @ début de boucle
    and r0,r3,r4                                       @ application du masque sur la valeur
    lsr r0,r2                                          @ et deplacement du résultat à la position 0 à droite
    cmp r0,#10                                         @ compare à 10
    addlt r0,#48                                       @ <10  -> c'est un chiffre de 0 à 9
    addge r0,#55                                       @ >10  -> c'est une lettre  A-F
    strb r0,[r1],#1                                    @ stocke le caractère à la position de la zone de reception et incremente r1 de 1
    lsr r4,#4                                          @ déplace le masque de 4 positions à droite
    subs r2,#4                                         @ compteur de bits - 4 <= zero  ?
    bge 1b                                             @  non -> boucle
    mov r0,#0
    strb r0,[r1]                                       @ stocke le 0 final
    mov r0,#8                                          @ longueur de la zone
    
100: 
    pop {r1-r4,lr}                                     @ restaur registres 
    bx lr       
/******************************************************************/
/*     affichage d'un registre 32 bits en binaire                 */ 
/*     nouvelle routine utilsant lsls et le carry                 */
/******************************************************************/
/* r0 contient la valeur à afficher */
/* r1 contient l'adresse de la zone de conversion 40 octets  */
/* r0 retourne la longueur utile de la zone  */
conversion2:                   @ INFO: conversion2
    push {r1-r4,lr}            @ save des registres
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
    moveq r4,#' '
    strb r4,[r1,r3]            @
    addeq r3,r3,#1             @ si égaux à 0b111 alors on ajoute un blanc 
    cmp r2,#0                  @ 32 bits analysés ?
    bge 1b                     @ non -> boucle
    mov r0,#32 + 3             @ longueur de la zone
    pop {r1-r4,lr}             @ restaur des registres
    bx lr                      @ retour procedure

/******************************************************************/
/*     affichage des messages   avec calcul longueur              */ 
/******************************************************************/
/* r0 contient l adresse du message */
afficherMess:                    @ INFO: afficherMess
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
/***************************************************/
/*   Conversion d'un registre en décimal non signé  */
/***************************************************/
/* r0 contient le registre   */
/* r1 contient l'adresse de la zone de conversion longueur >= 11 octets */
.equ LGZONE, 9
conversion10:                  @ INFO: conversion10
    push {r1-r4,lr}            @ save des registres
    mov r3,#0
    strb r3,[r1,#LGZONE+1]     @ stocke le 0 final
    mov r4,#LGZONE
    mov r3,#10                 @ conversion decimale
1:                             @ debut de boucle de conversion
    mov r2,r0                  @ copie nombre départ ou quotients successifs
    udiv r0,r2,r3              @ division par le facteur de conversion
    mls r2,r0,r3,r2            @ calcul du reste de la division 
    add r2,#48                 @ car c'est un chiffre
    strb r2,[r1,r4]            @ stockage du byte au debut zone (r1) + la position (r4)
    sub r4,r4,#1               @ position précedente
    cmp r0,#0                  @ arret si quotient est égale à zero
    bne 1b    
                               @ mais il faut déplacer le résultat en début de zone
    adds r4,#1                 @ début du résultat
    moveq r0,#LGZONE           @ si début = 0 la zone est compléte
    beq 100f                   @ donc fin 
    mov r2,#0                  @ indice début zone
2:                             @ boucle de déplacement
    ldrb r3,[r1,r4]            @ charge un octet du résultat
    strb r3,[r1,r2]            @ et le stocke au début
    add r2,#1                  @ incremente la position de stockage
    add r4,r4,#1               @ incremente la position de chargement
    cmp r4,#LGZONE + 1         @ c'est la fin ??
    ble 2b                     @ boucle si r4 <= longueur zone (y compris le 0 final)
    sub r0,r2,#1               @ retourne la longueur du résultat (sans le zéro final)

100:
                               @ fin standard de la fonction
    pop {r1-r4,lr}             @ restaur des registres
    bx lr                      @ retour de la fonction en utilisant lr
/***************************************************/
/*   conversion registre en décimal   signé  */
/***************************************************/
/* r0 contient le registre   */
/* r1 contient l'adresse de la zone de conversion */
.equ LGZONECAL,   10
conversion10S:                       @ INFO: conversion10S
    push {r1-r6,lr}                  @ save des registres
    mov r5,r1                        @ debut zone stockage
    mov r6,#'+'                      @ par defaut le signe est +
    cmp r0,#0                        @ nombre négatif ?
    movlt r6,#'-'                    @ oui le signe est -
    neglt r0,r0                      @ et inversion valeur
    mov r4,#LGZONECAL                       @ longueur de la zone
    mov r2,r0                        @ nombre de départ des divisions successives
    mov r1,#10                       @ conversion decimale
1:                                   @ debut de boucle de conversion
    mov r0,r2                        @ copie nombre départ ou quotients successifs
    udiv r2,r0,r1
    mls  r3,r2,r1,r0                 @ calcul reste
    add r3,#48                       @ car c'est un chiffre 
    strb r3,[r5,r4]                  @ stockage du byte en début de zone r5 + la position r4
    sub r4,r4,#1                     @ position précedente
    cmp r2,#0                        @ arret si quotient est égale à zero
    bne 1b    
    
    add r4,r4,#1
    mov r2,#1                        @ deplacement en tête de zone
2:
    ldrb r1,[r5,r4]
    strb r1,[r5,r2]
    add r2,#1
    add r4,#1
    cmp r4,#LGZONECAL
    ble 2b
                                     @ stockage du signe à la première position
    strb r6,[r5] 
    mov r6,#0
    strb r6,[r5,r2]                  @ 0 final
    mov r0,r2                        @ retourne longueur
100:                                 @ fin standard de la fonction
    pop {r1-r6,lr}                   @ restaur des autres registres
    bx lr
/***************************************************/
/*   affichage des indicateurs du registre d'état     */
/***************************************************/
afficherEtat:                 @ INFO: afficherEtat
    push {r0,r1,r2,lr}      @ save registres
    mrs r2,cpsr             @ save du registre d'état  dans r2
    ldr r1,iAdrszLigneEtat
    beq 1f                  @ flag zero à 1
    mov r0,#48
    strb r0,[r1,#11]
    b 2f
1:    
    mov r0,#49              @ Zero à 1
    strb r0,[r1,#11]
2:    
    bmi 3f                  @ Flag negatif a 1
    mov r0,#48
    strb r0,[r1,#16]
    b 4f
3:    
    mov r0,#49
    strb r0,[r1,#16]
4:        
    bvs 5f                  @ flag overflow à 1 ?
    mov r0,#48
    strb r0,[r1,#26]
    b 6f
5:                          @ overflow = 1
    mov r0,#49
    strb r0,[r1,#26]
6:        
    bcs 7f                  @ flag carry à 1 ?
    mov r0,#48
    strb r0,[r1,#21]
    b 8f
7:                          @ carry = 1
    mov r0,#49
    strb r0,[r1,#21]
8:        
    mov r0,r1               @ affiche le résultat
    bl afficherMess 
 
100:                        @ fin standard de la fonction
    msr cpsr,r2             @ restaur registre d'état
    pop {r0,r1,r2,lr}       @ restaur des registres
    bx lr                   @ retour de la fonction en utilisant lr
iAdrszLigneEtat:           .int szLigneEtat
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
/***************************************************/
/*   Affichage d'un registre en hexa  */
/***************************************************/
/* r0 contient la valeur à afficher   */
.equ LGZONE, 9
afficherUnRegistre:            @ INFO: afficherUnRegistre
    push {r0-r2,lr}            @ save des registres
    ldr r1,iAdrsZoneConvHexaReg
    bl conversion16
    mov r2,#' '                @ caractère espace
    strb r2,[r1,r0]            @ efface le 0 final avec un espace
    ldr r0,iAdrszMessAffReg
    bl afficherMess
    pop {r0-r2,lr}             @ restaur des registres
    bx lr
iAdrszMessAffReg:           .int szMessAffReg
iAdrsZoneConvHexaReg:       .int sZoneConvHexaReg
