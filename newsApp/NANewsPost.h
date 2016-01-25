//
//  NANewsPost.h
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NANewsObject.h"

@interface NANewsPost : NANewsObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* publicationDate;
@property (strong, nonatomic) NSURL* thumbnailURL;
@property (strong, nonatomic) NSString* newsID;
@property (strong, nonatomic) NSURL* newsImageURL;

@property (strong, nonatomic) UIImageView* thumbnailImageView;
@property (strong, nonatomic) UIImageView* newsImageView;

- (instancetype)initWithDictionary:(NSDictionary*) responseObject;

@end
