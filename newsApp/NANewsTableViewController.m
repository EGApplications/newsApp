//
//  NANewsTableViewController.m
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import "NANewsTableViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "NANewsDescription.h"
#import "NANewsPost.h"
#import "NAServerManager.h"
#import "NANewsDescriptionCell.h"
#import "NANewsPostCell.h"
#import "NASourceCell.h"
#import "NAError.h"

@interface NANewsTableViewController ()

@property (strong, nonatomic) NANewsDescription* newsDescription;
@property (strong, nonatomic) NSMutableArray* arrayOfError;
@property (strong, nonatomic) UIImage* newsImage;

@property (assign, nonatomic) CGFloat newsImageHeight;

@end

@implementation NANewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrayOfError = [NSMutableArray array];
    
    self.navigationItem.title = @"Описание";
    
    NSInteger newsID = [self.newsID integerValue];
    
    [self getNewsDescriptionFromServerWithID:newsID];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Own methods

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return destImage;
    
}

- (void) checkForTheErrors {
    
    if ([self.arrayOfError count] > 0) {
        
        NAError* errorObject = [self.arrayOfError firstObject];
        
        if ([errorObject.errorCode isEqualToString:@"404"]) {
            
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Ошибка" message:errorObject.errorMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }];
            
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else if ([errorObject.errorCode isEqualToString:@"401"]) {
            
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Ошибка" message:errorObject.errorMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
    }
    
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

- (void)reloadData:(BOOL)animated {
    
    [self.tableView reloadData];
    
    if (animated) {
        
        CATransition *animation = [CATransition animation];
        
        [animation setType:kCATransitionFade];
        
//        [animation setSubtype:kCATransitionFromTop];
        
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [animation setFillMode:kCAFillModeBoth];
        
        [animation setDuration:.5];
        
        [[self.tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
        
    }
    
}

#pragma mark - API methods

- (void) getNewsDescriptionFromServerWithID:(NSInteger) newsID {
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    
    [[NAServerManager sharedManager] getNewsPostFromServerWithID:newsID onSuccess:^(NANewsDescription *description) {
        
        self.newsDescription = description;
        self.newsDescription.newsImageURL = self.newsImageURL;
        self.newsDescription.publicationDate = self.publicationDate;
        
        if (self.newsDescription.newsImageURL != nil) {
            
            NSData* dataNewsImage = [[NSData alloc] initWithContentsOfURL:self.newsDescription.newsImageURL];
            
            self.newsImage = [UIImage imageWithData:dataNewsImage];
            
            dispatch_group_leave(group);
            
        }
        
    } onFailure:^(NSMutableArray* arrayOfError) {
        
        self.arrayOfError = arrayOfError;
        
        dispatch_group_leave(group);
        
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [self checkForTheErrors];
        
        // Animation reloading data with scrolling tableview to top
        [self reloadData:YES];
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    });
    
}

#pragma mark - UITableViewDataSource

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString* title;
    
    if (section == 1) {
        
        title = @"Похожие новости";
        
    }
    
    return title;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.newsDescription == nil) {
        
        return 0;
        
    } else {
        
        return 2;
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows;
    
    if (self.newsDescription == nil) {
        
        numberOfRows = 0;
        
    } else {
    
        if (section == 0) {
            
            numberOfRows = 2;
            
        } else if (section == 1) {
            
            numberOfRows = [self.newsDescription.spotlight count];
            
        }
        
    }
    
    return numberOfRows;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* newsDescriptionIdentifier = @"newsDescriptionCell";
    static NSString* sourceIdentifier = @"sourceCell";
    static NSString* spotlightIdentifier = @"newsPostCell";
    
    if (indexPath.section == 0) {
    
        if (indexPath.row == 0) {
            
            NANewsDescriptionCell* cell = [tableView dequeueReusableCellWithIdentifier:newsDescriptionIdentifier];
    
//             standard image post from server (384 x 288)
            if (self.newsImage != nil) {
                // if newsImage has been downloaded, reveal it on tableview
                
                CGSize newsImageSize = CGSizeMake(CGRectGetWidth(self.tableView.bounds), (288*CGRectGetWidth(self.tableView.bounds))/384);
                
                cell.postImageView.image = [self imageWithImage:self.newsImage convertToSize:newsImageSize];
                
            }
            
            cell.newsTextLabel.text = self.newsDescription.text;
            
            cell.publicationDateLabel.text = [self designDate:self.newsDescription.publicationDate];
            
            return cell;
            
        } else if (indexPath.row == 1) {
            
            NASourceCell* cell = [tableView dequeueReusableCellWithIdentifier:sourceIdentifier];
            
            cell.sourceLabel.text = [NSString stringWithFormat:@"Источник: %@", self.newsDescription.source];
            
            return cell;
            
        }
    
    } else if (indexPath.section == 1) {
        
        NANewsPostCell* cell = [tableView dequeueReusableCellWithIdentifier:spotlightIdentifier];
        
        NSDictionary* spotlightObject = [self.newsDescription.spotlight objectAtIndex:indexPath.row];
        
        NANewsPost* post = [[NANewsPost alloc] initWithDictionary:spotlightObject];
        
        cell.titleLabel.text = post.title;
        
        cell.publicationDateLabel.text = [self designDate:post.publicationDate];
        
        [cell.postImageView sd_setImageWithURL:post.thumbnailURL placeholderImage:nil];
        
        cell.postImageView.layer.cornerRadius = 10.0;
        
        cell.postImageView.layer.masksToBounds = YES;
        
        cell.postImageView.layer.borderWidth = 1.0;
        
        return cell;
        
    }
    
    return nil;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.tableView.estimatedRowHeight = 350;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    return UITableViewAutomaticDimension;
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section == 0 ? NO : YES;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        // It`s possible to watch news in spotlight
        
        NSDictionary* postDict = [self.newsDescription.spotlight objectAtIndex:indexPath.row];
        
        NANewsPost* post = [[NANewsPost alloc] initWithDictionary:postDict];
        
        NSInteger newsID = [post.newsID integerValue];
        
        self.publicationDate = post.publicationDate;
        
        self.newsImageURL = post.newsImageURL;
        
        [self getNewsDescriptionFromServerWithID:newsID];
        
    }
    
}

@end
