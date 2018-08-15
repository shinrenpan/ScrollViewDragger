實現 Apple Map 或是 Google Map, 可以拖拉 TableView 的效果.  
詳請參考 [Demo](Demo).

## 安裝 ##
使用 Carthage.


## 使用 ##



### 初始化 ###

```swift
init(drag scrollView: UIScrollView,
     minimum: CGFloat,
     maximum: CGFloat,
     constraint: NSLayoutConstraint? = nil,
     delegate: ScrollViewDraggerDelegate? = nil)
```

scrollView: 代表要拖動的 ScrollerView.

minimum: 代表能拖動的最小值, 水平拖動應該代表 x 最小值, 垂直拖動應該代表 y 最小值.

maximum: 代表能拖動的最大值, 水平拖動應該代表 x 最大值, 垂直拖動應該代表 y 最大值.

constraint: 代表是否使用 AutoLayout, 有值代表使用 AutoLayout, 無值代表使用AutoResizing.

delegate: drager delegation.



###  控制拖動 ###
使用 dragble = true / false 來控制拖動.  
例如:

```swift
let dragger = ...

// Scroller 可以拖動, 不能捲動.
dragger.dragble = true

// Scroller 可以捲動, 不能拖動.
dragger.dragble = false
```



### Delegation ###

**Dragger 開始拖動**

```swift
func dragger(_ dragger: ScrollViewDragger, beganWith constraint: NSLayoutConstraint?)
```

**Dragger 正在拖動**

```swift
func dragger(_ dragger: ScrollViewDragger, changedWith constraint: NSLayoutConstraint?)
```

**Dragger 拖動結束**  
可能觸發的原因:

1. 拖動超過 minimum 或 maximum.
2. 拖動手勢不是 UIGestureRecognizerState.began 或是 UIGestureRecognizerState.changed

```swift
func dragger(_ dragger: ScrollViewDragger, endWith constraint: NSLayoutConstraint?)
```

**Dragger 快速滑動**  
當 Dragger 快速滑動時, 將觸發這個 function, 而不是拖動結束,  

ScrollViewDragger.SwipeDirection 代表:

1. minimum: 快速滑向最小值方向.
2. maximum: 快速滑向最大值方向.

```swift
func dragger(_ dragger: ScrollViewDragger,
             swipeTo direction: ScrollViewDragger.SwipeDirection,
             with constraint: NSLayoutConstraint?)
```
