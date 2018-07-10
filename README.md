# ZBRulerView
金融类选择金额的游标尺

<p align="center">
<img src="https://upload-images.jianshu.io/upload_images/5132421-d8439eede1d017e3.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/398">
</p>


## 用法

```objective-c
#import "ZBRulerView.h"

...

ZBRulerView *rulerView = [[ZBRulerView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.frame), 100)];
rulerView.minAmount = 100;
[self.view addSubview:rulerView];

或在xib中设置ZBRulerView。
```
