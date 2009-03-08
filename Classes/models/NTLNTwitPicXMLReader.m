//
//  NTLNTwitPicXMLReader.m
//  HideNGoSnap
//
//  Created by John Ellis on 12/15/08.
//  Copyright 2008 Dove Valley Apps. All rights reserved.
//

#import "NTLNTwitPicXMLReader.h"


@implementation NTLNTwitPicXMLReader

@synthesize mediaId, mediaUrl, statusId, userId, errMsg, errCode;

- (void)parseXMLData:(NSData *)data {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
	[parser parse];
	[parser release];
}



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	readText = NO;
	
	[currentStringValue release];
	currentStringValue = nil;
	
	if ([elementName isEqualToString:@"mediaid"] ||
			   [elementName isEqualToString:@"mediaurl"] ||
			   [elementName isEqualToString:@"statusid"] ||
			   [elementName isEqualToString:@"userid"]) {
		readText = YES;
		currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
	}
	else if ([elementName isEqualToString:@"err"]) {
		NSString *code = [attributeDict objectForKey:@"code"];
		self.errCode = [code intValue];
		self.errMsg = [attributeDict objectForKey:@"msg"];
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
	if (readText) {
		if ([elementName isEqualToString:@"mediaid"]) {
			self.mediaId = currentStringValue;
		}
		else if ([elementName isEqualToString:@"mediaurl"]) {
			self.mediaUrl = currentStringValue;
		}
		else if ([elementName isEqualToString:@"statusid"]) {
			self.statusId = currentStringValue;
		}
		else if ([elementName isEqualToString:@"userid"]) {
			self.userId = currentStringValue;
		}
	}
	
	//	NSLog(@"<%@> : %@", elementName, currentStringValue);
    
	[currentStringValue release];
    currentStringValue = nil;
}




@end
