/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme affRegEtat64.s */
/* affichage des indicateurs d'état 64 bits  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

.equ LGZONEADR,   55

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
/********************************************************************/
/* macro d'enrobage affichage binaire d'un registre  avec étiquette */
/********************************************************************/
.macro affetattit str 
    str x0,[sp,-16]!          // save  registre
    adr x0,libetat1\@        // 
    bl afficherEtat          // affichage du registre en base 2
    ldr x0,[sp],16           // on restaure x0 pour avoir une pile réalignée
    b smacro1affetattit\@    // pour sauter le stockage de la chaine.
libetat1\@:  .asciz "\str"
.align 4
smacro1affetattit\@:
.endm

/*********************************/
/* Initialized data              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

szLigneEtat:         .ascii "Etats "
adresseLibEtat:      .fill LGZONEADR, 1, ' '
szValeursEtat:       .asciz  "\nZ=   N=   C=   V=       \n"
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    ands x0,x0,xzr
    affetattit  zero
    
    mov x0,10
    adds x0,x0,20
    affetattit  "Addition ok"

    mov x0,-1
    adds x0,x0,10
    affetattit  "depassement addition"
    
    mov x0,1
    lsl x0,x0,63
    sub x0,x0,1
    adds x0,x0,10
    affetattit  "overflow addition"
    
    mov x0,50
    subs x0,x0,20
    affetattit  "Soustraction OK"
    mov x0,10
    subs x0,x0,20
    affetattit  "depassement soustraction"

    mov x0,1
    lsl x0,x0,63
    subs x0,x0,10
    affetattit  "overflow soustraction"
    
    
    mov x0,10
    cmp x0,10
    affetattit  "test égalité"
    cset x0,eq
    bl afficherDecimal
    mov x0,10
    cmp x0,11
    affetattit  "test inégalité"
    cset x0,ne
    bl afficherDecimal
    
    mov x0,1
    lsl x0,x0,63
    add x0,x0,100          // grande valeur non signée
    cmp x0,11
    affetattit  "erreur test superieur "
    cset x0,gt 
    bl afficherDecimal
    mov x0,1
    lsl x0,x0,63
    add x0,x0,100          // grande valeur non signée
    cmp x0,11
    affetattit  "test superieur OK "
    cset x0,hi 
    bl afficherDecimal
    
    mov x0,-10
    cmp x0,11
    affetattit  "erreur test inférieur signé "
    cset x0,ls
    bl afficherDecimal
    
    mov x0,-10
    cmp x0,11
    affetattit  "test inférieur signé OK"
    cset x0,lt
    bl afficherDecimal
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne

/***************************************************/
/*   affichage des indicateurs du registre d'état     */
/***************************************************/
/* x0 contient l'adresse du titre à afficher */
afficherEtat:
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    mrs x4,nzcv                // save du registre d'état
    ldr x3,qAdradresseLibEtat  // adresse de stockage du resultat
    mov x2,#0
1:                             // boucle copie
    ldrb w1,[x0,x2]            // charge un octet
    cbz  w1,2f                 // zéro ?
    strb w1,[x3,x2]            // stocke dans zone affichage
    add x2,x2,#1               // increment indice
    cmp x2,#LGZONEADR          // longueur maxi ?
    ble 1b                     // non -> boucle
    b 4f
2:
    mov w1,#' '                 // on met des blancs en fin de libellé 
3:                              // pour effacer libellé précédent si plus grand
    cmp x2,#LGZONEADR
    bge 4f
    strb w1,[x3,x2]
    add x2,x2,#1
    b 3b                         // et boucle
4:
    ldr x1,qAdrszValeursEtat
    mov x2,49                   // 1
    mov x3,48                   // 0
    msr nzcv,x4                 // restaur registre d'état
    csel x0,x2,x3,eq            // si indicateur Z = 0 alors x0 = 49 sinon 48
    strb w0,[x1,#3]
    csel x0,x2,x3,mi            // indicateur négatif 
    strb w0,[x1,#8]
    csel x0,x2,x3,vs            // indicateur overflow
    strb w0,[x1,#18]
    csel x0,x2,x3,cs            // indicateur carry
    strb w0,[x1,#13]

    ldr x0,qAdrszLigneEtat     // affiche le résultat
    bl afficherMess
 
100:
    msr nzcv,x4                // restaur registre d'état
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret    
qAdrszLigneEtat:       .quad szLigneEtat
qAdradresseLibEtat:    .quad adresseLibEtat
qAdrszValeursEtat:     .quad szValeursEtat
    