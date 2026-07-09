# Excalibur_v.3.0
# Excalibur ImGui

 <img src="IMG_4701.png" alt="UI preview" width="300" style="transform: rotate(90deg);">

Excalibur ImGui is a native iOS application that use ImGui to render a customizable HUD overlay. 

> Notice: this project targets experienced iOS developers and owners of jailbroken/trollstored devices. Use the code only for research and educational purposes, and only on your own devices.

## Building the Excalibur app (.tipa)

1. Make sure the `THEOS` environment variable points to your Theos installation.
2. From the project root, run:

   ```bash
   make package
   ```

3. After a successful build, the `packages/` directory will contain a file like:

   ```text
   Excalibur_<tag>.tipa
   ```

   where `<tag>` comes from `git describe --tags --always --abbrev=0`.

## License and credits

- The ImGui renderer code and related parts under `imgui/` are distributed under the MIT license (see `imgui/LICENSE`).
- The main project was remade by `andrdev`:
  - Telegram: `https://t.me/andrdevv`
  - GitHub: `https://github.com/andrd3v`
- https://github.com/Lessica/TrollSpeed
- https://github.com/34306/HuyJIT-ModMenu<br>
Before using or redistributing, make sure you comply with all licenses and platform rules for where you run this application.

