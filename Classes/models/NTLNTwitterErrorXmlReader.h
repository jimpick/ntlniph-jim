//
//  NTLNTwitterErrorXmlReader.h
//  HideNGoSnap
//
//  Created by John Ellis on 3/1/09.
//  Copyright 2009 Dove Valley Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTLNTwitterErrorXmlReader : NSObject {
	NSMutableString *currentStringValue;
	BOOL readText;

	NSString *request;
	NSString *error;
}

@property (nonatomic, retain) NSString *request;
@property (nonatomic, retain) NSString *error;

- (void)parseXMLData:(NSData *)data;

@end
