//
//  NAServerManager.m
//  newsApp
//
//  Created by Евгений Глухов on 23.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import "NAServerManager.h"
#import "AFNetworking.h"
#import "NANewsPost.h"
#import "NANewsDescription.h"
#import "NAError.h"

@interface NAServerManager()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

@end

@implementation NAServerManager

+ (NAServerManager*) sharedManager {
    
    static NAServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[NAServerManager alloc] init];
        
    });
    
    return manager;
    
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"http://medsolutions.uxp.ru/api/v1/"];
        
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
     
        self.requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        
    }
    
    return self;
}

// News feed
- (void) getNewsListFromServerWithPage:(NSInteger)page withPageCount:(NSInteger)count onSuccess:(void (^)(NSMutableArray* newsList))success onFailure:(void (^)(NSMutableArray* arrayOfError))failure {
    
    // параметры, которые передаем с запросе
    //    page @(1)
    //    limit @(5)
    //    order_by title
    //    order asc
    //    Content-Type: application/json
    //    @"API-KEY", @"secret_key",
    
    
    [self.requestOperationManager.requestSerializer setValue:@"secret_key" forHTTPHeaderField:@"API-KEY"];
    [self.requestOperationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(page), @"page",
                            @(count), @"limit",
                            @"title", @"order_by",
                            @"desc", @"order", nil];
    
    [self.requestOperationManager GET:@"news" parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation,NSDictionary* responseObject) {
        
        NSArray* newsArray = [responseObject objectForKey:@"data"];

        NSMutableArray* newsPostsArray = [NSMutableArray array];
        
        for (NSDictionary* dict in newsArray) {
            
            NANewsPost* post = [[NANewsPost alloc] initWithDictionary:dict];
            
            [newsPostsArray addObject:post];
            
        }
        
        if (success) {
            
            success(newsPostsArray);
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        NSDictionary* response = [operation.responseObject objectForKey:@"error"];
        
        NSMutableArray* responseArray = [NSMutableArray array];
            
        NAError* errorObject = [[NAError alloc] initWithDictionary:response];
        
        [responseArray addObject:errorObject];
        
        failure(responseArray);
        
    }];
    
}

// concrete news post
- (void) getNewsPostFromServerWithID:(NSInteger)newsPostID onSuccess:(void (^)(NANewsDescription* newsDescription))success onFailure:(void (^)(NSMutableArray* arrayOfError))failure {
    
    // параметры, которые передаем с запросе
    //    id newsPostID
    //    Content-Type: application/json
    //    @"API-KEY", @"secret_key",
    
    // Для второго запроса GET - news/1, parameters: nil
    
    [self.requestOperationManager.requestSerializer setValue:@"secret_key" forHTTPHeaderField:@"API-KEY"];
    [self.requestOperationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString* GETParameter = [NSString stringWithFormat:@"news/%ld", (long)newsPostID];
    
    [self.requestOperationManager GET:GETParameter parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary* responseObject) {
        
        NSArray* newsDescriptionArray = [responseObject objectForKey:@"data"];

        for (NSDictionary* dict in newsDescriptionArray) {

            NANewsDescription* description = [[NANewsDescription alloc] initWithDictionary:dict];
            
            // NANewsPost objects inside
            description.spotlight = [responseObject objectForKey:@"spotlight"];

            if (success) {
                
                success(description);
                
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        NSLog(@"FAIL");
        
        NSDictionary* response = [operation.responseObject objectForKey:@"error"];
        
        NSMutableArray* responseArray = [NSMutableArray array];
        
        NAError* errorObject = [[NAError alloc] initWithDictionary:response];
        
        [responseArray addObject:errorObject];
        
        failure(responseArray);
        
    }];
    
}

@end
