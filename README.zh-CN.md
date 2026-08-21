# Luciferase

> 让你的服务器在黑暗中发光。

Luciferase 是基于 [Lophine](https://github.com/LophineLabs/Lophine) 的服务端分支，
继承了其 Folia 优化、可配置的原版机制、红石相关功能、错误修复与实用工具。

[English](./README.md) | **简体中文** | [繁體中文](./README.zh-TW.md)

## 兼容性

Luciferase 会保留 Lophine 的 Java 包名、配置路径、资源命名空间、命令、权限和
API 坐标，因此现有 Lophine 配置与插件无需在此初始分支中迁移命名空间。

## 构建要求

- Git
- JDK 25

```bash
./gradlew applyAllPatches
./gradlew createPaperclipJar
```

构建产物位于 `lophine-server/build/libs/`。该模块路径为兼容性而保留，发行版
JAR 会使用 Luciferase 品牌。

更多说明请参阅[英文 README](./README.md)。
