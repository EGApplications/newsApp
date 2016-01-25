//
//  NAServerManager.h
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NANewsDescription.h"

@interface NAServerManager : NSObject

+ (NAServerManager*) sharedManager;


- (void) getNewsListFromServerWithPage:(NSInteger)page withPageCount:(NSInteger)count onSuccess:(void (^)(NSMutableArray* newsList))success onFailure:(void (^)(NSMutableArray* arrayOfError))failure;

- (void) getNewsPostFromServerWithID:(NSInteger)newsPostID onSuccess:(void (^)(NANewsDescription* newsDescription))success onFailure:(void (^)(NSMutableArray* arrayOfError))failure;

@end
