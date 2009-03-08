#import <UIKit/UIKit.h>

@interface NTLNUser : NSObject {
	@private
	NSString *user_id;
	NSString *twit_uid;
	NSString *screen_name;
	NSString *profile_image_url;
	NSString *webpage;
}

@property (readwrite, copy) NSString *user_id;
@property (readwrite, copy) NSString *twit_uid;
@property (readwrite, copy) NSString *screen_name;
@property (readwrite, copy) NSString *profile_image_url;
@property (readwrite, copy) NSString *webpage;

@end
