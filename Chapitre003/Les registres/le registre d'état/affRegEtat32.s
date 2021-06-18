/* ARM assembleur Android termux  32 bits */
/*  program affRegEtat32.s   */
/* affichage des flags du registre d'état   */
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
/* pour affichage du registre d'état   */
szLigneEtat: .asciz "Etats :  Z=   N=   C=   V=       \n"
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
    
    afficherLib "Nombre négatif"
    movs r0,#-1
    bl affichetat
    
    afficherLib "Nombre zero"
    mov r1,#0
    movs r0,r1
    bl affichetat
        
    afficherLib "\nAddition signée non ok "
    ldr r1,iGrandNbPos
    mov r2,#20
    adds r0,r1,r2
    bl affichetat
    afficherLib "\nAddition non signée non ok "
    ldr r1,iGrandNbNS
    mov r2,#40
    adds r0,r1,r2
    bl affichetat
    
    afficherLib "\nsoustraction signée non ok "
    ldr r1,iGrandNbNeg
    mov r2,#20
    subs r0,r1,r2
    bl affichetat
    afficherLib "\nsoustraction non signée non ok "
    mov r1,#10
    mov r2,#40
    subs r0,r1,r2
    bl affichetat
    
    /* Comparaison      */ 
    afficherLib "\nTest égalité : "
    mov r0,#10
    cmp r0,#10
    bl affichetat
    moveq r0,#2                   @ si égal
    movne r0,#1                   @ si différent
    
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "\nTest inégalité non signée : "
    mov r0,#15
    cmp r0,#-20                  @ attention en non signée cette valeur est très grande
    bl affichetat
    movhi r0,#2                  @ si plus grand
    movls r0,#1                  @ si plus petit ou égal
    
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    afficherLib "\nTest inégalité signée : "
    mov r0,#15
    cmp r0,#-20
    bl affichetat
    movgt r0,#2                  @ si plus grand
    movle r0,#1                  @ si plus petit ou égal
    
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
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
iAdrszZoneConvS:        .int szZoneConvS
iAdrszZoneConvHexa:     .int szZoneConvHexa
iGrandNbPos:            .int 2147483640
iGrandNbNeg:            .int -2147483640
iGrandNbNS:             .int 4294967280
/***************************************************/
/*   affichage des indicateurs du registre d'état     */
/***************************************************/
affichetat:                 @ fonction
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
