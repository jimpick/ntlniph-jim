#import <UIKit/UIKit.h>
#import "ntlniphAppDelegate.h"
#import "NTLNTwitterClient.h"

@class NTLNMessage;
@class NTLNFriendsViewController;
@class NTLNBrowserViewController;
@class NTLNTweetPostViewController;
@class NTLNUserTimelineViewController;

@interface NTLNURLPair : NSObject
{
	NSString *url;
	NSString *text;
	NSString *screenName;
	BOOL singleUser;
}

@property(readwrite, retain) NSString *url, *text, *screenName;
@property(readwrite) BOOL singleUser;

@end



@interface NTLNLinkViewController : UITableViewController 
										<UITableViewDelegate, 
										UITableViewDataSource, 
										NTLNTwitterClientDelegate> {

	NTLNAppDelegate *appDelegate;
	NTLNTweetPostViewController *tweetPostViewController;
											
	NTLNMessage *message;
	NSMutableArray *urls;
	NTLNURLPair *messageOwnerUrl;
	
	UIButton *favButton;
	UIButton *followButton;
											
	UIImage *redButton;
	UIImage *greenButton;
}

- (CGFloat)getTextboxHeight:(NSString *)str;
- (UITableViewCell *)screenNameCell;
- (UITableViewCell *)urlCell:(NTLNURLPair*)pair isEven:(BOOL)isEven;
- (void)parseToken;

@property(readwrite, assign) NTLNAppDelegate *appDelegate;
@property(readwrite, assign) NTLNTweetPostViewController *tweetPostViewController;

@property(readwrite, retain) NTLNMessage *message;

@end

@interface NTLNLinkCell : UITableViewCell
{
	NTLNURLPair *pair;
	BOOL isEven;
}

- (void)createCell:(NTLNURLPair*)pair isEven:(BOOL)isEven;

@end

@interface NTLNSelectedLinkCellBackground : UIView
{
	NTLNURLPair *pair;
	BOOL isEven;
}

@property (readwrite, retain) NTLNURLPair *pair;

@end

