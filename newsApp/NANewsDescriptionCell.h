//
//  NANewsDescriptionCell.h
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NANewsDescriptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *publicationDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsTextLabel;

@end
