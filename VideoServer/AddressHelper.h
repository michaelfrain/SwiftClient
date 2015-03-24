//
//  AddressHelper.h
//  VideoServer
//
//  Created by Michael Frain on 3/23/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressHelper : NSObject

+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (NSString *)documentsDirectory;
+ (NSArray *)getFullFileList;

@end
