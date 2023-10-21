#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct _DNS_HEADER
{
    unsigned short idn;
    unsigned char  rd     :1;
    unsigned char  tc     :1;
    unsigned char  aa     :1;
    unsigned char  opcode :4;
    unsigned char  qr     :1;
    unsigned char  rcode  :4;
    unsigned char  cd     :1;
    unsigned char  ad     :1;
    unsigned char  z      :1;
    unsigned char  ra     :1;
    unsigned short qlen;
    unsigned short alen;
    unsigned short aulen;
    unsigned short adlen;
} DNS_HEADER;

NS_ASSUME_NONNULL_END
