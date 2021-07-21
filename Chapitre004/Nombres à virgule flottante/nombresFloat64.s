/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme nombresFloat.s */
/* traitement des nombres à virgule flottante 64 bits  */

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
/* Données initialisées              */
/*********************************/
.data
szMessDebutPgm:      .asciz "Début programme.\n"
szMessFinPgm:        .asciz "Fin normale du programme. \n"
szRetourLigne:       .asciz "\n"

szAfficheVal1:       .asciz "Valeur = %+09.15f\n"


.align 8
dNombre1:             .double 100
dNombre2:             .double 3.141592653589793
dNombre3:             .double 20
dNombre4:             .double 30

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
    adr x0,qOfszMessDebutPgm
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
    
    afficherLib "Affichage 1 "
    fmov d0,0.15625
    adr x0,qOfszAfficheVal1
    ldr x1,[x0]
    add x0,x0,x1
    bl printf
    
    afficherLib "Conversion et Affichage "
    mov x0,-155
    scvtf d0,x0                    // ou ucvtf pour non signé
    adr x0,qOfszAfficheVal1
    ldr x1,[x0]
    add x0,x0,x1
    bl printf
    
    
    afficherLib "chargement et affichage "
    adr x0,qOfsdNombre2
    ldr x1,[x0]
    add x0,x0,x1
    ldr d0,[x0]
    adr x0,qOfszAfficheVal1
    ldr x1,[x0]
    add x0,x0,x1
    bl printf
    
    afficherLib "chargement et addition "
    adr x0,qOfsdNombre1
    ldr x1,[x0]
    add x0,x0,x1
    ldr d0,[x0]
    adr x0,qOfsdNombre2
    ldr x1,[x0]
    add x0,x0,x1
    ldr d1,[x0]
    fadd d0,d0,d1           // addition
    adr x0,qOfszAfficheVal1
    ldr x1,[x0]
    add x0,x0,x1
    bl printf
    
    afficherLib "multiplication +  addition "
    adr x0,qOfsdNombre1
    ldr x1,[x0]
    add x0,x0,x1
    ldr d0,[x0]
    adr x0,qOfsdNombre2
    ldr x1,[x0]
    add x0,x0,x1
    ldr d1,[x0]
    adr x0,qOfsdNombre3
    ldr x1,[x0]
    add x0,x0,x1
    ldr d2,[x0]
    fmadd d0,d0,d2,d1               // multiplie d0 par d2 et ajoute le résultat à d3
    adr x0,qOfszAfficheVal1
    ldr x1,[x0]
    add x0,x0,x1
    bl printf                      // attention detruit les registres d0 à d?
    
        afficherLib "comparaison "
    adr x0,qOfsdNombre1
    ldr x1,[x0]
    add x0,x0,x1
    ldr d0,[x0]
    adr x0,qOfsdNombre2
    ldr x1,[x0]
    add x0,x0,x1
    ldr d1,[x0]
    adr x0,qOfsdNombre3
    ldr x1,[x0]
    add x0,x0,x1
    ldr d2,[x0]
    adr x0,qOfsdNombre4
    ldr x1,[x0]
    add x0,x0,x1
    ldr d3,[x0]
    fcmp d0,d1               // compare do et d1
    fcsel d0,d2,d3,gt        // si d0 > d1  met d2 dans d0 sinon met d4
    adr x0,qOfszAfficheVal1
    ldr x1,[x0]
    add x0,x0,x1
    bl printf

    adr x0,qOfszMessFinPgm
    ldr x1,[x0]
    add x0,x0,x1
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qOfszMessDebutPgm:    .quad szMessDebutPgm - .
qOfszMessFinPgm:      .quad szMessFinPgm - .
qOfszRetourLigne:     .quad szRetourLigne - .
qOfszAfficheVal1:     .quad szAfficheVal1 - .
qOfsdNombre1:             .quad dNombre1 - .
qOfsdNombre2:             .quad dNombre2 - .
qOfsdNombre3:             .quad dNombre3 - .
qOfsdNombre4:             .quad dNombre4 - .

/******************************************************************/
/*     affichage texte avec calcul de la longueur                */ 
/******************************************************************/
/* x0 contient l' adresse du message */
afficherMess:                  // INFO: afficherMess
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
    
 