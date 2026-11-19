# Warp 설정

`install.sh`가 `themes/`를 `~/.warp/themes`로 연결한다. `settings.toml`은 계정·AI 권한 같은 컴퓨터별 설정이 섞여 있고 Warp가 직접 고쳐 쓰므로 통째로 연결하지 않는다. 대신 새 컴퓨터에서 아래 프롬프트를 Claude에게 붙여 넣는다.

## 새 컴퓨터용 프롬프트

```text
Warp 터미널 설정을 아래대로 맞춰줘.

0. 먼저 ~/git/my-harness 의 install.sh 를 실행해서 ~/.warp/themes 가 저장소의 extras/warp/themes 로 연결됐는지 확인해.
   저장소가 없으면 https://github.com/Bongseop-Kim/my-harness 를 ~/git/my-harness 로 받아.
1. 폰트 "D2CodingLigature Nerd Font" 가 설치돼 있는지 확인하고, 없으면 설치해 (brew install --cask font-d2coding-nerd-font).
2. ~/.warp/settings.toml 을 바꾸기 전에 백업해.
3. settings.toml 의 해당 절에 아래 값을 넣어. 이미 있는 키는 값만 바꾸고, 다른 설정은 건드리지 마.
   절이 없으면 새로 만들어.

   [appearance.text]
   font_size = 18.0
   font_name = "D2CodingLigature Nerd Font"
   line_height_ratio = 1.06
   use_thin_strokes = "always"

   [appearance.themes]
   system_theme = true
   selected_system_themes = { dark = { custom = { name = "Catppuccin Mocha", path = "<홈>/.warp/themes/catppuccin_mocha.yml" } }, light = { custom = { name = "Catppuccin Latte", path = "<홈>/.warp/themes/catppuccin_latte.yml" } } }

   [appearance.panes]
   should_dim_inactive_panes = true

   [terminal]
   copy_on_select = true

   [general]
   restore_session = true

   <홈> 은 이 컴퓨터의 실제 홈 경로(예: /Users/이름)로 바꿔. ~ 는 쓰지 마.
4. Warp가 실행 중이면 저장 즉시 반영된다. ~/Library/Logs/warp.log 에 설정 오류가 없는지 확인하고, 폰트가 안 바뀌었으면 Warp를 다시 켜라고 알려줘.

주의:
- 폰트는 "Nerd Font Mono" 를 쓰지 마. Mono 종류는 한글 폭이 영문 한 칸으로 줄어 있어서 탭 제목 등에서 한글이 겹쳐 깨진다.
- use_thin_strokes 를 "always" 로 두지 않으면 고해상도(레티나) 화면에서 글자가 Ghostty보다 두껍게 나온다.
- Warp 설정 동기화로 테마 경로가 다른 컴퓨터의 경로로 넘어와 있을 수 있다. 그래서 3번에서 경로를 이 컴퓨터 기준으로 다시 쓴다.
```
