//
//  MKMapView+Additions.m
//  ImIn
//
//  Created by KYONGJIN SEO on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MKMapView+Additions.h"

@implementation MKMapView (MKMapView_Additions)

- (UIImageView *)googleLogo {
    UIImageView *imgView = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isMemberOfClass:[UIImageView class]]) {
            imgView = (UIImageView *)subview;
            break;
        }
    }
    return imgView;
}
@end
