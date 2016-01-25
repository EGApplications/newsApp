//
//  NAError.h
//  newsApp
//
//  Created by Евгений Глухов on 25.01.16.
//  Copyright © 2016 Evgeny Glukhov. All rights reserved.
//

#import "NANewsObject.h"

@interface NAError : NANewsObject

@property (strong, nonatomic) NSString* errorMessage;
@property (strong, nonatomic) NSString* errorCode;

@end
