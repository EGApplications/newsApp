//
//  NANewsObject.h
//  newsApp
//
//  Created by Евгений Глухов on 25.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NANewsObject : NSObject

- (instancetype)initWithDictionary:(NSDictionary*) responseObject;

@end
