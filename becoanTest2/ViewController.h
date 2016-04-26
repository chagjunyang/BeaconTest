//
//  ViewController.h
//  becoanTest2
//
//  Created by NHNENT on 2016. 4. 11..
//  Copyright © 2016년 NHNENT. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

