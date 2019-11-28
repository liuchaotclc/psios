# 源码导读

## <span id="工程概述">工程概述</span>
入口页面为PSBrowserController，点击按钮打开PSPaintingSizeController选取画布尺寸。
获取返回尺寸创建画布并在页面PSCanvasController打开
PSCanvasController 有上下左右四处操作，上部为计时和设置等 左部操作颜色、大小。右部为图层操作 下部为不刷设置、图片导入、橡皮等。
画笔调整页面为PSBrushController，画笔选择为PSBrushesController
左部颜色滑块支持点击和拖动打开 点击弹出颜色列表，滑动弹出PSColorPickerController


## <span id="总体流程">总体流程</span>

画图的总体流程如下：
* PSBrowserController点击创建
* PSPaintingSizeController选取画布尺寸
* PSCanvasController画布画画页面，使用大小、Alpha调整画笔画画、图层、橡皮等完成创作
* PSCanvasController右上角设置点击保存到本地相册图片

## <span id="主要第三方库">主要第三方库</span>

* opengles 图层渲染效果
* IFMMenu 弹出悬浮菜单
* ZFPopupMenu 弹出横向悬浮菜单（swift语言）

### 工程结构说明

源码主要分成三个 package controllers、managers、view
- controllers：所有页面
- managers：图层、文件操作管理。
- view：自定义view 

下面具体介绍 videoEdit 包下的子包结构：
- 一级目录：PSAppDelegate
- controllers：控制器。
- Document Updates：数据传递。
- Serialization：文件缓存
- Managers: 操作图层等工具。
- Model：数据模型
- view：自定义view。

### 重点类说明

- PSCanvasController : 画布页面、左右弹出菜单在显示坐标之外，关闭页面的时候可以隐藏掉。
- PSBarSliderVertical：画笔大小滑块。
- ColorListChooseView: 颜色选择列表页面。
- RightLayerListView:图层操作View
- PSAlphaSliderVertical Alpha滑块
- PSActiveState 画布中所有状态、颜色等
# psios
