
#ifndef PlacesReview_TMConstants_h
#define PlacesReview_TMConstants_h



#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


#define  configDetailsBASEURLKey @"configDetailsBASEURL"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
// ALog will always output like NSLog

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define TimeStamp(TimeIntervalInMilliseconds)[NSDate dateWithTimeIntervalSince1970:(TimeIntervalInMilliseconds/1000)];


#define UIAppFontGillSansLightItalicWithSize(fontSize) [UIFont fontWithName:@"GillSans-LightItalic" size:fontSize]

#define UIAppFontGillSansWithSize(fontSize) [UIFont fontWithName:@"GillSans" size:fontSize]
#define UIAppFontGillSansBoldWithSize(fontSize) [UIFont fontWithName:@"GillSans-Bold" size:fontSize]
#define UIAppFontGillSansLightWithSize(fontSize) [UIFont fontWithName:@"GillSans-Light" size:fontSize]
#define UIAppFontGillSansBoldItalicWithSize(fontSize) [UIFont fontWithName:@"GillSans-BoldItalic" size:fontSize]

#define UIAppFontHelvetica(fontSize) [UIFont fontWithName:@"Helvetica" size:fontSize]

#define UIAppFontFuturaMeduim(fontSize) [UIFont fontWithName:@"Futura-Medium" size:fontSize]

#define UIAppFontHelveticaBold(fontSize) [UIFont fontWithName:@"Helvetica-Bold" size:fontSize]
#define UIAppFontHelveticaLight(fontSize) [UIFont fontWithName:@"Helvetica-Light" size:fontSize]
#endif
