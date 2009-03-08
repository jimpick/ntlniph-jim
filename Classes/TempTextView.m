//
//  TempTextView.m
//  HideNGoSnap
//
//  Created by John Ellis on 12/3/08.
//  Copyright 2008 Dove Valley Apps. All rights reserved.
//

#import "TempTextView.h"


@implementation TempTextView

- (void) setSelectedRange:(NSRange)newRange {
	NSLog(@"========================== set sel: %d", newRange.location);
	[super setSelectedRange:newRange];
}
- (void) setText:(NSString*)newText {
	NSLog(@"========================== set text: %@", newText);
	[super setText:newText];
}

- (BOOL)becomeFirstResponder {
	NSLog(@"========================== firstResponder");
	return [super becomeFirstResponder];
}

@end
