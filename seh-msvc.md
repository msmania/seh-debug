## Debug log of MSVC binary

I manually added markers in the `uf` output to indicate which instructions are within the range of each `ScopeRecord`.

The `!ex` command used in the output is a part of my debugger extension [on.dll](https://github.com/msmania/bangon).  It parses [the .pdata section](https://docs.microsoft.com/en-us/windows/win32/debug/pe-format#the-pdata-section) and [Unwind data](https://docs.microsoft.com/en-us/cpp/build/exception-handling-x64?view=vs-2019#unwind-data-definitions-in-c).

I think all of the four ScopeRecord ranges are correct.

```
0:000> uf t!TestSimpleFunction
t!TestSimpleFunction [D:\src\seh-debug\src\main.cpp @ 66]:
   66 00007ff7`614d6d30 4883ec28        sub     rsp,28h
0>   68 00007ff7`614d6d34 33c9            xor     ecx,ecx
0>   68 00007ff7`614d6d36 ff153c260800    call    qword ptr [t!_imp_CoInitialize (00007ff7`61559378)]
0>   69 00007ff7`614d6d3c eb01            jmp     t!TestSimpleFunction+0xf (00007ff7`614d6d3f)

t!TestSimpleFunction+0xf [D:\src\seh-debug\src\main.cpp @ 73]:
   73 00007ff7`614d6d3f 4883c428        add     rsp,28h
   73 00007ff7`614d6d43 c3              ret

0:000> uf t!TestClassMethod
t!TestClassMethod [D:\src\seh-debug\src\main.cpp @ 40]:
   40 00007ff7`614d6cb0 4883ec28        sub     rsp,28h
   41 00007ff7`614d6cb4 ff0556a40700    inc     dword ptr [t!counter (00007ff7`61551110)]
0>   43 00007ff7`614d6cba 488b01          mov     rax,qword ptr [rcx]
0>   43 00007ff7`614d6cbd 8bd0            mov     edx,eax
0>   43 00007ff7`614d6cbf ff10            call    qword ptr [rax]
0>   44 00007ff7`614d6cc1 eb01            jmp     t!TestClassMethod+0x14 (00007ff7`614d6cc4)

t!TestClassMethod+0x14 [D:\src\seh-debug\src\main.cpp @ 49]:
   49 00007ff7`614d6cc4 ff0546a40700    inc     dword ptr [t!counter (00007ff7`61551110)]
1>   51 00007ff7`614d6cca 488b0d47a40700  mov     rcx,qword ptr [t!global (00007ff7`61551118)]
1>   51 00007ff7`614d6cd1 488b01          mov     rax,qword ptr [rcx]
1>   51 00007ff7`614d6cd4 8bd0            mov     edx,eax
1>   51 00007ff7`614d6cd6 ff10            call    qword ptr [rax]
1>   52 00007ff7`614d6cd8 eb01            jmp     t!TestClassMethod+0x2b (00007ff7`614d6cdb)

t!TestClassMethod+0x2b [D:\src\seh-debug\src\main.cpp @ 57]:
   57 00007ff7`614d6cdb ff052fa40700    inc     dword ptr [t!counter (00007ff7`61551110)]
2>   59 00007ff7`614d6ce1 8b0d4da40700    mov     ecx,dword ptr [t!_tls_index (00007ff7`61551134)]
2>   59 00007ff7`614d6ce7 65488b042558000000 mov   rax,qword ptr gs:[58h]
2>   59 00007ff7`614d6cf0 ba08010000      mov     edx,108h
2>   59 00007ff7`614d6cf5 488b04c8        mov     rax,qword ptr [rax+rcx*8]
2>   59 00007ff7`614d6cf9 488b0c02        mov     rcx,qword ptr [rdx+rax]
2>   59 00007ff7`614d6cfd 488b01          mov     rax,qword ptr [rcx]
2>   59 00007ff7`614d6d00 8bd0            mov     edx,eax
2>   59 00007ff7`614d6d02 ff10            call    qword ptr [rax]
2>   60 00007ff7`614d6d04 eb01            jmp     t!TestClassMethod+0x57 (00007ff7`614d6d07)

t!TestClassMethod+0x57 [D:\src\seh-debug\src\main.cpp @ 64]:
   64 00007ff7`614d6d07 4883c428        add     rsp,28h
   64 00007ff7`614d6d0b c3              ret

0:000> .load on
0:000> !ex t 00007ff7`614d6d36
@00007ff7`61554018
UNWIND_INFO[2] 00007ff7`615493ec [ 00007ff7`614d6d30 00007ff7`614d6d44 )
  Version       = 1
  Flags         = 1
  SizeOfProlog  = 4
  FrameRegister = 0
  FrameOffset   = 0
  UnwindCode[0] = {CodeOffset:4 UnwindOp:2 OpInfo:4}
  ExceptionHandler = 00007ff7`614d2f31 t!ILT+7980(__C_specific_handler)
  HandlerData = 00007ff7`615493f8
  ScopeRecord[0] 00007ff7`615493fc = {
    [ 00007ff7`614d6d34 00007ff7`614d6d3e )
    Filter:  00007ff7`615392e0 t!`TestSimpleFunction'::`1'::filt$0
    Handler: 00007ff7`614d6d3e t!TestSimpleFunction+0xe
  }

0:000> !ex t 00007ff7`614d6cbf
@00007ff7`6155400c
UNWIND_INFO[1] 00007ff7`6154938c [ 00007ff7`614d6cb0 00007ff7`614d6d0c )
  Version       = 1
  Flags         = 1
  SizeOfProlog  = 4
  FrameRegister = 0
  FrameOffset   = 0
  UnwindCode[0] = {CodeOffset:4 UnwindOp:2 OpInfo:4}
  ExceptionHandler = 00007ff7`614d2f31 t!ILT+7980(__C_specific_handler)
  HandlerData = 00007ff7`61549398
  ScopeRecord[0] 00007ff7`6154939c = {
    [ 00007ff7`614d6cba 00007ff7`614d6cc3 )
    Filter:  00007ff7`61539270 t!`TestClassMethod'::`1'::filt$0
    Handler: 00007ff7`614d6cc3 t!TestClassMethod+0x13
  }
  ScopeRecord[1] 00007ff7`615493ac = {
    [ 00007ff7`614d6cca 00007ff7`614d6cda )
    Filter:  00007ff7`6153928e t!`TestClassMethod'::`1'::filt$1
    Handler: 00007ff7`614d6cda t!TestClassMethod+0x2a
  }
  ScopeRecord[2] 00007ff7`615493bc = {
    [ 00007ff7`614d6ce1 00007ff7`614d6d06 )
    Filter:  00007ff7`615392ac t!`TestClassMethod'::`1'::filt$2
    Handler: 00007ff7`614d6d06 t!TestClassMethod+0x56
  }
```
