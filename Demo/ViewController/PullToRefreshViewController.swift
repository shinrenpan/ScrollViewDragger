//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import ScrollViewDragger
import UIKit

final class PullToRefreshViewController: UIViewController
{
    private var __dragger: ScrollViewDragger?
    @IBOutlet private var __label: UILabel!
    @IBOutlet private var __tableView: UITableView!
    @IBOutlet private var __top: NSLayoutConstraint!
}

// MARK: - LifeCycle

extension PullToRefreshViewController
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

extension PullToRefreshViewController: UITableViewDataSource
{
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int
    {
        return Int(arc4random() % 20) + 20
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

extension PullToRefreshViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        __label.text = "Clicked at \(indexPath.row)"
    }
}

// MARK: - UIScrollViewDelegate

extension PullToRefreshViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Dragger 可以拖拉時, 執行 dragger 拖拉.
        if __dragger?.dragble == true
        {
            return
        }

        // 回到 tableView 可以滾動時.
        let offsetY: CGFloat = scrollView.contentOffset.y

        // 當 TableView 可以滾動, 且 __top 在最上方, 且向下滾到頂...
        // 就執行 dragger 拖拉.
        if
            __top.constant <= __dragger?.minimum ?? 0,
            offsetY < 0.0
        {
            __dragger?.dragble = true
        }

        // 當 TableView 可以滾動, 且 __top 在最下方, 請向上滾到頂...
        // 就執行 dragger 拖拉.
        if
            __top.constant >= __dragger?.maximum ?? 0,
            offsetY > 0.0
        {
            __dragger?.dragble = true
        }
    }
}

// MARK: - ScrollViewDraggerDelegate

extension PullToRefreshViewController: ScrollViewDraggerDelegate
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

        dragger.dragble = false

        if constraint.constant < dragger.maximum / 2.0
        {
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

private extension PullToRefreshViewController
{
    final func __setupDragger()
    {
        __tableView.refreshControl = {
            let temp: UIRefreshControl = UIRefreshControl()
            temp.addTarget(self, action: #selector(__pullToRefresh(_:)), for: .valueChanged)

            return temp
        }()

        let minimum: CGFloat = 44.0
        let maximum: CGFloat = 100.0

        __dragger = ScrollViewDragger(drag: __tableView,
                                      minimum: minimum,
                                      maximum: maximum,
                                      constraint: __top,
                                      delegate: self)

        __dragger?.dragble = false
    }
}

private extension PullToRefreshViewController
{
    @objc final func __pullToRefresh(_ sender: UIRefreshControl)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
        {
            sender.endRefreshing()
            self.__tableView.reloadData()
        }
    }
}
