//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import ScrollViewDragger
import UIKit

final class WithAutoLayoutViewController: UIViewController
{
    private var _dragger: ScrollViewDragger?
    @IBOutlet private var _label: UILabel!
    @IBOutlet private var _tableView: UITableView!
    @IBOutlet private var _top: NSLayoutConstraint!
}

/// MARK: - LifeCycle
extension WithAutoLayoutViewController
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

extension WithAutoLayoutViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
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
        _label.text = "\(indexPath.row)"
    }
}

// MARK: - UIScrollViewDelegate

extension WithAutoLayoutViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Dragger 可以拖拉時, 執行 dragger 拖拉.
        if _dragger?.draggable == true
        {
            return
        }

        // 當 TableView 可以滾動, 且 _top 在最上方, 且向下滾到頂...
        // 就執行 dragger 拖拉.
        let offsetY = scrollView.contentOffset.y

        if offsetY < 0.0
        {
            _dragger?.draggable = true
        }
    }
}

// MARK: - ScrollViewDraggerDelegate

extension WithAutoLayoutViewController: DraggerDelegate
{
    func draggerDidFinishDrag(_ dragger: ScrollViewDragger)
    {
        if _top.constant < dragger.maximum / 2.0
        {
            // _top 回到最上方時, dragger 不能拖拉, 換能滾動 _tableView.
            dragger.draggable = false
            _top.constant = dragger.minimum
        }
        else
        {
            dragger.draggable = true
            _top.constant = dragger.maximum
        }

        UIView.animate(withDuration: 0.2)
        {
            self.view.layoutIfNeeded()
        }
    }

    func dragger(_ dragger: ScrollViewDragger, quickSwipeTo direction: ScrollViewDragger.SwipeDirection)
    {
        switch direction
        {
            case .minimum:
                dragger.draggable = false
                _top.constant = dragger.minimum

            case .maximum:
                dragger.draggable = true
                _top.constant = dragger.maximum
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
        _dragger = ScrollViewDragger(
            scrollView: _tableView,
            minimum: 44.0,
            maximum: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - _tableView.rowHeight,
            constraint: _top,
            delegate: self)

        _dragger?.draggable = false
    }
}
