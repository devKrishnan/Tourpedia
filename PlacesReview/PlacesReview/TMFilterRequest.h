//
//  TMFilterRequest.h
//  PlacesReview
//
//  Created by devKrishnan on 09/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject, TMLocation, TMReview;

@interface TMFilterRequest : NSManagedObject
@property (nonatomic, retain) NSString * uniqueHashID;
@property (nonatomic, retain) NSManagedObject *hasCategories;
@property (nonatomic, retain) TMLocation *hasLocations;
@property (nonatomic, retain) NSSet *hasReviews;
@end

@interface TMFilterRequest (CoreDataGeneratedAccessors)

- (void)addHasReviewsObject:(TMReview *)value;
- (void)removeHasReviewsObject:(TMReview *)value;
- (void)addHasReviews:(NSSet *)values;
- (void)removeHasReviews:(NSSet *)values;

@end
