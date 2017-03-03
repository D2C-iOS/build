//
//  UploadIPA.m
//  111111
//
//  Created by fengjiwen on 17/3/1.
//  Copyright © 2017年 fengjiwen. All rights reserved.
//

#import "UploadIPA.h"

#define D2CEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]

@interface UploadIPA()<NSURLConnectionDataDelegate>

@property (nonatomic ,strong) NSString *uKey;

@property (nonatomic ,strong) NSString *apiKey;

@property (nonatomic ,strong) NSURLConnection *connection;

@end

@implementation UploadIPA


- (instancetype)initWithUKey:(NSString *)uKey withAIPKey:(NSString *)apiKey {
    if (self = [super init]) {
        _uKey = uKey;
        _apiKey = apiKey;
    }
    return self;
}

- (void)uploadIPA:(NSString *)ipaPath description:(NSString *)description {
    if (![ipaPath hasSuffix:@".ipa"]) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:ipaPath];
    NSData *fileData = [NSData dataWithContentsOfURL:url];
    NSString *filename = ipaPath.lastPathComponent;
    NSString *mimeType = [self MIMEType:url];
    NSDictionary *params = @{
                             @"uKey" : _uKey,
                             @"_api_key" : _apiKey,
                             @"updateDescription":description,
                             
                             };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.pgyer.com/apiv1/app/upload"]];
    request.HTTPMethod = @"POST";
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:D2CEncode(@"--D2CM\r\n")];
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"", filename];
    [body appendData:D2CEncode(disposition)];
    NSString *type = [NSString stringWithFormat:@"Content-Type: %@", mimeType];
    [body appendData:D2CEncode(type)];
    [body appendData:D2CEncode(@"\r\n")];
    
    [body appendData:D2CEncode(@"\r\n")];
    [body appendData:fileData];
    [body appendData:D2CEncode(@"\r\n")];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [body appendData:D2CEncode(@"--D2CM\r\n")];
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", key];
        [body appendData:D2CEncode(disposition)];
        [body appendData:D2CEncode(@"\r\n")];
        
        [body appendData:D2CEncode(@"\r\n")];
        [body appendData:D2CEncode(obj)];
        [body appendData:D2CEncode(@"\r\n")];
    }];
    [body appendData:D2CEncode(@"--D2CM\r\n--")];
    request.HTTPBody = body;
    request.timeoutInterval = 60 * 60;
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",@"D2CM"];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [self.connection start];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ([self.delegate respondsToSelector:@selector(connectionTotalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.delegate connectionTotalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [self.delegate connection:connection didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if ([self.delegate respondsToSelector:@selector(connectionappShortcutUrl:appQRCodeURL:appUpdateDescription:appVersion:)]) {
        [self.delegate connectionappShortcutUrl:dict[@"data"][@"appShortcutUrl"] appQRCodeURL:dict[@"data"][@"appQRCodeURL"] appUpdateDescription:dict[@"data"][@"appUpdateDescription"] appVersion:dict[@"data"][@"appVersion"]];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"上传失败！");
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"上传完毕！");
}

- (void)cancel {
    [self.connection cancel];
}

- (NSString *)MIMEType:(NSURL *)url{
    // 1.创建一个请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 2.发送请求（返回响应）
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    // 3.获得MIMEType
    return response.MIMEType;
}
@end
