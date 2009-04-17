#import <UIKit/UIKit.h>
#import "NTLNAccelerometerSensor.h"

@interface NTLNBrowserViewController : UIViewController 
			<UITextFieldDelegate, UIWebViewDelegate, NTLNAccelerometerSensorDelegate, UIActionSheetDelegate> {

	UIWebView	*myWebView;
	UIBarButtonItem	*actionButton;
	UILabel *urlLabel;

	NSString *url;
	
	BOOL shown;
	BOOL loading;
	
	UIView *browserViewSuperView;
	CGRect browserViewOriginalFrame;
				
	NSURLRequest *lastRequest;
}

@property (readwrite, retain) NSString *url;
@property (readwrite, retain) NSURLRequest *lastRequest;

@end
