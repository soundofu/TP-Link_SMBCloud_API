# TP-Link_SMBCloud_API

TP-LINK 商用云平台开放接口文档的第三方 Markdown 整理版。

当前文本抽取版本为 **2026-08-31**，详见 [doc/INDEX.md](doc/INDEX.md) 和 [CHANGELOG.md](CHANGELOG.md)。本项目不是 TP-LINK 官方项目，所有接口定义、字段说明、错误码和业务规则均以 TP-LINK 官方发布的文档为准。

## 项目说明

TP-LINK 商用云平台开放接口文档通常以 PDF 形式发布，历史版本之间没有官方 changelog。为了便于检索、对比版本差异，以及在开发时让编辑器、脚本或 Agent 快速定位接口说明，本仓库将 PDF 文档拆分为 Markdown 文本，并维护本地变更记录。

本仓库主要适合这些场景：

- 按接口 Path、章节标题或关键字快速检索文档；
- 查看相邻文档版本之间新增、删除、调整了哪些接口；
- 在开发项目中引用 Markdown 文档，减少直接阅读 PDF 的成本；
- 为后续新版本 PDF 的抽取和人工校对保留工具脚本。

## 仓库结构

| 路径 | 说明 |
|---|---|
| [doc/](doc/) | 2026-08-31 版本的 Markdown 文档正文和索引 |
| [doc/INDEX.md](doc/INDEX.md) | 章节/接口索引，可按 Path 或标题定位到具体文件和行号 |
| [doc/1.1-1.3-概述-鉴权-签名.md](doc/1.1-1.3-概述-鉴权-签名.md) | 概述、开发前准备、鉴权签名、接口规则 |
| `doc/1.4.01-*.md` ~ `doc/1.4.22-*.md` | 各业务 API 章节，一章一个文件 |
| [doc/1.5-错误码.md](doc/1.5-错误码.md) | 错误码说明 |
| [CHANGELOG.md](CHANGELOG.md) | 本地整理的官方文档版本差异记录 |
| [tools/](tools/) | PDF 抽取、章节对比、接口对比相关脚本 |
| [tools/README.md](tools/README.md) | 工具脚本的原始使用说明 |

当前仓库没有 `legacy/` 目录，也没有提交 PDF 原件；如需重新抽取或对比，请自行从官方渠道取得对应版本 PDF。

## 快速使用

### 按接口 Path 查找

例如查找 `getDeviceOnlineStatus`：

```bash
rg "getDeviceOnlineStatus" doc/INDEX.md
```

`INDEX.md` 的“位置”列会给出对应 Markdown 文件和行号，再打开相应章节阅读即可。

### 按关键字全文检索

```bash
rg "云存储" doc
rg "/tums/open/cloudStorage" doc
rg "错误码" doc/1.5-错误码.md
```

### 查看版本变化

优先阅读 [CHANGELOG.md](CHANGELOG.md)。该文件只记录文档本身的变化，例如新增接口、字段变化、错误码变化等；当前已整理：

- 2026-08-31 对比 2026-08-07；
- 2026-08-07 对比无日期初版的接口级补录。

## 文档范围

当前 `doc/` 覆盖这些章节：

- 1.1-1.3：概述、入门、鉴权、签名、协议；
- 1.4.01-1.4.22：AK/SK、分组管理、设备管理、设备配置、预览回放、HTTP-FLV 拉流、监控点报警、消息订阅、云录制、AI 图像检测分析、设备托管、客流统计、录像配置、车辆管理、水位管理、云存储、云广播、云停车、云门禁、充电管理、成员权限、国标设备；
- 1.5：错误码。

## 阅读注意事项

- Markdown 内容来自 `pdftotext -layout` 的文本抽取，参数表会保留 PDF 的原始列排版。遇到嵌套对象、跨页表格时，需要按列对齐理解。
- 原 PDF 中的截图和流程图没有完整保留，Markdown 通常只保留图里的文字。有疑问时请回到官方 PDF 核对。
- `doc/INDEX.md` 是检索入口，不是完整正文；完整接口参数、请求示例、返回示例在对应章节文件中。
- 本项目是个人整理版本，不保证准确性和及时性。生产环境开发、合同交付或故障排查时，请以 TP-LINK 官方文档和实际接口行为为准。

## 更新文档

`tools/` 中保留了抽取和对比脚本：

- `pdf2md.pl`：将 `pdftotext -layout` 输出拆分为章节 Markdown 和索引；
- `compare_sections.pl`：按小节比较两版文档差异；
- `compare_endpoints.pl`：按接口 Path 比较两版文档差异；
- `update.sh`：串联 PDF 转文本、生成 Markdown、输出对比报告。

注意：当前仓库结构为根目录 `tools/` + `doc/`，而工具脚本和 [tools/README.md](tools/README.md) 中仍保留了部分旧目录布局说明。复用脚本前，请先检查并按当前目录结构调整路径逻辑，尤其是 `update.sh` 中的 `DOC_DIR`、`ROOT` 推导，以及示例命令里的旧路径。

推荐的人工维护流程：

1. 从官方渠道下载新版 PDF，并确认文件名包含日期，例如 `TP-LINK商用云平台开放接口文档-YYYY-MM-DD.pdf`。
2. 使用工具脚本生成新版 Markdown 和对比报告。
3. 人工核对报告，剔除页码变化、PDF 排版错位等噪音。
4. 更新 [doc/](doc/) 下的章节文件和 [doc/INDEX.md](doc/INDEX.md)。
5. 在 [CHANGELOG.md](CHANGELOG.md) 顶部新增版本记录，说明新增/删除接口、已有接口变化、错误码变化。

## 反馈

如果发现文档抽取错误、版本差异遗漏，或有新的官方文档版本，可以提交 PR 或 issue。提交变更时建议同时说明来源文档版本、对比方式和人工核对结论。

## 版权声明

本项目中由维护者整理的 Markdown 微调内容、索引和 changelog 可按 MIT 协议使用；文档中涉及的 API 接口定义、官方描述、示例、错误码等核心内容版权仍归原官方所有。
