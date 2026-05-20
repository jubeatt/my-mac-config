# Kiro CLI 多代理工作流使用指南

## 1. 系統概覽

這是一套基於 Kiro CLI 的多代理系統。`code_supervisor` 是主要的協調者，負責拆解任務、分派子代理、管控品質迴圈。另有 `light` 代理用於快速問答與小型變更。

## 2. Agent 一覽

| Agent           | 角色                       | Model           |
| --------------- | -------------------------- | --------------- |
| code_supervisor | 任務協調與品質管控         | claude-opus-4.6 |
| light           | 通用助手，快速任務         | claude-opus-4.6 |
| planner         | 結構化執行計畫產生器       | claude-opus-4.6 |
| developer       | 程式碼實作                 | claude-opus-4.6 |
| reviewer        | 程式碼審查 + YAGNI 執行者  | claude-opus-4.6 |
| designer        | Figma 設計擷取 + UI/UX     | claude-opus-4.6 |
| simplifier      | 程式碼精煉                 | claude-opus-4.6 |
| tester          | 測試撰寫（僅在明確要求時） | claude-opus-4.6 |
| debugger        | 深度調查持續性 bug         | claude-opus-4.6 |
| explorer        | 程式碼庫探索與研究         | claude-opus-4.6 |
| researcher      | 學術論文研究               | claude-opus-4.6 |
| council-master  | 綜合議員回應               | claude-opus-4.6 |
| councillor-a    | 議會顧問                   | claude-opus-4.6 |
| councillor-b    | 議會顧問                   | glm-5           |
| councillor-c    | 議會顧問                   | claude-opus-4.5 |

## 3. 工作流程

`code_supervisor` 遵循 8 階段工作流：

| 階段 | 名稱                             | 說明                                                   |
| ---- | -------------------------------- | ------------------------------------------------------ |
| 1    | Understand                       | 理解需求，確認範圍                                     |
| 2    | Path Selection                   | 判斷任務複雜度，選擇直接執行或完整流程                 |
| 3    | Delegation Check                 | 決定是否需要委派子代理                                 |
| 4    | Split and Parallelize            | 拆分獨立子任務，平行執行                               |
| 5    | Task Initialization              | explore → plan → grill loop → confirm                  |
| 6    | Code Iteration                   | developer → simplifier → reviewer → 迴圈至通過         |
| 7    | User Feedback & Issue Resolution | debugger → planner → developer → simplifier → reviewer |
| 8    | Verify                           | 最終驗證與交付                                         |

### `.plan/` 資料夾結構

每個任務會在 `.plan/<task-name>/` 下產生：

```
.plan/<task-name>/
├── exploration-brief.md    # 程式碼庫探索摘要（explorer）
├── task.md                 # 執行計畫（planner）
├── questions.md            # 釐清問題（planner）
├── answers.md              # 使用者回答（supervisor）
├── design-spec.md          # UI 設計規格（designer）
├── assets/                 # 設計素材（designer）
├── dev-notes.md            # 實作筆記（developer）
├── simplifier-notes.md     # 精煉摘要（simplifier）
├── test-notes.md           # 測試筆記（tester）
├── review.md               # 審查結果（reviewer）
└── feedback-investigation.md # 問題調查報告（debugger）
```

## 4. Council 機制

Council 是一個多模型決策機制，適用於高風險、需要多元觀點的決策場景。

**運作方式：**

1. 3 位 councillor（分別使用不同模型）平行回答同一問題
2. `council-master` 綜合三方回應，產出最終建議

**適用時機：**

- 架構決策
- 技術選型
- 有爭議的設計取捨

## 5. 依賴項目

### MCP Servers

| MCP Server           | 使用的 Agent           | 用途                 |
| -------------------- | ---------------------- | -------------------- |
| @context7 (Context7) | explorer, light        | 函式庫文件查詢       |
| @exa (Exa)           | explorer, researcher, light | 程式碼範例、學術論文 |
| @figma-developer-mcp | designer, light        | Figma 設計擷取       |
| @chrome-devtools     | explorer, developer    | 瀏覽器除錯           |
| @atlassian           | light                  | Jira/Confluence      |
| @git                 | light                  | Git 操作             |

### Skills

| Skill                                  | 說明                                                   |
| -------------------------------------- | ------------------------------------------------------ |
| git-workflow                           | Conventional Commits、rebase 策略、commit message 產生 |
| commit-s                               | 從 staged changes 產生簡潔 commit（僅標題）            |
| commit-v                               | 從 staged changes 產生詳細 commit（標題 + 描述）       |
| playwright-cli                         | Playwright 瀏覽器自動化                                |
| vercel-react-best-practices            | React/Next.js 效能最佳化（69 條規則）                  |
| vercel-composition-patterns            | React 組合模式（8 條規則）                             |
| get-code-context-exa                   | Exa 程式碼上下文搜尋指引                               |
| web-search-advanced-research-paper-exa | 透過 Exa 搜尋學術論文                                  |
| council-session                        | 多模型議會協調協議                                     |
| cmux                                   | cmux 拓樸與路由控制（window/workspace/pane/surface）   |
| cmux-markdown                          | 在 cmux 面板開啟 Markdown 檔案並即時重載               |
| grill-me                               | 對計畫或設計進行深度質問                               |
| gh-comment                             | 讀取 PR review comments，產生結構化 feedback 修正紀錄  |
| gh-read-comment                        | 讀取 PR review comments，統整成 review.md              |
| deps-upgrade-check                     | 驗證 dependabot PR 的依賴升級是否安全                  |

### Hooks

| Hook                 | 觸發時機                                       | 說明                                     |
| -------------------- | ---------------------------------------------- | ---------------------------------------- |
| phase-reminder.sh    | `userPromptSubmit` on `code_supervisor`         | 提醒 supervisor 當前工作流階段           |
| cmux-notify.sh       | `stop` on `code_supervisor`, `light`            | 回應完成時透過 cmux 發送桌面通知         |
| post-write-format.sh | `postToolUse` on `light` (matcher: `fs_write`) | 寫入檔案後自動用 Biome 或專案 formatter 格式化 |

### Steering

- `steering/rules.md`：全域規則，套用於所有 agent — zh-TW 回應、Biome 格式化、pnpm、named exports、程式碼風格慣例

### CLI Settings

| 設定項                 | 值              |
| ---------------------- | --------------- |
| chat.defaultModel      | claude-opus-4.7 |
| chat.defaultAgent      | light           |
| chat.enableSubagent    | true            |
| chat.enableDelegate    | true            |
| chat.ui                | classic         |

## 6. 常用指令

| 情境              | 做法                                     |
| ----------------- | ---------------------------------------- |
| 啟動完整工作流    | 以 `code_supervisor` agent 開啟 Kiro CLI |
| 快速問答 / 小改動 | 以 `light` agent 開啟 Kiro CLI           |
| Agent 行為異常    | 傳送 `rule?`，agent 會重新檢視規則並修正 |
| 任務計畫資料夾    | `.plan/<task-name>/` 會自動建立          |

## 7. 注意事項

- **測試是 opt-in**：`tester` 僅在明確要求時才執行
- **Debugger 門檻**：修復失敗 2 次以上才會派遣 `debugger`
- **Council 成本高**：4 個 agent 同時運行，僅用於高風險決策
- **所有 agent 以 zh-TW 回應**（由 `steering/rules.md` 強制）
- **程式碼註解與 commit message 一律使用英文**
- **Biome** 是唯一的 formatter — 不使用 ESLint 或 Prettier
- **pnpm** 是唯一的套件管理器 — 不使用 npm 或 yarn
