//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

public protocol DraggerDelegate: class
{
    func draggerDidStartDrag(_ dragger: ScrollViewDragger)
    func draggerDidChangeDrag(_ dragger: ScrollViewDragger)
    func draggerDidFinishDrag(_ dragger: ScrollViewDragger)
    func dragger(_ dragger: ScrollViewDragger, quickSwipeTo direction: ScrollViewDragger.SwipeDirection)
}

public extension DraggerDelegate
{
    func draggerDidStartDrag(_ dragger: ScrollViewDragger) {}
    func draggerDidChangeDrag(_ dragger: ScrollViewDragger) {}
    func draggerDidFinishDrag(_ dragger: ScrollViewDragger) {}
    func dragger(_ dragger: ScrollViewDragger, quickSwipeTo direction: ScrollViewDragger.SwipeDirection) {}
}
