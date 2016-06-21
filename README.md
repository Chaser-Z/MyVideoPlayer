# 一个简单的视频播放器
## 用法:

```
var myPlayerView: MyVideoPlayView!
初始化方法
myPlayerView = MyVideoPlayView(frame: CGRectMake(0, 20, SCREENW, 200), urlString: "")   
urlString(播放视频的链接)

播放方法
self.myPlayerView.playVideo()
代理
self.myPlayerView.delegate = self
视频播放的容器
self.myPlayerView.contrainerViewController = self

移除播放器
self.myPlayerView.destoryAVPlayer()


```


## 结束:

```
目前还有许多不完善，可能还存在些bug，后期我会一一改正。希望多提意见，谢谢！

```


