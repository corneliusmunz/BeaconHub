//
//  Beacon.m
//  BeaconHub
//
//  Created by mz82fe on 19.08.14.
//  Copyright (c) 2014 Bosch Thermotechnik GmbH. All rights reserved.
//

#import "Beacon.h"

@implementation Beacon

@synthesize proximityUUID, major, minor, measuredPower, RSSI, lastUpdated;

- (id)initWithProximityUUID:(NSUUID *)_proximityUUID major:(NSNumber *)_major minor:(NSNumber *)_minor measuredPower:(NSNumber *)_power rssi:(NSNumber *)rssi {
    self = [super init];
    
    if (self) {
        self.proximityUUID = _proximityUUID;
        self.major = _major;
        self.minor = _minor;
        self.measuredPower = _power;
        self.RSSI = rssi;
        self.lastUpdated = [NSDate date];
    }
    return self;
}

-(void) updateWithAdvertismentDataDictionary:(NSDictionary *)advertisementDataDictionary rssi:(NSNumber *)rssi {
    NSData *data = (NSData *)[advertisementDataDictionary objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (data) {
        Beacon *newBeacon = [Beacon beaconWithManufacturerAdvertisementData:data rssi:rssi];
        if (newBeacon) {
            if ([self isEqualToBeacon:newBeacon]) {
                [self updateBeaconWithMeasuredPower:newBeacon.measuredPower rssi:newBeacon.RSSI];
            }
        }

    }
}

-(void)updateBeaconWithMeasuredPower:(NSNumber *)power rssi:(NSNumber *)rssi {
    self.measuredPower = power;
    self.RSSI = rssi;
    self.lastUpdated = [NSDate date];
}

+(Beacon *)beaconWithAdvertismentDataDictionary:(NSDictionary *)advertisementDataDictionary rssi:(NSNumber *)rssi{
    NSData *data = (NSData *)[advertisementDataDictionary objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (data) {
        return [self beaconWithManufacturerAdvertisementData:data rssi:rssi];
    }
    return nil;
}



+(Beacon *)beaconWithManufacturerAdvertisementData:(NSData *)data rssi:(NSNumber *)rssi{
    if ([data length] != 25) {
        return nil;
    }
    
    Beacon *beacon = [[Beacon alloc] initWithProximityUUID:[self fetchProximityUUID:data]
                                                                          major:[NSNumber numberWithUnsignedInteger:[self fetchMajorID:data]]
                                                                          minor:[NSNumber numberWithUnsignedInteger:[self fetchMinorID:data]]
                                                                  measuredPower:[NSNumber numberWithShort:[self fetchPowerLevel:data]]
                                                                           rssi:rssi];
    return beacon;
}

-(NSString *)getBeaconKey {
    return [NSString stringWithFormat:@"%@-%@-%@", self.proximityUUID, self.major, self.minor];
}

+(NSString *)getBeaconKeyForProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor {
    return [NSString stringWithFormat:@"%@-%@-%@", proximityUUID, major, minor];
}

+(int)fetchMajorID:(NSData *)data {
    if ([data length] != 25) {
        return 0;
    }
    
    u_int16_t major = 0;
    
    NSRange majorRange = NSMakeRange(20, 2);
    [data getBytes:&major range:majorRange];
    major = (major >> 8) | (major << 8);
    
    return major;
}

+(int)fetchMinorID:(NSData *)data {
    if ([data length] != 25) {
        return 0;
    }
    
    u_int16_t minor = 0;
    
    NSRange minorRange = NSMakeRange(22, 2);
    [data getBytes:&minor range:minorRange];
    minor = (minor >> 8) | (minor << 8);
    
    return minor;
}

+(int)fetchPowerLevel:(NSData *)data {
    if ([data length] != 25) {
        return 0;
    }
    
    u_int16_t powerLevel = 0;
    
    NSRange powerRange = NSMakeRange(24, 1);
    [data getBytes:&powerLevel range:powerRange];
    
    return powerLevel;
}

+(NSUUID *)fetchProximityUUID:(NSData *)data {
    if ([data length] != 25) {
    }
    
    char uuidBytes[17] = {0};
    
    NSRange uuidRange = NSMakeRange(4, 16);
    [data getBytes:&uuidBytes range:uuidRange];
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDBytes:(const unsigned char*)&uuidBytes];
    
    return proximityUUID;
}

-(BOOL)isEqualToBeacon:(Beacon *)beacon {
    return ([self.proximityUUID isEqualTo:beacon.proximityUUID] &&
            [self.major isEqualToNumber:beacon.major] &&
            [self.minor isEqualToNumber:beacon.minor]);
}

-(BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[Beacon class]]) {
        Beacon *beacon = (Beacon *)object;
        return [self isEqualToBeacon:beacon];
    }
    return [super isEqualTo:object];
}

+(NSString *)toString:(Beacon *)beacon {
    if (beacon) {
        return [NSString stringWithFormat:@"UUID:%@, major:%i, minor:%i, RSSI:%i, power:%i", beacon.proximityUUID, [beacon.major intValue], [beacon.minor intValue], [beacon.RSSI intValue], [beacon.measuredPower intValue]];
    } else {
        return @"";
    }
}


@end
