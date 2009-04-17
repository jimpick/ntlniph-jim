#import "NTLNLinkViewController.h"
#import "NTLNMessage.h"
#import "NTLNURLUtils.h"
#import "NTLNBrowserViewController.h"
#import "NTLNFriendsViewController.h"
#import "NTLNTweetPostViewController.h"
#import "NTLNAccount.h"
#import "NTLNRoundedIconView.h"
#import "NTLNUserTimelineViewController.h"
#import "NTLNConfiguration.h"
#import "NTLNColors.h"
#import "NTLNCellBackgroundView.h"
#import "NTLNXMLHTTPEncoder.h"

#define TEXT_FONT_SIZE	16.0

#define FAVBUTTON_DESTROY_FAV	@"Un-Favorite"
#define FAVBUTTON_MAKE_FAV		@"Favorite"

#define FOLBUTTON_UN_FOLLOW		@"UN-FOLLOW"
#define FOLBUTTON_FOLLOW		@"FOLLOW"

#define HASHTAG_URL_FORMAT		@"http://search.twitter.com/search?q=%@"

@implementation NTLNURLPair
@synthesize url, text, screenName, singleUser;

- (void)dealloc {
	[url release];
	[text release];
	[screenName release];
	[super dealloc];
}
@end

@implementation NTLNLinkViewController

@synthesize message, appDelegate, tweetPostViewController;

- (void)setupTableView {
	UITableView *tv = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
												   style:UITableViewStylePlain] autorelease];	
	tv.delegate = self;
	tv.dataSource = self;
	tv.autoresizesSubviews = YES;
	tv.separatorStyle = UITableViewCellSeparatorStyleNone;
	
/*	
	UIView *v = [[[UIView alloc] initWithFrame:CGRectMake(0, -10, 320, 10)] autorelease];
	v.backgroundColor = [UIColor blueColor];
	[tv addSubview:v];
	
	v = [[[UIView alloc] initWithFrame:CGRectMake(0, 300, 320, 10)] autorelease];
	v.backgroundColor = [UIColor blueColor];
	[tv addSubview:v];
*/		
	self.view = tv;
}

- (void)viewDidLoad {
	[self setupTableView];
	[urls release];
	urls = [[NSMutableArray alloc] init];
	((UITableView*)self.view).autoresizesSubviews = YES;
	[self.navigationItem setTitle:@"Tweet"];
}

