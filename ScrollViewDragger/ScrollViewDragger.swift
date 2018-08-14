//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

// MARK: - Protocol

public protocol ScrollViewDraggerDelegate: class
{
    func dragger(_ dragger: ScrollViewDragger, beganIn scrollView: UIScrollView, constraint: NSLayoutConstraint?)

    func dragger(_ dragger: ScrollViewDragger, changedIn scrollView: UIScrollView, constraint: NSLayoutConstraint?)

    func dragger(_ dragger: ScrollViewDragger, endIn scrollView: UIScrollView, constraint: NSLayoutConstraint?)
}

// MARK: - Class

public final class ScrollViewDragger: NSObject
{
    public var dragble: Bool = true
    {
        didSet
        {
            __scrollView?.isScrollEnabled = !dragble
        }
    }

    public weak var delegate: ScrollViewDraggerDelegate?

    public private(set) var minimum: CGFloat
    public private(set) var maximum: CGFloat

    private var __pan: UIPanGestureRecognizer

    private weak var __scrollView: UIScrollView?
    private weak var __constraint: NSLayoutConstraint?

    public init(drag scrollView: UIScrollView,
                minimum: CGFloat,
                maximum: CGFloat,
                constraint: NSLayoutConstraint? = nil,
                delegate: ScrollViewDraggerDelegate? = nil)
    {
        __scrollView = scrollView
        __constraint = constraint
        dragble = true

        self.minimum = minimum
        self.maximum = maximum
        self.delegate = delegate

        __pan = UIPanGestureRecognizer()

        super.init()

        __pan.addTarget(self, action: #selector(__panGestureInScroller(_:)))
        __pan.delegate = self
        __scrollView?.addGestureRecognizer(__pan)
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
    @objc final func __panGestureInScroller(_ pan: UIPanGestureRecognizer)
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
            __handleDragWithAutoLayout(scrollView, with: constraint)
        }
        else
        {
            __handleDragWithAutoResizing(scrollView)
        }
    }
}

private extension ScrollViewDragger
{
    final func __handleDragWithAutoLayout(_ scrollView: UIScrollView, with constraint: NSLayoutConstraint)
    {
        switch __pan.state
        {
            case .began:
                delegate?.dragger(self, beganIn: scrollView, constraint: constraint)

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
                delegate?.dragger(self, changedIn: scrollView, constraint: constraint)

            default:
                delegate?.dragger(self, endIn: scrollView, constraint: constraint)
        }
    }
}

private extension ScrollViewDragger
{
    final func __handleDragWithAutoResizing(_ scrollView: UIScrollView)
    {
        switch __pan.state
        {
            case .began:
                delegate?.dragger(self, beganIn: scrollView, constraint: nil)

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
                delegate?.dragger(self, changedIn: scrollView, constraint: nil)

            default:
                delegate?.dragger(self, endIn: scrollView, constraint: nil)
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
