# TP-Link_SMBCloud_API
TP-Link 商用云平台开发者API（第三方维护版本）

## 项目声明
本项目，基于TP-LINK商用云平台 https://open.tp-link.com.cn/?from=nav 的《API文档》进行梳理，一切以官方文档为准。
**个人维护项目，对于准确性和及时性不做承诺，仅供参考。因使用本身体导致的任何损失概不负责。**

## 项目来由
由于TP-Link商云的开发者API文档没有changelog，发布新版本的时候也没有通知，下载的时候只能通过文件名后缀的YYYY-MM-DD来区分版本。为了便于开发维护基于TP-Link商云的功能，只能自己维护一套MARKDOWN（.md）格式的API文档，以及changelog。

再次声明： **最终请以TP-LINK商云文档为准** 

## 主要内容
- doc/ 包含各章节的md文档
- legacy/ 包含各历史版本的文档
- tools/ 生成md、对比用到的脚本，感兴趣的可以自行拿去修改使用
- CHANGELOG.md 修改记录
- INDEX.md API文档的目录

## 使用方法
changelog.md 可以便于开发者快速确认不同版本进行了哪些修改和变动。
doc/ 各章节的markdown内容，可以放在工程目录下，被agent调用。

## 反馈
- 如果有错误，可以提交pr；
- 如果有新的文档，可以提交issue。
- 如果您认为存在引用了

## 版权声明
本项目中由本人整理的 Changelog 和 Markdown 格式微调采用 MIT 协议开源，但文档中涉及的 API 接口定义、官方描述等核心内容的版权仍归原官方所有。
