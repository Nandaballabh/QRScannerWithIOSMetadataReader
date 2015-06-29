//
//  NBScanner.h
//  iOSInBuildScanner
//
//  Created by Nanda Ballabh on 6/29/15.
//  Copyright (c) 2015 Nanda Ballabh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBScanner : NSObject

+ (instancetype) scanner;
- (void) scanMetadataWithCompletionBlock:(void (^)(NSString * scanedString , BOOL finished))completionBlock;

@end