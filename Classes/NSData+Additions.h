//
//  NSData+Additions.h
//  PSIos
//
//

#import <Foundation/Foundation.h>


@interface NSData (WDAdditions)

// gzip compression utilities
- (NSData *)decompress;
- (NSData *)compress;

- (NSString *)hexadecimalString;

@end
