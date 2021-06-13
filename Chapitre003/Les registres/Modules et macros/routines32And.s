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

/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
szZoneHexa:        .skip  9                    @ reserve 9 octets à zéro pour zone de conversion
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global conversion16,conversion2,afficherMess

/******************************************************************/
/*     Conversion registre 32 bits en hexadécimal                        */ 
/******************************************************************/
/* r0 contient la valeur et r1 contient l'adresse de la zone de conversion   */
/* r0 retourne la longueur utile de la zone  */
conversion16:
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
conversion2:  
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
    