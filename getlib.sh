#/usr/bin/env bash

init=$PWD

mkdir lib && mkdir jar && mkdir data && cd jar \
 && curl --remote-name https://repo1.maven.org/maven2/org/bytedeco/hdf5/1.12.0-1.5.3/hdf5-1.12.0-1.5.3-linux-x86_64.jar \
 && curl --remote-name https://repo1.maven.org/maven2/org/bytedeco/leptonica/1.79.0-1.5.3/leptonica-1.79.0-1.5.3-linux-x86_64.jar \
 && curl --remote-name https://repo1.maven.org/maven2/org/nd4j/nd4j-native/1.0.0-beta7/nd4j-native-1.0.0-beta7-linux-x86_64.jar \
 && curl --remote-name https://repo1.maven.org/maven2/org/bytedeco/openblas/0.3.9-1.5.3/openblas-0.3.9-1.5.3-linux-x86_64.jar \
 && curl --remote-name https://repo1.maven.org/maven2/org/bytedeco/opencv/4.3.0-1.5.3/opencv-4.3.0-1.5.3-linux-x86_64.jar \
 && cd ../lib \
 && mkdir nd4j-native-1.0.0-beta7-linux-x86_64 && mkdir openblas-0.3.9-1.5.3-linux-x86_64 \
 && cd nd4j-native-1.0.0-beta7-linux-x86_64 && jar -xvf ../../jar/nd4j-native-1.0.0-beta7-linux-x86_64.jar \
 && mv org/nd4j/nativeblas/linux-x86_64/*.so* $init/lib && cd .. \
 && cd openblas-0.3.9-1.5.3-linux-x86_64 && jar -xvf ../../jar/openblas-0.3.9-1.5.3-linux-x86_64.jar \
 && mv org/bytedeco/openblas/linux-x86_64/*.so* $init/lib \
 && cd $init/lib && ln -s libopenblas.so libopenblas_nolapack.so.0 \
 && rm -fr $init/lib/nd4j-native-1.0.0-beta7-linux-x86_64 $init/lib/openblas-0.3.9-1.5.3-linux-x86_64 $init/lib/include $init/lib/lib