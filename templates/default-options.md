# MAA 默认选项（用户偏好）

> 用户指定的默认选项（写入时间：2026-08-28）。运行 MAA 任务时默认采用以下设置；
> 具体任务可在此基础上覆盖。可直接使用的任务模板见同目录 `default-options.toml`。

## 理智作战（Fight）

| 选项 | 值 | MAA 参数 |
| --- | --- | --- |
| 使用药剂 | 0 | `medicine = 0` |
| 使用源石 | 0 | `stone = 0` |

## 基建换班（Infrast）

| 选项 | 值 | MAA 参数 |
| --- | --- | --- |
| 基建模式 | 队列轮换（Rotation） | `mode = 20000` |
| 无人机 | 不使用 | `drones = "_NotUse"` |
| 源石碎片自动补货 | true | `replenish = true` |
| 会客室信息板收取信用 | true | `reception_message_board = true` |
| 进行线索交流 | true | `reception_clue_exchange = true` |
| 赠送线索 | false | `reception_send_clue = false` |
| 训练完成后继续尝试专精当前技能 | false | `continue_training = false` |

> 注：`continue_training` 对应 MAA GUI「基建-训练室是否尝试连续专精」（MaaCore Infrast 任务参数，
> 见 MaaWpfGui `AsstInfrastTask.cs` 序列化的 `continue_training` 键）。队列轮换模式下会跳过
> 控制中枢/发电站/宿舍/办公室，`facility` 建议在 Mfg/Trade/Reception/Processing/Training 中选取。

## 自动肉鸽（Roguelike）

| 选项 | 值 | MAA 参数 |
| --- | --- | --- |
| 开始探索 N 次后停止任务 | 2 | `starts_count = 2` |
| 满级后自动停止 | true | `stop_at_max_level = true` |
