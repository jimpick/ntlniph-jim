//
//  NTLNPhotoUtil.m
//  HideNGoSnap
//
//  Created by John Ellis on 12/2/08.
//  Copyright 2008 Dove Valley Apps. All rights reserved.
//

#import "NTLNPhotoUtil.h"
#import "WaitingViewController.h"

@implementation NTLNPhotoUtil

@synthesize maxRes, navDelegate, waiting;

- (id)initWithDelegate:(NSObject<NTLNPhotoUtilDelegate>*)aDelegate {
	self = [super init];
	delegate = aDelegate;
	self.maxRes = 640;
	self.waiting = [[[WaitingViewController alloc] init]autorelease];
	return self;
}

- (void) dealloc {
	self.waiting = nil;
	[super dealloc];
}

- (void) chooseImage:(UIViewController*)controller withClear:(BOOL)clear {
	clearButton = clear;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
											delegate:self cancelButtonTitle:@"Cancel" 
											destructiveButtonTitle:clear?@"Clear Current Selection":nil
											otherButtonTitles:@"Take Photo", @"Choose Existing Photo", nil];
	actionSheet.actionSheetStyle = UIStatusBarStyleBlackTranslucent;
	[actionSheet showInView:controller.view];
	[actionSheet release];
	viewController = controller;
}

- (UIImagePickerController*) chooseImage:(UIViewController*)controller from:(UIImagePickerControllerSourceType)type {
	UIImagePickerController *picker = [[[UIImagePickerController alloc]init]autorelease];
	
	picker.sourceType = type;
    picker.delegate = self;
    picker.allowsImageEditing = NO;

	viewController = controller;
	
    [controller presentModalViewController:picker animated:YES];
	
	return picker;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == (clearButton?3:2)) {
		[delegate userDidCancel:self];
		return;
	}
	
	if (clearButton && buttonIndex == 0) {
		[delegate imageChoosen:nil fromUtil:self];
	}		
	else {
		if (clearButton) {
			buttonIndex--;
		}
		
		[self chooseImage:viewController 
				 from:(buttonIndex==0?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary)];
	}
}

- (void) imageSelected:(UIImage*)theImage {
	CGSize realImageSize = theImage.size;
	
	if (realImageSize.width > self.maxRes || realImageSize.height > self.maxRes) {
		CGFloat ratio = realImageSize.width/realImageSize.height;
		if (ratio > 1) {
			realImageSize.width = self.maxRes;
			realImageSize.height = realImageSize.width / ratio;
		}
		else {
			realImageSize.height = self.maxRes;
			realImageSize.width = realImageSize.height * ratio;
		}
	}
	
	[viewController dismissModalViewControllerAnimated:YES];
	
	if (fromCamera) {
		UIImageWriteToSavedPhotosAlbum(theImage, nil, nil, nil);
	}
	
	UIGraphicsBeginImageContext(realImageSize);
	UIGraphicsGetCurrentContext();
	CGRect bounds = CGRectMake(0, 0, realImageSize.width, realImageSize.height);
	[theImage drawInRect:bounds];
	UIImage *returned = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[delegate imageChoosen:returned fromUtil:self];
	// [picker release];
	
	[self.waiting.view removeFromSuperview];
}

- (void)imagePickerController:(UIImagePickerController *)picker
		didFinishPickingImage:(UIImage *)theImage
				  editingInfo:(NSDictionary *)editingInfo {
	picker.delegate = nil;
	fromCamera = (picker.sourceType == UIImagePickerControllerSourceTypeCamera);

	if (fromCamera) {
		[[UIApplication sharedApplication].keyWindow addSubview:waiting.view];
	}
	
	[self performSelector:@selector(imageSelected:) withObject:theImage afterDelay:0.01];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[delegate userDidCancel:self];
	picker.delegate = nil;
	// [picker release];
}

- (void)navigationController:(UINavigationController *)navigationController 
	  willShowViewController:(UIViewController *)_viewController animated:(BOOL)animated {
	
	if (self.navDelegate && 
		[self.navDelegate respondsToSelector: @selector( navigationController:willShowViewController:animated: )]) {
		[self.navDelegate navigationController:navigationController willShowViewController:_viewController animated:animated];
	}
}

- (void)navigationController:(UINavigationController *)navigationController 
	   didShowViewController:(UIViewController *)_viewController animated:(BOOL)animated {
	
	if (self.navDelegate && 
		[self.navDelegate respondsToSelector: @selector( navigationController:didShowViewController:animated: )]) {
		[self.navDelegate navigationController:navigationController didShowViewController:_viewController animated:animated];
	}
}


@end
