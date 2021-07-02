/* Programme assembleur ARM android avec Termux */
/* Assembleur 64 bits ARM   */
/* Programme manipBits64.s */
/* Manipulation de bits  */

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
szMessAffComptGau:    .asciz "Comptage des zéros à gauche :\n"
szMessAffComptDro:    .asciz "comptage des 1 à gauche  :\n"
szMessAffCopieNP:     .asciz "Copie de n bits à la position p :\n"
szMessAffCopiePN:     .asciz "Copie de p bits à la position n :\n"
szMessAffAjoutGA:     .asciz "Ajout à gauche de p bits :\n"
szMessAffInvReg:      .asciz "Inversion des 64 bits du registre :\n"
szMessAffBswapp:      .asciz "Inversion ordre octets  :\n"
szMessAffBswapp16:    .asciz "Inversion ordre demi mots  :\n"
szMessAffBswapp32:    .asciz "Inversion ordre des mots  :\n"
szMessAffRazCopie:   .asciz "Raz registre puis copie bits  :\n"
szMessAffRazNCopie:  .asciz "Raz registre avec signe puis copie bits  :\n"
szMessAffExt32:      .asciz "Extension 32 bits :\n"


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

    
    mov x1,0b1110011
    mov x0,x1                      // affichage du registre de départ
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffComptGau    // titre
    bl afficherMess
    clz x0,x1                      // comptage des zeros à gauche
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffComptDro    // titre
    bl afficherMess
    mvn x2,x1                       // inversion des bits
    mov x0,x2                       // affichage du registre inversé
    bl afficherBinaire
    cls x0,x2                       // comptage des 1 à gauche
    bl afficherBinaire
    ldr x0,qAdrszMessAffCopieNP     // titre
    bl afficherMess
    mov x0,xzr                      // raz de x0 
    bfi x0,x1,#20,#3                // copie de 3 bits de la position 0 de  x1 à la position 20 de x0
    bl afficherBinaire
    ldr x0,qAdrszMessAffCopiePN     // titre
    bl afficherMess
    //mov x0,xzr                     // pas de raz de x0
    bl afficherBinaire               // affichage de x0 pour voir son contenu avant copie
    
    bfxil x0,x1,#4,#3                // copie de 3 bits de la position 4 de x1 à la position 0 de x0
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffAjoutGA     // titre
    bl afficherMess
    mov x2,0b1111000000
    extr x0,x1,x2,4                // extrait 4 bits de x1 à la position 0 et les mets à gauche de x2
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffInvReg
    bl afficherMess
    rbit x0,x1                // inversion des 64 bits x1
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffBswapp
    bl afficherMess
    bl afficherBinaire       // affichage x0 avant 
    mov x2,0b1111000011001100
    rev x0,x2                // inverse l'ordre des 8 octets 
    bl afficherBinaire
    mov x0,x2
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffBswapp16
    bl afficherMess
    bl afficherBinaire         // affichage x0 avant 
    mov x2,0b1111000011001100
    rev16 x0,x2                // inverse les 2 octets des demi mots
    bl afficherBinaire
    mov x0,x2
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffBswapp32
    bl afficherMess
    bl afficherBinaire         // affichage x0 avant 
    mov x2,0b1111000011001100
    rev32 x0,x2                // inverse les 4 octets des mots
    bl afficherBinaire
    mov x0,x2
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffRazCopie
    bl afficherMess
    bl afficherBinaire           // affichage x0 avant 
    ubfiz x0,x1,5,2              // raz x0 puis met les 2 bits en position 5 de x1 à la position 5 de x0
    bl afficherBinaire

    ldr x0,qAdrszMessAffRazNCopie
    bl afficherMess
    mvn x0,x0
    bl afficherBinaire           // affichage x0 avant 
    sbfiz x0,x1,5,2              // raz x0 tout en conservant le signe
                                 // puis met les 2 bits en position 5 de x1 à la position 5 de x0
    bl afficherBinaire
    
    ldr x0,qAdrszMessAffExt32
    bl afficherMess
    mvn w2,w1
    mov x0,x2
    bl afficherBinaire           // affichage x2 avant 
    sxtw x0,w2                   // copie 32 bits avec extention du signe
                                 // puis met les 2 bits en position 5 de x1 à la position 5 de x0
    bl afficherBinaire
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
    
100:                            // fin standard
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0

qAdrszMessDebutPgm:      .quad szMessDebutPgm
qAdrszMessFinPgm:        .quad szMessFinPgm
qAdrszMessAffComptGau:   .quad szMessAffComptGau
qAdrszMessAffComptDro:   .quad szMessAffComptDro
qAdrszMessAffCopieNP:    .quad szMessAffCopieNP
qAdrszMessAffCopiePN:    .quad szMessAffCopiePN
qAdrszMessAffAjoutGA :   .quad szMessAffAjoutGA 
qAdrszMessAffInvReg:     .quad szMessAffInvReg
qAdrszMessAffBswapp:     .quad szMessAffBswapp
qAdrszMessAffBswapp16:   .quad szMessAffBswapp16
qAdrszMessAffBswapp32:   .quad szMessAffBswapp32
qAdrszMessAffRazNCopie:  .quad szMessAffRazNCopie
qAdrszMessAffRazCopie:   .quad szMessAffRazCopie
qAdrszMessAffExt32:      .quad szMessAffExt32
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
