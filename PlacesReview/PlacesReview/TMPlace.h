//
//  TMPlace.h
//  PlacesReview
//
//  Created by devKrishnan on 09/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TMLocation, TMReview;

@interface TMPlace : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) TMLocation *belongsToLocation;
@property (nonatomic, retain) NSSet *hasReviews;
@end

@interface TMPlace (CoreDataGeneratedAccessors)

- (void)addHasReviewsObject:(TMReview *)value;
- (void)removeHasReviewsObject:(TMReview *)value;
- (void)addHasReviews:(NSSet *)values;
- (void)removeHasReviews:(NSSet *)values;

@end
