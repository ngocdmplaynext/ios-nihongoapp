//
//  MeCabUtil.h
//
//  Created by Watanabe Toshinori on 10/12/22.
//  Copyright 2010 FLCL.jp. All rights reserved.
//

#include <mecab.h>
#import <UIKit/UIKit.h>

@interface MeCabUtil : NSObject {
	mecab_t *mecab;
}

+ (MeCabUtil *)sharedMeCabUtil;

- (NSArray *)parseToNodeWithString:(NSString *)string;

- (NSString *)stringJapaneseToRomaji:(NSString *)string withWordSeperator:(NSString *)seperator;

- (NSString *)stringJapaneseToRomaji:(NSString *)string;

- (NSArray *)stringJapaneseToArrayRomaji:(NSString *)string;

@end
