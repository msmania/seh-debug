#include <stdio.h>
#include <windows.h>

void Log(const char *format, ...) {
  //char linebuf[1024];
  va_list v;
  va_start(v, format);
  //vsprintf(linebuf, format, v);
  vprintf(format, v);
  va_end(v);
  //OutputDebugString(linebuf);
}

int ExceptionFilter(LPEXCEPTION_POINTERS ex) {
  return ex->ExceptionRecord->ExceptionCode == EXCEPTION_ACCESS_VIOLATION
    ? EXCEPTION_EXECUTE_HANDLER
    : EXCEPTION_CONTINUE_SEARCH;
}

struct Base {
  virtual void vfunc(int n) = 0;
};

struct Child1 : Base {
  virtual void vfunc(int n) {
    Log("+%s: %p %08x\n", __FUNCTION__, this, n);
  }
};

struct Child2 : Base {
  virtual void vfunc(int n) {
    Log("+%s: %p %08x\n", __FUNCTION__, this, n);
  }
};

int counter = 0;
Base *global = nullptr;
thread_local Base *thread;

void TestClassMethod(Base* local) {
  ++counter;  // Add `++counter` as a boundary between SEH blocks
  __try {
    local->vfunc(*reinterpret_cast<int*>(local));
  }
  __except (ExceptionFilter(GetExceptionInformation())) {
    __debugbreak();
  }

  ++counter;
  __try {
    global->vfunc(*reinterpret_cast<int*>(global));
  }
  __except (ExceptionFilter(GetExceptionInformation())) {
    __debugbreak();
  }

  ++counter;
  __try {
    thread->vfunc(*reinterpret_cast<int*>(thread));
  }
  __except (ExceptionFilter(GetExceptionInformation())) {
    __debugbreak();
  }
}

void TestSimpleFunction() {
  __try {
    CoInitialize(nullptr);
  }
  __except (ExceptionFilter(GetExceptionInformation())) {
    __debugbreak();
  }
}

int main(int argc, char* argv[]) {
  ++counter;
  TestSimpleFunction();

  ++counter;
  global = new Child1;
  thread = new Child2;
  TestClassMethod(new Child1);

  return 0;
}
