//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

public protocol DraggerDelegate: class
{
    func dragger(_ dragger: ScrollViewDragger, beganWith constraint: NSLayoutConstraint?)

    func dragger(_ dragger: ScrollViewDragger, changedWith constraint: NSLayoutConstraint?)

    func dragger(_ dragger: ScrollViewDragger, endWith constraint: NSLayoutConstraint?)

    func dragger(_ dragger: ScrollViewDragger,
                 swipeTo direction: ScrollViewDragger.SwipeDirection,
                 with constraint: NSLayoutConstraint?)
}

// Swift optional function 寫法, 不需要再使用 @objc
// 參考 https://medium.com/@ant_one/how-to-have-optional-methods-in-protocol-in-pure-swift-without-using-objc-53151cddf4ce
public extension DraggerDelegate
{
    func dragger(_: ScrollViewDragger, beganWith _: NSLayoutConstraint?) {}

    func dragger(_: ScrollViewDragger, changedWith _: NSLayoutConstraint?) {}

    func dragger(_: ScrollViewDragger, endWith _: NSLayoutConstraint?) {}

    func dragger(_: ScrollViewDragger,
                 swipeTo _: ScrollViewDragger.SwipeDirection,
                 with _: NSLayoutConstraint?) {}
}
