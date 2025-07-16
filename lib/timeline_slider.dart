import 'package:flutter/material.dart';
import 'package:timeline_slider/snappin_scroll_physics.dart';

class TimelineSlider extends StatefulWidget {
  /// Danh sách các mốc thời gian hiển thị trên thanh trượt
  final List<String> timePoints;

  /// Mốc thời gian đang được chọn
  final String selectedTime;

  /// Hàm callback khi người dùng chọn mốc thời gian mới
  final ValueChanged<String> onTimeChanged;

  /// Độ rộng của mỗi item (mốc thời gian)
  final double itemWidth;

  /// Chiều cao tổng thể của thanh trượt
  final double height;

  /// Màu sắc của các kẻ dọc (vertical bar)
  final Color verticalBarColor;

  /// Độ rộng của kẻ dọc (vertical bar)
  final double verticalBarWidth;

  /// Chiều cao của kẻ dọc (vertical bar)
  final double verticalBarHeight;

  /// Màu chữ của các mốc thời gian
  final Color timeTextColor;

  /// Kích thước chữ của các mốc thời gian
  final double timeTextSize;

  /// Màu chữ của thời gian đang chọn (hiển thị phía trên)
  final Color selectedTimeTextColor;

  /// Kích thước chữ của thời gian đang chọn (hiển thị phía trên)
  final double selectedTimeTextSize;

  /// Hiển thị title bên trái (ví dụ: "Earlier")
  final bool showTitle;

  /// Nội dung title
  final String title;

  /// Hiển thị icon button bên phải
  final bool showIconButton;

  /// Icon hiển thị trên button
  final IconData icon;

  /// Callback khi nhấn icon button
  final VoidCallback? onIconPressed;

  const TimelineSlider({
    Key? key,
    required this.timePoints,
    required this.selectedTime,
    required this.onTimeChanged,
    this.itemWidth = 60,
    this.height = 80,
    this.verticalBarColor = const Color(0xFFBDBDBD),
    this.verticalBarWidth = 2,
    this.verticalBarHeight = 20,
    this.timeTextColor = Colors.grey,
    this.timeTextSize = 12,
    this.selectedTimeTextColor = Colors.blue,
    this.selectedTimeTextSize = 18,
    this.showTitle = false,
    this.title = '',
    this.showIconButton = false,
    this.icon = Icons.layers,
    this.onIconPressed,
  }) : super(key: key);

  @override
  State<TimelineSlider> createState() => _TimelineSliderState();
}

class _TimelineSliderState extends State<TimelineSlider> {
  late ScrollController _scrollController;
  late int _selectedIndex;
  final GlobalKey _listKey = GlobalKey();
  bool _isJumpingToSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.timePoints.indexOf(widget.selectedTime);
    if (_selectedIndex < 0) _selectedIndex = 0;
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant TimelineSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTime != oldWidget.selectedTime) {
      int idx = widget.timePoints.indexOf(widget.selectedTime);
      if (idx < 0) idx = 0;
      if (idx != _selectedIndex) {
        setState(() {
          _selectedIndex = idx;
        });
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToSelected(),
        );
      }
    }
  }

  void _scrollToSelected([double sidePadding = 0]) {
    if (_selectedIndex < 0) return;
    final center = _getTimelineCenter();

    if (center == null) return;
    final targetOffset = (_selectedIndex * widget.itemWidth) +
        sidePadding -
        center +
        widget.itemWidth / 2;

    _isJumpingToSelected = true;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: Duration(milliseconds: 1),
      curve: Curves.linear,
    );
  }

  double? _getTimelineCenter() {
    final RenderBox? renderBox =
        _listKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.size.width / 2;
    }
    return null;
  }

  void _onScrollEnd() {
    final center = _getTimelineCenter();
    if (center == null) return;
    final RenderBox? renderBox =
        _listKey.currentContext?.findRenderObject() as RenderBox?;
    final double sidePadding =
        renderBox != null ? (renderBox.size.width - widget.itemWidth) / 2 : 0;
    final offset = _scrollController.offset;
    final centerOffset = offset + center - sidePadding;
    final index = (centerOffset / widget.itemWidth).floor().clamp(
          0,
          widget.timePoints.length - 1,
        );

    if (_selectedIndex != index ||
        widget.selectedTime != widget.timePoints[index]) {
      setState(() {
        _selectedIndex = index;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTimeChanged(widget.timePoints[index]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = widget.timePoints[_selectedIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.showTitle)
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.selectedTimeTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                const SizedBox(width: 1),
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: widget.selectedTimeTextSize,
                  color: widget.selectedTimeTextColor,
                ),
              ),
              if (widget.showIconButton)
                IconButton(
                  icon: Icon(widget.icon, color: widget.selectedTimeTextColor),
                  onPressed: widget.onIconPressed,
                )
              else
                const SizedBox(width: 1),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sidePadding =
                    (constraints.maxWidth - widget.itemWidth) / 2;

                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _scrollToSelected(sidePadding));
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    NotificationListener<ScrollEndNotification>(
                      onNotification: (notification) {
                        _onScrollEnd();
                        return true;
                      },
                      child: ListView.builder(
                        key: _listKey,
                        physics: SnappingScrollPhysics(
                          itemDimension: widget.itemWidth,
                        ),
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: sidePadding),
                        itemCount: widget.timePoints.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: widget.itemWidth,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Text(
                                    widget.timePoints[index],
                                    style: TextStyle(
                                      fontSize: widget.timeTextSize,
                                      color: widget.timeTextColor,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: widget.verticalBarWidth,
                                  height: widget.verticalBarHeight,
                                  color: widget.verticalBarColor,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
