//
//  ImageViewController.h
//  Imaginarium
//
//  Created by Sean on 14/8/14.
//  Copyright (c) 2014年 ZIWUXUANXU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

#import "ASMediaFocusManager.h"

@interface ImageViewController : UIViewController<ASMediasFocusDelegate>

@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;
@property (strong, nonatomic) Photo * photo;

@end
