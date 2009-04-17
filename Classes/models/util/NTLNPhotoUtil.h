//
//  NTLNPhotoUtil.h
//  HideNGoSnap
//
//  Created by John Ellis on 12/2/08.
//  Copyright 2008 Dove Valley Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTLNPhotoUtil;

@protocol NTLNPhotoUtilDelegate
- (void)userDidCancel:(NTLNPhotoUtil*)util;
- (void)imageChoosen:(UIImage*)image fromUtil:(NTLNPhotoUtil*)util;
@end


@interface NTLNPhotoUtil : NSObject<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	NSObject<NTLNPhotoUtilDelegate> *delegate;
	NSInteger maxRes;
	UIViewController *viewController;
	BOOL clearButton;
	id<UINavigationControllerDelegate> navDelegate;
	UIViewController *waiting;
	BOOL fromCamera;
}

// return a retained photo util
- (id)initWithDelegate:(NSObject<NTLNPhotoUtilDelegate>*)delegate;

- (void) chooseImage:(UIViewController*)controller withClear:(BOOL)clear;

- (UIImagePickerController*) chooseImage:(UIViewController*)controller from:(UIImagePickerControllerSourceType)type;

@property (nonatomic) NSInteger maxRes;
@property (nonatomic, assign) id<UINavigationControllerDelegate> navDelegate;
@property (nonatomic, retain) UIViewController *waiting;

@end
