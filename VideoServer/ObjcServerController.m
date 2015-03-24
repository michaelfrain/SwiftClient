//
//  ObjcServerController.m
//  VideoServer
//
//  Created by Michael Frain on 3/23/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

#import "ObjcServerController.h"
#import "HTTPServer.h"
#import "AddressHelper.h"
#import "VideoServer-Swift.h"
#import "ObjcServerConnection.h"

@interface ObjcServerController ()

@property (nonatomic, weak) IBOutlet UISwitch *switchServerActive;
@property (nonatomic, weak) IBOutlet UILabel *labelServerStatus;

@property (nonatomic, strong) HTTPServer *server;
@property (nonatomic, strong) NSString *currentAddress;

@end

@implementation ObjcServerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.server = [[HTTPServer alloc] init];
    [self.server setPort:8080];
    [self.server setDocumentRoot:[AddressHelper documentsDirectory]];
    [self.server setConnectionClass:[ObjcServerConnection class]];
    self.currentAddress = [AddressHelper getIPAddress:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Note!" message:@"I recommend setting your auto-lock preference to \"NEVER\", as this server CANNOT run in the background. Visit Settings > General > Auto-Lock to change this setting." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)serverSwitched:(UISwitch *)sender {
    if (sender.on) {
        if ([self.server start:nil]) {
            self.labelServerStatus.text = [NSString stringWithFormat:@"Current server status: Active with address %@:%u", self.currentAddress, self.server.listeningPort];
        } else {
            self.labelServerStatus.text = @"Server unable to start!";
        }
    } else {
        [self.server stop];
        self.labelServerStatus.text = @"Server stopped!";
    }
}

/*
 

@IBAction func serverSwitched(sender: UISwitch!) {
    if sender.on {
        if server.start(globalError) {
            labelServerStatus.text = "Current server status: Active with address \(currentAddress):\(server.listeningPort())"
        } else {
            labelServerStatus.text = "Current server status: Could not start server"
        }
    } else {
        server.stop()
        labelServerStatus.text = "Current server status: Server stopped"
    }
}*/

@end
