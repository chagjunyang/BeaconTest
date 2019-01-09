//
//  ViewController.m
//  BeaconTest
//
//  Created by NHNENT on 2016. 4. 11..
//  Copyright © 2016년 NHNENT. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () 

@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *checkAuthorizationButton;
@property (strong, nonatomic) IBOutlet UILabel *logLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupLocationManager];
    [self setupRegion];
}


#pragma mark - Setup


- (void)setupLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}


- (void)setupRegion
{
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    
    _myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
    _myBeaconRegion.notifyEntryStateOnDisplay = YES;
    _myBeaconRegion.notifyOnExit = YES;
    _myBeaconRegion.notifyOnEntry = YES;
}


#pragma mark - CLLocationManagerDelegate


-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region
{
    for(CLBeacon *beacon in beacons)
    {
        if ([self.myBeaconRegion.proximityUUID isEqual:beacon.proximityUUID])
        {
            NSString *sProximityString = @"";
            
            if(beacon.proximity == CLProximityUnknown)
            {
                sProximityString = @"Unkown";
            }
            else if(beacon.proximity == CLProximityNear)
            {
                sProximityString = @"Near";
            }
            else if(beacon.proximity == CLProximityImmediate)
            {
                sProximityString = @"Immediate";
            }
            else
            {
                sProximityString = @"Far";
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(nonnull CLBeaconRegion *)region withError:(nonnull NSError *)error
{
    [self.logLabel setText:[NSString stringWithFormat:@"rangingBeaconsDidFailForRegion %@", error]];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.logLabel setText:@"didStartMonitoringForRegion"];
    
    [self.locationManager requestStateForRegion:_myBeaconRegion];
}

// 모니터링 실패 시
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
        [self.logLabel setText:[NSString stringWithFormat:@"monitoringDidFailForRegion %@", error]];
}

//비콘에 진입하였을 때
- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion *)region
{
    [self.logLabel setText:@"didEnterRegion"];
}

//비콘에 멀어져 연결이 종료될 때
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.logLabel setText:@"didExitRegion"];
}

//비콘 상태
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside) {
        [self.logLabel setText:@"Beacon Monitoring Success : State Inside"];
        [self.locationManager startRangingBeaconsInRegion:_myBeaconRegion];
    }else if(state == CLRegionStateOutside){
        [self.logLabel setText:@"Beacon Monitoring Success : State Outside"];
        [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    }else{
        [self.logLabel setText:@"Beacon Monitoring Success : State Unkown"];
    }
}

//권한설정 변경
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status API_AVAILABLE(ios(4.2), macos(10.7))
{
    [self.logLabel setText:[self stateMessage:status]];
}


#pragma mark - Action


- (IBAction)tappedStartButton:(id)sender {
    [self startMonitoring];
}


- (IBAction)tappedStopButton:(id)sender {
    [self stopMonitoring];
}

- (IBAction)tappedCheckButton:(id)sender
{
    NSString *errorMessage;
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        errorMessage = [errorMessage stringByAppendingString: @"Beacons not supported!\n"];
    }
    else if (![CLLocationManager isRangingAvailable])
    {
        errorMessage = [errorMessage stringByAppendingString: @"Ranging not available!\n"];
    }
    else if([CLLocationManager locationServicesEnabled] == NO)
    {
        errorMessage = [errorMessage stringByAppendingString: @"위치서비스가 꺼져있습니다."];
        
        [self showAlertWithMessage:@"위치서비스가 꺼져있습니다."];
    }
    else
    {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        errorMessage = [self stateMessage:status];
        
        if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            [self showAlertWithMessage:errorMessage];
        }
        else if(status == kCLAuthorizationStatusNotDetermined)
        {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    
    [self.logLabel setText:errorMessage];
}


#pragma mark - Helper


- (void)showAlertWithMessage:(NSString *)aMessage
{
    NSString *sConfrimTitle = @"설정";
    
    UIAlertController *sAlertController = [UIAlertController alertControllerWithTitle:@"" message:aMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sConfirmAction = [UIAlertAction actionWithTitle:sConfrimTitle
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull aAction) {
                                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                           }];
    
    UIAlertAction *sCancelAction = [UIAlertAction actionWithTitle:@"닫기"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull aAction) {
                                                           }];
    
    [sAlertController addAction:sCancelAction];
    [sAlertController addAction:sConfirmAction];
    
    [self presentViewController:sAlertController animated:YES completion:nil];
}


- (void)startMonitoring
{
    [self.locationManager startMonitoringForRegion:_myBeaconRegion];
}


- (void)stopMonitoring
{
    [self.logLabel setText:@"Stop Monitoring"];
    
    [self.locationManager stopRangingBeaconsInRegion:_myBeaconRegion];
    [self.locationManager stopMonitoringForRegion:_myBeaconRegion];
}


- (NSString *)stateMessage:(CLAuthorizationStatus)status
{
    NSString *sStatusString = nil;
    
    if(status == kCLAuthorizationStatusNotDetermined)
    {
        sStatusString = @"위치서비스 권한 설정 안됨";
    }
    else if (status == kCLAuthorizationStatusDenied)
    {
        sStatusString = @"위치서비스 접근허용=`안함`";
    }
    else if(status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        sStatusString = @"위치서비스 접근허용=`앱을 사용하는 동안`";
    }
    else if(status == kCLAuthorizationStatusAuthorizedAlways)
    {
        sStatusString = @"위치서비스 접근허용=`항상`";
    }
    
    return sStatusString;
}


@end
