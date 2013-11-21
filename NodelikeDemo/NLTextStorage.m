//
//  NLTextStorage.m
//  Interpreter
//
//  Created by Sam Rijs on 11/20/13.
//  Copyright (c) 2013 Sam Rijs.
//
//  Syntax highlighting is based on:
//  - RegexHighlightView        - Copyright (c) 2012 Kristian Kraljic (dikrypt.com, ksquared.de)
//  - "Getting to Know TextKit" - objc.io Issue 5 - Max Seelemann
//

#import "NLTextStorage.h"

NSString *const kRegexHighlightViewTypeText                        = @"text";
NSString *const kRegexHighlightViewTypeBackground                  = @"background";
NSString *const kRegexHighlightViewTypeComment                     = @"comment";
NSString *const kRegexHighlightViewTypeDocumentationComment        = @"documentation_comment";
NSString *const kRegexHighlightViewTypeDocumentationCommentKeyword = @"documentation_comment_keyword";
NSString *const kRegexHighlightViewTypeString                      = @"string";
NSString *const kRegexHighlightViewTypeCharacter                   = @"character";
NSString *const kRegexHighlightViewTypeNumber                      = @"number";
NSString *const kRegexHighlightViewTypeKeyword                     = @"keyword";
NSString *const kRegexHighlightViewTypePreprocessor                = @"preprocessor";
NSString *const kRegexHighlightViewTypeURL                         = @"url";
NSString *const kRegexHighlightViewTypeAttribute                   = @"attribute";
NSString *const kRegexHighlightViewTypeProject                     = @"project";
NSString *const kRegexHighlightViewTypeOther                       = @"other";

@implementation NLTextStorage {

    NSMutableAttributedString *_imp;
    NSDictionary              *_theme;
    NSDictionary              *_definition;

}

- (id)init {
    self = [super init];
    if (self) {
        _imp        = [NSMutableAttributedString new];
        _theme      = [NLTextStorage theme];
        _definition = [NLTextStorage definition];
    }
    return self;
}

#pragma mark - Reading Text

- (NSString *)string {
    return _imp.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_imp attributesAtIndex:location effectiveRange:range];
}

#pragma mark - Text Editing

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [_imp replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [_imp setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

#pragma mark - Syntax highlighting

- (void)processEditing {

	NSRange paragaphRange = [self.string paragraphRangeForRange: self.editedRange];

    [self setAttributes:@{NSFontAttributeName:            [UIFont fontWithName:@"Menlo" size:14],
                          NSForegroundColorAttributeName: [UIColor blackColor]}
                  range:paragaphRange];

    for (NSString* key in _definition) {

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[_definition objectForKey:key]
                                                                               options:NSRegularExpressionDotMatchesLineSeparators error:nil];

        [regex enumerateMatchesInString:self.string options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            UIColor* textColor = [_theme objectForKey:key];
            [self addAttribute:NSForegroundColorAttributeName value:textColor range:result.range];
        }];

    }

    [super processEditing];

}

+ (NSDictionary *)definition {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Syntax" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:path];

}

+ (NSDictionary *)theme {

    return @{kRegexHighlightViewTypeText:                        [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],
             kRegexHighlightViewTypeBackground:                  [UIColor colorWithRed: 40.0/255 green: 43.0/255 blue: 52.0/255 alpha:1],
             kRegexHighlightViewTypeComment:                     [UIColor colorWithRed: 72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
             kRegexHighlightViewTypeDocumentationComment:        [UIColor colorWithRed: 72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
             kRegexHighlightViewTypeDocumentationCommentKeyword: [UIColor colorWithRed: 72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
             kRegexHighlightViewTypeString:                      [UIColor colorWithRed:230.0/255 green: 66.0/255 blue: 75.0/255 alpha:1],
             kRegexHighlightViewTypeCharacter:                   [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],
             kRegexHighlightViewTypeNumber:                      [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],
             kRegexHighlightViewTypeKeyword:                     [UIColor colorWithRed:195.0/255 green: 55.0/255 blue:149.0/255 alpha:1],
             kRegexHighlightViewTypePreprocessor:                [UIColor colorWithRed:211.0/255 green:142.0/255 blue: 99.0/255 alpha:1],
             kRegexHighlightViewTypeURL:                         [UIColor colorWithRed: 35.0/255 green: 63.0/255 blue:208.0/255 alpha:1],
             kRegexHighlightViewTypeAttribute:                   [UIColor colorWithRed:103.0/255 green:135.0/255 blue:142.0/255 alpha:1],
             kRegexHighlightViewTypeProject:                     [UIColor colorWithRed:146.0/255 green:199.0/255 blue:119.0/255 alpha:1],
             kRegexHighlightViewTypeOther:                       [UIColor colorWithRed:  0.0/255 green:175.0/255 blue:199.0/255 alpha:1]};

}

@end
