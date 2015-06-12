

#import "TMParsingUtility.h"
#import <CoreData/CoreData.h>
#import "TMCoreDataUtility.h"
#import "TMParserConstants.h"
#import "TMConstants.h"
#import "TMReview.h"
#import "TMLocation.h"
#import "TMPlace.h"
#import "TMCategory.h"
#import "TMLocation.h"
#import "TMFilterRequest.h"

@interface TMParsingUtility ()
@property(nonatomic,strong)TMCoreDataUtility *coreDataUtility;
@property(nonatomic,strong)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)NSDateFormatter *dateFormatter;
@end

@implementation TMParsingUtility
@synthesize coreDataUtility,managedObjectContext,dateFormatter;
-(id)initWithManagedObjectContext:(NSManagedObjectContext*)tempManagedContext
{
  NSAssert1(tempManagedContext, @"managedObjectContext can not be nil %s",__func__);
  self =  [super init];
  if (self) {
    
    NSDateFormatter *tempDateFormatter = [[NSDateFormatter alloc] init];
    [tempDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [tempDateFormatter setTimeZone:gmt];
    self.dateFormatter = tempDateFormatter;
    
    
    
    managedObjectContext = tempManagedContext;
    coreDataUtility = [[TMCoreDataUtility alloc]initWithManagedContext:managedObjectContext];
    if (nil == managedObjectContext || nil ==coreDataUtility   ) {
      return nil;
    }
    DLog(@"Core Data utility %@ \n coreDataUtility %@",self.coreDataUtility,coreDataUtility)
    NSAssert1(coreDataUtility, @"coreDataUtility can not be nil %s",__func__);
    
    NSAssert1(managedObjectContext, @"managedObjectContext can not be nil %s",__func__);
  }
  return self;
}

-(id)init
{
  return [self initWithManagedObjectContext:managedObjectContext];
  
}


-(NSSet*)parseAndStoreReviewList:(NSArray*)reviewList withError:(NSError**)error
{
  
 
    
  NSMutableSet *listOfReviews = [[NSMutableSet alloc]init];
  
  for (NSDictionary *reviewDict in reviewList) {
    
    ;
    
    //NSString *uniqueID = [self uniqueIDForDictionary:reviewDict];
    TMReview *managedrReview ;
    //= (TMReview*) [coreDataUtility  itemWithEntityID:uniqueID entityIDKey:@"uniqueHashID" withEntityType:[TMReview class]];
    
    
    managedrReview = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([TMReview class] ) inManagedObjectContext:managedObjectContext];
    //managedrReview.uniqueHashID = uniqueID;
    
    
    //managedrReview.reviewsForRequest = filterRequest;
    
    NSDate *reviewDate= [dateFormatter dateFromString:[reviewDict objectForKey:timeKey]];
    
    NSString *rating = [reviewDict objectForKey:ratingKey];
    if ([rating isKindOfClass:[NSString class]])
    {
      managedrReview.rating = [[NSNumber alloc] initWithInt: [rating intValue]];
    }
    else
    {
      
      managedrReview.rating = (NSNumber*)rating;
    }
    
    managedrReview.time = reviewDate;
    managedrReview.source = [reviewDict objectForKey:sourceKey];
    managedrReview.text = [reviewDict objectForKey:textKey];
    managedrReview.detailsURL = [reviewDict objectForKey:detailsKey];
    [listOfReviews addObject:managedrReview];
    
    
    
  }
  return listOfReviews;
  //[self.managedObjectContext save:error];
  
}

-(BOOL)insertCategories:(NSDictionary*)categoryDictionary locations:(NSDictionary*)locationDicttionary
{
  @autoreleasepool {
    
    for (NSString *categoryKey in [categoryDictionary allKeys]) {
      
      TMCategory *managedCategory ;
      managedCategory = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([TMCategory class] ) inManagedObjectContext:managedObjectContext];
      managedCategory.name = categoryKey;
      managedCategory.displayName = [categoryDictionary objectForKey:categoryKey];
      
    }
    
    for (NSString *locationKey in [locationDicttionary allKeys]) {
      
      TMLocation *managedLocation ;
      managedLocation = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([TMLocation class] ) inManagedObjectContext:managedObjectContext];
      managedLocation.name = locationKey;
      managedLocation.displayName = [locationDicttionary objectForKey:locationKey];
      
    }
    
  }
  NSError *error = nil;
  BOOL saveStatus = [self.managedObjectContext save:&error];
  
  return saveStatus;
}

-(BOOL)insertFetchRequestWithUniqueID:(NSString*)uniqueID withError:(NSError**)error
{
  TMFilterRequest *managedFR ;
  managedFR = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([TMFilterRequest class] ) inManagedObjectContext:managedObjectContext];
  managedFR.uniqueHashID = uniqueID;

  BOOL saveStatus = [self.managedObjectContext save:error];
  
  return saveStatus;

}

@end
