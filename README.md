# Luciferase

> Make your server glow in the dark.

Luciferase is a server fork based on [Lophine](https://github.com/LophineLabs/Lophine).
It carries Lophine's Folia-based optimizations, configurable vanilla behavior,
redstone-oriented features, bug fixes, and utility features into an independent
downstream project.

**English** | [简体中文](./README.zh-CN.md) | [繁體中文](./README.zh-TW.md)

## Features

- Configurable vanilla mechanics for different server needs
- Folia-oriented bug fixes and performance improvements
- Redstone and technical-survival features
- TPS status display and server utility features
- Multiple world-format support, including `b_linear`

For complete technical-survival parity, Fabric may still be the better fit.

## Compatibility

Luciferase intentionally retains Lophine's Java packages, configuration paths,
resource namespaces, commands, permissions, and API coordinates. Existing
Lophine-compatible plugins and configuration should not need a namespace
migration for this initial fork.

## Requirements

- Git
- JDK 25

## Building

```bash
./gradlew applyAllPatches
./gradlew createPaperclipJar
```

The server JAR is written under `lophine-server/build/libs/`. The module path
keeps its inherited name for compatibility; distributable server archives are
branded as Luciferase.

## API compatibility

The initial fork preserves Lophine's published API coordinate:

```kotlin
repositories {
    maven("https://repo.bacteriawa.com/repository/maven-public/")
}

dependencies {
    compileOnly("fun.bm.lophine:lophine-api:26.2.build.+")
}

java {
    toolchain.languageVersion.set(JavaLanguageVersion.of(25))
}
```

The repository above is an inherited build dependency, not a Luciferase
publishing destination.

## Upstream

Lophine is Luciferase's direct upstream and Folia is Lophine's upstream. The
full Lophine commit history is preserved, and the `upstream` Git remote points
to the official Lophine repository.

## Contributing

See the [contribution guide](./docs/CONTRIBUTING_EN.md). Compatibility names
such as `lophine-api`, `lophine-server`, `fun.bm.lophine`, and
`assets/lophine` must remain stable unless a migration is designed separately.

## License

Luciferase inherits its licensing from Lophine and the included upstream
projects. See [LICENSE.md](./LICENSE.md) for details and attribution.
