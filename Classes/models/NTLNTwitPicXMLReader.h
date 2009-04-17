//
//  NTLNTwitPicXMLReader.h
//  HideNGoSnap
//
//  Created by John Ellis on 12/15/08.
//  Copyright 2008 Dove Valley Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTLNTwitPicXMLReader : NSObject {
	NSMutableString *currentStringValue;
	BOOL readText;
	
	NSString *mediaUrl;
	NSString *mediaId;
	NSString *statusId;
	NSString *userId;
	
	NSString *errMsg;
	
	NSInteger errCode;
}

@property (nonatomic, retain) NSString *mediaId, *mediaUrl, *statusId, *userId, *errMsg;
@property (nonatomic) NSInteger errCode;

- (void)parseXMLData:(NSData *)data;

@end
