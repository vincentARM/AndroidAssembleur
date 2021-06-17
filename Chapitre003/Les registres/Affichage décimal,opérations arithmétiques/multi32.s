/* ARM assembleur Android termux  32 bits */
/*  program multi32.s   */
/* multiplications   */
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
 
    
    afficherLib "\nMultiplication simple"
    mov r1,#200
    mov r2,#10
    mul r0,r1,r2
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess 
    
    afficherLib "\nMultiplication négative signée "
    mov r1,#-10
    mov r2,#-20
    
    mul r0,r1,r2               @ 
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS      @ 
    bl afficherMess 
    
 
    
    AfficherLib "Multiplication non signée avec résultat sur 64 bits " 
    mov r1,#0x8000   
    lsl r1,#16               @ charge 0x80000000 soit 2 puis 31 soit 2 147 483 648
    mov r2,#5
    umull r0,r3,r1,r2            @ multiplication non signée 
    AfficherLib "Partie basse "
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Partie haute "
    mov r0,r3
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Multiplication signée avec résultat sur 64 bits cas 1" 
    mov r1,#0x8000   
    lsl r1,#16                   @ charge 0x80000000 soit 2 puis 31 soit 2 147 483 648
    sub r1,#1                    @  valeur positive maxi  2 147 483 647
    mov r2,#-5
    smull r0,r3,r1,r2            @ multiplication non signée 
    AfficherLib "Partie basse "
    ldr r1,iAdrszZoneConv
    bl conversion10              @ la partie basse doit être considérée non signée
    ldr r0,iAdrszZoneConv        @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Partie haute "
    mov r0,r3
    ldr r1,iAdrszZoneConvS
    bl conversion10S            @ la partie haute doit être considérée signée 
    ldr r0,iAdrszZoneConvS      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
       AfficherLib "Multiplication signée avec résultat sur 64 bits cas 2" 
    mov r1,#0x8000   
    lsl r1,#16                  @ charge 0x80000000 soit 2 puis 31 soit 2 147 483 648
    add r1,#1                   @ ajoute 1 ce qui donne 2 147 483 649 donc la valeur negative  - 2 147 483 647
    mov r2,#-5
    smull r0,r3,r1,r2            @ multiplication de 2 nombres négatifs
    AfficherLib "Partie basse "
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Partie haute "
    mov r0,r3
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Multiplication signée avec résultat sur 64 bits cas 3" 
    mov r1,#0x8000   
    lsl r1,#16                   @ charge 0x80000000 soit 2 puis 31 soit 2 147 483 648
    add r1,#1                    @ ajoute 1 ce qui donne 2 147 483 649 donc la valeur negative  - 2 147 483 647
    mov r2,#5
    smull r0,r3,r1,r2            @ multiplication de 2 nombres négatifs
    AfficherLib "Partie basse "
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "Partie haute "
    mov r0,r3
    ldr r1,iAdrszZoneConvS
    bl conversion10S
    ldr r0,iAdrszZoneConvS
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "instruction mla "
    mov r3,#1000
    mov r1,#25
    mov r2,#5
    mla r0,r1,r2,r3            @ = (r1 * r2) + r3
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv      @ 
    bl afficherMess
    ldr r0,iAdrszRetourLigne
    bl afficherMess
    
    AfficherLib "instruction mls "
    mov r3,#202
    mov r1,#20
    mov r2,#10
    mls r0,r1,r2,r3            @ = r3 - (r1 * r2)
    ldr r1,iAdrszZoneConv
    bl conversion10
    ldr r0,iAdrszZoneConv      @ 
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
