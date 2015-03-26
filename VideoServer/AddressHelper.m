//
//  AddressHelper.m
//  VideoServer
//
//  Created by Michael Frain on 3/23/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

#import "AddressHelper.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation AddressHelper

+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4];
    
    NSDictionary *addresses = [AddressHelper getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        if (address) *stop = YES;
    }];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    struct ifaddrs *interfaces;
    if (!getifaddrs(&interfaces)) {
        struct ifaddrs *interface;
        for (interface = interfaces; interface; interface = interface->ifa_next) {
            if (!(interface->ifa_flags & IFF_UP)) {
                continue;
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)];
            if (addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.count > 0 ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSArray *)getFullFileList {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"/private%@", [AddressHelper documentsDirectory]] error:nil];
    return fileList;
}

+ (NSData *)generatePlaylist:(NSArray *)tracks {
    NSMutableString *playlist = [[NSMutableString alloc] init];
    [playlist appendString:@"#EXTM3U\n"];
    [playlist appendString:@"#EXT-X-TARGETDURATION:8\n"];
    for (NSString *track in tracks) {
        [playlist appendString:@"#EXTINF:8\n"];
        [playlist appendFormat:@"http://%@:%@/", [AddressHelper getIPAddress:YES], @"8080"];
        [playlist appendString:track];
        [playlist appendString:@"\n"];
    }
    [playlist appendString:@"#EXT-X-ENDLIST"];
    NSData *playlistData = [playlist dataUsingEncoding:NSUTF8StringEncoding];
    return playlistData;
}

@end
