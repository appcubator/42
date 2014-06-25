//
//  UIButtonWithData.h
//  42
//
//  Created by Ilter Canberk on 6/24/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButtonWithData : UIButton {
    id extraData;
}

@property (nonatomic, readwrite, retain) id extraData;

@end
