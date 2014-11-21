//
//  AppDelegate.h
//  BeaconHub
//
//  Created by mz82fe on 15.08.14.
//  Copyright (c) 2014 Bosch Thermotechnik GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import "Beacon.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *testPeripheral;
}
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *UUIDTextField;
@property (weak) IBOutlet NSTextField *majorID;
@property (weak) IBOutlet NSTextField *minorID;
@property (weak) IBOutlet NSButton *scanButton;
- (IBAction)scanButtonPressed:(id)sender;
@property (weak) IBOutlet NSTextField *rssiTextField;
@property (weak) IBOutlet NSTextField *signalStregth;

@end