- (void)viewWillAppear:(BOOL)animated {
	NSIndexPath *tableSelection = [(UITableView*)self.view indexPathForSelectedRow];
	[(UITableView*)self.view deselectRowAtIndexPath:tableSelection animated:NO];
	
	[self parseToken];

	[messageOwnerUrl release];
	messageOwnerUrl = [[NTLNURLPair alloc] init];
	messageOwnerUrl.url = [@"http://twitter.com/" stringByAppendingString:message.screenName];
	messageOwnerUrl.text = [@"@" stringByAppendingString:message.screenName];
	
	[(UITableView*)self.view reloadData];
	
	((UITableView*)self.view).backgroundColor = [[NTLNColors instance] scrollViewBackground];
	if ([[NTLNConfiguration instance] darkColorTheme]) {
		((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleWhite;
	} else {
		((UITableView*)self.view).indicatorStyle = UIScrollViewIndicatorStyleBlack;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	NSLog(@"NTLNLinkViewController#didReceiveMemoryWarning");
}

- (void)dealloc {
	NSLog(@"NTLNLinkViewController#dealloc");
	[urls release];
	[messageOwnerUrl release];
	[message release];
	[redButton release];
	[greenButton release];
	[super dealloc];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == 0) {
		return 130 + [self getTextboxHeight:message.text];
	}
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1 + [urls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	switch(row)
	{
		case 0:
			return [self screenNameCell];
//		case 1:
//			return [self urlCell:messageOwnerUrl isEven:NO];
		default:
			return [self urlCell:[urls objectAtIndex:row-1] isEven:(row%2==0)];
	}
}

- (void)switchToUserTimelineViewWithScreenName:(NSString*)screenName {
	NTLNUserTimelineViewController *utvc = [[[NTLNUserTimelineViewController alloc] init] autorelease];
	utvc.screenName = screenName;
	utvc.appDelegate = appDelegate;
	utvc.tweetPostViewController = tweetPostViewController;
	[[self navigationController] pushViewController:utvc animated:YES];
}

- (void)switchToUserTimelineViewWithScreenNames:(NSArray*)screenNames {
	NTLNUserTimelineViewController *utvc = [[[NTLNUserTimelineViewController alloc] init] autorelease];
	utvc.screenNames = screenNames;
	utvc.appDelegate = appDelegate;
	utvc.tweetPostViewController = tweetPostViewController;
	[[self navigationController] pushViewController:utvc animated:YES];
}

- (void)switchToBrowserViewWithURL:(NSString*)url {
	if ([[NTLNConfiguration instance] useSafari]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	} else {
		NTLNBrowserViewController *browser = appDelegate.browserViewController;
		browser.url = url;
		[[self navigationController] pushViewController:browser animated:YES];
	}
}
	
- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NTLNURLPair *pair = nil;
	int row = [indexPath row];

	switch (row){
		case 0:
			break;
//		case 1:
//			[self switchToUserTimelineViewWithScreenName:message.screenName];
//			break;
		default:
			{
				NTLNURLPair *up = [urls objectAtIndex:row-1];
				if (up.screenName && up.singleUser) {
					[self switchToUserTimelineViewWithScreenName:message.screenName];
				}
				else if (up.screenName) {
					NSArray *names = [[NSArray alloc] initWithObjects:message.screenName, up.screenName, nil];
					[self switchToUserTimelineViewWithScreenNames:names];
					[names release];
				} else {
					pair = up;
				}
			}
			break;
	}
	
	if (pair)
	{
		[self switchToBrowserViewWithURL:pair.url];
	}
}

- (void)favButtonAction:(id)sender {
	NTLNTwitterClient *twitterClient = [[NTLNTwitterClient alloc] initWithDelegate:self];
	twitterClient.state = 1;
	if (message.favorited) {
		[twitterClient destroyFavoriteWithID:message.statusId];
	} else {
		[twitterClient createFavoriteWithID:message.statusId];
	}
	
	[favButton setTitle:@"(sending...)" forState:UIControlStateNormal]; // to redraw
	[favButton setTitle:@"(sending...)" forState:UIControlStateDisabled];
}

- (void)folButtonAction:(id)sender {
	NSNumber *following = [[NTLNAccount instance] amIFollowing:message.userId];

	NTLNTwitterClient *twitterClient = [[NTLNTwitterClient alloc] initWithDelegate:self];
	if (![following boolValue]) {
		twitterClient.state = 2;
		[twitterClient followUser:message.userId];
	} else {
		twitterClient.state = 3;
		[twitterClient unFollowUser:message.userId];
	}
	
	[followButton setTitle:@"(sending...)" forState:UIControlStateNormal]; // to redraw
	[followButton setTitle:@"(sending...)" forState:UIControlStateDisabled];
}

- (void)replyButtonAction:(id)sender {
	[[self navigationController].view addSubview:tweetPostViewController.view];
	
	if (message.replyType == NTLN_MESSAGE_REPLY_TYPE_DIRECT) {
		[tweetPostViewController createDMPost:message.screenName];
	} else {
		[tweetPostViewController createReplyPost:[@"@" stringByAppendingString:message.screenName]];
	}
	
	[tweetPostViewController showWindow];
}

- (void)retweetButtonAction:(id)sender {
	[[self navigationController].view addSubview:tweetPostViewController.view];
	
	[tweetPostViewController createReplyPost:[NSString stringWithFormat:@"RT @%@: %@", message.screenName, message.text]];
	
	[tweetPostViewController showWindow];
}

- (CGFloat)getTextboxHeight:(NSString *)str
{
	CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT_SIZE] constrainedToSize:CGSizeMake(290.0, 290.0)];
	CGFloat h = size.height;
//	if (h < 26.0) return 26.0;
	return h;
}

- (NSString*)favButtonText {
	if (message.favorited) {
		return FAVBUTTON_DESTROY_FAV;
	} else {
		return FAVBUTTON_MAKE_FAV;
	}
}

- (BOOL) isFollowing {
  NSNumber *following = [[NTLNAccount instance] amIFollowing:message.userId];
	if (!following) {
		return false;
	}
	
	BOOL followingBool = [following boolValue];
  return followingBool;
}
- (NSString*)followButtonText {
	if ([message.userId isEqualToString:[[NTLNAccount instance] userId]]) {
		return nil;
	}
	
	BOOL followingBool = [self isFollowing];

	if (followingBool) {
		return FOLBUTTON_UN_FOLLOW;
	} else {
		return FOLBUTTON_FOLLOW;
	}
}

#define kDetailButtonHeight 30
#define kDetailButtonWidth 93
#define kDetailButtonMargin 8

#define kFollowButtonWidth 65

