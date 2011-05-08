//
//  DomusAPI.m
//  MagicHome
//
//  Created by Patrick Quinn-Graham on 8/05/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "DomusAPI.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation DomusAPI

- (void)get:(NSString*)args method:(NSString*)method whenDone:(void (^)(NSDictionary*))doneBlock onError:(void (^)(NSError*))errorBlock {
    
    UIApplication*    app = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier bgTask;

    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://heyu.au.bigtr.net/api.php/%@", args]];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setUsername:@"..."];
    [request setPassword:@"..."];
    
    if(method) {
        if([method isEqualToString:@"POST"]) {
            [request appendPostData:[args dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [request setRequestMethod:method];
    }
    
    [request setCompletionBlock:^{
        NSDictionary *resp = (NSDictionary*)[[JSONDecoder decoder] objectWithData:[request responseData]];
        doneBlock(resp);
    }];
    [request setFailedBlock:^{
        errorBlock([request error]);
    }];
    [request startAsynchronous];
    
    
    [app endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}

- (void)getAliasState:(NSString*)alias withBlock:(void (^)(BOOL, NSInteger, NSError*))block {
    [self get:[NSString stringWithFormat:@"aliasstate/%@", alias] method:nil whenDone:^(NSDictionary* dict) {
        block([[dict objectForKey:@"state"] boolValue], [[dict objectForKey:@"level"] integerValue], nil);
    } onError:^(NSError *err) {
        block(NO, 0, err);
    }];
}

- (void)setAliasState:(NSString*)alias state:(BOOL)state withBlock:(void (^)(BOOL, NSError*))block {
    NSString *base = [NSString stringWithFormat:@"%@/%@", state ? @"on" : @"off", alias];
    [self get:base method:@"POST" whenDone:^(NSDictionary* dict) {
        block([[dict objectForKey:@"status"] isEqualToString:@"done"], nil);
    } onError:^(NSError *err) {
        block(NO, err);
    }];
}

@end
