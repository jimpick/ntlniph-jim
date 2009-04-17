#import <UIKit/UIKit.h>
#import "NTLNTwitterClient.h"
#import "NTLNPhotoUtil.h"

@class NTLNAppDelegate;

@interface NTLNTweetPostViewController : UIViewController <UITextViewDelegate, NTLNTwitterClientDelegate, NTLNPhotoUtilDelegate> {
	UITextView *tweetTextView;
	UILabel *textLengthView;

	NSString *backupFilename;
	UIView *superView;
	BOOL active;
	
	NSString *tmpTextForInitial;
	NSRange prevPosition;
	UIImage *attachedImage;
	UIImageView *picture;
	int maxText;
}

@property (readonly) BOOL active;
@property (nonatomic, retain) UIImage *attachedImage;
@property (nonatomic, retain) UIImageView *picture;

- (void)setSuperView:(UIView*)view;

- (IBAction)closeButtonPushed:(id)sender;
- (IBAction)sendButtonPushed:(id)sender;
- (IBAction)clearButtonPushed:(id)sender;
- (IBAction)photoButtonPushed:(id)sender;

- (void)createReplyPost:(NSString*)text;
- (void)createDMPost:(NSString*)reply_to;

- (void)showWindow;
- (void)closeWindow;

@end
