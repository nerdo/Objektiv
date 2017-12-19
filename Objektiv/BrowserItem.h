//
//  BrowserItem.h
//  Objektiv
//
//  Created by Ankit Solanki on 18/12/12.
//  Copyright (c) 2012 nth loop. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DomainBrowserMapSettings;
@class ModifierKeyBrowserMapSettings;

@interface BrowserItem : NSObject

@property NSString *identifier;
@property NSString *name;
@property NSString *path;
@property DomainBrowserMapSettings *domainBrowserMapSettings;
@property ModifierKeyBrowserMapSettings *modifierKeyBrowserMapSettings;
@property BOOL hidden;
@property BOOL isDefault;

- (BrowserItem*) initWithApplicationId: (NSString*)theId name: (NSString*)theName path: (NSString*) thePath;

@end
