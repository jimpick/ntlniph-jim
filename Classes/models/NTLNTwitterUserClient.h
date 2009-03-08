#import <UIKit/UIKit.h>
#import "NTLNUser.h"
#import "NTLNHttpClient.h"

@class NTLNTwitterUserClient;

@protocol NTLNTwitterUserClientDelegate
- (void)twitterUserClientSucceeded:(NTLNTwitterUserClient*)sender;
- (void)twitterUserClientFailed:(NTLNTwitterUserClient*)sender;
@end

@interface NTLNTwitterUserClient : NTLNHttpClient {
	@private
	NSObject<NTLNTwitterUserClientDelegate> *delegate;
	NTLNUser *user;
	NSArray *following;
	BOOL gettingFollowing;
}

- (id)initWithDelegate:(NSObject<NTLNTwitterUserClientDelegate>*)delegate;
- (void)getUserInfoForScreenName:(NSString*)screen_name;
- (void)getUserInfoForUserId:(NSString*)user_id;

- (void) verifyCredentials:(NSString*)_userName password:(NSString*)_password;

- (void) getFollowing:(NSString*)_userName password:(NSString*)_password;

@property (readonly) NTLNUser *user;
@property (nonatomic, retain) NSArray *following;

@end
