//
//  ImageViewController.m
//  Imaginarium
//
//  Created by Sean on 14/8/14.
//  Copyright (c) 2014年 ZIWUXUANXU. All rights reserved.
//

#import "ImageViewController.h"
#import "OmeletteFetcher.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) NSString * imageURL;
@property (strong, nonatomic) UIImage * image;
@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) UIWebView *gifView;
@end

@implementation ImageViewController

#pragma mark - Synthesize
@synthesize gifView = _gifView;
@synthesize scrollView = _scrollView;
@synthesize photo = _photo;

#pragma mark -main

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.spinner startAnimating];
}


#pragma mark - Utils

-(void)startDownloadingGIF
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Download GIF Thread", NULL);
    dispatch_async(fetchQ, ^{
        NSData *gifData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.gifView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
            [self.view addSubview:self.gifView];
        });
    });
}

- (void)startDownloadingImage
{
    self.image = nil;
    if(self.imageURL){
        dispatch_queue_t fetchQ = dispatch_queue_create("Download Photo Thread", NULL);
        dispatch_async(fetchQ, ^{
            UIImage * image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]]];
            /*最后得到的temp为图片的URL的String类型*/
            /*将URL转换为图片存入imgAnalyList中*/
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
                [self.scrollView addSubview:self.imageView];
                
                UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImage:)];
                [self.imageView addGestureRecognizer: tapGestureRecognizer];
                [self.imageView setUserInteractionEnabled:YES];
                
                [self.view addSubview:self.scrollView];
                self.spinner.hidden = YES;
            });
        });
    }
}


- (void)showImage:(UITapGestureRecognizer *)sender
{
    
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = self.imageView.image;
    imageInfo.referenceRect = self.imageView.frame;
    imageInfo.referenceView = self.imageView.superview;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
}





#pragma mark -Setter and getter

-(UIWebView *)gifView
{
    if(!_gifView){
        _gifView = [[UIWebView alloc]initWithFrame:CGRectMake(0, (self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height), self.view.frame.size.width, self.view.frame.size.height)];
        _gifView.scalesPageToFit = YES;
    }
    
    return _gifView;
}

- (void)setPhoto:(Photo *)photo
{
    _photo = photo;
    
    self.imageURL = photo.imageURL;
    
}

-(void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    
    self.title = self.photo.number;
    
    if ([imageURL hasSuffix:@"gif"]) {
        self.title = [self.title stringByAppendingString:@"[GIF]"];
        [self startDownloadingGIF];
    }else{
        [self startDownloadingImage];
    }
    
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
//    [self.imageView sizeToFit];
    
    //设置的是显示的图片的大小
    CGFloat rootViewWidth = self.view.frame.size.width;
    CGFloat rootViewHeight = self.view.frame.size.height;
    CGFloat rootViewProportion = (rootViewWidth / rootViewHeight);
    
    CGFloat imageViewWidth = image.size.width;
    CGFloat imageViewHeight = image.size.height;
    CGFloat imageViewProportion = (imageViewWidth / imageViewHeight);
    
    if (imageViewProportion > rootViewProportion) {
        // 图片比较宽
        // 高为View的高
        // 宽为图片等比例缩放的宽
//        CGFloat width = (rootViewHeight * imageViewWidth / imageViewHeight);
//        self.imageView.frame = CGRectMake(0, 0, rootViewHeight, width);
        CGFloat height = (rootViewWidth * imageViewHeight / imageViewWidth);
        self.imageView.frame = CGRectMake(0, 0, rootViewWidth, height);
    }
    else if (imageViewProportion <  rootViewProportion){
        // 图片比较高
        // 宽为View的宽
        // 高为图片等比例缩放的高
        CGFloat height = (rootViewWidth * imageViewHeight / imageViewWidth);
        self.imageView.frame = CGRectMake(0, 0, rootViewWidth, height);
    }
    else{
        //图片的宽高比例和View相同
        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height );
    }
    
}

- (UIImageView *)imageView
{
    if(_imageView == nil){
        _imageView = [[UIImageView alloc]init];
    }
    
    return _imageView;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0 ,(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height),self.view.frame.size.width ,self.view.frame.size.height)];
        
        //    zoomScale - 变化比例
        _scrollView.zoomScale = 1.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 2.0;
        
        _scrollView.scrollEnabled = NO;
        _scrollView.delegate = self;
        
        _scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    }
    
    
    return _scrollView;
}

#pragma mark - Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    self.scrollView.scrollEnabled = YES;

    return self.imageView;
}

@end
