#import "NTLNUser.h"

@implementation NTLNUser

@synthesize user_id, twit_uid, screen_name, profile_image_url, webpage;

- (void) dealloc {
	[user_id release];
	[screen_name release];
	[profile_image_url release];
	
	if (webpage) {
		[webpage release];
	}
    [super dealloc];
}

@end
