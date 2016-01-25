//
//  NAError.m
//  newsApp
//
//  Created by Евгений Глухов on 25.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import "NAError.h"

@implementation NAError

- (instancetype)initWithDictionary:(NSDictionary *)responseObject
{
    self = [super initWithDictionary:responseObject];
    
    if (self) {
        
        self.errorCode = [[responseObject objectForKey:@"code"] stringValue];
        self.errorMessage = [responseObject objectForKey:@"message"];
        
    }
    
    return self;
    
}

@end
