//
//  MCZNetworkClient.h
//  eyebeamz
//
//  Created by Ryohei Ueda on 12/06/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCZNetworkClient : NSObject <NSURLConnectionDelegate>

+ (id)callback:(void(^)(NSString*))callback;
- (void)postPhoto:(UIImage*)image;
@end
