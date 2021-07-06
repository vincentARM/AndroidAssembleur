/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme soustraction64.s */
/* affichage en base 10 signé et soustraction  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
.macro afficherLib str 
    str x0,[sp,-16]!        // save x0
    mrs x0,nzcv             // save du registre d'état  dans x0
    str x0,[sp,-16]!        // puis sur la pile
    adr x0,libaff1\@        // recup adresse libellé passé dans str
    bl afficherMess
    ldr x0,[sp],16
    msr nzcv,x0             // restaur registre d'état
    ldr x0,[sp],16          // restaur x0
    b smacroafficheMess\@   // pour sauter le stockage de la chaine.  
libaff1\@:     .ascii "\str"
               .asciz "\n"
.align 4
smacroafficheMess\@:     
.endm                       // fin de la macro


/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"
szMessAffDec:        .asciz "Affichage décimal : "
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
szZoneConvDec:             .skip 22
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    afficherLib "Soustraction :"
    mov x1,888
    mov x2,200
    sub x0,x1,x2
    bl afficherDecimal

    afficherLib "Soustraction fausse :"
    mov x1,10
    mov x2,20
    sub x0,x1,x2
    bl afficherDecimal
    
    afficherLib "Soustraction avec retenue :"
    mov x1,10
    mov x2,20
    subs x0,x1,x2
    bcc 1f
    afficherLib "Pas de retenue "
    b 2f
1:
    afficherLib "Retenue "
2:
  
    mov x0,-10
    bl afficherDecimalS
    
    mov x0,10
    bl afficherDecimalS
    
    mov x0,1
    lsl x0,x0,63            // calcule 2 puissance 63 = plus grosse valeur négative
    bl afficherDecimalS
    
    mov x0,1
    lsl x0,x0,63
    sub x0,x0,1            // calcule 2 puissance 63 - 1 = plus grosse valeur positive.
    bl afficherDecimalS
    
    afficherLib " Addition non signée :"
    mov x0,1
    lsl x0,x0,63
    sub x0,x0,8           // calcule  9 223 372 036 854 775 800 
    add x0,x0,20          // ajoute 20
    bl afficherDecimal    // affiche un nombre non signé
    
    afficherLib " Addition signée avec erreur :"
    mov x0,1
    lsl x0,x0,63
    sub x0,x0,8           // calcule  9 223 372 036 854 775 800 
    add x0,x0,20          // ajoute 20
    bl afficherDecimalS   // affiche un nombre négatif
    
    mov x0,1
    lsl x0,x0,63
    sub x0,x0,8           // calcule  9 223 372 036 854 775 800 
    adds x0,x0,20         // ajoute 20 et positionne les indicateurs
    bvs 3f                // saut si indicateur overflow 
    afficherLib "Pas de retenue "
    b 4f
3:
    afficherLib "Retenue "
4:
    
    
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
/******************************************************************/
/*     affichage registre en décimal signé                    */ 
/******************************************************************/
/* r0 contient la valeur   */
afficherDecimalS:              // afficherDecimalS
    stp x1,lr,[sp,-16]!        // save  registres
    str x0,[sp,-16]!           // save 1 registre
    ldr x1,qAdrszZoneConvDec
    bl conversion10S           // conversion décimal signée de x0
    ldr x0,qAdrszMessAffDec
    bl afficherMess            // affiche le titre
    ldr x0,qAdrszZoneConvDec
    bl afficherMess            // affiche la zone de conversion
    ldr x0,qAdrszRetourLigne
    bl afficherMess            // et un retour à la ligne
    ldr x0,[sp],16
    ldp x1,lr,[sp],16          // restaur registres
    ret
qAdrszMessAffDec:            .quad szMessAffDec
qAdrszZoneConvDec:           .quad szZoneConvDec

/******************************************************************/
/*     conversion décimale signée                             */ 
/******************************************************************/
/* x0 contient la valeur à convertir  */
/* x1 contient la zone receptrice  longueur >= 21 */
/* la zone recptrice contiendra la chaine ascii cadrée à gauche */
/* et avec un zero final */
/* x0 retourne la longueur de la chaine sans le zero */
.equ LGZONECONV,   21
conversion10S:
    stp x5,lr,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    cmp x0,0
    bge 11f
    mov x3,'-'
    neg x0,x0                  // inverse le nombre si négatif
    b 12f
11:
    mov x3,'+'
12:
    strb w3,[x1]
    mov x4,#LGZONECONV         // position dernier chiffre
    mov x5,#10                 // conversion decimale
1:                             // debut de boucle de conversion
    mov x2,x0                  // copie nombre départ ou quotients successifs
    udiv x0,x2,x5              // division par le facteur de conversion
    msub x3,x0,x5,x2           //calcul reste
    add x3,x3,#48              // car c'est un chiffre
    sub x4,x4,#1               // position précedente
    strb w3,[x1,x4]            // stockage du chiffre
    cbnz x0,1b                 // arret si quotient est égale à zero
    mov x2,LGZONECONV          // calcul longueur de la chaine (21 - dernière position)
    sub x0,x2,x4               // car pas d'instruction rsb en 64 bits
                               // mais il faut déplacer la zone au début
    cmp x4,1
    beq 3f                     // si pas complète
    mov x2,1                   // position début  
2:    
    ldrb w3,[x1,x4]            // chargement d'un chiffre
    strb w3,[x1,x2]            // et stockage au debut
    add x4,x4,#1               // position suivante
    add x2,x2,#1               // et postion suivante début
    cmp x4,LGZONECONV - 1      // fin ?
    ble 2b                     // sinon boucle
3: 
    mov w3,0
    strb w3,[x1,x2]            // zero final
    add x0,x0,1                // longueur chaine doit tenir compte du signe
100:
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x5,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30
    