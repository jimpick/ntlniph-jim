#import "NTLNTwitterXMLReader.h"
#import "NTLNXMLHTTPEncoder.h"
#import "NTLNIconRepository.h"
#import "NTLNAccount.h"

@implementation NTLNTwitterXMLReader

@synthesize messages;

- (id)init {
	self = [super init];
	messages = [[NSMutableArray alloc] init];
	return self;
}

+ (NSString*) decodeHeart:(NSString*)aString {
    NSMutableString *s = [aString mutableCopy];
    [s replaceOccurrencesOfString:@"<3" withString:@"♥" options:0 range:NSMakeRange(0, [s length])];
	[s autorelease];
    return s;
}

- (void)parseXMLData:(NSData *)data {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
	[parser parse];
	[parser release];
}

- (void)didParseMessage:(NTLNMessage*)message iconURL:(NSString*)iconURL {
	[message setIconForURL:iconURL];
	if ([currentInReplyToUserId isEqualToString:[[NTLNAccount instance] userId]]) {
		message.replyType = NTLN_MESSAGE_REPLY_TYPE_REPLY;
	} else {
		[message finishedToSetProperties:currentMsgDirectMessage];
	}
	[messages addObject:message];
}

- (void)dealloc {
	[currentMessage release];
	[currentIconURL release];
	[currentStringValue release];
	[messages release];	
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

	readText = NO;
	
	[currentStringValue release];
	currentStringValue = nil;
	
	BOOL d = [elementName isEqualToString:@"direct_message"];
	
	if ([elementName isEqualToString:@"status"] || d) {
		[currentMessage release];
		currentMessage = [[[NTLNMessage alloc] init] autorelease];
		[currentIconURL release];
		currentIconURL = nil;
		[currentInReplyToUserId release];
		currentInReplyToUserId = nil;
		statusTagChild = YES;
		userTagChild = NO;
		currentMsgDirectMessage = d;
	} else if (currentMessage && ([elementName isEqualToString:@"user"] || [elementName isEqualToString:@"sender"])) {
		statusTagChild = NO;
		userTagChild = YES;
	} else if ([elementName isEqualToString:@"id"] ||
				[elementName isEqualToString:@"text"] ||
				[elementName isEqualToString:@"created_at"] ||
			   [elementName isEqualToString:@"source"] ||
			   [elementName isEqualToString:@"favorited"] ||
				[elementName isEqualToString:@"name"] ||
			   [elementName isEqualToString:@"screen_name"] ||
			   [elementName isEqualToString:@"url"] ||
				[elementName isEqualToString:@"in_reply_to_user_id"] ||
			   [elementName isEqualToString:@"profile_image_url"]) {
		readText = YES;
		currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (readText) {
		[currentStringValue appendString:string];
	}
}

//- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
//}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if (currentMessage) {
		if ([elementName isEqualToString:@"status"] || [elementName isEqualToString:@"direct_message"]) {
			[self didParseMessage:currentMessage iconURL:currentIconURL];
			currentMessage = nil;
			[currentIconURL release];
			currentIconURL = nil;
			[currentInReplyToUserId release];
			currentInReplyToUserId = nil;
			currentMsgDirectMessage = NO;
		} else if (currentMessage && ([elementName isEqualToString:@"user"] || [elementName isEqualToString:@"sender"])) {
			userTagChild = NO;
		}
		
		if (statusTagChild) {
			if ([elementName isEqualToString:@"id"]) {
				[currentMessage setStatusId:currentStringValue];
			} else if ([elementName isEqualToString:@"text"]) {
				[currentMessage setText:[NTLNTwitterXMLReader decodeHeart:
										 [NTLNXMLHTTPEncoder decodeXML:currentStringValue]]];
			} else if ([elementName isEqualToString:@"source"]) {
				[currentMessage setSource:currentStringValue];
			} else if ([elementName isEqualToString:@"created_at"]) {
				struct tm time;
				strptime([currentStringValue UTF8String], "%a %b %d %H:%M:%S %z %Y", &time);
				[currentMessage setTimestamp:[NSDate dateWithTimeIntervalSince1970:mktime(&time)]];
			} else if ([elementName isEqualToString:@"favorited"]) {
				if ([currentStringValue isEqualToString:@"true"]) {
					currentMessage.favorited = TRUE;
				}
			} else if ([elementName isEqualToString:@"in_reply_to_user_id"]) {
				currentInReplyToUserId = [currentStringValue copy];
			}
		}

		if (userTagChild) {
			if ([elementName isEqualToString:@"name"]) {
				[currentMessage setName:currentStringValue];
			} else if ([elementName isEqualToString:@"screen_name"]) {
				[currentMessage setScreenName:currentStringValue];
			} else if ([elementName isEqualToString:@"id"]) {
				[currentMessage setUserId:currentStringValue];
			} else if ([elementName isEqualToString:@"profile_image_url"]) {
				//[currentMessage setName:currentStringValue];
				currentIconURL = currentStringValue;
				[currentIconURL retain];
			} else if ([elementName isEqualToString:@"url"]) {
				if ([currentStringValue length] > 0) {
					[currentMessage setUserWebpage:currentStringValue];
				}
			}
		}
	}

//	NSLog(@"<%@> : %@", elementName, currentStringValue);
    
	[currentStringValue release];
    currentStringValue = nil;
}

@end
