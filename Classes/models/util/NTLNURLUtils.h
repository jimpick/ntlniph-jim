#import <UIKit/UIKit.h>

#define NTLN_URLEXTRACTOR_PREFIX_HTTP @"http://"
#define NTLN_URLEXTRACTOR_PREFIX_ID @"@"
#define NTLN_URLEXTRACTOR_PREFIX_HASHTAG @"#"

// TODO: this class should be renamed to reflect its work.
@interface NTLNURLUtils : NSObject {

}
+ (id) utils;
- (NSArray*) tokenizeByAll:(NSString*)aString;
- (NSArray*) tokenizeByURL:(NSString*)aString;
- (NSArray*) tokenizeByID:(NSString*)aString;
- (NSArray*) tokenizeByHashtag:(NSString*)aString;
- (BOOL) isURLToken:(NSString*)token;
- (BOOL) isHashtagToken:(NSString*)token;
- (BOOL) isIDToken:(NSString*)token;
- (BOOL) isWhiteSpace:(NSString*)aString;
@end
