//
//  NTLNTwitterErrorXmlReader.m
//  HideNGoSnap
//
//  Created by John Ellis on 3/1/09.
//  Copyright 2009 Dove Valley Apps. All rights reserved.
//

#import "NTLNTwitterErrorXmlReader.h"


@implementation NTLNTwitterErrorXmlReader

@synthesize request, error;

- (void)parseXMLData:(NSData *)data {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
	[parser parse];
	[parser release];
}

- (void)dealloc {
	self.error = nil;
	self.request = nil;
	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser 
	didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict {
	
	readText = NO;
	
	if (currentStringValue) {
		[currentStringValue release];
		currentStringValue = nil;
	}
	readText = NO;
	
	if ([elementName isEqualToString:@"request"] ||
			   [elementName isEqualToString:@"error"]) {
		readText = YES;
		currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
	} 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (readText) {
		[currentStringValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser 
	didEndElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName {
	
	if (readText) {
		if ([elementName isEqualToString:@"request"]) {
			self.request = currentStringValue;
		} else if ([elementName isEqualToString:@"error"]) {
			self.error = currentStringValue;
		}
	}
	
    if (currentStringValue) {
		[currentStringValue release];
		currentStringValue = nil;
	}
}


@end
