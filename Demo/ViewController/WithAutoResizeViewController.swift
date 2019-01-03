//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import ScrollViewDragger
import UIKit

final class WithAutoResizeViewController: UIViewController
{
    private var _dragger: ScrollViewDragger?
    @IBOutlet private var _label: UILabel!
    @IBOutlet private var _tableView: UITableView!
}

// MARK: - LifeCycle

extension WithAutoResizeViewController
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

extension WithAutoResizeViewController: UITableViewDataSource
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

extension WithAutoResizeViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        _label.text = "\(indexPath.row)"
    }
}

// MARK: - UIScrollViewDelegate

extension WithAutoResizeViewController: UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Dragger 可以拖拉時, 執行 dragger 拖拉.
        if _dragger?.draggable == true
        {
            return
        }

        // 當 TableView 可以滾動, 且 top 在最上方, 且向下滾到頂...
        // 就執行 dragger 拖拉.
        let offsetY = scrollView.contentOffset.y

        if offsetY < 0.0
        {
            _dragger?.draggable = true
        }
    }
}

// MARK: - ScrollViewDraggerDelegate

extension WithAutoResizeViewController: DraggerDelegate
{
    func draggerDidFinishDrag(_ dragger: ScrollViewDragger)
    {
        var frame = _tableView.frame

        if frame.origin.y < dragger.maximum / 2.0
        {
            // 回到最上方時, dragger 不能拖拉, 換能滾動 _tableView.
            dragger.draggable = false
            frame.origin.y = dragger.minimum
        }
        else
        {
            dragger.draggable = true
            frame.origin.y = dragger.maximum
        }

        UIView.animate(withDuration: 0.2)
        {
            self._tableView.frame = frame
        }
    }

    func dragger(_ dragger: ScrollViewDragger, quickSwipeTo direction: ScrollViewDragger.SwipeDirection)
    {
        var frame = _tableView.frame

        switch direction
        {
            case .minimum:
                dragger.draggable = false
                frame.origin.y = dragger.minimum

            case .maximum:
                dragger.draggable = true
                frame.origin.y = dragger.maximum
        }

        UIView.animate(withDuration: 0.2)
        {
            self._tableView.frame = frame
        }
    }
}

// MARK: - Private

private extension WithAutoResizeViewController
{
    final func __setupDragger()
    {
        _dragger = ScrollViewDragger(
            scrollView: _tableView,
            minimum: 108,
            maximum: view.bounds.height - view.safeAreaInsets.bottom - _tableView.rowHeight,
            delegate: self
        )

        _dragger?.draggable = false
    }
}
