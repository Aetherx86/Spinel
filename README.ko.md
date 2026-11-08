# Spinel (고엔트로피 바이너리 섹션 맵 & 구조적 Diff 엔진)

[English](README.md) · [라이선스](LICENSE) · [라이브 워크벤치](https://aetherx86.github.io/spinel/)

Spinel은 ELF, Mach-O, PE/COFF 바이너리를 초고속으로 파싱하여 슬라이딩 윈도우 섀넌 엔트로피(Shannon Entropy)를 계산하고, 패킹 및 난독화 서명을 감지하며, 터미널 유니코드 브라유(Braille) 밀도 맵을 렌더링하는 헤드리스 분석 엔진입니다.

## 아키텍처 개요

- **섀넌 엔트로피 엔진**: 임의의 윈도우 크기에 대해 바이트 빈도 분포와 엔트로피를 정밀 계산하여 일반 데이터, 네이티브 기계어 코드, 암호화/가상화된 패킹 바이트코드 블록을 즉시 식별합니다.
- **다중 포맷 자동 식별**: ELF(매직 바이트 `\x7FELF`), Mach-O(32/64비트 유니버설 팻 및 단일 아키텍처), PE/COFF(`MZ` 시그니처) 헤더를 자동 판별합니다.
- **자립형 WebAssembly 배포**: 1.3 KB 초경량 자립형 WASM 아티팩트(`spinel.wasm`)로 컴파일되어 웹 브라우저에서 드래그 앤 드롭으로 즉각 실행됩니다.
- **터미널 스파크라인 시각화**: 유니코드 브라유 문자를 터미널 stdout으로 직접 출력하여 CLI 워크플로에서도 직관적인 엔트로피 맵을 제공합니다.

## WebAssembly C-ABI 인터페이스

```c
double spinel_calc_entropy(const uint8_t* ptr, size_t len);
uint32_t spinel_detect_format(const uint8_t* ptr, size_t len);
size_t spinel_sliding_window(
    const uint8_t* in_ptr,
    size_t in_len,
    size_t win_size,
    size_t step,
    double* out_ptr,
    size_t out_cap
);
```

## 빌드 및 검증

```bash
# 단위 테스트 실행
zig build test

# 자립형 WebAssembly 바이너리 빌드 (1.3 KB)
zig build -Doptimize=ReleaseSmall -Dtarget=wasm32-freestanding
```

## 라이선스

MIT License. Copyright (c) 2026 Jeong Hoon Kim (Aether Systems & Research Lab).
