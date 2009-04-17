#import "NTLNTwitterUserClient.h"
#import "NTLNTwitterUserXMLReader.h"
#import "NTLNAccount.h"
#import "SBJSON.h"

@implementation NTLNTwitterUserClient

@synthesize user, following;

- (id)init {
	return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(NSObject<NTLNTwitterUserClientDelegate>*)aDelegate {
	if ((self = [super init])) {
		delegate = aDelegate;
		[delegate retain];
	}
	return self;
}

- (void)getUserInfo:(NSString*)q {
	NSString *format = @"http://twitter.com/users/show/%@.xml";
	
	if ([q rangeOfString:@"@"].length > 0) {
		format = @"http://twitter.com/users/show.xml?email=%@";
	}
	
	NSString *url = [NSString stringWithFormat:format, q];
	
	if ([[NTLNAccount instance]screenName]) {
		[super requestGET:url username:[[NTLNAccount instance]screenName] password:[[NTLNAccount instance]password]];
	}
	else {
		[super requestGET:url];
	}
}

- (void)getUserInfoForScreenName:(NSString*)screen_name {
	[self getUserInfo:screen_name];
}

- (void)getUserInfoForUserId:(NSString*)user_id {
	[self getUserInfo:user_id];
}

- (void) verifyCredentials:(NSString*)_userName password:(NSString*)_password {
	NSString *url = @"http://twitter.com/account/verify_credentials.xml";
	[super requestGET:url username:_userName password:_password];
}

- (void)requestSucceeded {
	if (statusCode == 200) {
		if (gettingFollowing) {
			gettingFollowing = false;
			SBJSON *json = [[[SBJSON alloc]init]autorelease];
			NSError *error = nil;
			NSString *responseString = [[[NSString alloc] initWithData:recievedData encoding:NSUTF8StringEncoding]autorelease];
			
			if (error) {
				NSLog(@"%@", error);
			}
			else if (responseString) {
				NSArray *responseObject = [json objectWithString:responseString error:&error];
				self.following = responseObject;
			}
		}
		else if (contentTypeIsXml) {
			NTLNTwitterUserXMLReader *xr = [[NTLNTwitterUserXMLReader alloc] init];
			
			[xr parseXMLData:recievedData];
			user = [xr.user retain];
			[xr release];
		}
	}
	
	[delegate twitterUserClientSucceeded:self];
	[self autorelease];
}

- (void)requestFailed:(NSError*)error {
	[delegate twitterUserClientFailed:self];
	[self autorelease];
}

- (void) getFollowing:(NSString*)_userName password:(NSString*)_password {
	gettingFollowing = true;
	NSString *request = [NSString stringWithFormat:@"http://twitter.com/friends/ids/%@.json", _userName];
	[super requestGET:request username:_userName password:_password];
}

@end
