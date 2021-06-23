/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé     */
.macro afficherLib str 
    push {r0}               @ save r0
    mrs r0,cpsr             @ save du registre d'état  dans r0
    push {r0}               @ puis sur la pile
    adr r0,libaff1\@        @ recup adresse libellé passé dans str
    bl afficherMess
    pop {r0}
    msr cpsr,r0             @ restaur registre d'état
    pop {r0}                @ on restaure R0 pour avoir une pile réalignée
    b smacroafficheMess\@   @ pour sauter le stockage de la chaine.
libaff1\@:     .ascii "\str"
               .asciz "\n"
.align 4
smacroafficheMess\@:     
.endm   @ fin de la macro
/*****************************************************************/
/* macro d'enrobage affichage hexa d'un registre  avec étiquette */
/****************************************************************/
.macro affreghexa str 
    push {r0}              @ save r0
    mrs r0,cpsr            @ save du registre d'état  dans r0
    push {r0}
    adr r0,libhex1\@       @ utilisation de adr suite pb gros programme
    bl afficherMess
    ldr r0,[sp,#4]         @ on remet en etat r0 pour l'afficher correctement
    bl afficherUnRegistre  @ affichage registre
    pop {r0}
    msr cpsr,r0            @restaur registre d'état
    pop {r0}               @ on restaure r0 pour avoir une pile réalignée
    b smacro1affhextit\@   @ pour sauter le stockage de la chaine.
libhex1\@:  .ascii "\str"
            .asciz " : "
.align 4
smacro1affhextit\@:
.endm   @ fin de la macro

/****************************************************/
/* macro de vidage memoire                          */
/****************************************************/
/* affiche que les adresses ou le registre r0       */
.macro affichageMemoire str, adr, nb 
    push {r0-r3}           @ save registres
    mrs r3,cpsr            @ save du registre d'état  dans r3
    adr r2,lib1\@          @ recup libellé passé dans str
    .ifnc \adr,r0
    ldr r0,zon1\@
    .endif
    mov r1,#\nb            @ nombre de bloc a afficher
    bl afficherMemoire
    msr cpsr,r3            @ restaure registre d'état
    pop {r0-r3}            @ restaure des registres
    b smacro1vidregtit\@   @ pour sauter le stockage de la chaine.
.ifnc \adr,r0
zon1\@:  .int \adr
.endif
lib1\@:  .asciz "\str"
.align 4
smacro1vidregtit\@:     
.endm                      @ fin de la macro
