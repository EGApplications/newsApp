//
//  NANewsListController.m
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import "NANewsListTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "NAServerManager.h"
#import "NANewsDescription.h"
#import "NAError.h"
#import "NANewsPost.h"
#import "NANewsPostCell.h"
#import "NANewsTableViewController.h"

@interface NANewsListTableViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray* newsFeed;
@property (strong, nonatomic) NSMutableArray* arrayOfError;
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL loadingData;

@end

@implementation NANewsListTableViewController

const static NSInteger newsOnPageToDownload = 11;
const static NSInteger tableViewRowHeight = 70;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.newsFeed = [NSMutableArray array];
    
    self.arrayOfError = [NSMutableArray array];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    self.loadingData = NO;
    
    self.currentPage = 0;
    
    // footer for ActivityIndicator
    [self initFooterView];
    
    [self getNewsListFromServerWithCurrentPage:self.currentPage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Own methods

-(void)initFooterView {
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.bounds), tableViewRowHeight)];
    
    UIActivityIndicatorView * actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    actInd.color = [UIColor blueColor];
    
    actInd.tag = 10;
    
    CGFloat widthAndHeight = 20;
    
    actInd.frame = CGRectMake((CGRectGetWidth(self.tableView.bounds)/2) - widthAndHeight/2, 25.0, widthAndHeight, widthAndHeight);
    
    actInd.hidesWhenStopped = YES;
    
    [self.footerView addSubview:actInd];
    
    actInd = nil;
    
}


- (NSString*) designDate:(NSString*) date {
    
    if ([date length] > 16) {
        
        date = [date substringToIndex:[date length] - 3];
        
    }
    
    if ([date containsString:@"-"]) {
        
        date = [date stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        
    }
    
    return date;
    
}

- (void) checkForTheErrors {
    
    if ([self.arrayOfError count] > 0) {
        
        NAError* errorObject = [self.arrayOfError firstObject];
        
        if ([errorObject.errorCode isEqualToString:@"404"]) {
            
            [(UIActivityIndicatorView *)[self.footerView viewWithTag:10] stopAnimating];
            
            self.tableView.tableFooterView = nil;
            
        } else if ([errorObject.errorCode isEqualToString:@"401"]) {
            // Authorization error
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Ошибка" message:errorObject.errorMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
    }
    
}

#pragma mark - API Methods

- (void) getNewsListFromServerWithCurrentPage:(NSInteger) currentPage {
    
    dispatch_group_t loadGroup = dispatch_group_create();
    
    dispatch_group_enter(loadGroup);
    
    self.loadingData = YES;
    
    [[NAServerManager sharedManager] getNewsListFromServerWithPage:currentPage + 1 withPageCount:newsOnPageToDownload onSuccess:^(NSMutableArray *newsList) {
        
        NSArray* newsArray = newsList;
        
        [self.newsFeed addObjectsFromArray:newsArray];
        
        dispatch_group_leave(loadGroup);
        
    } onFailure:^(NSMutableArray* arrayOfError) {
        
        self.arrayOfError = arrayOfError;
        
        dispatch_group_leave(loadGroup);
        
    }];
    
    dispatch_group_notify(loadGroup, dispatch_get_main_queue(), ^{
        
        self.loadingData = NO;
        
        self.currentPage = currentPage + 1;
        
        [self checkForTheErrors];
        
        [self.tableView reloadData];
        
    });
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.newsFeed count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* newsPostIdentifier = @"newsPostCell";
    
    NANewsPostCell* postCell = [tableView dequeueReusableCellWithIdentifier:newsPostIdentifier];
    
    NANewsPost* post = [self.newsFeed objectAtIndex:indexPath.row];
    
    postCell.titleLabel.text = post.title;
    
    postCell.publicationDateLabel.text = [self designDate:post.publicationDate];
    
    [postCell.postImageView sd_setImageWithURL:post.thumbnailURL placeholderImage:nil];
    
    postCell.postImageView.layer.cornerRadius = 10.0;
    
    postCell.postImageView.layer.masksToBounds = YES;
    
    postCell.postImageView.layer.borderWidth = 1.0;
    
    return postCell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return tableViewRowHeight;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    BOOL endOfTable = (scrollView.contentOffset.y >= ((self.newsFeed.count * tableViewRowHeight) - scrollView.frame.size.height));
    
    if (endOfTable && !self.loadingData && !scrollView.dragging && !scrollView.decelerating) {
        
        self.tableView.tableFooterView = self.footerView;
        
        [(UIActivityIndicatorView *)[self.footerView viewWithTag:10] startAnimating];
        
        self.loadingData = YES;

        [self getNewsListFromServerWithCurrentPage:self.currentPage];
        
    }
    
}

#pragma mark - Segue 

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showNews"]) {
        
        NSIndexPath* indexPath = [self.tableView indexPathForCell:(NANewsPostCell*)sender];
        
        NANewsPost* post = [self.newsFeed objectAtIndex:indexPath.row];
    
        NANewsTableViewController* vc = (NANewsTableViewController*)segue.destinationViewController;
    
        vc.publicationDate = post.publicationDate;

        vc.newsImageURL = post.newsImageURL;
        
        vc.newsID = post.newsID;
        
    }
    
}

@end
