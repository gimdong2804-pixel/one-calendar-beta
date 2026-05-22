# One UI 1.0 (Beta 34)

## 업데이트 안내

이번 `One UI 1.0 (Beta 34)` 릴리즈에서는 특정 기기(특히 Android 14 이상)에서 앱 기동 직후 비정상 종료(크래시)되는 현상을 유발하는 런타임 요소 및 안드로이드 매니페스트 설정을 정밀 점검하고 완벽히 해결했습니다.

### 주요 수정 및 개선 사항

1. **AndroidManifest.xml 백그라운드 서비스 패키지 경로 일치화 (치명적 오류 해결)**
   - `flutter_background_service` 플러그인의 5.x 버전 명세에 따라 서비스 클래스명 경로를 기존 구버전 명칭인 `com.pravera.flutter_background_service.BackgroundService`에서 실제 네이티브 라이브러리와 매칭되는 **`id.flutter.flutter_background_service.BackgroundService`**로 정확히 변경했습니다.
   - 이를 통해 런타임에 서비스 클래스를 찾을 수 없어 발생하던 `ClassNotFoundException`과 이로 인해 기동 즉시 앱이 계속 중단되던 크래시 현상을 근본적으로 해결했습니다.

2. **백그라운드 서비스 `exported` 속성 충돌 제거**
   - 매니페스트에 임의 정의되어 있던 `android:exported="false"` 속성이 백그라운드 서비스 라이브러리 내부 머지 선언인 `true`와 상충하여 Gradle 빌드가 실패하던 현상을 해결하기 위해 `android:exported="true"`로 조율 및 설정하여 머지 충돌을 완벽히 방지했습니다.

3. **Android 14+ 포그라운드 서비스 시작 예외 해결**
   - Android 14(API 34) 이상 버전에서 앱이 완전한 포그라운드 상태가 되기 전에 백그라운드 서비스를 실행할 때 발생하는 `ForegroundServiceStartNotAllowedException` 크래시 문제를 수정하였습니다.
   - `lib/main.dart` 내 `main()` 함수의 시작 시점에서 즉시 초기화하던 백그라운드 업데이트 서비스를 화면 렌더링이 완전히 준비된 시점인 `OneCalendarApp` 위젯의 `initState` 내부 `WidgetsBinding.instance.addPostFrameCallback` 콜백 시점으로 이관하여 예외 없이 정상적으로 기동되도록 안전 조치했습니다.

4. **로컬 알림 서비스 초기화 안전성 확보**
   - 로컬 알림 플러그인의 알림 채널 생성이 플러그인 초기화(`initialize()`)보다 먼저 진행되어 바인딩이 누락되거나 비정상 중단될 수 있는 논리적 오류를 방지하기 위해, 초기화 순서를 역전시켰습니다. 

### 파일 정보

- **파일명**: `One UI 1.0 (Beta 34).apk`
- **배포 경로**: `beta/One UI 1.0 (Beta 34)/One UI 1.0 (Beta 34).apk`
- **해시값**: SHA256 체크섬은 동봉된 `SHA256SUMS.txt` 파일에서 확인할 수 있습니다.
