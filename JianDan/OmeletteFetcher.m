//
//  OmeletteFetcher.m
//  Omelette
//
//  Created by Sean on 14-9-2.
//  Copyright (c) 2014年 ZIWUXUANXU. All rights reserved.
//

#import "OmeletteFetcher.h"
#import "Photo.h"

@implementation OmeletteFetcher

//通过访问网页源码来将煎蛋内的图片的地址放入数据库
+ (void)putPhotosIntoManagedObjectContext:(NSManagedObjectContext *)context
                               ByAnalyzeWebURL:(NSString *)webURL
{
    NSURL * url = [NSURL URLWithString:webURL];
    NSData * data = [NSData dataWithContentsOfURL:url];
    //解决中文乱码,用GBK
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString * html = [[NSString alloc] initWithData:data encoding:enc];
    
//    readyAnalyzeCode
//    待分析的代码
    NSString *readyAnalyzeCode = html;

//    一直循环下去
//    一直到找到所有的图片的网址
    while (YES) {
//        下面一行代码因为煎蛋的网页的图片地址前缀发生改变而改变
//        NSRange photoPrePosition = [readyAnalyzeCode rangeOfString:@"<li class=\"row\" id"];
//        NSRange photoPrePosition = [readyAnalyzeCode rangeOfString:@"<img src=\""];
        
        NSString *page = [self getStringInSourceString:readyAnalyzeCode ByPrefix:@"current-comment-page\">[" andSuffix:@"]"];
        
        NSRange photoPrePosition = [readyAnalyzeCode rangeOfString:@"<li id"];
//        NSLog(@"\n photoPrePosition.location = %lu, html.length = %d\n", (unsigned long)photoPrePosition.location, html.length);
        
//        如果没有找到，则退出
        if(photoPrePosition.location > html.length) break;
        
//        临时变量
        NSString * temp = [readyAnalyzeCode substringFromIndex:photoPrePosition.location];
        
        NSRange photoAfterPosition = [temp rangeOfString:@"</li>"];
        if(photoAfterPosition.location > html.length) break;
        
//        一个图片的网址
//        代码过时，舍弃
//        NSString *onePhotoCode = [temp substringToIndex:photoAfterPosition.location];
        NSString *onePhotoCode = [temp substringToIndex:(photoAfterPosition.location+photoAfterPosition.length)];
        
//        然后拿出剩下的网页源代码
        readyAnalyzeCode = [temp substringFromIndex:(photoAfterPosition.location+photoAfterPosition.length)];
        
        [self putPhotoIntoManagedObjectContext:context ByAnalyzeOnePhotoCode:onePhotoCode withPage:page];
    }
}



+ (void)putPhotoIntoManagedObjectContext:(NSManagedObjectContext *)context
                   ByAnalyzeOnePhotoCode:(NSString *)onePhotoCode
                                withPage:(NSString *)page
{
    NSString *readyAnalyzeCode = onePhotoCode;
        
    NSString *unique = [self getStringInSourceString:readyAnalyzeCode ByPrefix:@"id=\"comment-" andSuffix:@"\">"];
    
    //query in database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    //execute query
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {  // nil means fetch failed; more than one impossible (unique!)
        // handle error
    }else if (![matches count]){ // none found, so let's create a Photo for that Omelette photo
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.page = page;
        photo.unique = unique;
        

        NSString *publisher = [self getStringInSourceString:readyAnalyzeCode ByPrefix:@"&quot;&gt;" andSuffix:@"&lt;"];
        
        photo.publisher = publisher;
        
        photo.date = [self getStringInSourceString:readyAnalyzeCode ByPrefix:@"&gt;: &#39;\">@" andSuffix:@"</a>"];
        
        NSString *getNumberTemp = [self getStringInSourceString:readyAnalyzeCode ByPrefix:@"<span class=\"righttext\">" andSuffix:@"</span>"];
        photo.number = [self getStringInSourceString:getNumberTemp ByPrefix:@"\">" andSuffix:@"</a>"];

        NSString *imageURL = nil;
        if ([readyAnalyzeCode rangeOfString:@"org_src"].length != 0) {

            imageURL = [self getStringInSourceString:readyAnalyzeCode ByPrefix:@"org_src=\"" andSuffix:@"\""];
            
            photo.thumbnail = [self getStringInSourceString:readyAnalyzeCode ByPrefix:@"<img src=\"" andSuffix:@"\""];
            
        }else{
            imageURL = [self getStringInSourceString:readyAnalyzeCode ByPrefix:@"<img src=\"" andSuffix:@"\""];
        }
        
        photo.imageURL = imageURL;
        photo.viewed  = [NSNumber numberWithBool:NO];        
        
    }else { // found the Photo do nothing
        NSLog(@"\nthere is only one photo in context which unique = %@\n", unique);
    }
}


+ (NSString *)getStringInSourceString:(NSString *)sourceString ByPrefix:(NSString *)prefix andSuffix:(NSString *)suffix
{
    NSString *readyAnalyzeCode = sourceString;
    NSString *resultString = nil;
    
    NSRange resultPrePosition = [readyAnalyzeCode rangeOfString:prefix];
    
    if (resultPrePosition.length == 0) {
        
        NSLog(@"Fetcher : 截取字段错误");
        
        return nil;
    }
    NSString *resultStringTemp = [readyAnalyzeCode substringFromIndex:resultPrePosition.location+resultPrePosition.length];
    NSRange resultAfterPosition = [resultStringTemp rangeOfString:suffix];
    resultString = [resultStringTemp substringToIndex:resultAfterPosition.location];
    
    return resultString;
}






@end
