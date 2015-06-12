//
//  TMReview.h
//  PlacesReview
//
//  Created by devKrishnan on 09/06/15.
//  Copyright (c) 2015 Sample. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject, TMPlace,TMFilterRequest;

@interface TMReview : NSManagedObject

@property (nonatomic, retain) NSString * detailsURL;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * uniqueHashID;
@property (nonatomic, retain) NSNumber * wordsCount;
@property (nonatomic, retain) TMPlace *reviewOfPlace;
@property (nonatomic, retain) TMFilterRequest *reviewsForRequest;
@end

@interface TMReview (CoreDataGeneratedAccessors)

- (void)addReviewsForRequestObject:(NSManagedObject *)value;
- (void)removeReviewsForRequestObject:(NSManagedObject *)value;
- (void)addReviewsForRequest:(NSSet *)values;
- (void)removeReviewsForRequest:(NSSet *)values;

@end
