//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

// MARK: - Class

public final class ScrollViewDragger: NSObject
{
    public var draggable: Bool = true
    {
        didSet
        {
            scrollView?.isScrollEnabled = !draggable
        }
    }

    public weak var delegate: DraggerDelegate?
    public private(set) weak var constraint: NSLayoutConstraint?
    public private(set) weak var scrollView: UIScrollView?
    public private(set) var minimum: CGFloat
    public private(set) var maximum: CGFloat

    private var _pan: UIPanGestureRecognizer

    public init(
        scrollView: UIScrollView,
        minimum: CGFloat,
        maximum: CGFloat,
        constraint: NSLayoutConstraint? = nil,
        delegate: DraggerDelegate? = nil
    )
    {
        draggable = true
        self.constraint = constraint
        self.scrollView = scrollView
        self.minimum = minimum
        self.maximum = maximum
        self.delegate = delegate

        _pan = UIPanGestureRecognizer()

        super.init()

        _pan.addTarget(self, action: #selector(__handlePanGesture(_:)))
        _pan.delegate = self
        scrollView.addGestureRecognizer(_pan)
    }
}

// MARK: - Enum

public extension ScrollViewDragger
{
    public enum SwipeDirection
    {
        case minimum, maximum
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ScrollViewDragger: UIGestureRecognizerDelegate
{
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool
    {
        return true
    }
}

// MARK: - Handle PanGestureRecognizer

private extension ScrollViewDragger
{
    @objc final func __handlePanGesture(_ pan: UIPanGestureRecognizer)
    {
        if draggable == false
        {
            return
        }

        if scrollView?.isScrollEnabled == true
        {
            return
        }

        if let _ = constraint
        {
            __handleDragWithAutoLayout()
        }
        else
        {
            __handleDragWithAutoResizing()
        }
    }
}

// MARK: - Handle AutoLayout Drag

private extension ScrollViewDragger
{
    final func __handleDragWithAutoLayout()
    {
        guard
            let scrollView = scrollView,
            let constraint = constraint
        else
        {
            return
        }

        switch _pan.state
        {
            case .began:
                delegate?.draggerDidStartDrag(self)
            case .changed:
                let translation = _pan.translation(in: scrollView)

                constraint.constant += translation.y

                if constraint.constant <= minimum
                {
                    __stop()
                }

                if constraint.constant >= maximum
                {
                    __stop()
                }

                _pan.setTranslation(.zero, in: scrollView)
                delegate?.draggerDidChangeDrag(self)

            default:
                let velocity = _pan.velocity(in: scrollView)

                if __isQuickSwipe(for: velocity)
                {
                    let direction = __direction(for: velocity)
                    delegate?.dragger(self, quickSwipeTo: direction)
                }
                else
                {
                    delegate?.draggerDidFinishDrag(self)
                }
        }
    }
}

// MARK: - Handle AutoResizing Drag

private extension ScrollViewDragger
{
    final func __handleDragWithAutoResizing()
    {
        guard let scrollView = scrollView else
        {
            return
        }

        switch _pan.state
        {
            case .began:
                delegate?.draggerDidStartDrag(self)

            case .changed:
                let translation = _pan.translation(in: scrollView)

                scrollView.center.y += translation.y

                if scrollView.frame.origin.y <= minimum
                {
                    __stop()
                }

                if scrollView.frame.origin.y >= maximum
                {
                    __stop()
                }

                _pan.setTranslation(.zero, in: scrollView)
                delegate?.draggerDidChangeDrag(self)

            default:
                let velocity = _pan.velocity(in: scrollView)

                if __isQuickSwipe(for: velocity)
                {
                    let direction = __direction(for: velocity)
                    delegate?.dragger(self, quickSwipeTo: direction)
                }
                else
                {
                    delegate?.draggerDidFinishDrag(self)
                }
        }
    }
}

// MARK: - Private

private extension ScrollViewDragger
{
    final func __stop()
    {
        // 使用 _pan.isEnabled 來觸發 pan.state = .ended
        _pan.isEnabled = false
        _pan.isEnabled = true
    }

    final func __isQuickSwipe(for velocity: CGPoint) -> Bool
    {
        let magnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        let slideMultiplier = magnitude / 200

        return slideMultiplier > 1.0
    }

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
