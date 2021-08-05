### Appel du système d’exploitation.

Dans l »assembleur ARM, il n’existe pas d’instructions d’entrées sorties.  Pour gérér les périphériques, les processeurs ARM utilisent des accès mémoire sur des adresses réservées (voir la documentation arm).

Mais nos programmes assembleur lancés sous linux, ne peuvent pas accéder à ces adresses, ils sont obligés de passer par des appels au système d’exploitation.

Nous avons vu le cas dès le premier programme pour afficher un message où nous avons dû faire appel à la fonction Write de Linux.

La convention d’appel précise que les paramètres sont passés dans les registres r0 à r6, et le code fonction dans le registre r7 . L’appel s’effectue avec l’instruction svc 0 et après l’appel, le code retour se trouve dans le registre r0. Le plus souvent s’il est négatif, il s’agit d’une erreur. 
Voici une liste des codes habituels :
```
#define EPERM            1      /* Operation not permitted */
#define ENOENT           2      /* No such file or directory */
#define ESRCH            3      /* No such process */
#define EINTR            4      /* Interrupted system call */
#define EIO              5      /* I/O error */
#define ENXIO            6      /* No such device or address */
#define E2BIG            7      /* Arg list too long */
#define ENOEXEC          8      /* Exec format error */
#define EBADF            9      /* Bad file number */
#define ECHILD          10      /* No child processes */
#define EAGAIN          11      /* Try again */
#define ENOMEM          12      /* Out of memory */
#define EACCES          13      /* Permission denied */
#define EFAULT          14      /* Bad address */
#define ENOTBLK         15      /* Block device required */
#define EBUSY           16      /* Device or resource busy */
#define EEXIST          17      /* File exists */
#define EXDEV           18      /* Cross-device link */
#define ENODEV          19      /* No such device */
#define ENOTDIR         20      /* Not a directory */
#define EISDIR          21      /* Is a directory */
#define EINVAL          22      /* Invalid argument */
#define ENFILE          23      /* File table overflow */
#define EMFILE          24      /* Too many open files */
#define ENOTTY          25      /* Not a typewriter */
#define ETXTBSY         26      /* Text file busy */
#define EFBIG           27      /* File too large */
#define ENOSPC          28      /* No space left on device */
#define ESPIPE          29      /* Illegal seek */
#define EROFS           30      /* Read-only file system */
#define EMLINK          31      /* Too many links */
#define EPIPE           32      /* Broken pipe */
#define EDOM            33      /* Math argument out of domain of func */
#define ERANGE          34      /* Math result not representable */
#define EDEADLK         35      /* Resource deadlock would occur */
#define ENAMETOOLONG    36      /* File name too long */
#define ENOLCK          37      /* No record locks available */
#define ENOSYS          38      /* Function not implemented */
#define ENOTEMPTY       39      /* Directory not empty */
#define ELOOP           40      /* Too many symbolic links encountered */
#define EWOULDBLOCK     11  /* Operation would block  idem EAGAIN */
#define ENOMSG          42      /* No message of desired type */
#define EIDRM           43      /* Identifier removed */
#define ECHRNG          44      /* Channel number out of range */
#define EL2NSYNC        45      /* Level 2 not synchronized */
#define EL3HLT          46      /* Level 3 halted */
#define EL3RST          47      /* Level 3 reset */
#define ELNRNG          48      /* Link number out of range */
#define EUNATCH         49      /* Protocol driver not attached */
#define ENOCSI          50      /* No CSI structure available */
#define EL2HLT          51      /* Level 2 halted */
#define EBADE           52      /* Invalid exchange */
#define EBADR           53      /* Invalid request descriptor */
#define EXFULL          54      /* Exchange full */
#define ENOANO          55      /* No anode */
#define EBADRQC         56      /* Invalid request code */
#define EBADSLT         57      /* Invalid slot */
#define EDEADLOCK       35      /* idem EDEADLK
#define EBFONT          59      /* Bad font file format */
#define ENOSTR          60      /* Device not a stream */
#define ENODATA         61      /* No data available */
#define ETIME           62      /* Timer expired */
#define ENOSR           63      /* Out of streams resources */
#define ENONET          64      /* Machine is not on the network */
#define ENOPKG          65      /* Package not installed */
#define EREMOTE         66      /* Object is remote */
#define ENOLINK         67      /* Link has been severed */
#define EADV            68      /* Advertise error */
#define ESRMNT          69      /* Srmount error */
#define ECOMM           70      /* Communication error on send */
#define EPROTO          71      /* Protocol error */
#define EMULTIHOP       72      /* Multihop attempted */
#define EDOTDOT         73      /* RFS specific error */
#define EBADMSG         74      /* Not a data message */
#define EOVERFLOW       75      /* Value too large for defined data type */
#define ENOTUNIQ        76      /* Name not unique on network */
#define EBADFD          77      /* File descriptor in bad state */
#define EREMCHG         78      /* Remote address changed */
#define ELIBACC         79      /* Can not access a needed shared library */
#define ELIBBAD         80      /* Accessing a corrupted shared library */
#define ELIBSCN         81      /* .lib section in a.out corrupted */
#define ELIBMAX         82      /* Attempting to link in too many shared libraries */
#define ELIBEXEC        83      /* Cannot exec a shared library directly */
#define EILSEQ          84      /* Illegal byte sequence */
#define ERESTART        85      /* Interrupted system call should be restarted */
#define ESTRPIPE        86      /* Streams pipe error */
#define EUSERS          87      /* Too many users */
#define ENOTSOCK        88      /* Socket operation on non-socket */
#define EDESTADDRREQ    89      /* Destination address required */
#define EMSGSIZE        90      /* Message too long */
#define EPROTOTYPE      91      /* Protocol wrong type for socket */
#define ENOPROTOOPT     92      /* Protocol not available */
#define EPROTONOSUPPORT 93      /* Protocol not supported */
#define ESOCKTNOSUPPORT 94      /* Socket type not supported */
#define EOPNOTSUPP      95      /* Operation not supported on transport endpoint */
#define EPFNOSUPPORT    96      /* Protocol family not supported */
#define EAFNOSUPPORT    97      /* Address family not supported by protocol */
#define EADDRINUSE      98      /* Address already in use */
#define EADDRNOTAVAIL   99      /* Cannot assign requested address */
#define ENETDOWN        100     /* Network is down */
#define ENETUNREACH     101     /* Network is unreachable */
#define ENETRESET       102     /* Network dropped connection because of reset */
#define ECONNABORTED    103     /* Software caused connection abort */
#define ECONNRESET      104     /* Connection reset by peer */
#define ENOBUFS         105     /* No buffer space available */
#define EISCONN         106     /* Transport endpoint is already connected */
#define ENOTCONN        107     /* Transport endpoint is not connected */
#define ESHUTDOWN       108     /* Cannot send after transport endpoint shutdown */
#define ETOOMANYREFS    109     /* Too many references: cannot splice */
#define ETIMEDOUT       110     /* Connection timed out */
#define ECONNREFUSED    111     /* Connection refused */
#define EHOSTDOWN       112     /* Host is down */
#define EHOSTUNREACH    113     /* No route to host */
#define EALREADY        114     /* Operation already in progress */
#define EINPROGRESS     115     /* Operation now in progress */
#define ESTALE          116     /* Stale NFS file handle */
#define EUCLEAN         117     /* Structure needs cleaning */
#define ENOTNAM         118     /* Not a XENIX named type file */
#define ENAVAIL         119     /* No XENIX semaphores available */
#define EISNAM          120     /* Is a named type file */
#define EREMOTEIO       121     /* Remote I/O error */
#define EDQUOT          122     /* Quota exceeded */
#define ENOMEDIUM       123     /* No medium found */
#define EMEDIUMTYPE     124     /* Wrong medium type */
```
Dans le programme saisie32.s nous allons voir comment lire une chaîne de caractère saisie dans le terminal quel qu’il soit. Ce peut être le clavier du smartphone ou le clavier du terminal sous lequel vous êtes connecté par ssh.

