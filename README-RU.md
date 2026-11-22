# Premium-OOS

[English](README.md) | Русский

Модуль KernelSU для разблокировки флагманских эффектов размытия, полупрозрачности и премиального интерфейса OriginOS 6.
ПОКА ТОЛЬКО Z9

## Описание

На бюджетных и среднебюджетных устройствах, таких как iQOO Z9 (Snapdragon 7 Gen 3 / SM7550), визуальные эффекты OriginOS 6 урезаны на уровне таблиц конфигурации и проверок системного фреймворка:
- Размытие часов на экране блокировки и Always-On Display, виджетов и шейдеры деформации заблокированы режимом Space System (`ssMode`) в `ActivityTaskManagerService`. Если режим равен 0 (`?spacesystem`), компонент `VivoDreamClockApp` полностью отключает шейдеры блюра.
- Оконный менеджер переводит режим в `ssMode = 2` только в случае, если при старте `system_server` вызов `FtFeature.getFeatureAttribute("vivo.software.spacesystem", "version", "0") >= 2` возвращает истину.
- Вендорный HAL ConfigStore (`vendor.vivo.hardware.configstore@1.0-service`) требует обязательного наличия параметров `vivo-support = 1` и `is_support_zygote = 1` в `vivo_config.ini`. При отсутствии `vivo-support` HAL считает фичу неподдерживаемой и возвращает значение по умолчанию `0`.
- SystemUI оценивает производительность устройства в `SystemPropertiesFacade.getPerformanceLevel()`. Без флагов `vivo.software.nativeblur` и Space System v2+ устройство определяется как low-performance (уровень 40 вместо 30), что отключает анимации деформации окон.
- Размытие фона при открытии и закрытии приложений отключено (`support_blur=0` в конфигурации vendor, `ro.launcher.blur.appLaunch=0`).
- Профиль системных эффектов переведён в режим Lite (`system_effect_type=1` вместо `0`).

Модуль динамически подменяет конфигурацию в оперативной памяти через KernelSU overlayfs и инъекцию системных свойств без записи в физические разделы и без изменения хэшей AVB.

## Возможности

- Разблокировка размытия часов и виджетов на экране блокировки и AOD.
- Включение размытия фона при запуске и сворачивании приложений в лаунчере.
- Активация пайплайна Space System v3 уровня 1 (режим `spacesystem` = 2).
- Переключение системного рендера эффектов из режима Lite (`1`) в режим Full (`0`).
- Включение аппаратного Native Blur, Motion Blur и эффектов полупрозрачности V-Glass.
- Полная безопасность для устройств с временным рутом (temproot) без перезаписи физических разделов.
- Поддержка кнопки Action в менеджере для мягкой перезагрузки и перезапуска ConfigStore HAL.
- Корректное размонтирование при удалении модуля (`uninstall.sh`) для предотвращения ошибок занятости файлов (`EBUSY`).
- Комплекс оптимизаций рендеринга для чипсета Snapdragon 7 Gen 3 (Adreno 720) и экрана 1.5K.

## Оптимизации производительности для iQOO Z9

Для устранения микрофризов и просадок FPS на Adreno 720:
- **Сбалансированный радиус деформации**: Значение радиуса размытия окон снижено с 44 до 24 (`min_blur_radius_temp = 24`), что снижает нагрузку на текстурные блоки GPU в два раза при сохранении мягкого визуального эффекта.
- **Динамический фреймрейт блюра**: Включен параметр `debug.blur.dynamic.frameRate=true`. Это позволяет графическому движку обновлять саму текстуру размытия на 60–90 fps, в то время как перемещение окна остаётся плавным на 120/144 fps.
- **Отключение избыточного градиента**: Снято форсирование тяжёлого уровня 4 (`persist.debug.blurlevel_4=false`), вызывающего упор в филлрейт памяти на экранах высокого разрешения.
- **Аппаратная оптимизация шторки**: Активирован параметр `persist.debug.qs_enable_hardware_optimize=true`.
- **Буст частот GPU**: Задан минимальный порог частоты Adreno при входе в анимацию блюра (`persist.blur.GPU.minlevel=60`, длительность 600 мс).

## Техническое устройство

1. `vendor/etc/vivo_config.ini`:
   - Настраивает секции `[vivo.software.spacesystem]`, `[vivo.software.spacesystem.borderlight]`, `[vivo.software.nativeblur]`, `[vivo.software.motionblur]`, `[vivo.software.asyncanimboost]`, `[vivo.software.vglasseffect]`, `[vivo.software.realtimeblur]` и оптимизированный `[vivo.software.windowdeformblur]`.
   - Добавляет атрибуты `vivo-support = 1` и `is_support_zygote = 1` для корректного экспорта фич через ConfigStore HAL в Zygote и System Server.
2. `system.prop`:
   - Задаёт системные свойства `ro.vendor.vivo.software.*` на ранней стадии инициализации Android.
   - Задаёт оптимизации для видеоядра Adreno 720.
3. `post-fs-data.sh`:
   - Назначает SELinux-контекст `u:object_r:vendor_configs_file:s0` для подмонтированных файлов.
   - Организует резервный bind-mount для `/vendor/etc/vivo_config.ini`.
   - Задаёт параметры через `resetprop`.
4. `service.sh`:
   - Настраивает параметры в системных базах настроек (`reduced_dynamic_effects=0`, `disable_window_blurs=0`).
   - Поддерживает свойства в активном состоянии после завершения загрузки.
5. `action.sh`:
   - Вызывается по нажатию кнопки Action в KernelSU / SukiSU Manager.
   - Проверяет монтирование, перезапускает `vendor.vivo.hardware.configstore@1.0-service` и выполняет мягкую перезагрузку Zygote.
6. `uninstall.sh`:
   - Вызывается при удалении модуля в менеджере.
   - Размонтирует слой `/vendor/etc/vivo_config.ini` во избежание блокировок inode (`Device or resource busy`).

## Безопасность

- Не изменяет физические разделы устройства (`/system`, `/vendor`, `/product`).
- Полностью совместим с временным рутом (temproot) и верификацией AVB.
- Все изменения применяются исключительно через overlayfs в памяти и через `resetprop`.

## Требования

- iQOO Z9 под управлением OriginOS 6 (Android 16 / платформа SM7550).
- KernelSU / APatch / Magisk с поддержкой overlay.
- Среда сборки на NixOS (через `nix-shell`).

## Сборка

Для сборки архива модуля:

```bash
./build.sh
```

Готовый архив сохраняется в каталог `out/premium-oos-v<VERSION>.zip`.

## Установка и активация

1. Перенесите `out/premium-oos-v0.5.0.zip` на устройство.
2. Прошейте zip через KernelSU Manager (или APatch / Magisk).
3. Активация:
   - При стандартном постоянном root: выполните перезагрузку устройства.
   - При временном root (temproot): нажмите кнопку «Действие» (Action) рядом с модулем в менеджере KernelSU / SukiSU или выполните вручную:
     ```bash
     su -c "killall -9 vendor.vivo.hardware.configstore@1.0-service && setprop ctl.restart zygote"
     ```
4. Проверка активации через adb shell:
   ```bash
   su -c "dumpsys window | grep spacesystem"
   ```
   В строке глобальной конфигурации должно отображаться `spacesystem` вместо `?spacesystem`.
5. Дайте смартфону время для оптимизации (поставьте его на зарядку на ночь и не трогайте его).

## Лицензия

Проект распространяется под лицензией GNU General Public License v3.0 (GPLv3). Подробности в файле [LICENSE](LICENSE).