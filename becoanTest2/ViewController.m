//
//  ViewController.m
//  BeaconTest
//
//  Created by NHNENT on 2016. 4. 11..
//  Copyright © 2016년 NHNENT. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () 

@property (strong, nonatomic) UITextView *label;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSLog(@"%d", [self deviceSettingsAreCorrect]);
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"];
    
    _myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
    _myBeaconRegion.notifyEntryStateOnDisplay= NO;

    [self.locationManager startMonitoringForRegion:_myBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:_myBeaconRegion];
    
    _label = [[UITextView alloc] init];
    
    [self.view addSubview:_label];
}

-(BOOL)deviceSettingsAreCorrect
{
    NSString *errorMessage;
    
    if (![CLLocationManager locationServicesEnabled]
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        errorMessage = [errorMessage stringByAppendingString: @"Location services are turned off! Please turn them on!\n"];
        [self.locationManager requestAlwaysAuthorization];
    }
    if (![CLLocationManager isRangingAvailable])
    {
        errorMessage = [errorMessage stringByAppendingString: @"Ranging not available!\n"];
    }
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        errorMessage = [errorMessage stringByAppendingString: @"Beacons ranging not supported!\n"];
    }
    if ([errorMessage length])
    {
        NSLog(@"%@",errorMessage);
    }
    
    return [errorMessage length] == 0;
}

-(void)setTextLabel:(NSString *)text
{
    [_label setText:text];
    [_label sizeToFit];
    
    CGRect frame = _label.frame;
    frame.origin.y = 50.0f;
    [_label setFrame:frame];
}

-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region
{
 //   NSLog(@"region : %@", region);
    for(CLBeacon *beacon in beacons)
    {
//        NSLog(@"UUID : %@",beacon.proximityUUID);
//        NSLog(@"major : %@",beacon.major);
//        NSLog(@"minor : %@",beacon.minor);
//        NSLog(@"proximity : %ld",beacon.proximity);
//        NSLog(@"rssi : %ld",beacon.rssi);
//        NSLog(@"a  : %lf", beacon.accuracy);
        if ([self.myBeaconRegion.proximityUUID isEqual:beacon.proximityUUID]) {
            [self setTextLabel:[NSString stringWithFormat:@"UID:%@ major:%@ accuracy:%lf", beacon.proximityUUID, beacon.major, beacon.accuracy]];
        } else {
            [self setTextLabel:[NSString stringWithFormat:@"this is not beacon"]];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"didStartMonitoringForRegion");
    [self.locationManager requestStateForRegion:self.myBeaconRegion];
}


// 모니터링 실패 시
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion : %@",error);
}

//비콘에 진입하였을 때
- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"didEnterRegion");
    [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
}

//비콘에 멀어져 연결이 종료될 때
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"didExitRegion");
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];;
}

//비콘 상태
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside) {
        NSLog(@"CLRegionStateInside");
    }else if(state == CLRegionStateOutside){
        NSLog(@"CLRegionStateOutside");
    }else{
        NSLog(@"CLRegionStateUnknown");
    }
}

@end