Nous définissons dans la .bss, un buffer avec une taille suffisante pour recuieullir les données saisies.

Puis dans le corps du système, nous affichons un libellé indicatif puis nous préparons l’appel système READ (code 3) qui va nous permettre de lire les données saisies. 

Nous passons un code indiquant la console standard d’entrée Linux (STDIN = 0), l’adresse du buffer de réception et sa taille puis le code fonction (toujours dans le registre r7).
Ces paramètres sont trouvés dans la documentation Linux des appels système  par exemple :
```C
ssize_t read(int fd, void *buf, size_t count);
```
En retour de l’appel, nous affichons le code retour pour vérification. Normalement il retourne le nombre de caractères saisis ou un nombre négatif s’il y a une erreur de lecture.

Nous affichons ensuite le buffer pour voir le résultat saisi : première surprise, la saisie se termine par le caractère 0xA et non pas par le caractère de fin de chaîne zéro binaire.

Cela signifie qu’il faut remplacer ce caractère par un 0 binaire si nous voulons utiliser cette chaine dans les routines précédentes.

C’est ce que fait le programme pour effectuer ensuite la comparaison avec le libellé « fin » pour terminer le programme.

Un autre exemple concernant les fichiers :

Dans le programme fichier32.s, nous allons voir comment lire un fichier et écrire dans un fichier.
Tout d’abord, nous créons dans le répertoire de travail un fichier test1.txt ou nous mettons une dizaine de caractères quelconques.

