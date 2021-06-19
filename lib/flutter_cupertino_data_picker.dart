///
/// author: Simon Chen
/// since: 2018/09/13
/// fork by Dylan Wu
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Pressed cancel callback.
typedef DateVoidCallback();

typedef DateChangedCallback(int index, dynamic data);

const double _kDatePickerHeight = 210.0;
const double _kDatePickerTitleHeight = 44.0;
const double _kDatePickerItemHeight = 36.0;
const double _kDatePickerFontSize = 18.0;

class DataPicker {
  static void showDatePicker(
    BuildContext context, {
    bool showTitleActions: true,
    required List<dynamic> options,
    int selectedIndex: 0,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateVoidCallback? onCancel,
    suffix: '',
    title: '',
    String? confirm,
    String? cancel,
    locale: 'zh',
    Color? backgroundColor,
    TextStyle? titleTextStyle,
    TextStyle? confirmTextStyle,
    TextStyle? cancelTextStyle,
    TextStyle? itemTextStyle,
  }) {
    Navigator.push(
        context,
        new _DatePickerRoute(
          showTitleActions: showTitleActions,
          initialData: selectedIndex,
          options: options,
          onChanged: onChanged,
          onConfirm: onConfirm,
          onCancel: onCancel,
          locale: locale,
          suffix: suffix,
          title: title,
          confirm: confirm,
          cancel: cancel,
          backgroundColor: backgroundColor,
          titleTextStyle: titleTextStyle,
          confirmTextStyle: confirmTextStyle,
          cancelTextStyle: cancelTextStyle,
          itemTextStyle: itemTextStyle,
          theme: Theme.of(context),
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
        ));
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    this.showTitleActions,
    required this.options,
    this.initialData,
    this.onChanged,
    this.onConfirm,
    this.onCancel,
    this.theme,
    this.barrierLabel,
    this.locale,
    this.suffix,
    this.title,
    this.confirm,
    this.cancel,
    this.backgroundColor,
    this.titleTextStyle,
    this.confirmTextStyle,
    this.cancelTextStyle,
    this.itemTextStyle,
    RouteSettings? settings,
  }) : super(settings: settings);

  final List<dynamic> options;
  final bool? showTitleActions;
  final int? initialData;
  final DateChangedCallback? onChanged;
  final DateChangedCallback? onConfirm;
  final DateVoidCallback? onCancel;
  final ThemeData? theme;
  final String? locale;
  final String? suffix;
  final String? title;
  final String? confirm;
  final String? cancel;
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? confirmTextStyle;
  final TextStyle? cancelTextStyle;
  final TextStyle? itemTextStyle;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DataPickerComponent(
        initialData: initialData,
        options: options,
        onChanged: onChanged,
        onCancel: onCancel,
        locale: locale,
        suffix: suffix,
        title: title,
        confirm: confirm,
        cancel: cancel,
        backgroundColor: backgroundColor,
        titleTextStyle: titleTextStyle,
        confirmTextStyle: confirmTextStyle,
        cancelTextStyle: cancelTextStyle,
        itemTextStyle: itemTextStyle,
        route: this,
      ),
    );
    if (theme != null) {
      bottomSheet = new Theme(data: theme!, child: bottomSheet);
    }
    return bottomSheet;
  }
}

class _DataPickerComponent extends StatefulWidget {
  _DataPickerComponent({
    Key? key,
    required this.route,
    this.initialData: 0,
    required this.options,
    this.onChanged,
    this.onCancel,
    this.locale,
    this.suffix,
    this.title,
    this.confirm,
    this.cancel,
    this.backgroundColor,
    this.titleTextStyle,
    this.confirmTextStyle,
    this.cancelTextStyle,
    this.itemTextStyle,
  }) : super(key: key);

  final DateChangedCallback? onChanged;
  final DateVoidCallback? onCancel;
  final int? initialData;
  final List<dynamic> options;

  final _DatePickerRoute route;

  final String? locale;
  final String? suffix;
  final String? title;
  final String? confirm;
  final String? cancel;

  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? confirmTextStyle;
  final TextStyle? cancelTextStyle;
  final TextStyle? itemTextStyle;

  @override
  State<StatefulWidget> createState() =>
      _DatePickerState(this.initialData ?? 0);
}

class _DatePickerState extends State<_DataPickerComponent> {
  int _initialIndex;
  late FixedExtentScrollController dataScrollCtrl;

