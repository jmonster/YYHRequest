//
//  YYHRequest.m
//  YYHRequest
//
//  Created by Angelo Di Paolo on 3/8/14.
//  Copyright (c) 2014 Yayuhh. All rights reserved.
//

#import "YYHRequest.h"

@interface YYHRequest ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, readwrite, copy) NSURLResponse *response;
@property (nonatomic, copy) NSMutableData *responseData;
@property (nonatomic, copy) void (^successCallback)(NSData *data);
@property (nonatomic, copy) void (^failureCallback)(NSError *error);

@end

@implementation YYHRequest

+ (NSOperationQueue *)operationQueue {
    static NSOperationQueue *_operationQueue;
    
    if (!_operationQueue) {
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 4;
    }
    
    return _operationQueue;
}

- (NSMutableData *)responseData {
    if (!_responseData) {
        _responseData = [NSMutableData new];
    }
    
    return _responseData;
}

#pragma mark - Creating a YYHRequest

+ (YYHRequest *)loadRequestWithURL:(NSURL *)url success:(void (^)(NSData *data))success failure:(void (^)(NSError *error))failure {
    return [[YYHRequest alloc] initWithURL:url success:success failure:failure];
}

- (instancetype)initWithURL:(NSURL *)url success:(void (^)(NSData *data))success  failure:(void (^)(NSError *error))failure {
    self = [super init];
    
    if (self) {
        self.url = url;
        self.successCallback = success;
        self.failureCallback = failure;
        
        NSURLRequest *request = [self requestWithURL:_url];
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        self.connection.delegateQueue = [YYHRequest operationQueue];
        [self.connection start];
    }
    
    return self;
}

- (void)responseReceived {
    self.successCallback(self.responseData);
}

#pragma mark - Creating a NSURLRequest

- (NSURLRequest *)requestWithURL:(NSURL *)url {
    return [NSURLRequest requestWithURL:url];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self responseReceived];
}

@end
