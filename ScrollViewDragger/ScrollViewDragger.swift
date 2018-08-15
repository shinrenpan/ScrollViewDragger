//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

// MARK: - Class

public final class ScrollViewDragger: NSObject
{
    public enum SwipeDirection
    {
        case minimum, maximum
    }

    public var dragble: Bool = true
    {
        didSet
        {
            __scrollView?.isScrollEnabled = !dragble
        }
    }

    public weak var delegate: DraggerDelegate?

    public private(set) var minimum: CGFloat
    public private(set) var maximum: CGFloat

    private var __pan: UIPanGestureRecognizer
    private weak var __constraint: NSLayoutConstraint?
    private weak var __scrollView: UIScrollView?

    public init(drag scrollView: UIScrollView,
                minimum: CGFloat,
                maximum: CGFloat,
                constraint: NSLayoutConstraint? = nil,
                delegate: DraggerDelegate? = nil)
    {
        __constraint = constraint
        dragble = true

        __scrollView = scrollView
        self.minimum = minimum
        self.maximum = maximum
        self.delegate = delegate

        __pan = UIPanGestureRecognizer()

        super.init()

        __pan.addTarget(self, action: #selector(__actionForPanGesture(_:)))
        __pan.delegate = self
        scrollView.addGestureRecognizer(__pan)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ScrollViewDragger: UIGestureRecognizerDelegate
{
    public func gestureRecognizer(_: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

// MARK: - Private

private extension ScrollViewDragger
{
    @objc final func __actionForPanGesture(_ pan: UIPanGestureRecognizer)
    {
        guard
            let scrollView: UIScrollView = pan.view as? UIScrollView,
            scrollView.isScrollEnabled == false,
            dragble == true
        else
        {
            return
        }

        if let constraint: NSLayoutConstraint = __constraint
        {
            __dragWithAutoLayout(in: scrollView, with: constraint)
        }
        else
        {
            __dragWithAutoResizing(in: scrollView)
        }
    }
}

private extension ScrollViewDragger
{
    final func __dragWithAutoLayout(in scrollView: UIScrollView, with constraint: NSLayoutConstraint)
    {
        switch __pan.state
        {
            case .began:
                delegate?.dragger(self, beganWith: constraint)

            case .changed:
                let translation = __pan.translation(in: scrollView)

                constraint.constant += translation.y

                if constraint.constant <= minimum
                {
                    __stop()
                }

                if constraint.constant >= maximum
                {
                    __stop()
                }

                __pan.setTranslation(.zero, in: scrollView)
                delegate?.dragger(self, changedWith: constraint)

            default:
                let velocity = __pan.velocity(in: scrollView)

                if __isQuickSwipe(for: velocity)
                {
                    let direction: SwipeDirection = __direction(for: velocity)
                    delegate?.dragger(self, swipeTo: direction, with: constraint)
                }
                else
                {
                    delegate?.dragger(self, endWith: constraint)
                }
        }
    }
}

private extension ScrollViewDragger
{
    final func __dragWithAutoResizing(in scrollView: UIScrollView)
    {
        switch __pan.state
        {
            case .began:
                delegate?.dragger(self, beganWith: nil)

            case .changed:
                let translation = __pan.translation(in: scrollView)

                scrollView.center.y += translation.y

                if scrollView.frame.origin.y <= minimum
                {
                    __stop()
                }

                if scrollView.frame.origin.y >= maximum
                {
                    __stop()
                }

                __pan.setTranslation(.zero, in: scrollView)
                delegate?.dragger(self, changedWith: nil)

            default:
                let velocity = __pan.velocity(in: scrollView)

                if __isQuickSwipe(for: velocity)
                {
                    let direction: SwipeDirection = __direction(for: velocity)
                    delegate?.dragger(self, swipeTo: direction, with: nil)
                }
                else
                {
                    delegate?.dragger(self, endWith: nil)
                }
        }
    }
}

private extension ScrollViewDragger
{
    final func __stop()
    {
        // 使用 _pan.isEnabled 來觸發 pan.state = .ended
        __pan.isEnabled = false
        __pan.isEnabled = true
    }
}

private extension ScrollViewDragger
{
    final func __isQuickSwipe(for velocity: CGPoint) -> Bool
    {
        let magnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        let slideMultiplier = magnitude / 200

        return slideMultiplier > 1.0
    }
}

private extension ScrollViewDragger
{
    // UIPanGestureRecognizer 滑動方向.
    // 參考 https://stackoverflow.com/questions/5187502/how-can-i-capture-which-direction-is-being-panned-using-uipangesturerecognizer
    final func __direction(for velocity: CGPoint) -> SwipeDirection
    {
        let isVertical = fabs(velocity.y) > fabs(velocity.x)

        var direction: SwipeDirection

        if isVertical
        {
            direction = velocity.y > 0 ? .maximum : .minimum
        }
        else
        {
            direction = velocity.x > 0 ? .maximum : .minimum
        }

        return direction
    }
}
