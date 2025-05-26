#!/bin/bash
# Certifique-se que o diretório existe
mkdir -p build/app/outputs/flutter-apk/

# Procure pelo APK e copie para o local correto
if [ -f "android/app/build/outputs/apk/debug/app-debug.apk" ]; then
    cp android/app/build/outputs/apk/debug/app-debug.apk build/app/outputs/flutter-apk/app-debug.apk
    echo "APK copiado para build/app/outputs/flutter-apk/"
fi

if [ -f "android/app/build/outputs/flutter-apk/app-debug.apk" ]; then
    cp android/app/build/outputs/flutter-apk/app-debug.apk build/app/outputs/flutter-apk/app-debug.apk
    echo "APK copiado para build/app/outputs/flutter-apk/"
fi