  _DatePickerState(this._initialIndex) {
    if (this._initialIndex < 0) {
      this._initialIndex = 0;
    }
    dataScrollCtrl =
        new FixedExtentScrollController(initialItem: _initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new AnimatedBuilder(
        animation: widget.route.animation!,
        builder: (BuildContext context, Widget? child) {
          return new ClipRect(
            child: new CustomSingleChildLayout(
              delegate: new _BottomPickerLayout(widget.route.animation!.value,
                  showTitleActions: widget.route.showTitleActions ?? true),
              child: new GestureDetector(
                child: Material(
                  color: Colors.transparent,
                  child: _renderPickerView(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _setData(int index) {
    if (_initialIndex != index) {
      _initialIndex = index;
      setState(() {});
      _notifyDateChanged();
    }
  }

  void _notifyDateChanged() {
    if (widget.onChanged != null) {
      widget.onChanged?.call(_initialIndex, widget.options[_initialIndex]);
    }
  }

  Widget _renderPickerView() {
    Widget itemView = _renderItemView();
    if (widget.route.showTitleActions ?? true) {
      return Column(
        children: <Widget>[
          _renderTitleActionsView(),
          itemView,
        ],
      );
    }
    return itemView;
  }

  Widget _renderDataPickerComponent(String suffixAppend) {
    return new Expanded(
      flex: 1,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: _kDatePickerHeight,
          decoration:
              BoxDecoration(color: widget.backgroundColor ?? Colors.white),
          child: CupertinoPicker(
            backgroundColor: widget.backgroundColor ?? Colors.white,
            scrollController: dataScrollCtrl,
            itemExtent: _kDatePickerItemHeight,
            onSelectedItemChanged: (int index) {
              _setData(index);
            },
            children: List.generate(widget.options.length, (int index) {
              return Container(
                height: _kDatePickerItemHeight,
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    new Expanded(
                        child: Text(
                      '${widget.options[index]}$suffixAppend',
                      style: widget.itemTextStyle ??
                          TextStyle(
                              color: Color(0xFF000046),
                              fontSize: _kDatePickerFontSize),
                      textAlign: TextAlign.center,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ))
                  ],
                ),
              );
            }),
          )),
    );
  }

  Widget _renderItemView() {
    return _renderDataPickerComponent(widget.suffix ?? '');
  }

  // Title View
  Widget _renderTitleActionsView() {
    String done = _localeDone();
    String cancel = _localeCancel();

    return Container(
      height: _kDatePickerTitleHeight,
      decoration: BoxDecoration(color: widget.backgroundColor ?? Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: _kDatePickerTitleHeight,
            child: FlatButton(
              child: Text(
                widget.cancel ?? '$cancel',
                style: widget.cancelTextStyle ??
                    TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 16.0,
                    ),
              ),
              onPressed: () {
                widget.onCancel?.call();
                Navigator.pop(context);
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: _kDatePickerTitleHeight,
            child: Text(
              widget.title ?? '',
              style: widget.titleTextStyle ??
                  TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
            ),
          ),
          Container(
            height: _kDatePickerTitleHeight,
            child: FlatButton(
              child: Text(
                widget.confirm ?? '$done',
                style: widget.confirmTextStyle ??
                    TextStyle(
                      color: Colors.blue,
                      fontSize: 16.0,
                    ),
              ),
              onPressed: () {
                if (widget.route.onConfirm != null) {
                  widget.route.onConfirm!(
                      _initialIndex, widget.options[_initialIndex]);
                }
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _localeDone() {
    if (widget.locale == null) {
      return 'Done';
    }

    String lang = widget.locale!.split('_').first;

    switch (lang) {
      case 'en':
        return 'Done';

      case 'zh':
        return '确定';

      default:
        return '';
    }
  }

  String _localeCancel() {
    if (widget.locale == null) {
      return 'Cancel';
    }

    String lang = widget.locale!.split('_').first;

    switch (lang) {
      case 'en':
        return 'Cancel';

      case 'zh':
        return '取消';

      default:
        return '';
    }
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress,
      {this.itemCount, required this.showTitleActions});

  final double progress;
  final int? itemCount;
  final bool showTitleActions;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = _kDatePickerHeight;
    if (showTitleActions) {
      maxHeight += _kDatePickerTitleHeight;
    }

    return new BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: maxHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return new Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
