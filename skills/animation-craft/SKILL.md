---
name: animation-craft
description: 'UI 애니메이션/모션 작업 전반에 적용하는 크래프트 가이드 (Emil Kowalski의 animations.dev 철학 압축). 애니메이션·트랜지션·모션 관련 작업이면 항상 트리거: 애니메이션 작성/수정/리뷰, CSS transition/keyframes, easing, duration, spring, Framer Motion/Motion, 드래그·스와이프·제스처, 모달/드로어/팝오버/토스트/드롭다운 enter·exit, hover/press 피드백, stagger, 스크롤 애니메이션, "부드럽게", "애니메이션 넣어줘", "모션 개선" 등. 애니메이션 코드를 한 줄이라도 쓰거나 리뷰하기 전에 로드.'
license: MIT
---

# Animation Craft

Emil Kowalski (Vercel/Linear, Sonner·Vaul 제작자)의 애니메이션 철학 압축본.
핵심: 애니메이션은 기본적으로 **덜** 넣는 것이 맞고, 넣을 때는 정확한 값을 쓴다.

## 1. 결정 프레임워크 — 코드 쓰기 전에 순서대로 답하라

### 애니메이션해야 하는가? (빈도 기준)

| 빈도 | 결정 |
| --- | --- |
| 하루 100회+ (키보드 단축키, 커맨드 팔레트) | **애니메이션 금지. 절대.** |
| 하루 수십 회 (hover, 리스트 탐색) | 제거하거나 극도로 축소 |
| 가끔 (모달, 드로어, 토스트) | 표준 애니메이션 |
| 드묾/최초 1회 (온보딩, 성공, 축하) | delight 허용 |

- **키보드로 시작된 동작은 절대 애니메이션하지 않는다** (Raycast에 열림/닫힘 애니메이션이 없는 이유).
- 목적을 하나로 명명할 수 없으면 넣지 않는다: 피드백 / 공간적 일관성 / 상태 표시 / 급격한 변화 방지 / 설명. "멋있어 보여서"는 목적이 아니다.
- 기능적·정보 밀집 UI(예: 뱅킹 앱의 그래프)에는 장식 모션이 오히려 해롭다. 애매하면 삭제가 정답.

### Easing 선택

- 요소가 **들어오거나 나감** → `ease-out` (빠르게 시작 = 즉각적으로 느껴짐)
- 화면 위에서 **이동/변형** → `ease-in-out`
- hover/색상 변화 → `ease`
- 등속 모션(마퀴, 프로그레스) → `linear`
- **`ease-in`은 UI에 절대 금지** — 사용자가 가장 집중하는 첫 순간을 지연시켜 굼뜨게 느껴진다.

