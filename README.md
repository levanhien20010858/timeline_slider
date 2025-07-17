# timeline_slider

[![pub package](https://img.shields.io/pub/v/timeline_slider.svg)](https://pub.dev/packages/timeline_slider)

A customizable horizontal timeline slider widget for Flutter. Supports custom time points, snapping, style customization, and optional title/icon button like modern time pickers.

---

## Features

- Customizable time points (e.g. 24h, 15/30 min steps)
- Snapping scroll physics
- Customizable bar and text style
- Optional title and icon button
- Easy integration

---

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  timeline_slider: ^0.0.6
```

Then run `flutter pub get`.

---

## Usage

```dart
import 'package:timeline_slider/timeline_slider.dart';

final timePoints = [
  '00:00', '00:15', '00:30', '00:45',
  // ...
  '23:45',
];

TimelineSlider(
  timePoints: timePoints,
  selectedTime: '00:15',
  onTimeChanged: (time) {
    print('Selected: $time');
  },
  showTitle: true,
  title: 'Earlier',
  showIconButton: true,
  icon: Icons.layers,
  onIconPressed: () {},
)
```

---

## Customization

- `verticalBarColor`, `verticalBarWidth`, `verticalBarHeight`
- `timeTextColor`, `timeTextSize`, `selectedTimeTextColor`, `selectedTimeTextSize`
- `showTitle`, `title`, `showIconButton`, `icon`, `onIconPressed`

---

## Demo

![Demo UI](https://github.com/levanhien20010858/timeline_slider/raw/main/assets/image.png)

---

## Donate

MB Bank: 0888801234568
LE VAN HIEN

## Contributing

Pull requests and issues are welcome! See [repository](https://github.com/yourusername/timeline_slider).

## License

MIT
