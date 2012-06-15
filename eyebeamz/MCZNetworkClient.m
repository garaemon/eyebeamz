//
//  MCZNetworkClient.m
//  eyebeamz
//
//  Created by Ryohei Ueda on 12/06/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MCZNetworkClient.h"

@interface MCZNetworkClient()
@property (strong, nonatomic) void (^failCallback)();
@property (strong, nonatomic) void (^callback)(NSDictionary*);
@end

@implementation MCZNetworkClient
@synthesize failCallback = _failCallback;
@synthesize callback = _callback;

+ (id)callback:(void(^)(NSDictionary*))callback
  failCallback:(void(^)())failCallback
{
  MCZNetworkClient* client = [[MCZNetworkClient alloc] init];
  if (client) {
    client.callback = callback;
    client.failCallback = failCallback;
  }
  return client;
}

- (void)postPhoto:(UIImage*)image
{
  NSString *boundary = @"_insert_some_boundary_here_";
  NSMutableData* result = [[NSMutableData alloc] init];
  NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
  // arrange data
  [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n",
                                @"iPhoneAppPhoto"] dataUsingEncoding:NSASCIIStringEncoding]];
  [result appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"]
                       dataUsingEncoding:NSASCIIStringEncoding]];
  [result appendData:imageData];
  [result appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
  [result appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
  NSURL *url = [NSURL URLWithString:@"http://eyebeam.herokuapp.com/upload"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:result];
  [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
  NSURLResponse *response = nil;
  NSError       *error    = nil;
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
}

@end
