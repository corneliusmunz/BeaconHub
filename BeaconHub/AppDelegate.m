//
//  AppDelegate.m
//  BeaconHub
//
//  Created by mz82fe on 15.08.14.
//  Copyright (c) 2014 Bosch Thermotechnik GmbH. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

}


- (IBAction)scanButtonPressed:(id)sender {
    
    NSLog(@"scanButton pressed");
    
    if ([self.scanButton.title isEqualToString:@"Start scanning"]) {
        self.scanButton.title = @"Stop scanning";
        [self.UUIDTextField setEnabled:NO];
        [self.majorID setEnabled:NO];
        [self.minorID setEnabled:NO];
        
        [self startScanning];
        
    } else {
        self.scanButton.title = @"Start scanning";
        [self.UUIDTextField setEnabled:YES];
        [self.majorID setEnabled:YES];
        [self.minorID setEnabled:YES];
        
        [self stopScanning];
    }
    
    
}


- (void)startScanning {
    //[ble findBLEPeripherals:100];
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        
//    [manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:self.UUIDTextField.stringValue]] options:options];
    
    //[manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"3DF338E8-71FE-41AD-8D73-394C9DD472A9"]] options:options];
    
    //B9407F30-F5F8-466E-AFF9-25556B57FE6D
    
    [manager scanForPeripheralsWithServices:nil options:options];
    
}
                                    
-(void)stopScanning {
    [manager stopScan];
}

#pragma mark - CBCentral Manager delegate methods

/*
 Invoked whenever the central manager's state is updated.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"update state");
}

/*
 Invoked when the central discovers thermometer peripheral while scanning.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [manager stopScan];
    NSLog(@"---------------");
    //NSLog(@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData);
    
    NSData *manufacturerData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSLog(@"major ID: %i", [self fetchMajorID:manufacturerData]);
    NSLog(@"minor ID: %i", [self fetchMinorID:manufacturerData]);
    NSLog(@"UUID: %@", [[self fetchProximityUUID:manufacturerData] UUIDString]);
    NSLog(@"Power level: %i", [self fetchPowerLevel:manufacturerData]);
    NSLog(@"RSSI: %@", RSSI);
    NSLog(@"---------------");
    NSLog(@"");


    //[self beaconWithManufacturerAdvertisementData:manufacturerData];
    
    testPeripheral = peripheral;
    
    //[manager connectPeripheral:testPeripheral options:nil];
    
    if ([self.scanButton.title isEqualToString: @"Stop scanning"]) {
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [manager scanForPeripheralsWithServices:nil options:options];
    }


    
}

-(int)fetchMajorID:(NSData *)data {
    if ([data length] != 25) {
        return 0;
    }
    
    u_int16_t major = 0;
    
    NSRange majorRange = NSMakeRange(20, 2);
    [data getBytes:&major range:majorRange];
    major = (major >> 8) | (major << 8);

    return major;
}

-(int)fetchMinorID:(NSData *)data {
    if ([data length] != 25) {
        return 0;
    }
    
    u_int16_t minor = 0;
    
    NSRange minorRange = NSMakeRange(22, 2);
    [data getBytes:&minor range:minorRange];
    minor = (minor >> 8) | (minor << 8);
    
    return minor;
}

-(int)fetchPowerLevel:(NSData *)data {
    if ([data length] != 25) {
        return 0;
    }
    
    u_int16_t powerLevel = 0;
    
    NSRange powerRange = NSMakeRange(24, 1);
    [data getBytes:&powerLevel range:powerRange];
    
    return powerLevel;
}

-(NSUUID *)fetchProximityUUID:(NSData *)data {
    if ([data length] != 25) {
    }
    
    char uuidBytes[17] = {0};
    
    NSRange uuidRange = NSMakeRange(4, 16);
    [data getBytes:&uuidBytes range:uuidRange];
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDBytes:(const unsigned char*)&uuidBytes];

    return proximityUUID;
}



-(void)beaconWithManufacturerAdvertisementData:(NSData *)data {
    if ([data length] != 25) {
    }
    
    u_int16_t companyIdentifier,major,minor = 0;
    
    int8_t measuredPower,dataType, dataLength = 0;
    char uuidBytes[17] = {0};
    
    NSRange companyIDRange = NSMakeRange(0,2);
    [data getBytes:&companyIdentifier range:companyIDRange];
    if (companyIdentifier != 0x4C) {
    }
    NSRange dataTypeRange = NSMakeRange(2,1);
    [data getBytes:&dataType range:dataTypeRange];
    if (dataType != 0x02) {
    }
    NSRange dataLengthRange = NSMakeRange(3,1);
    [data getBytes:&dataLength range:dataLengthRange];
    if (dataLength != 0x15) {
    }
    
    NSRange uuidRange = NSMakeRange(4, 16);
    NSRange majorRange = NSMakeRange(20, 2);
    NSRange minorRange = NSMakeRange(22, 2);
    NSRange powerRange = NSMakeRange(24, 1);
    [data getBytes:&uuidBytes range:uuidRange];
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDBytes:(const unsigned char*)&uuidBytes];
    [data getBytes:&major range:majorRange];
    major = (major >> 8) | (major << 8);
    [data getBytes:&minor range:minorRange];
    minor = (minor >> 8) | (minor << 8);
    [data getBytes:&measuredPower range:powerRange];
}
     
/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
*/
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect to peripheral: %@", peripheral);
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", peripheral, [error localizedDescription]);

}

#pragma mark - CBPeripheralDelegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    for (CBService * service in peripheral.services)
    {
        NSLog(@"Service found with UUID: %@", service.UUID);
    
    }
}




@end
