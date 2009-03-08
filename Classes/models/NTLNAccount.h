#import <UIKit/UIKit.h>
#import "NTLNTwitterUserClient.h"

@interface NTLNAccount : NSObject<NTLNTwitterUserClientDelegate> {
	NSMutableArray *following;
}

@property (nonatomic, retain) NSMutableArray *following;

+ (id) instance;
+ (id) newInstance;

- (NSString*) username;
- (NSString*) password;
- (NSString*) userId;
- (NSString*) screenName;

// add screenname here and in the return from "show"

- (void)setUsername:(NSString*)username;
- (void)setPassword:(NSString*)password;
	
- (BOOL) valid;

- (void)getUserId;

- (NSNumber*) amIFollowing:(NSString*)otherId;
- (void) followed:(NSString*)otherId;
- (void) unFollowed:(NSString*)otherId;

- (void) getFollowing;

@end


