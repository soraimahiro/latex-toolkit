---
title: "範例文件"
subtitle: "Example Document"
author: "作者甲、作者乙"
date: "2026-09-30"
abstract: 這是摘要，用來測試摘要區塊的顯示。
toc: true
---

# 1. 文字

這是一行文字。
這是緊接在下一行的文字（單純按 Enter 換行）。

這是新的段落，包含 **粗體**、*斜體*、`行內程式碼` 與 [連結](https://example.com)。

> 這是引用區塊。

分隔線

---

## 清單

- 項目一
- 項目二
  - 子項目

1. 第一項
2. 第二項

## 1.2 數學

行內公式 $E = mc^2$，區塊公式：

$$
\sum_{i=1}^{n} i = \frac{n(n+1)}{2}
$$

# 2. 程式碼

```python
def greet(name: str) -> str:
    return f"Hello, {name}!"

# 超長的單行會自動折行，不會超出頁面邊界
message = "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Nihil voluptatibus, quis sint voluptatem assumenda, pariatur molestias odit, sit atque repellendus natus? Sunt quo neque officiis nam et vero ad necessitatibus."
```

```bash
echo "Hello, World!"
```

# 3. 表格

| 名稱 | 數量 | 備註 |
| :--- | ---: | :--- |
| 蘋果 | 10 | 紅色 |
| 香蕉 | 25 | 黃色 |

# 4. 圖片

圖片需與前後文字之間空一行，才會當成獨立圖片（有說明文字時才能設定對齊）。

![向左對齊](./hello.png){width=4cm align=left}

![置中對齊](./hello.png){width=4cm align=center}

![向右對齊](./hello.png){width=4cm align=right}

行內圖片，3cm
![向右對齊](./hello.png){width=3cm}