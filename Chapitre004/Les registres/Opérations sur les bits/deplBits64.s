/* Programme assembleur ARM android avec Termux */
/* Assembleur 64 bits ARM   */
/* Programme deplBits64.s */
/* Déplacement de bitses bits  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits
/*********************************/
/* Données initialisées          */
/*********************************/
.data
szMessDebutPgm:       .asciz "Début programme.\n"
szMessFinPgm:         .asciz "Fin normale du programme. \n"
szMessAffDeplGau:     .asciz "Résultat déplacement gauche :\n"
szMessAffDeplDro:     .asciz "Résultat déplacement droit :\n"
szMessAffDeplAri:     .asciz "Résultat déplacement droit arithmétique :\n"
szMessAffBinRot:      .asciz "Résultat rotation droite :\n"
szMessAffDeplR:       .asciz "Résultat deplacement droit avec récupération bit : \n"



szZoneBin:        .space 76,' '
                 .asciz "\n"
/*********************************/
/* données non initialisée       */
/*********************************/
.bss  
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                               // point d'entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    
    mov x1,#0b1110011
    mov x0,x1                      // affichage du registre de départ
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffDeplGau    // titre
    bl afficherMess
    lsl x0,x1,#5                   // déplacement de 5 positions à gauche
    bl afficherBinaire
    ldr x0,qAdrszMessAffDeplDro    // titre
    bl afficherMess
    mov x2,#3
    lsr x0,x1,x2                   // déplacement de 3 positions sur la droite
    bl afficherBinaire
    ldr x0,qAdrszMessAffBinRot     // titre
    bl afficherMess
    ror x0,x1,#3                   // rotation sur la droite de 3 positions 
    bl afficherBinaire
    ldr x0,qAdrszMessAffDeplAri     // titre
    bl afficherMess
    lsl x2,x1,#57
    mov x0,x2
    bl afficherBinaire
    asr x0,x2,#4                  // opérateur asr
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffDeplGau
    bl afficherMess
    mov x2,#0b11                   // maj x2 
    mov x0,x2,lsl #8               // copie dans x0 après déplacement à gauche de 8 bits
    bl afficherBinaire
    
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
    
100:                            // fin standard
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0

qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:       .quad szMessFinPgm
qAdrszMessAffDeplGau:   .quad szMessAffDeplGau
qAdrszMessAffDeplDro:   .quad szMessAffDeplDro
qAdrszMessAffBinRot:    .quad szMessAffBinRot
qAdrszMessAffDeplAri:   .quad szMessAffDeplAri
qAdrszMessAffDeplR:     .quad szMessAffDeplR
/******************************************************************/
/*     affichage d'un registre 64 bits en binaire                 */ 
/******************************************************************/
/* x0 contient la valeur à afficher */
afficherBinaire:               
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    stp x5,x6,[sp,-16]!        // save  registres
    ldr x1,qAdrszZoneBin       // zone reception
    mov x2,63                  // position bit de départ
    mov x3,0                   // position écriture caractère
    mov x5,1                   // valeur pour tester un bit

1:                             // debut boucle
    lsl x6,x5,x2               // déplacement valeur de test à la position à tester
    tst x0,x6                  // test du bit à cette position
    bne 2f                     
    mov w4,#48                 // bit egal à zero -> caractère ascii '0'
    b 3f
2:
    mov w4,#49                 // bit egal à un -> caractère ascii '1'
3:
    strb w4,[x1,x3]            // caractère ascii ->  zone d'affichage
    sub x2,x2,#1               // decrement pour bit suivant
    add x3,x3,#1               // + 1 position affichage caractère
    and x4,x2,#7               // extraction 3 derniers bits du compteur
    cmp x4,#7                  // egaux à 111 ?
    bne 4f
    add x3,x3,#1               // oui on ajoute un blanc 
4:
    cmp x2,#0                  // 64 bits analysés ?
    bge 1b                     // non -> boucle
    ldr x0,qAdrszZoneBin       // adresse du message résultat
    bl afficherMess            // affichage message
100:                           // fin standard de la fonction
    ldp x5,x6,[sp],16          // restaur des  2 registres
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret    
qAdrszZoneBin:          .quad szZoneBin       

/******************************************************************/
/*     affichage texte avec calcul de la longueur                */ 
/******************************************************************/
/* x0 contient l' adresse du message */
afficherMess:
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    str x8,[sp,-16]!           // save registre
    mov x2,#0                  // compteur taille
1:                             // boucle calcul longueur chaine
    ldrb w1,[x0,x2]            // lecture un octet
    cmp w1,#0                  // fin de chaine si zéro
    beq 2f
    add x2,x2,#1               // incremente compteur
    b 1b
2:
    mov x1,x0                  // adresse du texte
    mov x0,#STDOUT             // sortie Linux standard
    mov x8,#WRITE              // code call system "write"
    svc #0                     // call systeme Linux
    ldr x8,[sp],16             // restaur registre
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30
