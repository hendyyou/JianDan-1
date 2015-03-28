//
//  PhotoTableViewController.m
//  JianDan
//
//  Created by Sean on 15/2/24.
//  Copyright (c) 2015年 ZIWUXUANXU. All rights reserved.
//

#import "PhotoTableViewController.h"

@interface PhotoTableViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UITextField *pageTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goPrePageBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *goNextPageBarButton;

@property (nonatomic, strong) NSString *prePage;
@property (nonatomic) NSInteger latestPage;

@end

@implementation PhotoTableViewController

#pragma mark - Synthesize
@synthesize managedObjectContext = _managedObjectContext;



#pragma mark - Main
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    Set managedObjectContext
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
//    Set TextField And Keyboard Delegate
    self.pageTextField.delegate = self;
//    self.pageTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.pageTextField.returnKeyType = UIReturnKeyGo;
    self.pageTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.latestPage = [self getLatestPage];
    self.prePage = [NSString stringWithFormat:@"%ld", (long)self.latestPage];
    
//    NSString *webURL = [PHOTOWEBURL stringByReplacingOccurrencesOfString:@"NUMBER"
//                                                              withString:[NSString stringWithFormat:@"%ld", (long)self.latestPage]];
//    [self startOmeletteFetchWith:webURL];
}

- (void)viewWillAppear:(BOOL)animated
{
    // 如果当前页面和最新页面相等，则不能到下一页
    self.goNextPageBarButton.enabled = self.prePage.integerValue == self.latestPage ? NO : YES;
    self.pageTextField.text = self.prePage != nil ? self.prePage : @"";
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Utils

- (void)startOmeletteFetchWith:(NSString *)webURL
{
    [OmeletteFetcher putPhotosIntoManagedObjectContext:self.managedObjectContext
                                       ByAnalyzeWebURL:webURL];
    
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"page = %@", self.prePage];
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];

//    NSLog(@"predicate : %@", self.fetchedResultsController.fetchRequest.predicate.predicateFormat);
}


- (NSInteger)getLatestPage
{
    NSURL * url = [NSURL URLWithString:WEBURL];
    NSError *error = nil;
    NSData * data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    if (error) {
        NSLog(@"error : %@", error);
    }
    //解决中文乱码,用GBK
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString * html = [[NSString alloc] initWithData:data encoding:enc];
    
    //    readyAnalyzeCode
    //    待分析的代码
    NSString *jdHomeHtml = html;
    
    NSString *latestPageStr = [OmeletteFetcher getStringInSourceString:jdHomeHtml ByPrefix:@"current-comment-page\">[" andSuffix:@"]"];
    
    return [latestPageStr integerValue];
}

- (void)goPageWithNumber:(NSInteger)destinationPageNum
{
//    NSString *page = self.pageTextField.text;
//    NSInteger pageNum = [page integerValue];
    
    
    if (self.prePage.integerValue == destinationPageNum) {
        
        NSLog(@"Page is Not Change");
        
        return;
    }
    else if (destinationPageNum > self.latestPage){
        NSLog(@"超出最新页面");
        
        
        return;
    }
    else{
        self.prePage = [NSString stringWithFormat:@"%ld", (long)destinationPageNum];
    }
        
    self.goNextPageBarButton.enabled = self.prePage.integerValue == self.latestPage ? NO : YES;
}


#pragma mark - IBAction

- (IBAction)goNextPage:(UIBarButtonItem *)sender
{
    [self goPageWithNumber:(self.prePage.integerValue + 1)];
}


- (IBAction)goPrePage:(UIBarButtonItem *)sender
{
    [self goPageWithNumber:(self.prePage.integerValue - 1)];
}


- (IBAction)goPage:(id)sender
{
    NSLog(@"Go Page %@", self.pageTextField.text);
    
    [self.pageTextField resignFirstResponder];
    
//    NSString *page = self.pageTextField.text;
    NSInteger pageNum = [self.pageTextField.text integerValue];
    
    [self goPageWithNumber:pageNum];
//    if ([page isEqual:self.prePage]) {
//        
//        NSLog(@"Page is Not Change");
//        
//        
//        return;
//    }
//    else if (pageNum > self.latestPage){
//        NSLog(@"超出最新页面");
//        
//        
//        return;
//    }
//    else{
//        self.prePage = page;
//        
//    }
}


//- (IBAction)TextField_DidEndOnExit:(id)sender {
//    // 隐藏键盘.
//    [sender resignFirstResponder];
//}




#pragma mark - Setter and Getter

- (void)setPrePage:(NSString *)prePage
{
    _prePage = prePage;

    self.pageTextField.text = prePage;
    
    NSString *webURL = [PHOTOWEBURL stringByReplacingOccurrencesOfString:@"NUMBER"
                                                              withString:prePage];
    [self startOmeletteFetchWith:webURL];
}



/*
-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    
    return _managedObjectContext;
}
 */

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
//        request.predicate = [NSPredicate predicateWithFormat:@"page like %@", self.prePage]; 
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
//        NSLog(@"predicate : %@", request.predicate.predicateFormat);
    } else {
        self.fetchedResultsController = nil;
    }
}


#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    
//    cell.textLabel.text = photo.publisher;
//    cell.detailTextLabel.text = photo.date;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.publisher;
    cell.detailTextLabel.text = photo.date;
    
    cell.textLabel.textColor = photo.viewed.boolValue ? [UIColor grayColor] : [UIColor blueColor];
    cell.detailTextLabel.textColor = photo.viewed.boolValue ? [UIColor grayColor] : [UIColor blackColor];

    
//    UILabel *publisherLabel = (UILabel *)[cell viewWithTag:100];
//    publisherLabel.text = photo.publisher ? photo.publisher : @"Loading";
//    
//    UILabel *dateLabel = (UILabel *)[cell viewWithTag:101];
//    dateLabel.text = photo.date ? photo.date : @"Loading";
//    
//    UILabel *gifLabel = (UILabel *)[cell viewWithTag:102];
//    
    if (photo.thumbnail != nil) {
        cell.backgroundColor = [UIColor colorWithRed:0.6 green:0.75 blue:0.85 alpha:1.0];
//        gifLabel.hidden = NO;
    }
    else{
        cell.backgroundColor = [UIColor whiteColor];
//        NSLog(@"%@ : %@", photo.publisher, photo.date);
//        gifLabel.hidden = YES;
    }
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([sender isKindOfClass:[UITableViewCell class]]){
        NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
        if(indexPath){
            if([segue.identifier isEqualToString:@"Show Photo"]){
                if([segue.destinationViewController isKindOfClass:[ImageViewController class]]){
                    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    photo.viewed = [NSNumber numberWithBool:YES];
                    [self.managedObjectContext save:nil];
                    
                    ImageViewController *imageVC = (ImageViewController *)segue.destinationViewController;
                    imageVC.photo = photo;
//                    imageVC.imageURL = photo.imageURL;
//                    imageVC.title = photo.title;
                }
            }
        }
    }
}


@end
