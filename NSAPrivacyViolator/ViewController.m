//
//  ViewController.m
//  NSAPrivacyViolator
//
//  Created by GLBMXM0002 on 10/15/14.
//  Copyright (c) 2014 globant. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface ViewController () <CLLocationManagerDelegate>

@property CLLocationManager *myLocationManager;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myLocationManager = [[CLLocationManager alloc] init];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self; //We are the delegate for this view, i.e when location changes.

}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"I failed:  %@", error);
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) { //check the accuracy
            self.textView.text = @"Location Found. Reverse Geocoding...";
            [self reverseGeocode:location];
            NSLog(@"The location: %@", location);
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }

}

-(void) reverseGeocode: (CLLocation *) location {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@ \n%@",
                             placemark.subThoroughfare,
                             placemark.thoroughfare,
                             placemark.locality];
        self.textView.text = [NSString stringWithFormat:@"Found you: %@", address];
        [self findJailNear: placemark.location];
    }];
}

- (void) findJailNear: (CLLocation *)location {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"prision";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        MKMapItem *mapItem = mapItems.firstObject;
        self.textView.text = [NSString stringWithFormat:@"You should go to %@", mapItem.name];
    }];
}

- (IBAction)startViolatingPrivacy:(id)sender {
    [self.myLocationManager startUpdatingLocation];
    self.textView.text = @"Locating you...";
    NSLog(@"Hello");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
