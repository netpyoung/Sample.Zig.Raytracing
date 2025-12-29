

## ch02

픽셀마다 r/g/b값을 찍어 파일로 만듬

### PPM(Portable Pixmap Format) 파일

- https://en.wikipedia.org/wiki/Netpbm#PPM_example
- P3 - ASCII (plain)
- P6 - Binary (raw)
  - https://en.wikipedia.org/wiki/Netpbm#Description

``` txt
<매직넘버>
<넓이> <높이>
<각 색의 최대 수치>
```

## ch03

vec3 도입

## ch04

ray 클래스
시작점(orig)과 방향(dir)이있음

가상의 카메라를 잡고 뷰포트를 잡아 이미지에 저장하는 방식

## ch05

2차방정식 해의 갯수를 판별하여, 원(sphere)과 선(ray)의 만남 여부를 판단.

## ch06

- 06_1
  - 2차방정식 양수 해를 구해, ray를 전진시켜 맞닿은 좌표를 구하고, (0, 0, -1)을 빼서 단위(unit)벡터 구한다.[-1.0 ~ +1.0]
  - (N + 1) * 0.5를 하여 [0.0 ~ 1.0]으로 Min-Max Scaling하여 출력하면 노말을 색상으로 확인가능
- 06_2 - 2차방정식 해를 구하는 로직 최적화
- 06_3 - sphere객체로 추상화 및 ray의 minmax 범위 적용
- 06_4 - face normal 판별
- 06_5 - hittable을 관리하는 HittableLsit
- 06_6 - cpp - shared_ptr 소개
- 06_7 - rtweekend 헤더 추가

### ch06_8

interval 헤더 추가 Minmax관리

## ch07

camera도입

## ch08

앤티앨리어싱 - samples_per_pixel 로 합한걸 나눔

## ch09

- 09_1
  - 무작위 반구방향으로 레이반사
  - ray_color
    - 반사될때마다 색이 0.5만큼 감소.
- 09_2
  - 반사 횟수 제한
- 09_3
  - 부동 소수점 오차를 고려한 interval
- 09_4
  - 반사 중점 조절 - 빛이 법선 방향으로 산란
    - vec3 direction = rec.normal + random_unit_vector();
- 09_5
  - linear_to_gamma

## ch10

material 설정

- 10_1 - material.h
- 10_2 - hit_record에 mat넣어줘서 hit시 설정하게
- 10_3 - lambert
- 10_4 - metal - reflect
- 10_5 - 씬배치
- 10_6 - metal에 fuzz 적용

## ch11

물, 유리, 다이아몬드와 같은 투명한 물질은 유전체

- 11_2
  - 스넬의 법칙
  - dielectric - refract
- 11_3
  - 스넬의 법칙을 사용해도 해를 구할 수 없는 광선 각도가 존재하는데 그때는 전반사
- 11_4
  - 슐릭 근사법
- 11_5
  - 씬 배치

## ch12

- 12_1
  - 카메라 vfov(Vertical view angle (field of view))
- 12_2
  - 카메라 위치조정

## ch13

- defocus blur. Note, photographers call this depth of field, so be sure to only use the term defocus blur among your raytracing friends.
- 13_2
  - defocus_angle, focus_dist 

## ch14

씬배치