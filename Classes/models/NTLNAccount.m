#import "NTLNAccount.h"

#define NTLN_PREFERENCE_USERID				@"userId"
#define NTLN_PREFERENCE_PASSWORD			@"password"
#define NTLN_PREFERENCE_TWITTER_USERID		@"twitter_user_id"
#define NTLN_PREFERENCE_TWIT_SCREEN_NAME	@"twitter_screen_name"

static NTLNAccount *_instance;

@implementation NTLNAccount

@synthesize following;

+ (id) instance {
    if (!_instance) {
        return [NTLNAccount newInstance];
    }
    return _instance;
}

+ (id) newInstance {
    if (_instance) {
        [_instance release];
        _instance = nil;
    }
    
    _instance = [[NTLNAccount alloc] init];
    return _instance;
}

- (void) dealloc {
	self.following = nil;
    [super dealloc];
}

- (void)setUsername:(NSString*)username {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:NTLN_PREFERENCE_USERID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setPassword:(NSString*)password {
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:NTLN_PREFERENCE_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setUserId:(NSString*)user_id {
    [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:NTLN_PREFERENCE_TWITTER_USERID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setScreenName:(NSString*)screenname {
    [[NSUserDefaults standardUserDefaults] setObject:screenname forKey:NTLN_PREFERENCE_TWIT_SCREEN_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) username {
	return [[NSUserDefaults standardUserDefaults] stringForKey:NTLN_PREFERENCE_USERID];
}

- (NSString*) password {
	return [[NSUserDefaults standardUserDefaults] stringForKey:NTLN_PREFERENCE_PASSWORD];
}

- (NSString*) userId {
	return [[NSUserDefaults standardUserDefaults] stringForKey:NTLN_PREFERENCE_TWITTER_USERID];
}

- (NSString*) screenName {
	return [[NSUserDefaults standardUserDefaults] stringForKey:NTLN_PREFERENCE_TWIT_SCREEN_NAME];
}

- (BOOL) valid {
	NSString *pwd = self.password;
	NSString *usn = self.username;
	return usn != nil && usn.length > 0 &&
			pwd != nil && pwd.length > 0;
}

- (void)getUserId {
	NTLNTwitterUserClient *c = [[NTLNTwitterUserClient alloc] initWithDelegate:self];
	c.state = 1;
	[c getUserInfoForScreenName:[self username]];
}

- (void)twitterUserClientSucceeded:(NTLNTwitterUserClient*)sender {
	if (sender.state == 2) {
		self.following = [NSMutableArray arrayWithArray:sender.following];
	}
	else if (sender.state == 1) {
		[self setUserId:sender.user.user_id];
		[self setScreenName:sender.user.screen_name];
		[self performSelector:@selector(getFollowing) withObject:nil afterDelay:0.01];
	}
}

- (void) getFollowing {
	NTLNTwitterUserClient *c = [[NTLNTwitterUserClient alloc] initWithDelegate:self];
	c.state = 2;
	[c getFollowing:[self username] password:[self password]];
}

- (void)twitterUserClientFailed:(NTLNTwitterUserClient*)sender {
}

- (NSNumber*) amIFollowing:(NSString*)otherId {
	if (!self.following) {
		return nil;
	}
	
	NSNumber *number = [NSNumber numberWithInt:[otherId intValue]];
	
	return [NSNumber numberWithBool:([self.following containsObject:number])];		
}

- (void) followed:(NSString*)otherId {
	NSNumber *number = [NSNumber numberWithInt:[otherId intValue]];
	[self.following addObject:number];
}

- (void) unFollowed:(NSString*)otherId {
	NSNumber *number = [NSNumber numberWithInt:[otherId intValue]];
	[self.following removeObject:number];
}

@end
