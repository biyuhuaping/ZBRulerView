# ZBRulerView
金融类选择金额的游标尺

<p align="center">
<img src="https://img-blog.csdn.net/20180626172222930?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2JpeXVodWFwaW5n/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70">
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
