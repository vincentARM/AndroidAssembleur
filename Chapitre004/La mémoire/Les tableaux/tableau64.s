/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme tableau64.s */
/* gestion des tableaux 64 bits  */

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

tbValeurs:          .quad 1,2,3,4,5,6,7,8     // définit une table de double mots
                     .equ NBELEMENTS,  (. - tbValeurs) / 8
/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
tbValeursCopie:        .skip 8 * NBELEMENTS
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    afficherLib "Affichage  poste 0"
    ldr x19,qAdrtbValeurs           // charge l'adresse du tableau32
    ldr x0,[x19]                    // charge le premier entier du tableau 
    affreghexa "Poste 0 :"
    
    afficherLib "Affichage poste 1"
    ldr x0,[x19,#8]                 // charge le deuxieme entier du tableau 
    affreghexa "Poste 1 :"
        
    afficherLib "Affichage  poste 5"
    mov x2,#5
    ldr x0,[x19,x2, lsl #3]         // calcule le déplacement (5 postes * 8 octets ) et charge le 6 ième entier
    affreghexa "Poste 5 :"
    
    mov x0,x19
    ldr x1,qAdrtbValeursCopie
    bl copierTableau
    
    affichageMemoire "Copie du tableau" x1 5
    
    mov x0,x19
    mov x1,#3                     // valeur dans tableau
    bl rechercherValeur
    
    mov x0,x19
    mov x1,#10                    // valeur non dans le tableau 
    bl rechercherValeur

    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrtbValeurs:         .quad tbValeurs
qAdrtbValeursCopie:    .quad tbValeursCopie
/***************************************************/
/*   copie de tableau d'entiers                     */
/***************************************************/
/* x0 contient l'adresse du tableau origine   */
/* x1 contient l'adresse de destination      */
/* Attention les registres ne sont pas sauvegardés !! */
copierTableau:                   // INFO: copierTableau
    mov x2,#0                    // init indice
1:
    ldr x3,[x0,x2,lsl #3]        // charge un poste du tableau d'origine
    str x3,[x1,x2,lsl #3]        // le stocke dans le tableau destination 
    add x2,x2,1                    // incremente l'indice
    cmp x2,#NBELEMENTS           // maxi atteint ?
    blt 1b                       // non -> boucle

100:
    ret                        // retour au programme appelant
/***************************************************/
/*   Recherche dans un tableau d'entiers            */
/***************************************************/
/* x0 contient l'adresse du tableau    */
/* x1 contient la valeur à rechercher      */
/* Attention les registres ne sont pas sauvegardés !! */
rechercherValeur:                   // INFO: rechercherValeur
    str lr,[sp,-16]!                // save registre de retour uniquement
    mov x2,#0                       // init indice
1:
    ldr x3,[x0,x2,lsl #3]           // charge un poste
    cmp x3,x1                       // égal à la valeur cherchée ?
    beq 2f                          // oui -> fin
    add x2,x2,1                       // non -> incremente l'indice
    cmp x2,#NBELEMENTS              // maxi atteint ?
    blt 1b                          // non -> boucle 
    afficherLib "Valeur non trouvée !!"
    b 100f
2:                                  // valeur trouvée affichage du N° de poste 
    afficherLib "Valeur trouvée"
    mov x0,x2
    affreghexa "poste N° "
100:
    ldr lr,[sp],16                       // l'adresse de retour est restaurée directement dans le compteur d'instruction
    ret
