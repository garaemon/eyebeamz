//
//  MCZNetworkClient.m
//  eyebeamz
//
//  Created by Ryohei Ueda on 12/06/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MCZNetworkClient.h"
#import "MCZUtil.h"

@interface MCZNetworkClient()
@property (strong, nonatomic) void (^callback)(NSString*);
@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, nonatomic) NSMutableData* receivedData;
@property (nonatomic) NSStringEncoding receivedDataEncoding;
@end

@implementation MCZNetworkClient
@synthesize receivedDataEncoding = _receivedDataEncoding;
@synthesize receivedData = _receivedData;
@synthesize connection = _connection;
@synthesize callback = _callback;

- (id)init
{
  self = [super init];
  if (self) {
    _receivedData = [[NSMutableData alloc] init];
  }
  return self;
}

+ (id)callback:(void(^)(NSString*))callback
{
  MCZNetworkClient* client = [[MCZNetworkClient alloc] init];
  if (client) {
    client.callback = callback;
  }
  return client;
}

- (void)postPhoto:(UIImage*)image
{
  NSString *boundary = @"_insert_some_boundary_here_";
  NSMutableData* result = [[NSMutableData alloc] init];
  NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
  // arrange data
  [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
  [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n",
                                @"iPhoneAppPhoto"] dataUsingEncoding:NSASCIIStringEncoding]];
  [result appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"]
                       dataUsingEncoding:NSASCIIStringEncoding]];
  [result appendData:imageData];
  [result appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
  [result appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
  NSURL *url = [NSURL URLWithString:@"http://eyebeam.herokuapp.com/upload"];
  //NSURL *url = [NSURL URLWithString:@"https://google.co.jp/"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:result];
  [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
  _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)callConnectionCallback:(NSString*)result
{
  LOG_INFO(@"'%@'", result);
  _callback(result);
}

// delegate methods
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
  LOG_INFO(@"connection established");
  NSString *encodingName = [response textEncodingName];
  LOG_INFO(@"encoding: %@", encodingName);
  if ([encodingName isEqualToString: @"euc-jp"]) {
    _receivedDataEncoding = NSJapaneseEUCStringEncoding;
  }
  else if ([encodingName isEqualToString: @"shift_jis"]) {
    _receivedDataEncoding = NSShiftJISStringEncoding;
  }
  else {
    _receivedDataEncoding = NSUTF8StringEncoding;
  }
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
  LOG_INFO(@"received data (byte): %d", [data length]);
  [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
  LOG_INFO(@"finish communication");
  NSString* result = [[NSString alloc] initWithData:_receivedData
                                           encoding:_receivedDataEncoding];
  [self callConnectionCallback:result];
}

@end
