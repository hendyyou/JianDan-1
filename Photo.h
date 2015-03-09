//
//  Photo.h
//  JianDan
//
//  Created by Sean on 15/3/9.
//  Copyright (c) 2015年 ZIWUXUANXU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * page;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * thumbnail;

@end
