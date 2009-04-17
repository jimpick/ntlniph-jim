#import <UIKit/UIKit.h>
#import "NTLNHttpClient.h"

@class NTLNTwitterClient;
@class NTLNMessage;

@protocol NTLNTwitterClientDelegate
- (void)twitterClientBegin:(NTLNTwitterClient*)sender;
- (void)twitterClientEnd:(NTLNTwitterClient*)sender;
- (void)twitterClientSucceeded:(NTLNTwitterClient*)sender messages:(NSArray*)messages;
- (void)twitterClientFailed:(NTLNTwitterClient*)sender;
@end

@interface NTLNTwitterClient : NTLNHttpClient {
	int requestPage;
	NSString *screenNameForUserTimeline;
	BOOL parseResultXML;
	BOOL postPicMessage;
	NSObject<NTLNTwitterClientDelegate> *delegate;
	BOOL requestForTimeline;
	BOOL requestForDirectMessage;
	NSString *message;
	NSString *userName;
	NSString *savedPass;
	NSString *imageUrl;
	BOOL requestFollow;
}

- (id)initWithDelegate:(NSObject<NTLNTwitterClientDelegate>*)delegate;

- (void)getFriendsTimelineWithPage:(int)page since_id:(NSString*)since_id;
- (void)getRepliesTimelineWithPage:(int)page;
- (void)getSentsTimelineWithPage:(int)page since_id:(NSString*)since_id;
- (void)getUserTimelineWithScreenName:(NSString*)screenName page:(int)page since_id:(NSString*)since_id;
- (void)getDirectMessagesWithPage:(int)page;
- (void)getSentDirectMessagesWithPage:(int)page;
- (void)createFavoriteWithID:(NSString*)messageId;
- (void)destroyFavoriteWithID:(NSString*)messageId;

- (void) followUser:(NSString*)userId;
- (void) unFollowUser:(NSString*)userId;

- (void)post:(NSString*)tweet;
- (void)post:(NSString*)tweet forUser:(NSString*)twid withPassword:(NSString*)password;

- (void)post:(NSString*)tweet withImage:(UIImage*)image;
- (void)post:(NSString*)tweet withImage:(UIImage*)image forUser:(NSString*)twid withPassword:(NSString*)password;

- (void)finishPicMessage:(NSString*)picUrl;

@property (readonly) int requestPage;
@property (readonly) BOOL requestForDirectMessage;
@property (nonatomic, retain) NSString *message, *userName, *savedPass, *imageUrl;

@end
