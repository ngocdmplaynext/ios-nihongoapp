//
//  MeCabUtil.m
//
//  Created by Watanabe Toshinori on 10/12/22.
//  Copyright 2010 FLCL.jp. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iconv.h>
#import "MeCabUtil.h"
#import "Node.h"
#import "NSString+Japanese.h"


@implementation MeCabUtil

- (NSArray *)parseToNodeWithString:(NSString *)string {

	if (mecab == NULL) {
		
#if TARGET_IPHONE_SIMULATOR
		// Homebrew mecab path
//		NSString *path = @"/usr/local/Cellar/mecab/0.996/lib/mecab/dic/ipadic";
		NSString *path = @"/usr/local/mecab/lib/mecab/dic/ipadic/";
#else
		NSString *path = [[NSBundle mainBundle] resourcePath];
#endif
		
		mecab = mecab_new2([[@"-d " stringByAppendingString:path] UTF8String]);

		if (mecab == NULL) {
			fprintf(stderr, "error in mecab_new2: %s\n", mecab_strerror(NULL));
			
			return nil;
		}
	}

	const mecab_node_t *node;
	const char *buf= [string cStringUsingEncoding:NSUTF8StringEncoding];
	NSUInteger l= [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

	node = mecab_sparse_tonode2(mecab, buf, l);
	if (node == NULL) {
		fprintf(stderr, "error\n");

		return nil;
	}
	
	NSMutableArray *newNodes = [NSMutableArray array];
	node = node->next;
	for (; node->next != NULL; node = node->next) {

		Node *newNode = [Node new];
		newNode.surface = [[NSString alloc] initWithBytes:node->surface length:node->length encoding:NSUTF8StringEncoding];
		newNode.feature = [NSString stringWithCString:node->feature encoding:NSUTF8StringEncoding];
		[newNodes addObject:newNode];
	}
	
	return [NSArray arrayWithArray:newNodes];
}

- (NSString *)stringJapaneseToRomaji:(NSString *)string {
    NSMutableString *str = [NSMutableString new];
    NSArray *array = [self parseToNodeWithString:string];
    for (Node* item in array) {
        NSString *pronoun = [item pronunciation];
        if (pronoun) {
            [str appendString: [pronoun stringByTransliteratingJapaneseToRomaji]];
        } else {
            [str appendString: [item.surface stringByTransliteratingJapaneseToRomaji]];
        }
        
        [str appendString:@" "];
    }
    
    return [str copy];
}

- (void)dealloc {
	if (mecab != NULL) {
		mecab_destroy(mecab);
	}
}

@end
