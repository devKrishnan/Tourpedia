
#import "FXForms.h"
#import <Foundation/Foundation.h>

@interface TMReviewDetailsForm : NSObject<FXForm>
@property (nonatomic, strong) NSString *text;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * time;

@end
