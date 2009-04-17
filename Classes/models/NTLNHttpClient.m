#import "NTLNHttpClient.h"
#import "ntlniphAppDelegate.h"

#define TIMEOUT_SEC		20.0

@implementation NTLNHttpClient

@synthesize recievedData, statusCode, imgQuality, imageData, state;

- (id)init {
	self = [super init];
	recievedData = [[NSMutableData alloc] init];
	self.imgQuality = 1;
	return self;
}

- (void)dealloc {
#ifdef DEBUG
	NSLog(@"NTLNHttpClient#dealloc");
#endif
	self.imageData = nil;
	[connection release];
	[recievedData release];
	[super dealloc];
}

+ (NSString*)stringEncodedWithBase64:(NSString*)str
{
	static const char *tbl = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	const char *s = [str UTF8String];
	int length = [str length];
	char *tmp = malloc(length * 4 / 3 + 4);

	int i = 0;
	int n = 0;
	char *p = tmp;
	
	while (i < length) {
		n = s[i++];
		n *= 256;
		if (i < length) n += s[i];
		i++;
		n *= 256;
		if (i < length) n += s[i];
		i++;
		
		p[0] = tbl[((n & 0x00fc0000) >> 18)];
		p[1] = tbl[((n & 0x0003f000) >> 12)];
		p[2] = tbl[((n & 0x00000fc0) >>  6)];
		p[3] = tbl[((n & 0x0000003f) >>  0)];
		
		if (i > length) p[3] = '=';
		if (i > length + 1) p[2] = '=';

		p += 4;
	}
	
	*p = '\0';
	
	NSString *ret = [NSString stringWithCString:tmp];
	free(tmp);

	return ret;
}

+ (NSString*) stringOfAuthorizationHeaderWithUsername:(NSString*)username password:(NSString*)password {
    NSString *s = @"Basic ";
    [s autorelease];
    return [s stringByAppendingString:[NTLNHttpClient stringEncodedWithBase64:[NSString stringWithFormat:@"%@:%@", username, password]]];
}

- (NSMutableURLRequest*)makeRequest:(NSString*)url {
	NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(
										NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:encodedUrl]];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	[request setTimeoutInterval:TIMEOUT_SEC];
	[request setHTTPShouldHandleCookies:FALSE];
	[encodedUrl release];
	return request;
}

- (NSMutableURLRequest*)makeRequest:(NSString*)url username:(NSString*)username password:(NSString*)password {
	NSMutableURLRequest *request = [self makeRequest:url];
	[request setValue:[NTLNHttpClient stringOfAuthorizationHeaderWithUsername:username password:password]
		forHTTPHeaderField:@"Authorization"];
	return request;
}

- (void)requestGET:(NSString*)url {
	[[NSNotificationCenter defaultCenter]postNotificationName:kIncNetActivityNotification object:self];
	NSMutableURLRequest *request = [self makeRequest:url];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)requestGET:(NSString*)url username:(NSString*)username password:(NSString*)password {
	[[NSNotificationCenter defaultCenter]postNotificationName:kIncNetActivityNotification object:self];
	NSMutableURLRequest *request = [self makeRequest:url username:username password:password];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}
/*
- (void)requestPOST:(NSString*)url body:(NSString*)body {
    [[NSNotificationCenter defaultCenter]postNotificationName:kIncNetActivityNotification object:self];
	NSMutableURLRequest *request = [self makeRequest:url];
    [request setHTTPMethod:@"POST"];
	if (body) {
		[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	}
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
*/

- (NSMutableURLRequest*) getRequest:(NSString*) url forImage:(UIImage*) image  message:(NSString*)message username:(NSString*)username password:(NSString*)password {
	//NSDictionary *headers = [NSDictionary dictionaryWithObject:title forKey:@"Slug"];
	self.imageData = UIImageJPEGRepresentation(image, self.imgQuality);
	NSLog(@"image size: %d", [imageData length]);
	NSString *boundary = @"END_OF_PART";
	NSMutableData *postBody = [NSMutableData data];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name=\"media\"; filename=\"ntln.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:self.imageData];

	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"username\"\r\n\r\n%@\r\n", username] 
						  dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n%@\r\n", password] 
						  dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"message\"\r\n\r\n%@\r\n", message] 
						  dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
	[request setURL: [NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	NSString *dataLength = [NSString stringWithFormat: @"%d", postBody.length]; 
	[request setValue: dataLength forHTTPHeaderField: @"Content-Length"];
	
	[request setHTTPBody: postBody];
	
	return request;
}

- (void)requestPOSTImage:(NSString*)url image:(UIImage*)image message:(NSString*)message username:(NSString*)username password:(NSString*)password {
	[[NSNotificationCenter defaultCenter]postNotificationName:kIncNetActivityNotification object:self];
	NSMutableURLRequest *request = [self getRequest:url forImage:image message:message username:username password:password];
    [request setHTTPMethod:@"POST"];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)requestPOST:(NSString*)url body:(NSString*)body username:(NSString*)username password:(NSString*)password {
	[[NSNotificationCenter defaultCenter]postNotificationName:kIncNetActivityNotification object:self];
	NSMutableURLRequest *request = [self makeRequest:url username:username password:password];
    [request setHTTPMethod:@"POST"];
	if (body) {
		[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	}
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)cancel {
	[connection cancel];
	[self requestFailed:nil];
	[[NSNotificationCenter defaultCenter]postNotificationName:kDecNetActivityNotification object:self];
}

- (void)requestSucceeded {
	// implement by subclass
}

- (void)requestFailed:(NSError*)error {
	// implement by subclass
}
/*
-(void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge { 
	[[challenge sender] cancelAuthenticationChallenge:challenge]; 
}    
*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    statusCode = [(NSHTTPURLResponse*)response statusCode];
	NSDictionary *header = [(NSHTTPURLResponse*)response allHeaderFields];

	contentTypeIsXml = NO;
	NSString *content_type = [header objectForKey:@"Content-Type"];
	if (content_type) {
		NSRange r = [content_type rangeOfString:@"xml"];
		if (r.location != NSNotFound) {
			contentTypeIsXml = YES;
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self requestSucceeded];
	[[NSNotificationCenter defaultCenter]postNotificationName:kDecNetActivityNotification object:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*) error {
	[self requestFailed:error];
	[[NSNotificationCenter defaultCenter]postNotificationName:kDecNetActivityNotification object:self];
}

@end
