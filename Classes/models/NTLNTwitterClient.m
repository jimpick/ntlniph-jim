#import "NTLNTwitterClient.h"
#import "NTLNAccount.h"
#import "NTLNXMLHTTPEncoder.h"
#import "NTLNConfiguration.h"
#import "NTLNTwitterXMLReader.h"
#import "NTLNTwitPicXMLReader.h"
#import "NTLNAlert.h"
#import "NTLNTwitterErrorXmlReader.h"

//#define kTwitPicPostUrl @"https://dovevalleyapps.com/api/upload"
#define kTwitPicPostUrl @"https://twitpic.com/api/upload"

@implementation NTLNTwitterClient

@synthesize requestPage, requestForDirectMessage, message, userName, savedPass, imageUrl;

/// private methods

+ (NSString*)URLForTwitterWithAccount {
	return @"https://twitter.com/";
}

- (void)getTimeline:(NSString*)path page:(int)page count:(int)count since_id:(NSString*)since_id forceGet:(BOOL)forceGet {
	NSString* url = [NSString stringWithFormat:@"%@%@.xml?count=%d", 
					 [NTLNTwitterClient URLForTwitterWithAccount], path, count];
		
	if (page >= 2) {
		url = [NSString stringWithFormat:@"%@&page=%d", url, page];
	} else if (since_id) {
		url = [NSString stringWithFormat:@"%@&since_id=%@", url, since_id];
	}
	
	requestPage = page;
	parseResultXML = YES;
	requestForTimeline = YES;
	
	NSString *username = [[NTLNAccount instance] username];
	NSString *password = [[NTLNAccount instance] password];

	if ( !forceGet && [[NTLNConfiguration instance] usePost]) {
		[super requestPOST:url body:nil username:username password:password];
//		[super requestPOST:@"http://www.livedoor.com/" body:nil];
	} else {
		[super requestGET:url username:username password:password];
//		[super requestGET:@"http://www.livedoor.com/"];
	}
	
	[delegate twitterClientBegin:self];
}

- (void) followUser:(NSString*)userId {
	// http://twitter.com/notifications/follow/12345.xml
	NSString* url = [NSString stringWithFormat:@"%@friendships/create/%@.xml", 
					 [NTLNTwitterClient URLForTwitterWithAccount], userId];
	
	NSString *username = [[NTLNAccount instance] username];
	NSString *password = [[NTLNAccount instance] password];
	
	requestFollow = true;
	
	[self requestPOST:url body:nil username:username password:password];
}

- (void) unFollowUser:(NSString*)userId {
	// http://twitter.com/notifications/leave/12345.xml
	NSString* url = [NSString stringWithFormat:@"%@friendships/destroy/%@.xml", 
					 [NTLNTwitterClient URLForTwitterWithAccount], userId];
	
	NSString *username = [[NTLNAccount instance] username];
	NSString *password = [[NTLNAccount instance] password];
	
	requestFollow = true;
	
	[self requestPOST:url body:nil username:username password:password];
}

- (void) dealloc {
	self.message = nil;
	self.userName = nil;
	self.savedPass = nil;
	self.imageUrl = nil;
	[delegate release];
	[screenNameForUserTimeline release];
	[super dealloc];
}

- (void)requestSucceeded {
	NSLog(@"request succeeded!!! %@", self.message);

	if (statusCode == 200) {
		if (parseResultXML) {
			if (postPicMessage) {
				postPicMessage = false;
				NTLNTwitPicXMLReader *xr = [[NTLNTwitPicXMLReader alloc] init];
				[xr parseXMLData:recievedData];

				if (!xr.mediaUrl) {
					NSLog(@"problem uploading pic: %@", 
						  [[[NSString alloc]initWithData:recievedData encoding:NSUTF8StringEncoding]autorelease]);
					postPicMessage = true;
					NSError *error = [NSError errorWithDomain:@"twitpic.com" code:xr.errCode userInfo:
									  [NSDictionary dictionaryWithObject:xr.errMsg forKey:NSLocalizedDescriptionKey]];
					[recievedData release];
					recievedData = [[NSMutableData alloc]init];
					[xr release];
					[self requestFailed:error];
					return;
				}
				
				[recievedData release];
				recievedData = [[NSMutableData alloc]init];
				[self finishPicMessage:xr.mediaUrl];
				[xr release];
				return;
			}
			else if (contentTypeIsXml) {
				NTLNTwitterXMLReader *xr = [[NTLNTwitterXMLReader alloc] init];
				[xr parseXMLData:recievedData];
				
				if ([xr.messages count] > 0) {
					[delegate twitterClientSucceeded:self messages:xr.messages];
				} else {
					[delegate twitterClientSucceeded:self messages:nil];
				}
				
				[xr release];
			} else {
				[[NTLNAlert instance] alert:@"Invaild XML Format" 
								withMessage:@"Twitter responded invalid format message, or please check your network environment."];
				[delegate twitterClientFailed:self];
			}
		} else {
			[delegate twitterClientSucceeded:self messages:nil];
		}
	} else {
		NSLog(@"error response: %s", [recievedData bytes]);
		NTLNTwitterErrorXmlReader *xr = [[[NTLNTwitterErrorXmlReader alloc]init]autorelease];
		[xr parseXMLData:recievedData];
		if (statusCode != 304) {
			switch (statusCode) {
				case 401:
				case 403:
					if (requestFollow) {
						[[NTLNAlert instance] alert:@"Notification Failed" withMessage:xr.error];
					}
					else if (screenNameForUserTimeline) {
						[[NTLNAlert instance] alert:@"Protected" 
										withMessage:[NSString 
													 stringWithFormat:@"@%@ has protected their updates.", 
													 screenNameForUserTimeline]];
					} else {
						[[NTLNAlert instance] alert:@"Authorization Failed" 
										withMessage:@"Wrong Username/Email and password combination."];
					}
					break;
				default:
					{
						if (requestForTimeline) {
							[[NTLNAlert instance] alert:@"Retrieving timeline failed" withMessage:xr.error];
						} else {
							[[NTLNAlert instance] alert:@"Sending a message failed" withMessage:xr.error];
						}
					}
					break;
			}
		}
		
		[delegate twitterClientFailed:self];
	}
	
	[delegate twitterClientEnd:self];
	[self autorelease];
}

