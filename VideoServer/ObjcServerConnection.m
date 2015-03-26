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
        NSLog(@"POST request expects body.");
        return YES;
    }
    
    if ([method isEqualToString:@"GET"]) {
        NSString *filePath = [self filePathForURI:path];
//        
//        if (![filePath hasPrefix:[AddressHelper documentsDirectory]]) {
//            return NO;
//        }
        
        NSString *relativePath = [filePath substringFromIndex:[AddressHelper documentsDirectory].length + 3];

        if ([relativePath isEqualToString:@"/download"]) {
            return YES;
        }
        
        if ([relativePath isEqualToString:@"/stream"]) {
            return NO;
        }
        
        return NO;
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
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:date];
    NSInteger day = components.day;
    
    BOOL success = [request.body writeToFile:[NSString stringWithFormat:@"%@/%lu/%lu.ts", [AddressHelper documentsDirectory], (long)day, (unsigned long)request.body.length] atomically:YES];
    
    if (success) {
        NSLog(@"Body finished!");
    }
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    NSString *filePath = [self filePathForURI:path];
    
    if (![filePath hasPrefix:[AddressHelper documentsDirectory]]) {
        return nil;
    }
    
    NSString *relativePath = [filePath substringFromIndex:[AddressHelper documentsDirectory].length + 3];
    HTTPDataResponse *dataResponse;
    
    if ([relativePath isEqualToString:@"/upload"]) {
        dataResponse = [[HTTPDataResponse alloc] initWithData:[NSData data]];
        return dataResponse;
    }
    
    if ([relativePath isEqualToString:@"/allclips"]) {
        NSArray *fileList = [AddressHelper getFullFileList];
        NSData *arrayAsData = [NSKeyedArchiver archivedDataWithRootObject:fileList];
        dataResponse = [[HTTPDataResponse alloc] initWithData:arrayAsData];
        return dataResponse;
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
        return dataResponse;
    }
    
    if ([relativePath isEqualToString:@"/stream"]) {
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:date];
        NSInteger day = components.day;
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *fileList = [manager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/26/", [AddressHelper documentsDirectory]] error:nil];
        NSMutableArray *shortFileList = [[NSMutableArray alloc] init];
        for (filePath in fileList) {
            NSArray *fileComps = [filePath componentsSeparatedByString:@"/"];
            [shortFileList addObject:[fileComps objectAtIndex:fileComps.count - 1]];
        }
        NSData *playlist = [AddressHelper generatePlaylist:shortFileList];
        dataResponse = [[HTTPDataResponse alloc] initWithData:playlist];
        return dataResponse;
    }
    
    NSData *clipData = [NSData dataWithContentsOfFile:filePath];
    dataResponse = [[HTTPDataResponse alloc] initWithData:clipData];
    return dataResponse;
}

@end
