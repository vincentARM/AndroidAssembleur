/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme pile64.s */
/* exemple utilisation de la pile 64 bits  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

/****************************************************/
/* fichier des macros                               */
/****************************************************/
.include "../ficmacros64.inc"


/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

.align 8
tbValeur1:            .quad 1,2,3,4,5,6,7,8,9
                       .equ NBELEMENTS, (. - tbValeur1) / 8

/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8

/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess
    
    ldr x19,qAdrtbValeur1        // adresse du tableau
    afficherLib "Appel 1 "
    mov x0,#5                    // rang du poste à extraire
    stp x0,x19,[sp,-16]!         // mets les paramètres sur la pile
    bl lireValeur
    affreghexa "retour = " 
    
    afficherLib "Utilisation pile : "
    mov x0,x19                    // cette fois ci on passe l'adresse du tableau par le registre x0
    bl extractSousTableau
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrtbValeur1:         .quad tbValeur1
/***************************************************/
/*   lecture valeur d'un tableau              */
/***************************************************/
/* les paramètres sont passées sur la pile : adresse du tableau et N   */
lireValeur:                    // INFO: lireValeur
    stp x1,lr,[sp,-16]!        // save  registres
    stp x2,fp,[sp,-16]!        // save  registres
    add fp,sp,#8 * 4           // 8 octets * nb registres sauvés
    mov x0,fp                  // affichage de la pile
    affichageMemoire "fp = " x0 4
    
    ldr x1,[fp]
    ldr x0,[fp,#8]
    affreghexa "param 2 = " 
    ldr x0,[x0,x1,lsl #3]
 
100:
    ldp x2,fp,[sp],16             // restaur  registres
    ldp x1,lr,[sp],16             // restaur registres
    add sp,sp,16                  // alignement pile car 2 paramètres mis sur la pile
    ret


/***************************************************/
/*   utilisation données internes              */
/***************************************************/
/* x0 contient l'adresse du tableau  */
extractSousTableau:            // INFO: extractSousTableau
    stp x1,lr,[sp,-16]!        // save  registres
    stp x2,fp,[sp,-16]!        // save  registres
    sub sp,sp,#8 * 6           // reserve 48 octets sur la pile (doit être un multiple de 16)
    mov fp,sp                  // garde l'adresse du début de la zone
    mov x1,#0                  // indice
    
1:
    ldr x2,[x0,x1,lsl #3]      // charge un entier du tableau
    str x2,[fp,x1,lsl #3]      // et le stocke dans la zone reservée de la pile
    add x1,x1,#1               // poste suivant
    cmp x1,#5                  // ne stocke que les 5 premiers
    blt 1b 
                               // verification du stockage
                               
    mov x0,fp
    affichageMemoire "fp = " x0 4
    
    ldr x0,[fp,#16]             // charge le 3ième poste de la zone reservée
    affreghexa "valeur  = " 
 
100:
    add sp,sp,#8 * 6           // reàlignement de la pile
    ldp x2,fp,[sp],16          // restaur  registres
    ldp x1,lr,[sp],16          // restaur registres
    ret
    
 