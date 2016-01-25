//
//  NANewsTableViewController.h
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NANewsTableViewController : UITableViewController

@property (strong, nonatomic) NSURL* newsImageURL;
@property (strong, nonatomic) NSString* publicationDate;
@property (strong, nonatomic) NSString* newsID;

@end
