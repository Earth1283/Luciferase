# Luciferase

> 讓你的伺服器在黑暗中發光。

Luciferase 是基於 [Lophine](https://github.com/LophineLabs/Lophine) 的伺服器分支，
繼承其 Folia 最佳化、可設定的原版機制、紅石相關功能、錯誤修正與實用工具。

[English](./README.md) | [简体中文](./README.zh-CN.md) | **繁體中文**

## 相容性

Luciferase 會保留 Lophine 的 Java 套件名稱、設定路徑、資源命名空間、指令、
權限與 API 座標，因此現有 Lophine 設定與外掛不需要在此初始分支中遷移命名空間。

## 建置需求

- Git
- JDK 25

```bash
./gradlew applyAllPatches
./gradlew createPaperclipJar
```

建置產物位於 `lophine-server/build/libs/`。此模組路徑為相容性而保留，發行版
JAR 會使用 Luciferase 品牌。

更多說明請參閱[英文 README](./README.md)。
