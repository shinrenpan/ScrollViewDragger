//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import ScrollViewDragger
import UIKit

final class PullToRefreshViewController: UIViewController
{
    private var _dragger: ScrollViewDragger?
    @IBOutlet private var _label: UILabel!
    @IBOutlet private var _tableView: UITableView!
    @IBOutlet private var _top: NSLayoutConstraint!
}

// MARK: - LifeCycle

extension PullToRefreshViewController
{
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()

        if _dragger == nil
        {
            __setupDragger()
        }
    }
}

// MARK: - UITableViewDataSource

extension PullToRefreshViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Int(arc4random() % 20) + 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
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
        _label.text = "\(indexPath.row)"
    }
}

// MARK: - UIScrollViewDelegate

extension PullToRefreshViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Dragger 可以拖拉時, 執行 dragger 拖拉.
        if _dragger?.draggable == true
        {
            return
        }

        // 回到 tableView 可以滾動時.
        let offsetY = scrollView.contentOffset.y

        // 當 TableView 可以滾動, 且 _top 在最上方, 且向下滾到頂...
        // 就執行 dragger 拖拉.
        if
            _top.constant <= _dragger?.minimum ?? 0,
            offsetY < 0.0
        {
            _dragger?.draggable = true
        }

        // 當 TableView 可以滾動, 且 _top 在最下方, 請向上滾到頂...
        // 就執行 dragger 拖拉.
        if
            _top.constant >= _dragger?.maximum ?? 0,
            offsetY > 0.0
        {
            _dragger?.draggable = true
        }
    }
}

// MARK: - ScrollViewDraggerDelegate

extension PullToRefreshViewController: DraggerDelegate
{
    func dragger(_ dragger: ScrollViewDragger, quickSwipeTo direction: ScrollViewDragger.SwipeDirection)
    {
        dragger.draggable = false

        switch direction
        {
            case .minimum:
                _top.constant = dragger.minimum
            case .maximum:
                _top.constant = dragger.maximum
        }

        UIView.animate(withDuration: 0.2)
        {
            self.view.layoutIfNeeded()
        }
    }

    func draggerDidFinishDrag(_ dragger: ScrollViewDragger)
    {
        dragger.draggable = false

        if _top.constant < dragger.maximum / 2.0
        {
            _top.constant = dragger.minimum
        }
        else
        {
            _top.constant = dragger.maximum
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
        _tableView.refreshControl = {
            let result = UIRefreshControl()
            result.addTarget(self, action: #selector(__pullToRefresh(_:)), for: .valueChanged)
            return result
        }()

        _dragger = ScrollViewDragger(
            scrollView: _tableView,
            minimum: 44,
            maximum: 100,
            constraint: _top,
            delegate: self
        )

        _dragger?.draggable = false
    }

    @objc
    final func __pullToRefresh(_ sender: UIRefreshControl)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
        {
            sender.endRefreshing()
            self._tableView.reloadData()
        }
    }
}
