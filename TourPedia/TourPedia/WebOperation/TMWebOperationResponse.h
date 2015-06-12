
#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    TMWebAPIResponseSuccessWithData,
    TMWebAPIResponseSuccessWithNoData,
    TMWebAPIResponseFail
} TMWebAPIResponseType;

@interface TMWebOperationResponse : NSObject
@property(nonatomic)TMWebAPIResponseType responseType;
@property(nonatomic)NSString *errorMessage;
@property(nonatomic)NSString *errorMessageTitle;
@property(nonatomic)NSObject *responseObject;
@property(nonatomic)NSDictionary *errorObject;
@end
