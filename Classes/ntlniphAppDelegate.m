#import "ntlniphAppDelegate.h"
#import "NTLNAccount.h"
#import "NTLNTweetPostViewController.h"
#import "NTLNFriendsViewController.h"
#import "NTLNReplysViewController.h"
#import "NTLNSentsViewController.h"
#import "NTLNUnreadsViewController.h"
#import "NTLNConfigViewController.h"
#import "NTLNCacheCleaner.h"
#import "NTLNBrowserViewController.h"

#define kLastOpenTab @"lastOpenTab"

@implementation NTLNAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize applicationActive;
@synthesize browserViewController;
@synthesize tweetPostViewController;

- (void) addExtraControllers:(NSMutableArray*)controllers {
  UINavigationController *nsen = [[[UINavigationController alloc] 
										initWithRootViewController:sentsViewController] autorelease];
	UINavigationController *nunr = [[[UINavigationController alloc] 
										initWithRootViewController:unreadsViewController] autorelease];

	[nsen.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nsen.tabBarItem setTitle:@"Sents"];
	[nsen.tabBarItem setImage:[UIImage imageNamed:@"sent.png"]];

	[nunr.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nunr.tabBarItem setTitle:@"Unreads"];
	[nunr.tabBarItem setImage:[UIImage imageNamed:@"unread.png"]];

	[controllers addObject:nsen];
	[controllers addObject:nunr];
}
- (void)createViews {
	tweetPostViewController = [[NTLNTweetPostViewController alloc] 
									initWithNibName:@"TweetView" bundle:nil];
	[tweetPostViewController setSuperView:tabBarController.view];
	
	browserViewController = [[NTLNBrowserViewController alloc] init];

	friendsViewController = [[NTLNFriendsViewController alloc] init];
	replysViewController = [[NTLNReplysViewController alloc] init];
	sentsViewController = [[NTLNSentsViewController alloc] init];
	unreadsViewController = [[NTLNUnreadsViewController alloc] init];
	
	unreadsViewController.friendsViewController = friendsViewController;
	unreadsViewController.replysViewController = replysViewController;
	
	friendsViewController.appDelegate = self;
	friendsViewController.tweetPostViewController = tweetPostViewController;
	replysViewController.appDelegate = self;
	replysViewController.tweetPostViewController = tweetPostViewController;
	sentsViewController.appDelegate = self;
	sentsViewController.tweetPostViewController = tweetPostViewController;
	unreadsViewController.appDelegate = self;
	unreadsViewController.tweetPostViewController = tweetPostViewController;
	
	configViewController = [[NTLNConfigViewController alloc] initWithNibName:@"ConfigView" bundle:nil];
	
	UINavigationController *nfri = [[[UINavigationController alloc] 
										initWithRootViewController:friendsViewController] autorelease];
	UINavigationController *nrep = [[[UINavigationController alloc] 
										initWithRootViewController:replysViewController] autorelease];
	UINavigationController *nset = [[[UINavigationController alloc] 
										initWithRootViewController:configViewController] autorelease];
	
	NSMutableArray *controllers = [NSMutableArray arrayWithObjects:nfri, nrep, nil];
	
	[self addExtraControllers:controllers];
	
	[controllers addObject:nset];
	
	[tabBarController setViewControllers:controllers];
	
	tabBarController.delegate = self;
	
	[nfri.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nfri.tabBarItem setTitle:@"Tweets"];
	[nfri.tabBarItem setImage:[UIImage imageNamed:@"friends.png"]];
	friendsViewController.tabBarItem = nfri.tabBarItem; // is it need (to show badge)?
	
	[nrep.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nrep.tabBarItem setTitle:@"Replies"];
	[nrep.tabBarItem setImage:[UIImage imageNamed:@"replies.png"]];
	replysViewController.tabBarItem  = nrep.tabBarItem; // is it need (to show badge)?

	[nset.navigationBar setBarStyle:UIBarStyleBlackOpaque];
	[nset.tabBarItem setTitle:@"Settings"];
	[nset.tabBarItem setImage:[UIImage imageNamed:@"setting.png"]];
}

- (void)startup {
	[self createViews];
	
	if (![[NTLNAccount instance] valid]) {		
		
		tabBarController.selectedIndex = 4; // config view
	}
	else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSInteger tabIndex = [defaults integerForKey:kLastOpenTab];
		tabBarController.selectedIndex = tabIndex;
	}
	
	NSString *user_id = [[NTLNAccount instance] userId];
	if (user_id == nil || [user_id length] == 0) {
		[[NTLNAccount instance] getUserId];
	}
	else {
		[[NTLNAccount instance]getFollowing];
	}
	
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
	applicationActive = TRUE;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkActivityIndicator:) name:kIncNetActivityNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkActivityIndicator:) name:kDecNetActivityNotification object:nil];

	NTLNCacheCleaner *cc = [NTLNCacheCleaner sharedCacheCleaner];
	cc.delegate = self;
	BOOL alertShown = [cc bootup];
	if (!alertShown) {
		[self startup];
	}
}

- (void)cacheCleanerAlertClosed {
	[self startup];
}

- (void)dealloc {
	[friendsViewController release];
	[replysViewController release];
	[sentsViewController release];
	[unreadsViewController release];
	[configViewController release];
	[browserViewController release];
	[tweetPostViewController release];
	
	[tabBarController release];
	[window release];
	[super dealloc];
}

- (void)tabBarController:(UITabBarController *)_tabBarController 
			didSelectViewController:(UIViewController *)viewController {
	/*
	NSLog(@"view selected: %@", [[viewController tabBarItem] title]);
	if (_tabBarController.selectedViewController) {
		[_tabBarController.selectedViewController viewWillDisappear:FALSE];
		[_tabBarController.selectedViewController viewDidDisappear:FALSE];
	}
	
	[viewController viewWillAppear:FALSE];
	[viewController viewDidAppear:FALSE];
	 */
	 
	NSInteger index = [_tabBarController.viewControllers indexOfObject:viewController];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setInteger:index forKey:kLastOpenTab];
	[defaults synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"applicationWillResignActive");
	applicationActive = FALSE;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"applicationDidBecomeActive");
	applicationActive = TRUE;
	[friendsViewController getTimelineWithPage:0 autoload:YES];
	[replysViewController getTimelineWithPage:0 autoload:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"applicationWillTerminate");
	[[NTLNCacheCleaner sharedCacheCleaner] shutdown];
}

- (void) networkActivityIndicator:(NSNotification*)notification {
	BOOL increment = [[notification name] isEqualToString:kIncNetActivityNotification];
	networkActivityCount += (increment?1:-1);
	[UIApplication sharedApplication].networkActivityIndicatorVisible = networkActivityCount > 0;
}

@end
