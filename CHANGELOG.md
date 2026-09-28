# TP-LINK 商云开放接口文档 本地变更记录

TP-LINK 官方不提供 changelog，本文件由本地对比相邻两版 PDF 得出，最新版本在最上面。

- **本文件只记录文档本身的变动**。某个版本对本工程代码有什么影响，另见 [changelog_infect.md](changelog_infect.md)。
- 每次有新版文档时，按 [README.md](README.md) 中"新版文档到来时"的流程生成对比报告，然后在本文件**顶部**新增一节。
- 每节固定包含：结论、新增/删除接口、现有章节改动、错误码。

| 版本 | 本地文件 | 入库日期 |
|---|---|---|
| 2026-08-31 | `doc/TP-LINK商用云平台开放接口文档-2026-08-31.pdf` | 2026-09-28，**当前权威版本** |
| 2026-08-07 | `doc/TP-LINK商用云平台开放接口文档-2026-08-07.pdf` | 2026-08-29 |
| （无日期） | `doc/TP-LINK商用云平台开放接口文档.pdf` | 2026-05-19 前后 |

---

## [2026-08-31] 对比 2026-08-07

> 对比日期：2026-09-28

### 结论

- 没有删除或改名任何接口 Path。旧版 205 个，新版 244 个，新增 39 个。
- 签名/鉴权章节（1.1–1.3）没有变化。
- 已有接口中只有 `createTempApplicationApiCredential` 的参数有变化，而且是向后兼容的新增；其余已有接口只有页码和章节号变了。
- 错误码只增不删，新增 43 个。

### 新增接口

| 章节 | 接口 | 说明 |
|---|---|---|
| 1.4.1.2–1.4.1.6 | `/tums/open/credentialManager/v1/createPolicy` `batchDeletePolicy` `editPolicy` `getPolicyDetail` `queryPolicyList` | 权限策略，用来限定临时 AK/SK 能调用哪些接口 |
| 1.4.3.3.12 | — | 设备固件升级说明（流程说明，不是接口） |
| 1.4.3.3.19 | `/tums/open/deviceManager/v1/getDeviceOnlineStatus` | 查询设备的在线状态 |
| 1.4.16 | `/tums/open/cloudStorage/v1/getEventListByPage` `getEventCalendar` `getEventIndexesByPage` `deleteEvents` `getEventCountOfDate`，`/tums/open/skm/v1/getDecryptKey` | **云存储**（新章节）：录像事件列表、事件日历、事件索引、批量删除事件、查询解密密钥 |
| 1.4.17 | `/tums/open/broadcastManager/v1/*`（22 个），`/tums/open/broadcastDeviceManager/v1/*`（4 个） | **云广播**（新章节）：定时/实时/喊话任务、素材库、文字转语音、音箱管理 |

新增章节插在原 1.4.16 之前，所以原来的 1.4.16 云停车到 1.4.20 国标设备都往后顺延了 2 号，现在是 1.4.18–1.4.22。

### 现有章节的改动

| 章节 | 改动 |
|---|---|
| 1.4.1.1 生成临时 AK/SK | 请求参数新增两个可选项：`policyIdList`（最多 10 个）限定可调用的接口，`devList`（最多 100 个）限定可访问的设备。两者都不传时，可以调用全部接口、访问全部设备，和原来一样。返回结果里会回显这两个字段。`expireTime` 的类型标注从 long 改成 int，取值范围仍是 [1, 86400] |
| 1.4.3.3.6 能力集说明 | IPC 能力集新增 `cloud_storage_version` 字段：字段不存在表示不支持云存储，"1.0" 及以上表示支持云存储录像 |
| 1.4.3.3.13–15 固件升级 | 补充了 `upgradestatus` / `resetUpgradeResult` 的用法说明 |
| 1.4.8.8 msgContentType | 网络设备报警新增 `deviceReset`（设备重置） |
| 1.4.10 AI 图像检测 | 回调、查询、删除接口的说明里，补充了"通过上传图片批量执行 AI 巡检任务"这种情况 |
| 1.4.18 云停车 | 车牌颜色/车主类型枚举增加了 black、other_plate、tenant 等值 |
| 1.4.18 云停车 | PDF 正文的小节编号和目录不一致，比如正文写 1.4.18.8，目录写 1.4.18.4。这是原文的问题 |
| 1.4.20 充电管理 | 去掉了原文里"错误！未找到引用源"的残留 |

### 错误码

新增 43 个，没有删除：

- `-111004`~`-111034`（部分编号）：云广播，涉及音频、素材、任务
- `-594061`~`-594066`、`-594081`：云存储，涉及容量、文件、服务到期
- `-83300`~`-83312`：任务类，比如任务不存在、任务正忙、设备被高优先级任务占用
- 其他：
  - `-20503` 设备未绑定账号，解绑失败
  - `-80603` 设备返回错误
  - `-81604` 名称已存在
  - `-82129` 余额不足
  - `-88308` 非项目型应用

完整列表见 [1.5-错误码.md](1.5-错误码.md)。

---

## [2026-08-07] 对比无日期初版（补录）

> 补录日期：2026-09-28。这一节**只做接口级补录，没有逐字段复核**。如果需要追溯某个接口的历史变化，重新运行 `update.sh <08-07 PDF> <无日期 PDF> --compare-only` 查看报告。

### 结论

- 没有删除任何接口 Path。旧版 154 个，新版 205 个，新增 51 个。
- 错误码的编号没有增删。
- 章节结构有调整：原 1.4.10 云录制前移为 1.4.9，又新增了多个章节，所以从这里往后的章节号都变了。

### 新增接口（按章节）

- **1.4.3 设备管理**：
  - 通过二维码添加设备到指定分组：`bindDeviceIntoRegionByQrCode`
  - 智能开局/设备发现绑定：`/tums/open/smartstart/v1/*`，共 3 个
  - 修改 IPC 网络配置：`setDeviceIpAddr`
- **1.4.4 设备配置**：
  - 云台：`absoluteMove`、`getPtzStatus`、`getZoomLimitConfig`
  - 低功耗设备：唤醒、功耗模式、功耗计划，`/vms/open/deviceManager/v1/*`，共 6 个
  - 植被指数检测：`/openapi/opAgriDeviceManager/v1/*`，共 3 个
- **1.4.10 AI 图像检测分析**（新章节）：`/openapi/aiInspection/v1/*`，`/openapi/algorithmProduct/v1/getStandardAlgorithmBasicInfo`
- **1.4.11 设备托管**（新章节）：`/tums/open/deviceEntrust/v1/*`，共 7 个
- **1.4.12 客流统计**：`getFlowOverview`、`getFlowList`、`getFlowDistribution`
- **1.4.13 录像配置**（新章节）：`/tums/open/record/v1/*`，共 7 个
- **1.4.15 水位管理**（新章节）：`/vms/open/waterLevelManager/v1/*`，共 3 个
- **1.4.17 云门禁**：`/ams/open/deviceManager/v1/getAmsDeviceExtendInfo`
- **1.4.19 成员权限**（新章节）：`/tums/open/account/v1/*`，共 7 个
- **国标设备**（新章节）

### 现有章节的改动（接口级）

- 设备管理、云台、预览回放类接口新增了可选参数 `deviceGbId` / `sipServerId`，只用于国标设备。
- `submitCaptureVideoTask` 新增 `liveRecordEndTime`，只在 type=101（实时录像）时必填。
- 云录制章节（1.4.9）的说明文字改动较多，还没有逐条整理。
