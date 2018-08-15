//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import ScrollViewDragger
import UIKit

final class WithAutoResizeViewController: UIViewController
{
    private var __dragger: ScrollViewDragger?
    @IBOutlet private var __label: UILabel!
    @IBOutlet private var __tableView: UITableView!
}

// MARK: - LifeCycle

extension WithAutoResizeViewController
{
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        if __dragger == nil
        {
            __setupDragger()
        }
    }
}

// MARK: - UITableViewDataSource

extension WithAutoResizeViewController: UITableViewDataSource
{
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int
    {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        else
        {
            fatalError()
        }

        cell.textLabel?.text = "\(indexPath.row)"

        return cell
    }
}

// MARK: - UITableViewDelegate

extension WithAutoResizeViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        __label.text = "Clicked at \(indexPath.row)"
    }
}

// MARK: - UIScrollViewDelegate

extension WithAutoResizeViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Dragger 可以拖拉時, 執行 dragger 拖拉.
        if __dragger?.dragble == true
        {
            return
        }

        // 當 TableView 可以滾動, 且 top 在最上方, 且向下滾到頂...
        // 就執行 dragger 拖拉.
        let offsetY: CGFloat = scrollView.contentOffset.y

        if offsetY < 0.0
        {
            __dragger?.dragble = true
        }
    }
}

// MARK: - ScrollViewDraggerDelegate

extension WithAutoResizeViewController: DraggerDelegate
{
    func dragger(_ dragger: ScrollViewDragger, endWith _: NSLayoutConstraint?)
    {
        var frame: CGRect = __tableView.frame

        if frame.origin.y < dragger.maximum / 2.0
        {
            // __top 回到最上方時, dragger 不能拖拉, 換能滾動 __tableView.
            dragger.dragble = false
            frame.origin.y = dragger.minimum
        }
        else
        {
            frame.origin.y = dragger.maximum
        }

        UIView.animate(withDuration: 0.2)
        {
            self.__tableView.frame = frame
        }
    }

    func dragger(_ dragger: ScrollViewDragger,
                 swipeTo direction: ScrollViewDragger.SwipeDirection,
                 with _: NSLayoutConstraint?)
    {
        var frame: CGRect = __tableView.frame

        switch direction
        {
            case .minimum:
                dragger.dragble = false
                frame.origin.y = dragger.minimum

            case .maximum:
                frame.origin.y = dragger.maximum
        }

        UIView.animate(withDuration: 0.2)
        {
            self.__tableView.frame = frame
        }
    }
}

// MARK: - Private

private extension WithAutoResizeViewController
{
    final func __setupDragger()
    {
        let minimum: CGFloat = 108.0

        let maximum: CGFloat = {
            view.bounds.height - view.safeAreaInsets.bottom - __tableView.rowHeight
        }()

        __dragger = ScrollViewDragger(drag: __tableView,
                                      minimum: minimum,
                                      maximum: maximum,
                                      delegate: self)

        __dragger?.dragble = false
    }
}
