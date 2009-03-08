#import <UIKit/UIKit.h>

@interface NTLNHttpClient : NSObject {
    NSURLConnection *connection;
    NSMutableData *recievedData;
	int statusCode;	
	BOOL contentTypeIsXml;
	CGFloat imgQuality;
	NSData *imageData;
	int state;
}

- (void)requestGET:(NSString*)url;
- (void)requestGET:(NSString*)url username:(NSString*)username password:(NSString*)password;
//- (void)requestPOST:(NSString*)url body:(NSString*)body;
- (void)requestPOST:(NSString*)url body:(NSString*)body username:(NSString*)username password:(NSString*)password;
- (void)requestPOSTImage:(NSString*)url image:(UIImage*)image message:(NSString*)message username:(NSString*)username password:(NSString*)password;
- (void)cancel;

- (void)requestSucceeded;
- (void)requestFailed:(NSError*)error;

@property (readonly) NSMutableData *recievedData;
@property (readonly) int statusCode;
@property (nonatomic) CGFloat imgQuality;
@property (nonatomic, retain) NSData *imageData;
@property (nonatomic) int state;

@end
