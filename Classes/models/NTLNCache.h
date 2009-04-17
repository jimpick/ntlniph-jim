//
//  NTLNCache.h
//  ntlniph
//
//  Created by Takuma Mori on 08/08/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NTLNCache : NSObject {

}

+ (NSString*)createCacheDirectoryWithName:(NSString*)name;
+ (NSString*)createIconCacheDirectory;
+ (NSString*)createXMLCacheDirectory;
+ (NSString*)createTextCacheDirectory;

+ (void)saveWithFilename:(NSString*)filename data:(NSData*)data;
+ (NSData*)loadWithFilename:(NSString*)filename;

+ (void)removeAllCachedData;

@end
