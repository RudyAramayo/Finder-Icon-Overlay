//
//  DesktopViewIconOverlay.m
//  FinderIconOverlayExample
//
//  Created by Villela Medina on 2/20/13.
//
//

#import "DesktopViewIconOverlay.h"
#import "FinderIconOverlayExample.h"
#include <objc/objc.h>
#include <objc/runtime.h>
#import <Quartz/Quartz.h>
#import "TFENodeHelper.h"

static TFENodeHelper *gNodeHelper;





@implementation DesktopViewIconOverlay

+ (void)pluginLoad
{

    
    
    // Create helper object
    gNodeHelper = [[TFENodeHelper alloc] init];
    if (gNodeHelper == nil) {
        NSLog(@"Failed to instantiate 'TFENodeHelper' class");
        return;
    }

    
    Method old, new;
	Class self_class = [self class];
    Class finder_class = [objc_getClass("TDesktopIcon") class];
    
    class_addMethod(finder_class, @selector(FO_drawIconInContext:),
                    class_getMethodImplementation(self_class, @selector(FO_drawIconInContext:)),"v@:@");
	
	old = class_getInstanceMethod(finder_class, @selector(drawIconInContext:));
	new = class_getInstanceMethod(finder_class, @selector(FO_drawIconInContext:));
	method_exchangeImplementations(old, new);


    finder_class = [objc_getClass("TDesktopViewController") class];

    
    class_addMethod(finder_class, @selector(FO_prepareToDrawNode:),
                    class_getMethodImplementation(self_class, @selector(FO_prepareToDrawNode:)),"v@:@");
	
	old = class_getInstanceMethod(finder_class, @selector(prepareToDrawNode:));
	new = class_getInstanceMethod(finder_class, @selector(FO_prepareToDrawNode:));
	method_exchangeImplementations(old, new);

}


- (void) FO_prepareToDrawNode:(const struct TFENode *)arg1 {
    
    NSString *path = [gNodeHelper pathForNode:arg1];
    NSLog(@"Path = %@", path);
    [[NSUserDefaults standardUserDefaults] setValue:path forKey:@"TDesktopIconURL"];
    
    //struct OpaqueNodeRef *opr = arg1->fNodeRef;
    
    //NSLog(@"path = %@", [[FINode nodeWithFENode:arg1] fullPath]);
    
    //id fiNode = [FINode nodeFromNodeRef:opr];
    //NSURL *url = [fiNode previewItemURL];
    //[[NSUserDefaults standardUserDefaults] setValue:[url path] forKey:@"TDesktopIconURL"];
    //NSLog(@"sending ", arg1->fNodeRef);
    // save url somewhere (I use NSUserDefaults)
    [self FO_prepareToDrawNode:arg1];
}



- (void) FO_drawIconInContext:(struct CGContext *)arg1
{
    [self FO_drawIconInContext:arg1];
    
    NSString *iconPath = [[NSUserDefaults standardUserDefaults] valueForKey:@"TDesktopIconURL"];
    NSLog(@"recieved %@", iconPath);

    //if (![iconPath isEqualToString:@"/Users/h0xff/Desktop/Restart Finder.app"])
    //    return;
    
    // I chose an image that everyone's mac would have... you need to embed your own images into the finder system somehow and then let the finder know about that image path...
    // possibly storing those images in /Library/Application Support/YourApp would be a good idea to have a fixed location...
    NSString *imagePath = @"/Library/User Pictures/Fun/Ying Yang.tif";
    NSImage *overlay = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    NSImage *mainImage = [(TDesktopIcon*)self thumbnailImage];
    
    float width = 256.0;
    float height = 256.0;
    
    NSImage *finalImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    
    [finalImage lockFocus];
    
    // draw the base image
    [mainImage drawInRect:NSMakeRect(0, 0, width, height)
                 fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    // draw the overlay image at some offset point
    [overlay drawInRect:NSMakeRect(0, 0, [overlay size].width/6.0, [overlay size].height/6.0)
               fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [finalImage unlockFocus];
    
   
    // set image...
    [(TDesktopIcon*)self setThumbnailImage:finalImage];
    [self FO_drawIconInContext:arg1];
}

@end
