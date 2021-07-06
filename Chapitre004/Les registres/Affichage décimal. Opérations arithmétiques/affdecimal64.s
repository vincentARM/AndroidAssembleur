/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme affdecimal64.s */
/* affichage en base 10 et addition  */

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
/*********************************/
/* UnInitialized data            */
/*********************************/
.bss  
szZoneConv:             .skip 21
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess
    mov x0,sp
    bl afficherHexa             // affichage adresse de la pile 

    afficherLib "Affichage décimal :"
    mov x0,100
    ldr x1,qAdrszZoneConv
    bl conversion10             // conversion décimale
    bl afficherHexa             // pour vérifier la longueur retournée
    
    ldr x0,qAdrszZoneConv       // affichage de la zone de conversion
    bl afficherMess
    ldr x0,qAdrszRetourLigne    // affichage retour ligne
    bl afficherMess

    mov x0,sp
    bl afficherHexa             // affichage adresse de la pile pour vérifier si identique au début
 
    afficherLib "affectation et affichage grand nombre !\n"
    mov x0,0xFFFF
    movk x0,0xFFFF, lsl 16
    movk x0,0xFFFF, lsl 32
    movk x0,0xFFFF, lsl 48     // valeur maximun
    ldr x1,qAdrszZoneConv
    bl conversion10
    bl afficherHexa            // pour vérifier la longueur retournée
    
    ldr x0,qAdrszZoneConv
    bl afficherMess
    ldr x0,qAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Affectation nombre octal : "
    mov x0,020
    ldr x1,qAdrszZoneConv
    bl conversion10
    ldr x0,qAdrszZoneConv
    bl afficherMess
    ldr x0,qAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Addition nombres : "
    mov x0,1234
    add x0,x0,16384                    // addition valeur maximun
    ldr x1,qAdrszZoneConv
    bl conversion10
    ldr x0,qAdrszZoneConv
    bl afficherMess
    ldr x0,qAdrszRetourLigne
    bl afficherMess
    
    afficherLib "Addition valeur maxi : "
    mov x0,0xFFFF
    movk x0,0xFFFF, lsl 16
    movk x0,0xFFFF, lsl 32
    movk x0,0xFFFF, lsl 48     // valeur maximun
    add x0,x0,5
    ldr x1,qAdrszZoneConv
    bl conversion10
    ldr x0,qAdrszZoneConv
    bl afficherMess
    ldr x0,qAdrszRetourLigne
    bl afficherMess
    
    
    afficherLib "Addition valeur maxi et test retenue: "
    mov x0,0xFFFF
    movk x0,0xFFFF, lsl 16
    movk x0,0xFFFF, lsl 32
    movk x0,0xFFFF, lsl 48     // valeur maximun
    adds x0,x0,5
    bcs 1f                     // saut si retenue mise (branch if carry set)
    afficherLib "Pas de retenue"
    b 2f
1:
    afficherLib "Retenue"
2:

    afficherLib "Addition sur 128 bits "
    mov x1,0xFFFA
    movk x1,0xFFFF, lsl 16
    movk x1,0xFFFF, lsl 32
    movk x1,0xFFFF, lsl 48            // partie basse du 1er nombre
    mov  x2,5                         // partie haute du 1er nombre
    mov x3,20                         // partie basse du 2ieme nombre
    mov x4,2                          // partie haute du 2ième nombre
    adds x5,x1,x3                     // addition des parties basses
    adc  x6,x2,x4                     // addition des parties hautes avec prise en compte de la retenue
    
    afficherLib "parties basses :"
    mov x0,x5
    ldr x1,qAdrszZoneConv
    bl conversion10
    ldr x0,qAdrszZoneConv
    bl afficherMess
    ldr x0,qAdrszRetourLigne
    bl afficherMess
    afficherLib "parties hautes :"
    mov x0,x6
    ldr x1,qAdrszZoneConv
    bl conversion10
    ldr x0,qAdrszZoneConv
    bl afficherMess
    ldr x0,qAdrszRetourLigne
    bl afficherMess
    
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
qAdrszZoneConv:        .quad szZoneConv
/***************************************************/
/*   Conversion d'un registre en décimal non signé  */
/***************************************************/
/* x0 contient le registre   */
/* x1 contient l'adresse de la zone de conversion longueur >= 21 octets */
.equ LGZONE, 20
conversion10:
    stp x2,lr,[sp,-16]!        // save  registres
    stp x3,x4,[sp,-16]!        // save  registres
    mov x3,#0
    strb w3,[x1,#LGZONE+1]     // stocke le 0 final
    mov x4,#LGZONE
    mov x3,#10                 // conversion decimale
1:                             // debut de boucle de conversion
    mov x2,x0                  // copie nombre départ ou quotients successifs
    udiv x0,x2,x3              // division par le facteur de conversion
    msub x2,x0,x3,x2            // calcul du reste de la division 
    add x2,x2,#48              // car c'est un chiffre
    strb w2,[x1,x4]            // stockage du byte au debut zone (x1) + la position (x4)
    sub x4,x4,#1               // position précedente
    cmp x0,#0                  // arret si quotient est égale à zero
    bne 1b    
                               // mais il faut déplacer le résultat en début de zone
    adds x4,x4,#1              // début du résultat
    beq 90f                    // donc fin 
    mov x2,#0                  // indice début zone
2:                             // boucle de déplacement
    ldrb w3,[x1,x4]            // charge un octet du résultat
    strb w3,[x1,x2]            // et le stocke au début
    add x2,x2,#1                  // incremente la position de stockage
    add x4,x4,#1               // incremente la position de chargement
    cmp x4,#LGZONE + 1         // c'est la fin ??
    ble 2b                     // boucle si x4 <= longueur zone (y compris le 0 final)
    sub x0,x2,#1               // retourne la longueur du résultat (sans le zéro final)
    b 100f
90:
    mov x0,#LGZONE           // si début = 0 la zone est compléte
100:
    ldp x3,x4,[sp],16          // restaur des  2 registres
    ldp x2,lr,[sp],16          // restaur des  2 registres
    ret    
