#include <algorithm>
#include <stdio.h>
#include <windows.h>
#include <winnt.h>
#include <winternl.h>

template <typename T>
struct SimpleHolder {
  T val_ = {};
  void set(const T val) { val_ = val; }
  operator const T&() const { return val_; }
};

__declspec(noinline) PVOID SwapThreadLocalStoragePointer(PVOID newValue) {
  std::swap(::NtCurrentTeb()->Reserved1[11], newValue);
  return newValue;
}

const uint32_t kTlsDataValue = 42;
static thread_local SimpleHolder<uint32_t> sTlsData;

__declspec(noinline) bool TestThreadLocalStorageHead() {
  auto origTlsHead = SwapThreadLocalStoragePointer(nullptr);
  bool isExceptionThrown = false;
  __try {
    sTlsData.set(~kTlsDataValue);
  }
  __except (GetExceptionCode() == EXCEPTION_ACCESS_VIOLATION
                     ? EXCEPTION_EXECUTE_HANDLER
                     : EXCEPTION_CONTINUE_SEARCH) {
    isExceptionThrown = true;
  }
  SwapThreadLocalStoragePointer(origTlsHead);
  sTlsData.set(kTlsDataValue);

  if (!isExceptionThrown) {
    printf("[%s] No exception from setter!\n", __FUNCTION__);
    return false;
  }
  if (sTlsData != kTlsDataValue) {
    printf("[%s] TLS is broken!\n", __FUNCTION__);
    return false;
  }
  printf("[%s] Passed!\n", __FUNCTION__);
  fflush(stdout);
  return true;
}

int main(int argc, char* argv[]) {
  TestThreadLocalStorageHead();
  return 0;
}
