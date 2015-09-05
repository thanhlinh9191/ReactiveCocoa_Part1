//
//  RWDummySignInService.h
//  RWReactivePlayground
//
//  Created by THANHLINH on 9/05/15.
//  Copyright (c) 2015 THANHLINH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RWSignInResponse)(BOOL);

@interface RWDummySignInService : NSObject

- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(RWSignInResponse)completeBlock;

@end
