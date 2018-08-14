//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import ScrollViewDragger
import UIKit

final class WithAutoLayoutViewController: UIViewController
{
    private var __dragger: ScrollViewDragger?
    @IBOutlet private var __label: UILabel!
    @IBOutlet private var __tableView: UITableView!
    @IBOutlet private var __top: NSLayoutConstraint!
}

/// MARK: - LifeCycle
extension WithAutoLayoutViewController
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

extension WithAutoLayoutViewController: UITableViewDataSource
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

extension WithAutoLayoutViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        __label.text = "Clicked at \(indexPath.row)"
    }
}

// MARK: - UIScrollViewDelegate

extension WithAutoLayoutViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Dragger 可以拖拉時, 執行 dragger 拖拉.
        if __dragger?.dragble == true
        {
            return
        }

        // 當 TableView 可以滾動, 且 __top 在最上方, 且向下滾到頂...
        // 就執行 dragger 拖拉.
        let offsetY: CGFloat = scrollView.contentOffset.y

        if offsetY < 0.0
        {
            __dragger?.dragble = true
        }
    }
}

// MARK: - ScrollViewDraggerDelegate

extension WithAutoLayoutViewController: ScrollViewDraggerDelegate
{
    func dragger(_: ScrollViewDragger, beganIn _: UIScrollView, constraint _: NSLayoutConstraint?)
    {
    }

    func dragger(_: ScrollViewDragger, changedIn _: UIScrollView, constraint _: NSLayoutConstraint?)
    {
    }

    func dragger(_ dragger: ScrollViewDragger, endIn _: UIScrollView, constraint: NSLayoutConstraint?)
    {
        // 使用 Autolayout 一定有 constraint.
        guard let constraint: NSLayoutConstraint = constraint
        else
        {
            return
        }

        if constraint.constant < dragger.maximum / 2.0
        {
            // __top 回到最上方時, dragger 不能拖拉, 換能滾動 __tableView.
            dragger.dragble = false
            constraint.constant = dragger.minimum
        }
        else
        {
            constraint.constant = dragger.maximum
        }

        UIView.animate(withDuration: 0.2)
        {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Private

private extension WithAutoLayoutViewController
{
    final func __setupDragger()
    {
        let minimum: CGFloat = 44.0

        // __top 最大值是下方保留 __tableView 高.
        let maximum: CGFloat = {
            view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - __tableView.rowHeight
        }()

        __dragger = ScrollViewDragger(drag: __tableView,
                                      minimum: minimum,
                                      maximum: maximum,
                                      constraint: __top,
                                      delegate: self)

        __dragger?.dragble = false
    }
}
