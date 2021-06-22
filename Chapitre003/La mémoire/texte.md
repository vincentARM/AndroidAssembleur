Vu d’un programme assembleur, la mémoire mis à sa disposition par le système d’exploitation est divisée en plusieurs zones : 

        * .data : qui contient les données initialisées par le programmeur
        
        * .bss : qui contient les données initialisées à zéro par le système d’exploitation au chargement du programme
        
        * .text : qui contient les instructions en langage machine à exécuter
        
        * la pile : zone située en fin de la mémoire attribuée
        
        * le tas : zone comprise entre la dernière des 3 premières zones et la pile.
        
        * D’autres zones sont possibles d’usage particulier et définies par l’éditeur de lien.
        
L’ordre des 3 premières zones en mémoire est défini par les directives du linker mais en règle générale on trouve la section .text puis la .data puis la .bss. Mais leur définition dans le programme source peut être quelconque.
