/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme affmem64.s */
/* affichage des zones mémoire 64 bits  */

/************************************/
/* Constantes                       */
/************************************/
.equ STDOUT, 1      // Linux output console
.equ EXIT,   93     // Linux syscall 64 bits
.equ WRITE,  64     // Linux syscall 64 bits

.equ NBCARLIBEL, 40      // longueur du titre

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
/****************************************************/
/* macro de vidage memoire                          */
/****************************************************/
/* n'affiche que les adresses de zones ou les adresses des registre x0 et x1      */
.macro affichageMemoire str, adr, nb 
    stp x0,x1,[sp,-16]!        // save  registre
    stp x2,x3,[sp,-16]!        // save  registre
    mrs x3,nzcv                // save du registre d'état dans x3
    adr x2,lib1\@              // recup adresse libellé passé dans str
    .ifc \adr,x1
    mov x0,x1
    .else
    .ifnc \adr,x0
    ldr x0,zon1\@
    .endif
    .endif
    mov x1,#\nb                // nombre de bloc a afficher
    bl affmemoireTit
    msr nzcv,x3                // restaur registre d'état
    ldp x0,x1,[sp],16          // restaur des registre
    ldp x2,x3,[sp],16          // restaur des registr
    b smacro1affmemtit\@       // pour sauter le stockage de la chaine.
.ifnc \adr,x0
.ifnc \adr,x1
zon1\@:  .quad \adr
.endif
.endif
lib1\@:  .asciz "\str"
.align 4
smacro1affmemtit\@:
.endm

/*********************************/
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"
szTitre1:            .asciz "Affichage zones"

/*  donnees pour vidage mémoire */
szVidregistreMem: .ascii "Aff mémoire "
sadr1:            .ascii " adresse : "
sAdresseMem :     .fill 17,1,' '
sSuiteMem:        .fill NBCARLIBEL,1,' '
                  .asciz "\n"
sDebmem:          .fill 13, 1, ' '
s1mem:            .ascii " "
sZone1:           .fill 47, 1, ' '
s2mem:            .ascii " "
sZone2:           .fill 16, 1, ' '
s3mem:            .asciz "\n"

.align 8
qValeur1:            .quad 0x1234567890123456  // définit un double mot de 8 octets
qValeurNeg:          .int -1
tabValeurs:          .quad 1,2,3,4,5,6,7,8     // définit une table de double mots
/*********************************/
/* Données non initialisées       */
/*********************************/
.bss  
.align 8
qValeur2:           .skip 8       // réserve la place pour un double mot
szZoneConv:         .skip 20
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    afficherLib "Test routine :"
    ldr x0,qAdrqValeur1
    mov x1,4
    ldr x2,qAdrszTitre1
    bl affmemoireTit
 
    afficherLib "Test macro :"
    affichageMemoire "zones  1"  szMessFinPgm  5 
    
    ldr x1,qAdrqValeur2
    ldr x0,qConst1
    str x0,[x1]

    affichageMemoire "Stockage"  x1  2  // affichage de la zone adresse qui est dans x1
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrqValeur1:          .quad qValeur1
qAdrqValeur2:          .quad qValeur2
qAdrszTitre1:          .quad szTitre1
qConst1:               .quad 0x1111222233334444
/*******************************************/    
/* affichage zone memoire                  */
/*******************************************/    
/* x0  adresse memoire  x1 nombre de bloc x2 titre */
affmemoireTit:
    stp x0,lr,[sp,-16]!        // save  registres
    stp x1,x2,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    stp x5,x6,[sp,-16]!        // save  registres
    stp x7,x8,[sp,-16]!        // save  registres
    mov x4,x0                  // save adresse mémoire
    mov x6,x1                  // save nombre de bloc
    ldr x1,qAdrsAdresseMem     //adresse de stockage du resultat
    bl conversion16            // conversion en base 16
    mov x3,' '                 // remplacer le 0 final par un blanc
    strb w3,[x1,x0]
                               // recup libelle dans x2
    mov x7,#0
    ldr x5,qAdrsAdresse_suiteMem // adresse de stockage du resultat
1:                               // boucle copie
    ldrb w3,[x2,x7]
    cbz w3,2f
    beq 2f
    strb w3,[x5,x7]
    add x7,x7,#1
    cmp x7,NBCARLIBEL
    ble 1b
2:
    mov w3,#' '                 // on met des blancs en fin de libellé 
3:                              // pour effacer libellé précédent si plus grand
    cmp x7,#NBCARLIBEL
    bge 4f
    strb w3,[x5,x7]
    add x7,x7,#1
    b 3b                         // et boucle
