CLANG_SIMULATOR = xcrun --sdk iphonesimulator clang -Os -miphoneos-version-min=9.0 -isysroot "`xcrun --sdk iphonesimulator --show-sdk-path`" -arch i386 -arch x86_64 -fmodules #-fobjc-arc

all:
	$(CLANG_SIMULATOR) -c -o Injector.o Injector.m
	$(CLANG_SIMULATOR) -c -o ZKSwizzle.o ../ZKSwizzle.m
	$(CLANG_SIMULATOR) -dynamiclib -o Injector.dylib Injector.o ZKSwizzle.o

clean:
	rm -f *.o Injector.dylib