//
//  NANewsDescription.m
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import "NANewsDescription.h"

@implementation NANewsDescription

- (instancetype)initWithDictionary:(NSDictionary*) responseObject
{
    self = [super initWithDictionary:responseObject];
    if (self) {
        
        self.newsID = [[responseObject objectForKey:@"id"] stringValue];
        self.lead = [responseObject objectForKey:@"lead"];
        self.source = [NSURL URLWithString:[responseObject objectForKey:@"source"]];
        self.text = [responseObject objectForKey:@"text"];
        
    }
    return self;
}

@end
