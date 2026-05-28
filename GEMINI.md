# One Calendar Project Rules

## Language

* 항상 한국어로 답합니다.

## Project Information

* 이 프로젝트는 Flutter(Dart) 기반 One Calendar 프로젝트입니다.
* 현재 프로젝트는 개발 버전(Flutter)입니다.
* 기존 HTML 버전은(old 버전) 별도 저장소에서 관리되며 수정 대상이 아닙니다.

## Git Rules

* 작업 전 현재 브랜치를 확인합니다.
* 대규모 수정 전 변경 계획을 먼저 짠 뒤 설명합니다.
* 기존 기능을 함부로 삭제하지 않습니다.
* 기존 코드가 이해되지 않을 경우 먼저 분석 후 수정합니다.

## Version Rules

git에 배포할 때 이름 다음 형식을 지킵니다.

공식 버전 형식:

* One UI X.X

베타 버전 형식:

* One UI X.X (Beta ?)
예) One UI 1.0 (Beta 1), (Beta 10), (Beta 100) 등

위 형식을 임의로 변경하지 않습니다.

update_service.dart의 버전명도 항상 수정해야합니다. 그 외에 앱 내에 버전명들도 승격시켜야합니다.

## Beta Build Rules

* 베타 APK는 beta 폴더에 빌드합니다..(C:\Users\gimdo\Desktop\one_calendar_new\beta)
* 새 베타 빌드 생성 시 기존 베타 파일을 삭제하지 않습니다.
* 베타 버전 번호는 기존 버전보다 증가해야 합니다.

## Development Rules

* Flutter 최신 안정 버전 기준으로 개발합니다.
* Android 및 Windows 환경을 우선 지원합니다.
* 유지보수가 쉬운 구조를 유지합니다.

## Safety Rules

* 기존 기능 제거보다 기능 추가를 우선합니다.
* 파일 대량 삭제 전 반드시 사용자 확인을 요청합니다.
* 데이터 손실 가능성이 있는 작업 전 반드시 사용자 확인을 요청합니다.

## UI Rules

* 기존 One Calendar 디자인 스타일을 최대한 유지합니다.
* UI 변경 시 사용자 경험을 해치지 않도록 합니다.

## Update history creation format

* 업데이트 내용은 다음과 같은 형식으로 작성합니다.

1. -를 먼저 적고, 띄어쓰기를 한다음 쓰면 됩니다.

예) 

- 버그 수정
- 버벅이는 문제 수정
- 설정 진입창 애니메이션 교체
- 업데이트 알림창 디자인 변경 등


2. 전문 용어를 사용하지 않습니다.
