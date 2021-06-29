/*constantes Linux syscall */
.equ EXIT,   1
.equ FORK,   2
.equ READ,   3
.equ WRITE,  4
.equ OPEN,   5
.equ CLOSE,  6
.equ EXECVE, 0xB
.equ PIPE,   0x2A
.equ IOCTL,  0x36

/* console */
.equ STDIN,  0
.equ STDOUT, 1
.equ STDERR, 2  

/*  fichier */
.equ O_RDONLY, 0
.equ O_WRONLY, 0x0001    
.equ O_RDWR,   0x0002          @ open for reading and writing

.equ O_CREAT,  0x0200          @ create if nonexistant
.equ O_TRUNC,  0x0400          @ truncate to zero length
.equ O_EXCL,   0x0800          @ error if already exists 
.equ O_SYNC,   04010000        @ valeur en octal à vérifier ????

.equ S_IRWXU,  0x00700   /* user (file owner) has read, write, and execute permission */

.equ  PROT_READ,	0x1     /* Page can be read.  */
.equ PROT_WRITE,	0x2     /* Page can be written.  */
.equ PROT_EXEC,	0x4     /* Page can be executed.  */
.equ PROT_NONE,	0x0     /* Page can not be accessed.  */

.equ MAP_SHARED,	0x01    /* Share changes.  */
.equ MAP_PRIVATE,	0x02    /* Changes are private.  */

.equ MAP_FIXED,	0x10    /* Interpret addr exactly.  */
.equ MAP_FILE,	0
.equ MAP_ANONYMOUS,	0x20    /* Don't use a file.  */
.equ MAP_ANON,	MAP_ANONYMOUS

.equ MAP_DENYWRITE,	0x0800  /* ETXTBSY */
.equ MAP_FOOBAR,	0x0800  /* ETXTBSY */

.equ MS_ASYNC,	1		/* sync memory asynchronously */
.equ MS_SYNC,		2		/* synchronous memory sync */
.equ MS_INVALIDATE,	4		/* invalidate the caches */


//.equ FBIOGET_FSCREENINFO, 0x4602
/* Constantes générales */
.equ false, 0
.equ true,  1

/* constantes X11 */
.equ KeyPressed,  2
.equ ButtonPress, 4  
.equ MotionNotify,	6
.equ EnterNotify, 7
.equ LeaveNotify,  8
.equ Expose,   12  
.equ ClientMessage,    33      
.equ KeyPressMask, 1
.equ ButtonPressMask, 4
.equ ButtonReleaseMask, 8
.equ ExposureMask, 1<<15
.equ StructureNotifyMask, 1<<17
.equ EnterWindowMask, 1<<4
.equ LeaveWindowMask, 1<<5 
.equ ConfigureNotify, 22


.equ GCForeground,	1<<2
.equ GCBackground, 1<<3
.equ GCLine_width, 1<<4
.equ GCLine_style, 1<<5
.equ GCFont,	1<<14

.equ CWBackPixel,	1<<1
.equ CWBorderPixel,	1<<3
.equ CWEventMask,	1<<11
.equ CWX,			1<<0
.equ CWY, 			(1<<1)
.equ CWWidth, 		1<<2
.equ CWHeight, 		1<<3
.equ CWBorderWidth, 1<<4
.equ CWSibling, 	1<<5
.equ CWStackMode, 		1<<6


.equ InputOutput,	1
.equ InputOnly,	2

.equ InputHint,	1 << 0
.equ StateHint,	1 << 1
.equ IconPixmapHint,	1<< 2
.equ IconWindowHint,	1 << 3
.equ IconPositionHint,	1<< 4
.equ IconMaskHint,	1<< 5
.equ WindowGroupHint,	1<< 6
.equ UrgencyHint,	1 << 8
.equ WithdrawnState,	0
.equ NormalState,	1	/* most applications start this way */
.equ IconicState,	3	/* application wants to start as an icon */

.equ USPosition,	1 << 0	/* user specified x, y */
.equ USSize,		1 << 1	/* user specified width, height */
.equ PPosition,	1 << 2	/* program specified position */
.equ PSize,		(1 << 3)	/* program specified size */
.equ PMinSize,	(1 << 4)	/* program specified minimum size */
.equ PMaxSize,	(1 << 5)	/* program specified maximum size */
.equ PResizeInc,	(1 << 6)	/* program specified resize increments */
.equ PAspect,		(1 << 7)	/* program specified min and max aspect ratios */
.equ PBaseSize,	(1 << 8)
.equ PWinGravity,	(1 << 9)

.equ Button1MotionMask, 1<<8
.equ Button2MotionMask,  1<<9 
.equ ButtonMotionMask,	(1<<13)

.equ CoordModeOrigin,	0
.equ CoordModePrevious,	1

.equ XYPixmap,	1
.equ ZPixmap,	2


.equ Complex,			0
.equ Nonconvex,			1
.equ Convex,			2

/*
#define KeyPress                2
#define KeyRelease              3
#define ButtonPress             4
#define ButtonRelease           5
#define MotionNotify            6
#define EnterNotify             7
#define LeaveNotify             8
#define FocusIn                 9
#define FocusOut                10
#define KeymapNotify            11
#define Expose                  12
#define GraphicsExpose          13
#define NoExpose                14
#define VisibilityNotify        15
#define CreateNotify            16
#define DestroyNotify           17
#define UnmapNotify             18
#define MapNotify               19
#define MapRequest              20
#define ReparentNotify          21
#define ConfigureNotify         22
#define ConfigureRequest        23
#define GravityNotify           24
#define ResizeRequest           25
#define CirculateNotify         26
#define CirculateRequest        27
#define PropertyNotify          28
#define SelectionClear          29
#define SelectionRequest        30
#define SelectionNotify         31
#define ColormapNotify          32
#define ClientMessage           33
#define MappingNotify           34
#define GenericEvent            35
*/
