# Scalemer Android fork 的修改记录

本仓库从 `Suwayomi/Tachidesk-Sorayomi` 的 `df37f4c` 提交创建，并移植了
`Scalemer/Tachidesk-Sorayomi` 中唯一的个人提交
`694150ac6d64955492c3e95026baae3998aad754` 的运行时行为。

## 实际修改的功能

个人提交的核心并不是章节切换动画，而是章节首次加载补偿：

- `MangaBookRepository.getChapterPages()` 第一次正常返回 `null` 或空 `pages`
  时，等待 1.5 秒并自动请求一次。
- 这用于处理部分 Suwayomi source 首次请求只预热章节缓存、过去必须退出阅读器再
  进入一次才会出现页面的问题。
- 第一次已经返回页面时不会重试；最多补偿一次。

另外保留了个人提交中的网络默认设置：

- 默认请求超时由 5 秒改为 30 秒。
- 默认开启超时自动重试。
- 超时后等待 1.5 秒，并最多额外尝试一次；每次请求都有完整的 30 秒超时。

这些默认值只影响尚未保存过对应设置的新安装/新配置。章节空页补偿则始终生效。

## 容易混淆的上游功能

末页滑动进入下一章、方向手势和章节切换动画来自上游提交 `95a2c58`，早于个人
提交，已经包含在本仓库的上游基线中，无需另外移植。

## 与原 iOS fork 的区别

原个人提交还添加了一个仅用于生成无签名 IPA 的 iOS workflow。Android 仓库没有
复制它，改为 `.github/workflows/android.yml`，用于测试并生成通用和分 ABI APK。

## 网络重试注意事项

HTTP 超时重试位于 GraphQL 客户端底层，因此也可能重放 mutation。首次空页补偿则
只作用于 `fetchChapterPages`。二者是独立机制；如果服务器端 mutation 不是幂等的，
可以在设置中关闭全局超时自动重试，章节空页补偿仍会保留。