Nous reprenons la partie saisie du précédent programme pour demander le nom du fichier à lire qui sera stocké dans un buffer.

Puis nous ouvrons le fichier en utilisant l’appel système OPEN (code 5) en  passant l’adresse du buffer contenant le nom, un code pour demander l’ouverture en lecture écriture (nous aurions pu demander l’ouverture en lecture seule avec le code .equ O_RDONLY, 0 et un mode à zéro.

Nous testons le code retour et s’il est négatif nous signalons une erreur. Ce test est obligatoire car le fichier peut ne pas exister, ou l’opérateur a pu faire une erreur de saisie.

Si l’ouverture est correcte, le code retour correspond au descripteur de fichier (File Descripor) attribué par le système, FD que nous sauvons dans un registre. Puis  nous utilisons l’appel système READ pour lire le fichier dans un buffer de lecture assez grand pour contenir la totalité du fichier.

Nous testons aussi le code retour et s’il est positif, nous l’affichons et le contenu du buffer de lecture. 
Vous pouvez constater qu’il contient bien les données du fichier.

Nous continuons en demandant le nom du fichier à écrire et nous le créons en utilisant l’appel système CREATE. Remarquez que nous passons un code de création en octol et qui correspond aux droits attribués au fichier crée.

Si la création est OK, nous sauvegardons dans un registre le File Descriptor attribué et nous écrivons 10 caractères dans le fichier à partir du buffer de lecture avec l’appel système WRITE.

Si tout se passe bien, nous fermons les 2 fichiers avec l’appel système CLOSE.

Voici l’éxecution du programme :
```
Début du programme 32 bits.
Veuillez saisir le nom du fichier à lire :
test1.txt
Code retour =  : Valeur hexa du registre : 00000027
Aff mémoire  adresse : 000211AB  Lecture :
000211A0  00 00 00 00 00 00 00 00 00 00 00*31 32 33 34 35  ...........12345
000211B0  36 37 38 39 30 0A 41 42 43 44 45 46 47 48 49 4A  67890.ABCDEFGHIJ
000211C0  4B 4C 4D 4E 4F 50 51 52 53 54 55 56 57 58 59 5A  KLMNOPQRSTUVWXYZ
Veuillez saisir le nom du fichier à écrire :
test2.txt
Fin normale du programme.
~/asm32/debut3 $ more test2.txt
1234567890
```

Maintenant il ne vous reste plus qu’à rechercher la documentation de tous les appels système Linux pour les utiliser dans vos programmes.

Vous pouvez voir de nombreux exemples sur la programmation pour le raspberry pi sur  http://assembleurarmpi.blogspot.com/p/blog-page.html 
 ou même sur le site du projet rosetta : http://www.rosettacode.org/wiki/Rosetta_Code
