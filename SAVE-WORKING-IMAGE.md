# Резервная прошивка Galaxy A50

Все команды выполнять на Mac. Телефон должен быть в TWRP, раздел **Data** смонтирован, `adb devices` показывает `recovery`.

## Сохранить

```bash
cd /Users/pashkevich.e/PROJECTS/LinuxGalaxyA50
mkdir -p backups/a50-working
cd backups/a50-working

adb exec-out 'gzip -1 -c /data/ubuntu.img' > ubuntu.img.gz
adb exec-out 'dd if=/dev/block/by-name/BOOT bs=4M 2>/dev/null' > boot.img

gzip -t ubuntu.img.gz
shasum -a 256 ubuntu.img.gz boot.img > SHA256SUMS
shasum -a 256 -c SHA256SUMS
```

Обе проверки должны завершиться без ошибок. Сохранить всю папку `backups/a50-working` на другом диске.

## Восстановить телефон

Загрузить TWRP, смонтировать **Data**, подключить USB и выполнить:

```bash
cd /Users/pashkevich.e/PROJECTS/LinuxGalaxyA50/backups/a50-working
shasum -a 256 -c SHA256SUMS

gzip -dc ubuntu.img.gz | adb shell 'cat > /data/ubuntu.img'
adb push boot.img /tmp/boot.img
adb shell 'dd if=/tmp/boot.img of=/dev/block/by-name/BOOT bs=4M && sync'
adb reboot
```

Использовать эти файлы только для Samsung Galaxy A50 SM-A505F.