- (UITableViewCell *)screenNameCell {
	UIColor *bgcolor = [[NTLNColors instance] evenBackground];

	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
		
	CGFloat followButtonWidth = 0;
	
	NSString *folButtonText = [self followButtonText];
	
	if (folButtonText) {
		followButtonWidth = kFollowButtonWidth + kDetailButtonMargin;
	}
	
	UILabel *name = [[[UILabel alloc] initWithFrame:CGRectMake(76.0, 6.0, 
															   230.0 - followButtonWidth, 
															   30.0)] autorelease];
	name.font = [UIFont boldSystemFontOfSize:20.0];
//	name.textColor = [UIColor grayColor];
	name.backgroundColor = bgcolor;
	name.lineBreakMode = UILineBreakModeTailTruncation;
	name.adjustsFontSizeToFitWidth = YES;
	name.textColor = [[NTLNColors instance] textForground];
	name.text = message.name;
	name.shadowColor = [[NTLNColors instance] textShadow];
	name.shadowOffset = CGSizeMake(0, 1);
	[cell.contentView addSubview:name];	

	UILabel *name2 = [[[UILabel alloc] initWithFrame:CGRectMake(76.0, 6.0+30, 230.0, 20.0)] autorelease];
	name2.font = [UIFont boldSystemFontOfSize:14.0];
//	name2.textColor = [UIColor grayColor];
	name2.backgroundColor = bgcolor;
	name2.lineBreakMode = UILineBreakModeTailTruncation;
	name2.textColor = [[NTLNColors instance] textForground];
	name2.text = message.screenName;
	name2.shadowColor = [[NTLNColors instance] textShadow];
	name2.shadowOffset = CGSizeMake(0, 1);
	[cell.contentView addSubview:name2];	
	
	NTLNRoundedIconView *iconview = [[[NTLNRoundedIconView alloc] 
										initWithFrame:CGRectMake(10, 10.0, 56.0, 56.0) 
												image:message.icon 
												round:10.0] autorelease];
	iconview.backgroundColor = bgcolor;
	[iconview addTarget:self action:@selector(replyButtonAction:)
		forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:iconview];	
	
	if (folButtonText) {
		redButton = [[[UIImage imageNamed:@"red-button.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] retain];
		greenButton = [[[UIImage imageNamed:@"green-button.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:0] retain];
		
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setFrame:CGRectMake(76.0 + 230.0 - kFollowButtonWidth, 10.0, 
							   kFollowButtonWidth, 25)];
		[b setTitle:folButtonText forState:UIControlStateNormal];
		[b addTarget:self action:@selector(folButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		b.font = [UIFont boldSystemFontOfSize:10];
		[cell addSubview:b];
		followButton = b;
		[followButton setBackgroundImage:[self isFollowing]?redButton:greenButton forState:UIControlStateNormal];
	}
	
	CGFloat textHeight = [self getTextboxHeight:message.text];
	
	UILabel *text = [[[UILabel alloc] initWithFrame:CGRectMake(10.0, 76.0, 290.0, textHeight)] autorelease];
	text.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
	//	text.textColor = [UIColor grayColor];
	text.backgroundColor = bgcolor;
	text.lineBreakMode = UILineBreakModeWordWrap;
	text.textColor = [[NTLNColors instance] textForground];
	text.text = message.text;
	text.numberOfLines = 0;	
	[cell.contentView addSubview:text];	
	
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.selectedTextColor = [UIColor whiteColor];
	
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[b setFrame:CGRectMake(kDetailButtonMargin, 86 + textHeight, kDetailButtonWidth, kDetailButtonHeight)];
		[b setTitle:@"Reply" forState:UIControlStateNormal];
		[b addTarget:self action:@selector(replyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[b setFrame:CGRectMake((kDetailButtonMargin * 2) + kDetailButtonWidth, 86 + textHeight, kDetailButtonWidth, kDetailButtonHeight)];
		[b setTitle:@"Re-Tweet" forState:UIControlStateNormal];
		[b addTarget:self action:@selector(retweetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
	}
	{
		UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[b setFrame:CGRectMake((kDetailButtonMargin * 3) + (kDetailButtonWidth * 2), 86 + textHeight, 
							   kDetailButtonWidth, kDetailButtonHeight)];
		[b setTitle:[self favButtonText] forState:UIControlStateNormal];
		[b addTarget:self action:@selector(favButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell addSubview:b];
		favButton = b;
	}
	
	cell.backgroundView = [[[NTLNCellBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
	cell.backgroundView.backgroundColor = bgcolor;
	
	return cell;
}

- (UITableViewCell *)urlCell:(NTLNURLPair*)pair isEven:(BOOL)isEven {	
	NTLNLinkCell *cell = [[[NTLNLinkCell alloc] initWithFrame:CGRectZero] autorelease];
	[cell createCell:pair isEven:isEven];
	return cell;
}

- (void)parseToken {
	
	[urls removeAllObjects];
	
	if (message.userWebpage) {
		// add webpage url
		NTLNURLPair *pair = [[[NTLNURLPair alloc]init]autorelease];
		pair.text = [NSString stringWithFormat:@"%@ Web", message.screenName];
		pair.url = message.userWebpage;
		[urls addObject:pair];
	}	
	
	NTLNURLPair *pair = [[[NTLNURLPair alloc]init]autorelease];
	pair.text = [NSString stringWithFormat:@"@%@", message.screenName];
	pair.screenName = message.screenName;
	pair.url = [@"http://twitter.com/" stringByAppendingString:pair.screenName];
	pair.singleUser = true;
	[urls addObject:pair];
	
	NTLNURLUtils *utils = [NTLNURLUtils utils];
    NSArray *tokens = [utils tokenizeByAll:message.text];
	int i;
    for (i = 0; i < [tokens count]; i++) {
        NSString *token = [tokens objectAtIndex:i];
        if ([utils isURLToken:token]) {
			NTLNURLPair *pair = [[NTLNURLPair alloc] init];
			pair.text = token;
			pair.url = token;
			[urls addObject:pair];
			[pair release];
		} 
		else if ([utils isIDToken:token] && 
				 ! [message.screenName isEqualToString:[token substringFromIndex:1]]) {
			NTLNURLPair *pair = [[NTLNURLPair alloc] init];
			pair.text = [NSString stringWithFormat:@"@%@ + %@", message.screenName, token];
			pair.screenName = [token substringFromIndex:1];
			pair.url = [@"http://twitter.com/" stringByAppendingString:pair.screenName];
			[urls addObject:pair];
			[pair release];
        }
		else if ([utils isHashtagToken:token]) {
			NTLNURLPair *pair = [[NTLNURLPair alloc] init];
			pair.text = token;
			
			NSString *tag = [token substringFromIndex:1];
			
			pair.url = [NSString stringWithFormat:HASHTAG_URL_FORMAT, [NTLNXMLHTTPEncoder encodeHTTP:tag]];
			[urls addObject:pair];
			[pair release];
        }
    }
}

- (void)twitterClientSucceeded:(NTLNTwitterClient*)sender messages:(NSArray*)messages {
	if (sender.state == 1) {
		message.favorited = !message.favorited;
		[favButton setTitle:[self favButtonText] forState:UIControlStateNormal];
	}
	else if (sender.state == 2) {
		// add to array
		[[NTLNAccount instance]followed:message.userId];
		[followButton setTitle:[self followButtonText] forState:UIControlStateNormal];
	}
	else if (sender.state == 3) {
		// remove from array
		[[NTLNAccount instance]unFollowed:message.userId];
		[followButton setTitle:[self followButtonText] forState:UIControlStateNormal];
	}
	[followButton setBackgroundImage:[self isFollowing]?redButton:greenButton forState:UIControlStateNormal];
}

- (void)twitterClientFailed:(NTLNTwitterClient*)sender {
	[favButton setTitle:[self favButtonText] forState:UIControlStateNormal];
	[followButton setTitle:[self followButtonText] forState:UIControlStateNormal];
}

- (void)twitterClientBegin:(NTLNTwitterClient*)sender {
	NSLog(@"LinkView#twitterClientBegin");
}

- (void)twitterClientEnd:(NTLNTwitterClient*)sender {
	NSLog(@"LinkView#twitterClientEnd");
}

@end


@implementation NTLNLinkCell

+ (void)drawText:(NSString*)text selected:(BOOL)selected{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (selected) {
		CGContextSetFillColorWithColor(context, [[NTLNColors instance] textSelected].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [[NTLNColors instance] textForground].CGColor);
	}
	
	[text drawInRect:CGRectMake(10, 10, 280, 24)
						withFont:[UIFont boldSystemFontOfSize:18]
					lineBreakMode:UILineBreakModeTailTruncation];
}	

- (void)createCell:(NTLNURLPair*)aPair isEven:(BOOL)_isEven {
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	[pair release];
	pair = [aPair retain];
	isEven = _isEven;
	
	NTLNSelectedLinkCellBackground *v = [[[NTLNSelectedLinkCellBackground alloc] 
										  initWithFrame:CGRectZero] autorelease];
	v.pair = pair;
	self.selectedBackgroundView = v;
}

- (void)dealloc {
	[pair release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	
	UIColor *bgcolor;
	if (isEven) {
		bgcolor = [[NTLNColors instance] evenBackground];
	} else {
		bgcolor = [[NTLNColors instance] oddBackground];
	}
	
	[NTLNCellBackgroundView drawBackground:rect backgroundColor:bgcolor];
	[NTLNLinkCell drawText:pair.text selected:NO];
}

@end


@implementation NTLNSelectedLinkCellBackground

@synthesize pair;

- (void)dealloc {
	[pair release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[NTLNCellBackgroundView drawBackground:rect backgroundColor:[[NTLNColors instance] selectedBackground]];
	[NTLNLinkCell drawText:pair.text selected:YES];
}

@end

