/* Fichier des macros 64 bits ARM  */

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
/* macro d'affichage registre en hexadécimal                   */
/****************************************************/
.macro affregHexa str 
    stp x0,x1,[sp,-16]!        // save x0
    mov x1,x0
    mrs x0,nzcv             // save du registre d'état  dans x0
    str x0,[sp,-16]!        // puis sur la pile
    adr x0,libaff1\@        // recup adresse libellé passé dans str
    bl afficherMess
    mov x0,x1
    bl afficherHexa
    ldr x0,[sp],16
    msr nzcv,x0             // restaur registre d'état
    ldp x0,x1,[sp],16          // restaur x0
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
