/* Programme assembleur ARM Raspberry ou Android */
/* Assembleur 64 bits ARM Raspberry              */
/* programme division64.s */
/* exemple de division 64 bits  */

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
/*********************************/
/*  code section                 */
/*********************************/
.text
.global main 
main:                            // entrée du programme
    ldr x0,qAdrszMessDebutPgm
    bl afficherMess

    afficherLib "Division non signée :"
    mov x1,888
    mov x2,200
    udiv x0,x1,x2
    bl afficherDecimal
    msub x0,x0,x2,x1           // calcul du reste 
    bl afficherDecimal

    afficherLib "division signée :"
    mov x1,-1005
    mov x2,50
    sdiv x0,x1,x2
    bl afficherDecimalS
    msub x0,x0,x2,x1           // calcul du reste 
    bl afficherDecimalS
    
    afficherLib "division par 0 :"
    mov x1,1005
    mov x2,0
    udiv x0,x1,x2
    bl afficherDecimalS

    
    
    ldr x0,qAdrszMessFinPgm
    bl afficherMess
100:                            // fin standard du programme
    mov x0,0                    // code retour
    mov x8,EXIT                 // system call "Exit"
    svc #0
qAdrszMessDebutPgm:    .quad szMessDebutPgm
qAdrszMessFinPgm:      .quad szMessFinPgm
qAdrszRetourLigne:     .quad szRetourLigne
