!IF "$(PLATFORM)"=="X64" || "$(PLATFORM)"=="x64"
ARCH=amd64
CPU=x86-64
TRIPLE=x86_64-pc-windows-msvc19.23.28106
!ELSE
ARCH=x86
CPU=pentium4
TRIPLE=i386-pc-windows-msvc19.23.28106
!ENDIF

OUTDIR=bin\$(ARCH)
OBJDIR=obj\$(ARCH)
OUTDIR_CLANG=bin-clang\$(ARCH)
OBJDIR_CLANG=obj-clang\$(ARCH)
SRCDIR=src

MSVCDIR=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC
VCINCLUDE=$(MSVCDIR)\Tools\MSVC\14.23.28105
WIN10KITINCLUDE=C:\Program Files (x86)\Windows Kits\10\Include\10.0.18362.0
GTEST_SRC_DIR=D:\src\googletest
GTEST_BUILD_DIR=D:\src\googletest\build\$(ARCH)

RD=rd/s/q
RM=del/q
TARGET=t.exe
CC=cl.exe
LINKER=link.exe
CLANG=D:\llvm\LLVM-9.0.0-win64\bin\clang++.exe
LLD=D:\llvm\LLVM-9.0.0-win64\bin\lld-link.exe

OBJS=\
	$(OBJDIR)\main.obj\

OBJS_CLANG=\
	$(OBJDIR_CLANG)\main.obj\

LIBS=\
	ole32.lib\

CFLAGS=\
	/nologo\
	/c\
	/O2\
	/W4\
	/Zi\
	/EHsc\
	/Fo"$(OBJDIR)\\"\
	/Fd"$(OBJDIR)\\"\
	/I"$(GTEST_SRC_DIR)\googletest\include"\
	/I"$(GTEST_SRC_DIR)\googlemock\include"\

LFLAGS=\
	/NOLOGO\
	/DEBUG\
	/SUBSYSTEM:CONSOLE\
	/LIBPATH:"$(GTEST_BUILD_DIR)\lib\Release"\

CLANG_FLAGS=\
	-cc1\
	-emit-obj\
	-std=c++14\
	-O2\
	-Wall\
	-triple $(TRIPLE)\
	-target-cpu $(CPU)\
	--dependent-lib=msvcrt\
	-internal-isystem "$(VCINCLUDE)\include"\
	-internal-isystem "$(VCINCLUDE)\atlmfc\include"\
	-internal-isystem "$(WIN10KITINCLUDE)\shared"\
	-internal-isystem "$(WIN10KITINCLUDE)\um"\
	-internal-isystem "$(WIN10KITINCLUDE)\winrt"\
	-internal-isystem "$(WIN10KITINCLUDE)\ucrt"\
	-internal-isystem "$(GTEST_SRC_DIR)\googletest\include"\
	-internal-isystem "$(GTEST_SRC_DIR)\googlemock\include"\
	-fms-compatibility\
	-fms-compatibility-version=19.23.28106\
	-debug-info-kind=limited\
	-gcodeview\
#	-MP\
#	-cfguard\
#	-disable-free\
#	-disable-llvm-verifier\
#	-discard-value-names\
#	-faddrsig\
#	-fdata-sections\
#	-fdelayed-template-parsing\
#	-fdeprecated-macro\
#	-fdiagnostics-format msvc\
#	-fdiagnostics-show-option\
#	-ferror-limit 19\
#	-ffunction-sections\
#	-fmath-errno\
#	-fmessage-length 0\
#	-fms-extensions\
#	-fms-volatile\
#	-fno-rtti-data\
#	-fno-use-cxa-atexit\
#	-fobjc-runtime=gcc\
#	-masm-verbose\
#	-mconstructor-aliases\
#	-mincremental-linker-compatible\
#	-mllvm -x86-asm-syntax=intel\
#	-momit-leaf-frame-pointer\
#	-mrelocation-model pic\
#	-mthread-model posix\
#	-munwind-tables\
#	-pic-level 2\
#	-relaxed-aliasing\
#	-stack-protector 2\
#	-vectorize-loops\
#	-vectorize-slp\
#	-x c++\

LLD_FLAGS=\
	-debug\
	-SUBSYSTEM:CONSOLE,6.01\
	-LIBPATH:"$(GTEST_BUILD_DIR)\lib\Release"\

all: $(OUTDIR)\$(TARGET) $(OUTDIR_CLANG)\$(TARGET)

$(OUTDIR)\$(TARGET): $(OBJS)
	@if not exist $(OUTDIR) mkdir $(OUTDIR)
	$(LINKER) $(LFLAGS) $(LIBS) /PDB:"$(@R).pdb" /OUT:$@ $**

{$(SRCDIR)}.cpp{$(OBJDIR)}.obj:
	@if not exist $(OBJDIR) mkdir $(OBJDIR)
	$(CC) $(CFLAGS) $<

$(OUTDIR_CLANG)\$(TARGET): $(OBJS_CLANG)
	@if not exist $(OUTDIR_CLANG) mkdir $(OUTDIR_CLANG)
	"$(LLD)" $(LLD_FLAGS) $(LIBS) /pdb:"$(@R).pdb" /out:$@ $**

{$(SRCDIR)}.cpp{$(OBJDIR_CLANG)}.obj:
	@if not exist $(OBJDIR_CLANG) mkdir $(OBJDIR_CLANG)
	"$(CLANG)" $(CLANG_FLAGS) -o $@ $<

clean:
	@if exist $(OBJDIR) $(RD) $(OBJDIR)
	@if exist $(OUTDIR)\$(TARGET) $(RM) $(OUTDIR)\$(TARGET)
	@if exist $(OUTDIR)\$(TARGET:exe=ilk) $(RM) $(OUTDIR)\$(TARGET:exe=ilk)
	@if exist $(OUTDIR)\$(TARGET:exe=pdb) $(RM) $(OUTDIR)\$(TARGET:exe=pdb)
	@if exist $(OBJDIR_CLANG) $(RD) $(OBJDIR_CLANG)
	@if exist $(OUTDIR_CLANG)\$(TARGET) $(RM) $(OUTDIR_CLANG)\$(TARGET)
	@if exist $(OUTDIR_CLANG)\$(TARGET:exe=pdb) $(RM) $(OUTDIR_CLANG)\$(TARGET:exe=pdb)