4:
    mov x2,x4                        //récuperation debut memoire a afficher
    ldr x0,qAdrsAdresse_chaineMem    // affichage entete
    bl afficherMess
                                     //calcul du debut du bloc de 16 octets
    mov x1, x2, LSR #4               // x1 ← (x2/16)
    mov x1, x1, LSL #4               // x1 ← (x2*16)
    /* mettre une étoile à la position de l'adresse demandée*/
    mov x8,#3                       // 3 caractères pour chaque octet affichée 
    sub x0,x2,x1                    // calcul du deplacement dans le bloc de 16 octets
    mul x5,x0,x8                    // deplacement * par le nombre de caractères
    ldr x0,qAdrsAdresse_zone1       // adresse de stockage
    add x7,x0,x5                    // calcul de la position
    sub x7,x7,#1                    // on enleve 1 pour se mettre avant le caractère
    mov w0,#'*'           
    strb w0,[x7]                    // stockage de l'étoile
    
5:              // 3                    // debut boucle affichage des blocs
    mov x5,x1                       // afficher le debut  soit x1
    mov x0,x1
    ldr x1,qAdrszZoneConv           // conversion adresse du bloc en hexa
    bl conversion16                 // conversion en base 16
    mov x8,' '
    strb w8,[x1,x0]
                                    // recopie de 12 caractères de l'adresse
    mov x8,#3                       // pour supprimer les 4 premiers zeros
    mov x0,#0
    ldr x1,qAdrszZoneConv
    ldr x2,qAdrsAdresse_debmem     // et mettre le résultat dans la zone d'affichage
6:
    ldrb w4,[x1,x8]
    strb w4,[x2,x0]
    add x0,x0,#1
    add x8,x8,#1
    cmp x8,#15                     // arrêt au 15ième caractère
    ble 6b
                                   // balayer 16 octets de la memoire
    mov x8,#3
    mov x2,#0
    mov x1,x5
    
7:          //4                       // debut de boucle de vidage par bloc de 16 octets
    ldrb w4,[x1,x2]                // recuperation du byte à l'adresse début + le compteur
                                   // conversion byte pour affichage
    ldr x0,qAdrsAdresse_zone1      // adresse de stockage du resultat
    mul x5,x2,x8                   // calcul position x5 <- x2 * 3 
    add x0,x0,x5
    mov x3, x4, ASR #4             // x3 ← (x4/16)
    cmp x3,#9                      // inferieur a 10 ?
    bgt 8f
    add x5,x3,#48                  // oui
    b 9f
8:
    add x5,x3,#55                  // c'est une lettre en hexa
9:
    strb w5,[x0]                  // on le stocke au premier caractères de la position 
    add x0,x0,#1                  // 2ième caractere
    mov x5,x3,LSL #4              // x5 <- (x4*16)
    sub x3,x4,x5                  // pour calculer le reste de la division par 16
    cmp x3,#9                     // inferieur a 10 ?
    bgt 10f
    add x5,x3,#48
    b 11f
10:
    add x5,x3,#55
11:
    strb w5,[x0]                  // stockage du deuxieme caractere
    add x2,x2,#1                  // +1 dans le compteur
    cmp x2,#16                    // fin du bloc de 16 caractères ?
    blt 7b
                  /* affichage en caractères */
    mov x2,#0                     // compteur
12:                                // debut de boucle
    ldrb w4,[x1,x2]               // recuperation du byte à l'adresse début + le compteur
    cmp w4,#31                    // compris dans la zone des caractères imprimables ?
    ble 13f                        // non
    cmp w4,#125
    ble 14f
13:
    mov w4,#46                    // on force le caractere .
14:
    ldr x0,qAdrsAdresse_zone2     // adresse de stockage du resultat
    add x0,x0,x2
    strb w4,[x0]
    add x2,x2,#1
    cmp x2,#16                    // fin de bloc ?
    blt 12b    

    /* affichage resultats */
    ldr x0,qAdrsAdresse_debmem
    bl afficherMess
    mov w0,#' '
    strb w0,[x7]                 // on enleve l'étoile pour les autres lignes
    add x1,x1,#16                // adresse du bloc suivant de 16 caractères
    subs x6,x6,#1                // moins 1 au compteur de blocs
    bgt 5b                       // boucle si reste des bloc à afficher
100:                           // fin de la fonction
    ldp x7,x8,[sp],16          // restaur des  2 registres
    ldp x5,x6,[sp],16          // restaur des  2 registres
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x1,x2,[sp],16          // restaur des  2 registres
    ldp x0,lr,[sp],16          // restaur des  2 registres
    ret                        // retour adresse lr x30

qAdrsAdresse_chaineMem:        .quad szVidregistreMem
qAdrsAdresse_debmem:           .quad sDebmem
qAdrsAdresse_suiteMem:         .quad sSuiteMem
qAdrsAdresse_zone1:            .quad sZone1
qAdrsAdresse_zone2:            .quad sZone2
qAdrsAdresseMem:               .quad sAdresseMem
qAdrszZoneConv:                .quad szZoneConv