- (void)requestFailed:(NSError*)error {
	NSLog(@"request failed!!! %@", self.message);
	if (error) {
		[[NTLNAlert instance] alert:@"Network error" withMessage:[error localizedDescription]];
	}
	
	[delegate twitterClientFailed:self];
	[delegate twitterClientEnd:self];
	[self autorelease];
}

/// public interfaces

- (id)initWithDelegate:(NSObject<NTLNTwitterClientDelegate>*)aDelegate {
	self = [super init];
	postPicMessage = false;
	delegate = aDelegate;
	[delegate retain];
	return self;
}

- (void)getFriendsTimelineWithPage:(int)page since_id:(NSString*)since_id {
	[self getTimeline:@"statuses/friends_timeline" 
				 page:page 
				count:[[NTLNConfiguration instance] fetchCount] 
			 since_id:since_id
			 forceGet:NO];
}

- (void)getRepliesTimelineWithPage:(int)page {
	[self getTimeline:@"statuses/replies" 
				 page:page 
				count:20 
			 since_id:nil 
			 forceGet:NO];
}

- (void)getSentsTimelineWithPage:(int)page since_id:(NSString*)since_id {
	[self getTimeline:@"statuses/user_timeline" 
				 page:page 
				count:20 
			 since_id:since_id 
			 forceGet:NO];
}

- (void)getDirectMessagesWithPage:(int)page {
	requestForDirectMessage = YES;
	[self getTimeline:@"direct_messages" 
				 page:page 
				count:20 
			 since_id:nil 
			 forceGet:YES];
}

- (void)getSentDirectMessagesWithPage:(int)page {
	requestForDirectMessage = YES;
	[self getTimeline:@"direct_messages/sent" 
				 page:page 
				count:20 
			 since_id:nil 
			 forceGet:YES];
}

- (void)getUserTimelineWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id {
	[screenNameForUserTimeline release];
	screenNameForUserTimeline = screenName;
	[screenNameForUserTimeline retain];
	[self getTimeline:[NSString stringWithFormat:@"statuses/user_timeline/%@", screenName]
				 page:page 
				count:20 
			 since_id:since_id
			 forceGet:NO];
}

- (void)post:(NSString*)tweet {
	NSString *username = [[NTLNAccount instance] username];
	NSString *password = [[NTLNAccount instance] password];
	[self post:tweet forUser:username withPassword:password];
}

- (void)post:(NSString*)tweet forUser:(NSString*)twid withPassword:(NSString*)password {
	parseResultXML = YES;
	NSString* url = [NSString stringWithFormat:@"%@statuses/update.xml", 
					 [NTLNTwitterClient URLForTwitterWithAccount]];
    NSString *postString = [NSString stringWithFormat:@"status=%@&source=NatsuLiphone", 
							[NTLNXMLHTTPEncoder encodeHTTP:tweet]];
	
	self.message = tweet;
	self.userName = twid;
	self.savedPass = password;
	[self requestPOST:url body:postString username:twid password:password];
}	

- (void)post:(NSString*)tweet withImage:(UIImage*)image {
	NSString *username = [[NTLNAccount instance] username];
	NSString *password = [[NTLNAccount instance] password];
	[self post:tweet withImage:image forUser:username withPassword:password];
}

- (void)post:(NSString*)tweet withImage:(UIImage*)image forUser:(NSString*)twid withPassword:(NSString*)password {
	parseResultXML = YES;
	postPicMessage = YES;
	self.message = tweet;
	self.userName = twid;
	self.savedPass = password;
	[self requestPOSTImage:kTwitPicPostUrl image:image message:tweet username:twid password:password];
}

- (void)finishPicMessage:(NSString*)picUrl {
	self.imageUrl = picUrl;
	int over = 139 - ([self.message length] + [picUrl length]);
	
	if (over < 0) {
		self.message = [self.message substringToIndex:[self.message length] + over];
	}
	
	[self post:[NSString stringWithFormat:@"%@ %@", self.message, picUrl] forUser:self.userName withPassword:self.savedPass];
}

- (void)createFavoriteWithID:(NSString*)messageId {
	NSString* url = [NSString stringWithFormat:@"%@favorites/create/%@.xml", 
					 [NTLNTwitterClient URLForTwitterWithAccount], messageId];
	
	NSString *username = [[NTLNAccount instance] username];
	NSString *password = [[NTLNAccount instance] password];

	[self requestPOST:url body:nil username:username password:password];
}

- (void)destroyFavoriteWithID:(NSString*)messageId {
	NSString* url = [NSString stringWithFormat:@"%@favorites/destroy/%@.xml", 
					 [NTLNTwitterClient URLForTwitterWithAccount], messageId];
	NSString *username = [[NTLNAccount instance] username];
	NSString *password = [[NTLNAccount instance] password];

	[self requestPOST:url body:nil username:username password:password];
}

@end
