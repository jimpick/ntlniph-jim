#import "NTLNBrowserViewController.h"
#import "NTLNAlert.h"
#import "NTLNAccelerometerSensor.h"
#import "ntlniphAppDelegate.h"

@interface NTLNBrowserViewController(Private)
- (void)setReloadButton:(BOOL)reloadBtn;
- (void)stopProgressIndicator;
- (void)reloadButton:(id)sender;

- (void)fullScreenBrowser;
- (void)normalScreenBrowser;
- (void)toggleFullScreenTimeline;
@end

@implementation NTLNBrowserViewController

@synthesize url, lastRequest;

- (void)dealloc
{
	NSLog(@"NTLNBrowserViewController#dealloc");
	[myWebView release];
	[actionButton release];
	[urlLabel release];
	self.lastRequest = nil;
	[super dealloc];
}

- (void)setReloadButton:(BOOL)reloadBtn {
}

- (void)loadView
{	
	myWebView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	myWebView.backgroundColor = [UIColor whiteColor];
	myWebView.scalesPageToFit = YES;
	myWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	myWebView.delegate = self;
	myWebView.autoresizesSubviews = YES;
	self.view = myWebView;
	
	CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width - 40, 50);
	urlLabel = [[UILabel alloc] initWithFrame:frame];
	urlLabel.font = [UIFont systemFontOfSize:14.f];
	urlLabel.text = url;
	urlLabel.textColor = [UIColor whiteColor];
	urlLabel.backgroundColor = [UIColor clearColor];
	urlLabel.lineBreakMode = UILineBreakModeTailTruncation;
	urlLabel.numberOfLines = 1;
	
	[[self navigationItem] setTitleView:urlLabel];
	
	actionButton = [[UIBarButtonItem alloc] 
					initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
					target:self action:@selector(actionButton:)];
	
	[[self navigationItem] setRightBarButtonItem:actionButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

// this helps dismiss the keyboard when the "Done" button is clicked
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[textField text]]]];
	
	return YES;
}


#pragma mark UIWebView delegate methods

- (void)stopProgressIndicator
{
    loading = NO;
	[[NSNotificationCenter defaultCenter]postNotificationName:kDecNetActivityNotification object:self];
	[self setReloadButton:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	self.lastRequest = request;
	return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	loading = YES;
	[[NSNotificationCenter defaultCenter]postNotificationName:kIncNetActivityNotification object:self];
	[self setReloadButton:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self stopProgressIndicator];
	urlLabel.text = [[webView.request URL] absoluteString];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self stopProgressIndicator];
	
	if (shown && error.code != -999) {
		[[NTLNAlert instance] alert:@"Browser error" withMessage:error.localizedDescription];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[NTLNAccelerometerSensor sharedInstance].delegate = nil;
	shown = NO;
	[myWebView loadHTMLString:nil baseURL:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	shown = YES;
	urlLabel.text = url;
	[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	[NTLNAccelerometerSensor sharedInstance].delegate = self;
}

- (void)actionButton:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
													delegate:self cancelButtonTitle:@"Cancel" 
													destructiveButtonTitle:nil
													otherButtonTitles:@"Open in Safari", @"Mail Link", @"Reload", nil];
	actionSheet.actionSheetStyle = UIStatusBarStyleBlackTranslucent;
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)fullScreenBrowser {
	if (browserViewSuperView == nil) {
		browserViewSuperView = myWebView.superview;
		[myWebView removeFromSuperview];
		[[self tabBarController].view addSubview:myWebView];
		CGSize s = [self tabBarController].view.frame.size;
		browserViewOriginalFrame = myWebView.frame;
		myWebView.frame = CGRectMake(0, 0, s.width, s.height);
	}
}

- (void)normalScreenBrowser {
	if (browserViewSuperView) {
		[myWebView removeFromSuperview];
		myWebView.frame = browserViewOriginalFrame;
		[browserViewSuperView addSubview:myWebView];
		browserViewSuperView = nil;
	}
}

- (void)toggleFullScreenTimeline {
	if (browserViewSuperView) {
		[self normalScreenBrowser];
	} else {
		[self fullScreenBrowser];
	}
}

- (void)accelerometerSensorDetected {
	[self toggleFullScreenTimeline];
}

- (void) emailLink {
	NSString *subject = @"";
	NSString *body = [[myWebView.request URL] absoluteString];
	
	NSString *emailAddress = @"";
	
	NSString *mailtoLink = 
	[NSString stringWithFormat: @"mailto:%@?subject=%@&body=%@", emailAddress, subject, body];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[mailtoLink stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[[UIApplication sharedApplication] openURL:[myWebView.request URL]];
			break;
		case 1:
			[self emailLink];
			break;
		case 2:
			[myWebView reload];
			break;
		default:
			break;
	}

}

@end
