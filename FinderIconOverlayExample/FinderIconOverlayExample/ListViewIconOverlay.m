//
//  ListViewIconOverlay.m
//  FinderIconOverlayExample
//
//  Created by Les Nie on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListViewIconOverlay.h"
#import "FinderIconOverlayExample.h"
#include <objc/objc.h>
#include <objc/runtime.h>

/**
 * Renames the selector for a given method.
 * Searches for a method with origSEL and reassigned overrideSEL to that
 * implementation.
 * http://www.mikeash.com/pyblog/friday-qa-2010-01-29-method-replacement-for-fun-and-profit.html
 */
static void MethodSwizzle(Class c, SEL origSEL, SEL overrideSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method overrideMethod = class_getInstanceMethod(c, overrideSEL);
    
    NSLog(@"orig=%p, override=%p", origMethod, overrideMethod);
    
    if(class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

static void OverrideClass(const char *name, SEL origSEL, Method overrideMethod) {
    Class c = objc_getClass(name);
    if (c != nil) {
        // add override method to target class
        class_addMethod(c,
                        method_getName(overrideMethod),
                        method_getImplementation(overrideMethod),
                        method_getTypeEncoding(overrideMethod));
        // swizzle methods
        MethodSwizzle(c, origSEL, method_getName(overrideMethod));
        NSLog(@"Method 'menuForEvent:' overriden in class %s", name);
    } else {
        NSLog(@"Class %s not found to override", name);
    }
}


@implementation ListViewIconOverlay

+ (NSArray *) getOSVersion {
    NSDictionary *systemVersionDictionary = [NSDictionary dictionaryWithContentsOfFile:
                                             @"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *systemVersion = [systemVersionDictionary objectForKey:@"ProductVersion"];
    NSArray *version = [systemVersion componentsSeparatedByString:@"."];
    
    return version;
}


+ (void)pluginLoad
{
    
    NSArray *version = [self getOSVersion];
    int majorVersion = [[version objectAtIndex:0] intValue];
    int minorVersion = [[version objectAtIndex:1] intValue];
    
    // Finder symbols are different based on which OS version is running
    if (majorVersion == 10 && minorVersion > 5 && minorVersion < 8)
    {
        //MacOS 10.6-10.7
        Method old, new;
        Class self_class = [self class];
        Class finder_class = [objc_getClass("TIconAndTextCell") class];
        
        
        class_addMethod(finder_class, @selector(FO_drawIconWithFrame:),
                        class_getMethodImplementation(self_class, @selector(FO_drawIconWithFrame:)),"v@:{CGRect={CGPoint=dd}{CGSize=dd}}");
        
        old = class_getInstanceMethod(finder_class, @selector(drawIconWithFrame:));
        new = class_getInstanceMethod(finder_class, @selector(FO_drawIconWithFrame:));
        method_exchangeImplementations(old, new);
        
        
        
    } else if (majorVersion == 10 && minorVersion >= 8) {
        Method old, new;
        Class self_class = [self class];
        Class finder_class = [objc_getClass("TListViewIconAndTextCell") class];
        
        
        class_addMethod(finder_class, @selector(FO_drawIconWithFrame:),
                        class_getMethodImplementation(self_class, @selector(FO_drawIconWithFrame:)),"v@:{CGRect={CGPoint=dd}{CGSize=dd}}");
        
        old = class_getInstanceMethod(finder_class, @selector(drawIconWithFrame:));
        new = class_getInstanceMethod(finder_class, @selector(FO_drawIconWithFrame:));
        method_exchangeImplementations(old, new);
        
        
    }
    
    
    
}

- (void) FO_drawIconWithFrame:(struct CGRect)arg1
{
    [self FO_drawIconWithFrame:arg1];
    
    float badgeh = arg1.size.height * 0.8;
    //Try to use an 8x8 image if you can
    NSString *imagePath = @"/Library/User Pictures/Fun/Ying Yang.tif";
    NSImage *sicon = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSaveGState(myContext);
    CGContextTranslateCTM(myContext, arg1.origin.x, arg1.origin.y + arg1.size.height);
    CGContextScaleCTM(myContext, 1.0, -1.0);
    NSRect newrect = NSMakeRect(arg1.origin.x + 4 ,2 , badgeh, badgeh);
    struct CGImage *cimg = [sicon CGImageForProposedRect:&newrect context:[NSGraphicsContext currentContext] hints:Nil];
    
    CGContextDrawImage(myContext, *(CGRect *)&newrect, cimg);
    CGContextRestoreGState(myContext);
}

@end
