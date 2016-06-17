CLANG_SIMULATOR = xcrun --sdk iphonesimulator clang -Os -miphoneos-version-min=9.0 -isysroot "`xcrun --sdk iphonesimulator --show-sdk-path`" -arch i386 -arch x86_64 -fmodules #-fobjc-arc

all:
	$(CLANG_SIMULATOR) -c -o FullSafari.o FullSafari.m
	$(CLANG_SIMULATOR) -c -o ZKSwizzle.o ../ZKSwizzle.m
	$(CLANG_SIMULATOR) -dynamiclib -o FullSafari.dylib FullSafari.o ZKSwizzle.o

clean:
	rm -f *.o FullSafari.dylib