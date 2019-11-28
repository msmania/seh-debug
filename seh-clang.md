## Debug log of Clang binary

With Clang, `TestSimpleFunction` and `TestClassMethod` are inlined.  I manually added markers in the `uf` output to indicate which instructions are within the range of each `ScopeRecord`.

The `!ex` command used in the output is a part of my debugger extension [on.dll](https://github.com/msmania/bangon).  It parses [the .pdata section](https://docs.microsoft.com/en-us/windows/win32/debug/pe-format#the-pdata-section) and [Unwind data](https://docs.microsoft.com/en-us/cpp/build/exception-handling-x64?view=vs-2019#unwind-data-definitions-in-c).

As noted, none of the four ScopeRecord ranges looks correct.

0. `xor` at ``00007ff7`64dc1153`` should be included because it's for the 1st argument.
1. `mov` at ``00007ff7`64dc11c0`` should be included, and `add` at ``00007ff7`64dc11ca`` should not.
2. The range does not even include `call`.  A correct range should be ``00007ff7`64dc11d1`` to ``00007ff7`64dc11dd``.
3. The range does not even include `call`.  A correct range should be ``00007ff7`64dc11e6`` to ``00007ff7`64dc1205``.

```
0:000> uf t!main
t!main [D:\src\seh-debug\src\main.cpp @ 75]:
   75 00007ff7`64dc1140 55              push    rbp
   75 00007ff7`64dc1141 56              push    rsi
   75 00007ff7`64dc1142 57              push    rdi
   75 00007ff7`64dc1143 4883ec20        sub     rsp,20h
   75 00007ff7`64dc1147 488d6c2420      lea     rbp,[rsp+20h]
   76 00007ff7`64dc114c 8305e53f000001  add     dword ptr [t!counter (00007ff7`64dc5138)],1
   77 00007ff7`64dc1153 31c9            xor     ecx,ecx
0>   77 00007ff7`64dc1155 ff1555270000    call    qword ptr [t!_imp_CoInitialize (00007ff7`64dc38b0)]
0>   79 00007ff7`64dc115b 8b3dd73f0000    mov     edi,dword ptr [t!counter (00007ff7`64dc5138)]
   80 00007ff7`64dc1161 b908000000      mov     ecx,8
   80 00007ff7`64dc1166 e819010000      call    t!operator new (00007ff7`64dc1284)
   80 00007ff7`64dc116b 488d35961e0000  lea     rsi,[t!Child1::`vftable' (00007ff7`64dc3008)]
   80 00007ff7`64dc1172 488930          mov     qword ptr [rax],rsi
   80 00007ff7`64dc1175 488905c43f0000  mov     qword ptr [t!global (00007ff7`64dc5140)],rax
   81 00007ff7`64dc117c b908000000      mov     ecx,8
   81 00007ff7`64dc1181 e8fe000000      call    t!operator new (00007ff7`64dc1284)
   81 00007ff7`64dc1186 488d0d6b1f0000  lea     rcx,[t!Child2::`vftable' (00007ff7`64dc30f8)]
   81 00007ff7`64dc118d 488908          mov     qword ptr [rax],rcx
   81 00007ff7`64dc1190 8b0dba3f0000    mov     ecx,dword ptr [t!_tls_index (00007ff7`64dc5150)]
   81 00007ff7`64dc1196 65488b142558000000 mov   rdx,qword ptr gs:[58h]
   81 00007ff7`64dc119f 488b0cca        mov     rcx,qword ptr [rdx+rcx*8]
   81 00007ff7`64dc11a3 48898108000000  mov     qword ptr [rcx+8],rax
   82 00007ff7`64dc11aa b908000000      mov     ecx,8
   82 00007ff7`64dc11af e8d0000000      call    t!operator new (00007ff7`64dc1284)
   82 00007ff7`64dc11b4 488930          mov     qword ptr [rax],rsi
   82 00007ff7`64dc11b7 83c702          add     edi,2
   82 00007ff7`64dc11ba 893d783f0000    mov     dword ptr [t!counter (00007ff7`64dc5138)],edi
   82 00007ff7`64dc11c0 4889c1          mov     rcx,rax
1>   82 00007ff7`64dc11c3 89f2            mov     edx,esi
1>   82 00007ff7`64dc11c5 e866000000      call    t!Child1::vfunc (00007ff7`64dc1230)
1>   82 00007ff7`64dc11ca 8305673f000001  add     dword ptr [t!counter (00007ff7`64dc5138)],1
   82 00007ff7`64dc11d1 488b0d683f0000  mov     rcx,qword ptr [t!global (00007ff7`64dc5140)]
   82 00007ff7`64dc11d8 8b11            mov     edx,dword ptr [rcx]
   82 00007ff7`64dc11da 488b01          mov     rax,qword ptr [rcx]
   82 00007ff7`64dc11dd ff10            call    qword ptr [rax]
2>   82 00007ff7`64dc11df 8305523f000001  add     dword ptr [t!counter (00007ff7`64dc5138)],1
   82 00007ff7`64dc11e6 8b05643f0000    mov     eax,dword ptr [t!_tls_index (00007ff7`64dc5150)]
   82 00007ff7`64dc11ec 65488b0c2558000000 mov   rcx,qword ptr gs:[58h]
   82 00007ff7`64dc11f5 488b04c1        mov     rax,qword ptr [rcx+rax*8]
   82 00007ff7`64dc11f9 488b8808000000  mov     rcx,qword ptr [rax+8]
   82 00007ff7`64dc1200 8b11            mov     edx,dword ptr [rcx]
   82 00007ff7`64dc1202 488b01          mov     rax,qword ptr [rcx]
   82 00007ff7`64dc1205 ff10            call    qword ptr [rax]
3>   84 00007ff7`64dc1207 31c0            xor     eax,eax
   84 00007ff7`64dc1209 4883c420        add     rsp,20h
   84 00007ff7`64dc120d 5f              pop     rdi
   84 00007ff7`64dc120e 5e              pop     rsi
   84 00007ff7`64dc120f 5d              pop     rbp
   84 00007ff7`64dc1210 c3              ret

0:000> .load on
0:000> !ex t 00007ff7`64dc1155
@00007ff7`64dc6018
UNWIND_INFO[2] 00007ff7`64dc4058 [ 00007ff7`64dc1140 00007ff7`64dc1220 )
  Version       = 1
  Flags         = 3
  SizeOfProlog  = 12
  FrameRegister = 5
  FrameOffset   = 2
  UnwindCode[0] = {CodeOffset:12 UnwindOp:3 OpInfo:0}
  UnwindCode[1] = {CodeOffset:7 UnwindOp:2 OpInfo:3}
  UnwindCode[2] = {CodeOffset:3 UnwindOp:0 OpInfo:7}
  UnwindCode[3] = {CodeOffset:2 UnwindOp:0 OpInfo:6}
  UnwindCode[4] = {CodeOffset:1 UnwindOp:0 OpInfo:5}
  ExceptionHandler = 00007ff7`64dc2480 t!_C_specific_handler
  HandlerData = 00007ff7`64dc406c
  ScopeRecord[0] 00007ff7`64dc4070 = {
    [ 00007ff7`64dc1154 00007ff7`64dc115c )
    Filter:  00007ff7`64dc1130 t!TestSimpleFunction+0x20
    Handler: 00007ff7`64dc121a t!main+0xda
  }
  ScopeRecord[1] 00007ff7`64dc4080 = {
    [ 00007ff7`64dc11c1 00007ff7`64dc11cb )
    Filter:  00007ff7`64dc10e0 t!TestClassMethod+0x70
    Handler: 00007ff7`64dc1217 t!main+0xd7
  }
  ScopeRecord[2] 00007ff7`64dc4090 = {
    [ 00007ff7`64dc11de 00007ff7`64dc11e0 )
    Filter:  00007ff7`64dc10f0 t!TestClassMethod+0x80
    Handler: 00007ff7`64dc1214 t!main+0xd4
  }
  ScopeRecord[3] 00007ff7`64dc40a0 = {
    [ 00007ff7`64dc1206 00007ff7`64dc1208 )
    Filter:  00007ff7`64dc1100 t!TestClassMethod+0x90
    Handler: 00007ff7`64dc1211 t!main+0xd1
  }
```
