# One UI 1.0 (Beta 30)

## 변경 사항
- **백그라운드 업데이트 서비스 크래시 버그 원천적 해결 (`flutter_background_service`)**:
  - 백그라운드 엔진 구동 시 메인 스레드와 격리된 아일랜드(Isolate) 내부에서 외부 플러그인(`shared_preferences`, `connectivity_plus` 등)이 제대로 초기화 및 바인딩되지 못하던 문제를 `DartPluginRegistrant.ensureInitialized()` 호출을 통해 성공적으로 조치했습니다.
  - 백그라운드 진입점 콜백 함수(`onStart`, `onStartBackground`)를 클래스 내부 정적 메서드에서 클래스 외부의 **독립적인 탑레벨(Top-level) 함수** 구조로 전면 분리 개편하여, Android/iOS 네이티브 영역에서의 콜백 매핑 유실 현상을 완벽히 차단했습니다.
- **백그라운드 전용 알림 엔진 초기화 보강 (`flutter_local_notifications`)**:
  - 백그라운드 Isolate 단에서 푸시 알림을 발송하기 전, 독립적인 알림 환경이 완벽하게 세팅되도록 인스턴스를 재초기화하는 안전 장치를 추가했습니다.
- **메인 앱 시작 로직 안전 장치 점검**:
  - 백그라운드 구동에 에러가 발생하더라도 메인 앱 진입 자체가 물리적으로 막히는 무한 락아웃(Lockout) 현상을 영구적으로 방지했습니다.

## 파일 정보
- **파일명:** One UI 1.0 (Beta 30).apk
- **SHA256 Checksum:** 6931DB532A9721CF551995FDD2095A702868E02C1450A008F86E8F6BB0A0D9AB
