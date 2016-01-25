//
//  NANewsDescription.h
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NANewsObject.h"

@interface NANewsDescription : NANewsObject

@property (strong, nonatomic) NSString* newsID;
@property (strong, nonatomic) NSString* lead;
@property (strong, nonatomic) NSURL* source;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSURL* newsImageURL;
@property (strong, nonatomic) NSString* publicationDate;
@property (strong, nonatomic) NSMutableArray* spotlight;

- (instancetype)initWithDictionary:(NSDictionary*) responseObject;

@end
