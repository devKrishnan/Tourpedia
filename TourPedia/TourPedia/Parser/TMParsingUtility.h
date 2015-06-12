

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TMFilterRequest.h"

@interface TMParsingUtility : NSObject
-(id)initWithManagedObjectContext:(NSManagedObjectContext*)mgdobjectContext;
-(NSSet*)parseAndStoreReviewList:(NSArray*)reviewList withError:(NSError**)error;
-(BOOL)insertCategories:(NSDictionary*)categoryDictionary locations:(NSDictionary*)locationDicttionary;
-(BOOL)insertFetchRequestWithUniqueID:(NSString*)uniqueID  withError:(NSError**)error;

@end
