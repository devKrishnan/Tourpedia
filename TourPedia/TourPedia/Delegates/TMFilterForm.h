
#import "FXForms.h"

@interface TMFilterForm :  NSObject<FXForm>
@property(nonatomic,strong)NSArray *availableCategories;
@property(nonatomic,strong)NSArray *availableLocations;
@property(nonatomic,strong)NSArray *selectedCategoryList;
@property(nonatomic,strong)NSArray *selectedLocationList;
@end
