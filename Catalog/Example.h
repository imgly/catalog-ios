@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface Example : NSObject

/// The view controller that this example is being invoked from.
@property (nonatomic, weak) UIViewController *presentingViewController;

- (void)invokeExample;

@end

NS_ASSUME_NONNULL_END
