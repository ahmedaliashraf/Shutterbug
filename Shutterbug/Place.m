//
//  Place.m
//  Shutterbug
//
//  Created by Ultimate on 11/28/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "Place.h"

@interface Place ()
@end

@implementation Place


- (void)setCity:(NSString *)city{
    _city = city;
}
- (void)setProvince:(NSString *)province{
    _province = province;
}
- (void)setCountry:(NSString *)country{
    _country = country;
}
- (void)setPlaceID:(NSString *)placeID{
    _placeID = placeID;
}

- (void)setAssignedToRow:(BOOL)assignedToRow {
    _assignedToRow = assignedToRow;
}

- (NSComparisonResult)compare:(Place *)otherPlace{
    return [self.country compare:otherPlace.country];
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.city = @"Unknown";
        self.province = @"Unknown";
        self.country = @"Unknown";
        self.placeID = @"Unknown";
        self.assignedToRow = NO;
    }
    return self;
}
@end
