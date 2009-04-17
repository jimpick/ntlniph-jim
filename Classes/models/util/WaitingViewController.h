//
//  WaitingViewController.h
//  HideNGoSnap
//
//  Created by John Ellis on 2/24/09.
//  Copyright 2009 Dove Valley Apps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingViewController : UIViewController {
	IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@end
