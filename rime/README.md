# 我的 Rime 配置

使用基于 [Rime 中州韵输入引擎](https://rime.im/)的输入法的配置文件夹。

输入方案采用[雾凇拼音](https://github.com/iDvel/rime-ice)，直接修改配置文件而没有使用 `patch` 。

macOS: 输入法为[鼠须管 - Squirrel](https://github.com/rime/squirrel)。

Android: 输入法为[小企鹅输入法](https://fcitx.cn)，加载 [Rime 插件](https://github.com/fcitx5-android/fcitx5-android)。

Windows: 用的很少，暂时没配置。

## 主要配置

目前就用全拼，删除双拼以及拆字相关的配置。
拆字很酷，但不习惯，生僻字百度一下，还可以问 AI 😄。

精简了一些用不到的配置。

### 字体与主题

使用 [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) 字体，打字时感觉一下就文艺起来了。

主题为 [Catppuccin](https://github.com/catppuccin/squirrel)，不知咋的，这款主题 22 年发现的，很戳我，
然后发现这个项目适配各种了软件，当发现软件能配置主题时，
就想着去项目主页搜一搜看有没有适配。

### 完全禁用用户词典

因为个人输入习惯的原因，有时莫名奇妙就打完拼音就直接空格了，如果启用用户词典的话，
词频会动态调整，有时就会输错了。而对于不在首选项的字，大概率是退格重新打再选一次。
虽然有点耗时，但根据个人习惯来看，日常使用中常用词就那么一些，打多了记住哪个字在第几个，
实在生僻的字输出的频率很低，到时再翻页找就行了。可能是以前微软标准输入法的症吧。

### 词库取舍

对于中文词库：

- custom: 自己添加的词组，不想放 custom_phrase 里，没权重也就没放 ext 中了。
- 8105: [保持原样](https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/cn_dicts/8105.dict.yaml)
- base: [保持原样](https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/cn_dicts/base.dict.yaml)
- others: [保持原样](https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/cn_dicts/others.dict.yaml)
- ext: 计算机科学相关的词库，取自搜狗词库并去重

其他词库一律舍弃。

对于英文词库：

- cn_en.txt: [保持原样](https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/en_dicts/cn_en.txt)
- en: [保持原样](https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/en_dicts/en.dict.yaml)
- en_ext: [保持原样](https://raw.githubusercontent.com/iDvel/rime-ice/refs/heads/main/en_dicts/en_ext.dict.yaml)

### 快捷键

启用 Emacs 风格的快捷键，又配置 `Ctrl-g` `Ctrl-[` 为 `escape` 键。

### `custom_phrase.txt`

自定义短语，包含个人信息，使用 `git-crypt` 加密。

可为方案增加一些要置顶的词汇及短语，
例如邮箱、手机号、常用短语等等。编码可以随便起，不限于拼音。
可以增加自己的 .txt 文件，并在方案的 custom_phrase/user_dict
指定为自己的文件。

以 Tab 分割：`词汇<Tab>编码<Tab>权重`

这个文件内的字词会占据最高权重（即排在候选项的最前面，
因为指定了权重 custom_phrase/initial_quality）。
但不与其他翻译器互相造词，如果使用了完整编码，
那么这个字或词将无法参与造词，即自造词无法被记住。
所以只建议固定非完整拼音的编码，
如果需求是置顶指定拼音的候选项，请参考方案中的 pin_cand_filter 。

```txt
# Rime table
# coding: utf-8
#@/db_name      custom_phrase.txt
#@/db_type      tabledb
#
#
# version: "2025-12-04"
#
# no comment

Rime    rime    4
鼠须管  rime    3
https://rime.im/        rime    2
Squirrel        rime    1

>       dy      2
≥       dy      1
<       xy      2
≤       xy      1
✔︎       correct 2
✗       wrong   2
×       times   2
÷       division        2
·       cdot    2
●       ldot    2
§       section 2

TODO    todo

# 修改了 symbol_v.yaml 的 `vi` -> `vii`
# 为了有时在终端没切输入法的可以打出 vi
# 不改的话没法生效，用 pin 固定也无效
vi      vi      9

# 个人信息
# ...

# 身边一些人的名字，不包含姓氏
# ...
```
