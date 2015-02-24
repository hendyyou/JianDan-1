//
//  Photo.h
//  JianDan
//
//  Created by Sean on 15/2/24.
//  Copyright (c) 2015年 ZIWUXUANXU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;

@end
