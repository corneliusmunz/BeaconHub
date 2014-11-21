//
//  Beacon.h
//  BeaconHub
//
//  Created by mz82fe on 19.08.14.
//  Copyright (c) 2014 Bosch Thermotechnik GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>


@interface Beacon : NSObject

@property (strong,nonatomic) NSUUID *proximityUUID;
@property (strong,nonatomic) NSNumber *major;
@property (strong,nonatomic) NSNumber *minor;
@property (strong,nonatomic) NSNumber *measuredPower;
@property (strong,nonatomic) NSNumber *RSSI;
@property (strong,nonatomic) NSDate *lastUpdated;


- (id)initWithProximityUUID:(NSUUID *)proximityUUID
                      major:(NSNumber *)major
                      minor:(NSNumber *)minor
              measuredPower:(NSNumber *)power
                       rssi:(NSNumber *)rssi;

+(Beacon *)beaconWithAdvertismentDataDictionary:(NSDictionary *)advertisementDataDictionary rssi:(NSNumber *)rssi;
+(Beacon *)beaconWithManufacturerAdvertisementData:(NSData *)data rssi:(NSNumber *)rssi;

+(NSUUID *)fetchProximityUUID:(NSData *)data;
+(int)fetchPowerLevel:(NSData *)data;
+(int)fetchMinorID:(NSData *)data;
+(int)fetchMajorID:(NSData *)data;
-(NSString *)getBeaconKey;
+(NSString *)getBeaconKeyForProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor;

-(BOOL)isEqualToBeacon:(Beacon *)beacon;


@end
