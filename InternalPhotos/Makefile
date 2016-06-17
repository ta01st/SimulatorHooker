CLANG_SIMULATOR = xcrun --sdk iphonesimulator clang -Os -miphoneos-version-min=9.0 -isysroot "`xcrun --sdk iphonesimulator --show-sdk-path`" -arch i386 -arch x86_64 -fmodules #-fobjc-arc

all:
	$(CLANG_SIMULATOR) -c -o InternalPhotos.o InternalPhotos.m
	$(CLANG_SIMULATOR) -c -o ZKSwizzle.o ../ZKSwizzle.m
	$(CLANG_SIMULATOR) -dynamiclib -o InternalPhotos.dylib InternalPhotos.o ZKSwizzle.o

clean:
	rm -f *.o InternalPhotos.dylib