#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>

int _go = 1;

#define PAGE_SIZE ( 4 * 1024 * 1024 )

int main( int argc, char *argv[] )
{
    int i;
    const char *fname = "/corrupted-fs/mmapped_file";
    enum { MODE_MMAP, MODE_PWRITE } write_mode = MODE_MMAP;

    while (( i = getopt( argc, argv, "pf:" )) != EOF )
    {
        switch ( i )
        {
            case 'f':
                fname = optarg;
                break;

            case 'p':
                write_mode = MODE_PWRITE;
                break;
        }
    }

    int fd = open( fname, O_RDWR | O_CREAT, 0666 );
    if ( fd == -1 )
    {
        perror( "open failed" );
        return EXIT_FAILURE;
    }

    if ( ftruncate( fd, PAGE_SIZE ) != 0 )
    {
        perror( "ftruncate failed" );
        return EXIT_FAILURE;
    }

    void *ptr = mmap( 0, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0 );
    if ( ptr == MAP_FAILED )
    {
        perror( "mmap failed" );
        return EXIT_FAILURE;
    }

    unsigned char counter = 0;
    while ( _go != 0 )
    {
        unsigned char buf[ PAGE_SIZE ];
        memset( buf, counter, PAGE_SIZE );

        if ( write_mode == MODE_MMAP )
        {
            memcpy( ptr, buf, sizeof( buf ));
        }
        else if ( write_mode == MODE_PWRITE )
        {
            if ( pwrite( fd, buf, sizeof( buf ), 0 ) != sizeof( buf ) )
            {
                perror( "pwrite failed" );
                return EXIT_FAILURE;
            }
        }

        counter ++;
    }

    close( fd );

    return EXIT_SUCCESS;
}
