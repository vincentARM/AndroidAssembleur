/* ARM assembleur Android termux  32 bits */
/*  program affDecimal32.s   */
/*  affichage décimal d'un registre. Opération addition   */
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
szZoneConv:           .space 11,' '
szZoneConvHexa:       .space 9,' '
/**************************************/
/* Données non initialisées               */
/**************************************/
.bss
//szZoneConv:           .skip 10
//szZoneConvHexa:       .skip 9
/**************************************/
/* Code du programme                  */
/**************************************/
.text
.global main 
main:
    ldr r0,iAdrszMessDebPgm        @ adresse du message 
    bl afficherMess                @ appel fonction d'affichage

    afficherLib "Vérification affichage décimal :"
    mov r0,#100                    @ met dans r0 un nombre décimal
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    afficherLib "Longueur :"
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    ldr r0,iAdrszZoneConv
    bl afficherMess 
    
    afficherLib "\nGrand nombre : "
    mov r1,#0xFFFF
    add r0,r1,r1,lsl #16
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r1,iAdrszZoneConvHexa
    bl conversion16
    afficherLib "Longueur :"
    ldr r0,iAdrszZoneConvHexa
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    ldr r0,iAdrszZoneConv
    bl afficherMess 
    
    afficherLib "\nAutre affectation grand nombre : "
    mov r0,#0xFFFF
    movt r0,#0xFFFF
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess 
    
    afficherLib "\nAffectation nombre en octal: "
    mov r0,#020
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    
    afficherLib "\nErreur affectation : "
    mov r0,#5678
    movt r0,#1234
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    
    afficherLib "\nAddition"
    mov r1,#200
    add r0,r1,#10
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess 
    
    afficherLib "\nAddition grand nombre"
    mov r1,#0xFFFF
    mov r2,#0xFFFA
    add r0,r2,r1,lsl #16       @ positionne dans r0 le nombre 4 294 967 290
    
    add r0,#20                 @ ajoute 20
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv      @ le résultat est faux !!!
    bl afficherMess 
    
    afficherLib "\nAddition grand nombre 2"
    mov r1,#0xFFFF
    mov r2,#0xFFFA
    add r0,r2,r1,lsl #16       @ positionne dans r0 le nombre 4 294 967 290
    
    adds r0,#2                  @ ajoute 2   et il n'y a pas de retenue
    //adds r0,#20                 @ ajoute 20 et il y a retenue
    bcc 1f
    afficherLib "Retenue positionnée. \n"
    b 2f
1:
   afficherLib "Pas de retenue. \n"
2:
                                    @ additions successives 
                                    
    afficherLib "Addition sur 64 bits "
    mov r1,#0xFFFF
    mov r6,#0xFFFA
    add r1,r6,r1,lsl #16           @ positionne dans r1 le nombre 4 294 967 290   (partie basse d'un nombre de 64 bits)
    mov r2,#5                     @ positionne 5 dans r2 partie haute du nombre de 64 bits
    mov r3,#20                     @ positionne 20 dans r3  partie basse du 2ième nombre de 64 bits
    mov r4,#10                     @ positionne 10 dans r4 partie haute du 2 iéme nombre
    adds r5,r1,r3                  @ ajoute les 2 parties basses 
    adc  r6,r2,r4                  @ ajoute les 2 parties hautes et la retenue
    mov r0,r5                      @ pour afficher la partie basse du résultat
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv          @ resultat partie basse
    bl afficherMess 
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    mov r0,r6                      @ pour afficher la partie haute
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv          @   resultat partie haute
    bl afficherMess 
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    
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
iAdrszZoneConvHexa:     .int szZoneConvHexa
/***************************************************/
/*   Conversion d'un registre en décimal non signé  */
/***************************************************/
/* r0 contient le registre   */
/* r1 contient l'adresse de la zone de conversion longueur >= 11 octets */
.equ LGZONE, 9
conversion10:
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
           
