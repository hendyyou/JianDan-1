//
//  OmeletteFetcher.h
//  Omelette
//
//  Created by Sean on 14-9-2.
//  Copyright (c) 2014年 ZIWUXUANXU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface OmeletteFetcher : NSObject
+ (void)putPhotosIntoManagedObjectContext:(NSManagedObjectContext *)context
                          ByAnalyzeWebURL:(NSString *)webURL;
@end
