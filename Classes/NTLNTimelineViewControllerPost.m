#import "NTLNTimelineViewController.h"
#import "NTLNTweetPostViewController.h"
#import "ntlniphAppDelegate.h"

@implementation NTLNTimelineViewController(Post)

#pragma mark Private

- (void)setupPostButton {
	UIBarButtonItem *postButton = [[[UIBarButtonItem alloc] 
									initWithBarButtonSystemItem:UIBarButtonSystemItemCompose 
									target:self 
									action:@selector(postButton:)] autorelease];
	
	[[self navigationItem] setLeftBarButtonItem:postButton];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweetPostActivity:) name:kSendingTweetNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweetPostActivity:) name:kDoneSendingTweetNotification object:nil];
}

- (void)postButton:(id)sender {
	[tweetPostViewController showWindow];
}

- (void) tweetPostActivity:(NSNotification*)notification {
	BOOL enabled = [[notification name]isEqualToString:kDoneSendingTweetNotification];
	[self navigationItem].leftBarButtonItem.enabled = enabled;
}

@end