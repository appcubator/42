//
//  UIButtonForRow.h
//  42
//
//  Created by Ilter Canberk on 5/29/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButtonForRow : UIButton {
    id indexPath;
}

@property (nonatomic, readwrite, retain) id indexPath;

@end
