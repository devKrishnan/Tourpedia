

#import "TMFilterForm.h"
#import "TMConstants.h"
#import "TMCategory.h"
#import "TMLocation.h"

@implementation TMFilterForm
- (NSArray *)fields
{
  
  
  NSArray *listOfCategories = @[@"accommodation",@"Attraction" , @"Restaurant", @"poi"];
  NSArray *listOfLocations = @[@"Amsterdam",@"Barcelona" , @"Berlin", @"Dubay",@"London",@"Paris",@"Rome",@"Tuscany"];
  
  
  
  
  return  @[
            @{ FXFormFieldKey: @"selectedCategoryList",FXFormFieldTitle:@"Category",FXFormFieldOptions:  listOfCategories,@"textLabel.font": UIAppFontGillSansLightWithSize(14),@"detailTextLabel.font":UIAppFontGillSansWithSize(12),FXFormFieldInline:@YES,FXFormFieldSortable:@YES},
            
            @{FXFormFieldKey: @"selectedLocationList",FXFormFieldTitle:@"Locations",FXFormFieldOptions:listOfLocations,@"textLabel.font": UIAppFontGillSansLightWithSize(14),@"detailTextLabel.font":UIAppFontGillSansWithSize(12),FXFormFieldInline:@YES,FXFormFieldSortable:@YES
              }];
  
  
}


@end
