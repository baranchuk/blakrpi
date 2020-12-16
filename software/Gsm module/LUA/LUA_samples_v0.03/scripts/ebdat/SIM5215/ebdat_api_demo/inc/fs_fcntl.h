
#ifndef _FS_FCNTL_H
#define _FS_FCNTL_H

#define O_ACCMODE          0003
#define O_RDONLY             00
#define O_WRONLY             01
#define O_RDWR               02
#define O_CREAT            0100 /**< not fcntl */
#define O_EXCL             0200 /**< not fcntl */
#define O_NOCTTY           0400 /**< not fcntl */
#define O_TRUNC           01000 /**< not fcntl */
#define O_APPEND          02000
#define O_NONBLOCK        04000
#define O_NDELAY        O_NONBLOCK
#define O_SYNC           010000
#define FASYNC           020000 /**< fcntl, for BSD compatibility */
#define O_DIRECT         040000 /**< direct disk access hint */
#define O_LARGEFILE     0100000
#define O_DIRECTORY     0200000 /**< must be a directory */
#define O_NOFOLLOW      0400000 /**< don't follow links */
#define O_ITEMFILE     01000000 /**< Create special ITEM file. */
#define O_AUTODIR      02000000 /**< Allow auto-creation of directories */
#define O_SFS_RSVD     04000000 /**< Reserved for Secure FS internal use */

# define SEEK_SET       0       /**< Seek from beginning of file.  */
# define SEEK_CUR       1       /**< Seek from current position.  */
# define SEEK_END       2       /**< Seek from end of file.  */

#define EFS_IOFBF       0       /**< Full buffering.    */
#define EFS_IOLBF       1       /**< Line buffering.    */
#define EFS_IONBF       2       /**< No buffering.      */

#endif /* End of _FS_FCNTL_H */
