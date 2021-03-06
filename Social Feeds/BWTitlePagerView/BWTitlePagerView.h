//
// Created by Bruno Wernimont on 2014
// Copyright 2014 BWTitlePagerView
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

@interface BWTitlePagerView : UIView {
    BOOL _isObservingScrollView;
}

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *currentTintColor;
@property (nonatomic, strong) UIFont *font;

- (void)addObjects:(NSArray *)images;

- (void)observeScrollView:(UIScrollView *)scrollView;
- (NSInteger)getCurrentPage;
@end
