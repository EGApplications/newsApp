//
//  NANewsPost.m
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import "NANewsPost.h"

@implementation NANewsPost

- (instancetype)initWithDictionary:(NSDictionary*) responseObject;
{
    self = [super initWithDictionary:responseObject];
    if (self) {
        
        self.thumbnailURL = [NSURL URLWithString:[responseObject objectForKey:@"thumbnail"]];
        self.newsImageURL = [NSURL URLWithString:[responseObject objectForKey:@"image"]];
        self.newsID = [[responseObject objectForKey:@"id"] stringValue];
        self.title = [responseObject objectForKey:@"title"];
        self.publicationDate = [responseObject objectForKey:@"created_at"];
        
    }
    return self;
}

@end
