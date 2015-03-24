//
//  ObjcServerConnection.m
//  VideoServer
//
//  Created by Michael Frain on 3/23/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

#import "ObjcServerConnection.h"
#import "HTTPMessage.h"
#import "AddressHelper.h"
#import "HTTPDataResponse.h"

@implementation ObjcServerConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    if ([method isEqualToString:@"POST"]) {
        NSLog(@"POST called");
        return YES;
    }
    
    if ([method isEqualToString:@"GET"]) {
        NSLog(@"GET called");
        return YES;
    }
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    if ([method isEqualToString:@"POST"]) {
        NSLog(@"YES");
        return YES;
    }
    
    if ([method isEqualToString:@"GET"]) {
        NSString *filePath = [self filePathForURI:path];
        
        if (![filePath hasPrefix:[AddressHelper documentsDirectory]]) {
            return nil;
        }
        
        NSString *relativePath = [filePath substringFromIndex:[AddressHelper documentsDirectory].length];

        if ([relativePath isEqualToString:@"/download"]) {
            return YES;
        }
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (void)processBodyData:(NSData *)postDataChunk {
    
    BOOL result = [request appendData:postDataChunk];
    if (!result) {
        NSLog(@"Could not append data!");
    }
}

- (void)finishBody {
    [request.body writeToFile:[NSString stringWithFormat:@"%@/%lu.ts", [AddressHelper documentsDirectory], (unsigned long)request.body.length] atomically:YES];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    NSString *filePath = [self filePathForURI:path];
    
    if (![filePath hasPrefix:[AddressHelper documentsDirectory]]) {
        return nil;
    }
    
    NSString *relativePath = [filePath substringFromIndex:[AddressHelper documentsDirectory].length];
    HTTPDataResponse *dataResponse;
    
    if ([relativePath isEqualToString:@"/allclips"]) {
        NSArray *fileList = [AddressHelper getFullFileList];
        NSData *arrayAsData = [NSKeyedArchiver archivedDataWithRootObject:fileList];
        dataResponse = [[HTTPDataResponse alloc] initWithData:arrayAsData];
    }
    
    if ([relativePath isEqualToString:@"/download"]) {
        NSDictionary *params = [self parseGetParams];
        NSArray *array = [params objectForKey:@"clips"];
        NSMutableDictionary *clipDict = [[NSMutableDictionary alloc] init];
        for (filePath in array) {
            NSData *clip = [NSData dataWithContentsOfFile:filePath];
            if (clip != nil) {
                [clipDict setValue:clip forKey:filePath];
            }
        }
        NSData *serializedArray = [NSKeyedArchiver archivedDataWithRootObject:clipDict];
        dataResponse = [[HTTPDataResponse alloc] initWithData:serializedArray];
    }
    return dataResponse;
}

@end