내장 CSS easing은 약하다. 커스텀 커브를 쓴다:

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);      /* UI 인터랙션용 강한 ease-out */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);  /* 화면 내 이동용 */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);   /* iOS풍 드로어 커브 */
```

### Duration

| 요소 | 시간 |
| --- | --- |
| 버튼 press 피드백 | 100–160ms |
| 툴팁, 작은 팝오버 | 125–200ms |
| 드롭다운, 셀렉트 | 150–250ms |
| 모달, 드로어 | 200–500ms |
| 마케팅/설명용 | 더 길어도 됨 |

**UI 애니메이션은 300ms 미만.** 180ms 드롭다운이 400ms보다 반응적으로 느껴진다. 빠른 스피너는 로딩을 빠르게 느끼게 한다 — 체감 속도가 실제 속도만큼 중요하다.

## 2. 컴포넌트 패턴

- **버튼은 press에 반응해야 한다**: `:active { transform: scale(0.97) }` + `transition: transform 160ms ease-out`. 스케일은 0.95–0.98로 미묘하게. 누를 수 있는 모든 요소에 적용.
- **`scale(0)`에서 시작 금지** — 현실에서 무(無)에서 나타나는 건 없다. `scale(0.95)` + `opacity: 0`에서 시작.
- **팝오버는 트리거에서 자라나야 한다**: `transform-origin`을 트리거 위치로. Radix: `var(--radix-popover-content-transform-origin)`, Base UI: `var(--transform-origin)`. **모달은 예외** — 중앙 유지.
- **툴팁: 첫 hover만 딜레이, 이후는 즉시** (딜레이+애니메이션 스킵, `data-instant`류) — 툴바 전체가 빨라진 느낌.
- **빠르게 반복 트리거되는 UI(토스트, 토글)는 keyframes 대신 transition** — transition은 중간에 끊고 retarget 가능, keyframes는 0부터 재시작.
- **enter는 `@starting-style`** (JS 없이): 구형 브라우저는 `useEffect(() => setMounted(true), [])` + `data-mounted` 폴백.
- **crossfade가 어색하면 `filter: blur(2px)`** 를 전환 중에 얹어 두 상태를 하나로 블렌딩. blur는 20px 미만(Safari에서 비쌈).
- **enter/exit 비대칭 타이밍**: 사용자가 결정하는 단계는 느리게(hold-to-delete: 2s linear), 시스템 응답은 빠르게(release: 200ms ease-out).
- **그룹 등장은 stagger**: 아이템 간 30–80ms. 장식이므로 인터랙션을 막지 않는다.
- **`translateY(100%)` 퍼센트 사용** — 요소 자신의 크기 기준이라 하드코딩 px보다 안전 (Sonner/Vaul 방식).

## 3. Spring

물리 기반이라 자연스럽고, **중단 시 속도를 유지**한다 (keyframes는 0부터 재시작). 용도: 모멘텀 있는 드래그, 중간에 뒤집을 수 있는 제스처, "살아있는" 요소(Dynamic Island), 장식용 마우스 추적.

```js
{ type: "spring", duration: 0.5, bounce: 0.2 }  // Apple식 — 권장, 추론이 쉬움
{ type: "spring", mass: 1, stiffness: 100, damping: 10 }  // 물리식 — 세밀 제어
```

- 기본은 bounce 0 (critically damped). **bounce(0.1–0.3)는 제스처 자체에 모멘텀이 있었을 때만** — 플릭한 카드의 overshoot는 자연스럽고, 그냥 페이드인한 메뉴의 overshoot는 이상하다.
- 마우스 추적 값은 직접 대입하지 말고 `useSpring`으로 보간 (직결 = 인위적, 모멘텀 없음).

## 4. 제스처 & 드래그

- **속도 기반 dismiss**: 거리 임계값만 요구하지 말 것. `Math.abs(distance) / elapsedMs > ~0.11`이면 거리와 무관하게 dismiss — 빠른 플릭이면 충분해야 한다.
- **경계에서 러버밴딩**: 한계를 넘는 드래그는 저항이 점점 커지게. 딱 멈추는 벽은 "얼어붙은" 느낌.
- **드래그 시작 시 `setPointerCapture`** — 포인터가 요소를 벗어나도 추적 지속. 잡은 지점의 오프셋 존중(중앙 스냅 금지).
- **멀티터치 방어**: 드래그 시작 후 추가 터치 무시 (`if (isDragging) return`).
- **모든 애니메이션은 중단 가능해야 한다**: 전환 중 입력을 잠그지 말고, 중단 시 현재 화면상 값에서 새 애니메이션 시작 (목표값에서 시작하면 점프 발생).
- **release 속도를 spring 초기 속도로 전달** — 드래그와 애니메이션 사이 이음새가 없어진다.
- **플릭은 모멘텀 투영으로 목적지 결정**: `projected = current + (v/1000) * d / (1 - d)`, `d ≈ 0.998` — 투영점에 가장 가까운 스냅 포인트로.

## 5. 성능

- **`transform`과 `opacity`만 애니메이션** — GPU에서 실행. `width`/`height`/`margin`/`padding`/`top`/`left`는 layout+paint 유발.
- **부모의 CSS 변수로 자식 transform 구동 금지** — 전체 자식 스타일 recalc. 요소에 직접 `element.style.transform = ...`.
- **Framer Motion 단축 prop(`x`/`y`/`scale`)은 하드웨어 가속 아님** (메인 스레드 rAF) — 부하 시 프레임 드랍. 가속하려면 full string: `animate={{ transform: "translateX(100px)" }}`.
- **CSS 애니메이션은 부하에서 JS를 이긴다** (메인 스레드 밖) — 정해진 모션은 CSS, 동적/중단 가능 모션은 JS/spring.
- **프로그래매틱 CSS 성능이 필요하면 WAAPI**: `element.animate([...], { duration, easing, fill: 'forwards' })` — 라이브러리 없이 가속+중단 가능.

## 6. 접근성

```css
@media (prefers-reduced-motion: reduce) {
  /* opacity/색상 전환은 유지, 이동(transform) 모션만 제거 — 0이 아니라 '더 부드럽게' */
}
@media (hover: hover) and (pointer: fine) {
  /* hover 모션은 반드시 이 안에 — 터치 기기는 탭에 hover가 발동 */
}
```

## 7. 리뷰 체크리스트

리뷰 시 반드시 Before/After/Why 마크다운 테이블로 출력 (목록 형식 금지):

| 문제 | 수정 |
| --- | --- |
| `transition: all` | 정확한 속성 명시: `transition: transform 200ms ease-out` |
| `scale(0)` 진입 | `scale(0.95)` + `opacity: 0` |
| UI에 `ease-in` | `ease-out` 또는 커스텀 커브 |
| 팝오버에 `transform-origin: center` | 트리거 기준 origin (모달은 예외) |
| 키보드 동작에 애니메이션 | 애니메이션 제거 |
| UI에 300ms 초과 | 150–250ms로 축소 |
| 미디어쿼리 없는 hover 애니메이션 | `@media (hover: hover) and (pointer: fine)` |
| 빠르게 트리거되는 요소에 keyframes | CSS transition으로 (중단 가능성) |
| 부하 상황의 Framer Motion `x`/`y` | full `transform` string |
| enter/exit 동일 속도 (press·hold 계열) | exit/응답을 더 빠르게 |
| 전부 동시에 등장 | 30–80ms stagger |
| 레이아웃 속성 애니메이션 | `transform`/`opacity`로 이전 |
| reduced-motion 미처리 | 미디어쿼리 추가 |

수정 우선순위: **삭제 > 축소 > easing 수정 > origin/물리성 수정 > 중단 가능하게 > GPU로 이전 > 폴리시**.

## 8. 마무리 감각

- 모션은 컴포넌트의 성격과 맞아야 한다 — 장난스러운 컴포넌트는 bouncy하게, 대시보드는 crisp하고 빠르게.
- 느낌이 확신 없으면: 슬로모션(2–5배 duration)·DevTools 프레임 단위 검사·다음 날 새 눈으로 재검토. 제스처는 실기기에서 테스트.
- 애매하면 삭제. 매일 쓰는 인터페이스는 모션이 적을수록 좋다.
