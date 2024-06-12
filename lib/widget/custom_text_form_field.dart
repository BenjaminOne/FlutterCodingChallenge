import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.labelText,
    this.label,
    this.initialValue,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onSaved,
    this.inputFormatters,
    this.keyboardType,
    this.autofillHints,
    this.readOnly = false,
  });

  final String? labelText;
  final Widget? label;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final bool readOnly;

  @override
  State createState() => _State();
}

class _State extends State<CustomTextFormField> {
  final _key = GlobalKey<FormFieldState>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller.text = widget.initialValue ?? "";

    _controller.addListener(() {
      setState(() {
        // This causes rebuild so that we can update x mark icon
      });
    });

    _focusNode.addListener(() {
      setState(() {
        // This causes rebuild so that we can update x mark icon
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final result = widget.validator?.call(value);

    bool newHasError = result != null;
    if (newHasError != _hasError) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _hasError = newHasError;
        });
      });
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final Widget? suffixIcon;

    if (widget.readOnly) {
      suffixIcon = null;
    } else {
      if (_hasError) {
        suffixIcon = const Icon(Icons.warning, color: Colors.red);
      } else if (_controller.text.isNotEmpty && _focusNode.hasFocus) {
        suffixIcon = Transform(
          transform: Matrix4.translationValues(0, 8, 0),
          child: IconButton(
            focusNode: FocusNode(skipTraversal: true),
            icon: const Icon(Icons.clear, color: Colors.black),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call("");
            },
          ),
        );
      } else {
        suffixIcon = null;
      }
    }

    return TextFormField(
      key: _key,
      controller: _controller,
      focusNode: _focusNode,
      style: const TextStyle(fontSize: 14, color: Colors.black),
      validator: _validate,
      autovalidateMode: null,
      textCapitalization: widget.textCapitalization,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.keyboardType,
      autofillHints: widget.autofillHints,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withOpacity(0.05),
        border: OutlinedInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        focusedBorder: widget.readOnly
            ? null
            : OutlinedInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.1),
                  width: 2,
                ),
                innerBorderSide: BorderSide(
                  color: Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
        labelText: widget.labelText,
        label: widget.label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
        floatingLabelStyle: const TextStyle(fontSize: 12, color: Colors.black),
        errorStyle:
            TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
        hintStyle:
            TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
        suffixIcon: suffixIcon,
        counter: const SizedBox.shrink(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class OutlinedInputBorder extends InputBorder {
  /// Creates a rounded rectangle outline border for an [InputDecorator].
  ///
  /// If the [borderSide] parameter is [BorderSide.none], it will not draw a
  /// border. However, it will still define a shape (which you can see if
  /// [InputDecoration.filled] is true).
  ///
  /// If an application does not specify a [borderSide] parameter of
  /// value [BorderSide.none], the input decorator substitutes its own, using
  /// [copyWith], based on the current theme and [InputDecorator.isFocused].
  ///
  /// The [borderRadius] parameter defaults to a value where all four
  /// corners have a circular radius of 4.0. The [borderRadius] parameter
  /// must not be null and the corner radii must be circular, i.e. their
  /// [Radius.x] and [Radius.y] values must be the same.
  ///
  /// See also:
  ///
  ///  * [InputDecoration.floatingLabelBehavior], which should be set to
  ///    [FloatingLabelBehavior.never] when the [borderSide] is
  ///    [BorderSide.none]. If let as [FloatingLabelBehavior.auto], the label
  ///    will extend beyond the container as if the border were still being
  ///    drawn.
  const OutlinedInputBorder({
    super.borderSide = const BorderSide(),
    this.innerBorderSide = const BorderSide(color: Colors.transparent),
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  });

  /// The radii of the border's rounded rectangle corners.
  ///
  /// The corner radii must be circular, i.e. their [Radius.x] and [Radius.y]
  /// values must be the same.
  final BorderRadius borderRadius;

  final BorderSide innerBorderSide;

  @override
  bool get isOutline => false;

  @override
  OutlinedInputBorder copyWith({
    BorderSide? borderSide,
    BorderSide? innerBorderSide,
    BorderRadius? borderRadius,
  }) {
    return OutlinedInputBorder(
      borderSide: borderSide ?? this.borderSide,
      innerBorderSide: innerBorderSide ?? this.innerBorderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(borderSide.width);
  }

  @override
  OutlinedInputBorder scale(double t) {
    return OutlinedInputBorder(
      borderSide: borderSide.scale(t),
      innerBorderSide: innerBorderSide.scale(t),
      borderRadius: borderRadius * t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is OutlinedInputBorder) {
      final OutlinedInputBorder outline = a;
      return OutlinedInputBorder(
        borderRadius: BorderRadius.lerp(outline.borderRadius, borderRadius, t)!,
        borderSide: BorderSide.lerp(outline.borderSide, borderSide, t),
        innerBorderSide:
            BorderSide.lerp(outline.innerBorderSide, innerBorderSide, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is OutlinedInputBorder) {
      final OutlinedInputBorder outline = b;
      return OutlinedInputBorder(
        borderRadius: BorderRadius.lerp(borderRadius, outline.borderRadius, t)!,
        borderSide: BorderSide.lerp(borderSide, outline.borderSide, t),
        innerBorderSide:
            BorderSide.lerp(innerBorderSide, outline.innerBorderSide, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(borderRadius
          .resolve(textDirection)
          .toRRect(rect)
          .deflate(borderSide.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paintInterior(Canvas canvas, Rect rect, Paint paint,
      {TextDirection? textDirection}) {
    canvas.drawRRect(borderRadius.resolve(textDirection).toRRect(rect), paint);
  }

  @override
  bool get preferPaintInterior => true;

  /// Draw a rounded rectangle around [rect] using [borderRadius].
  ///
  /// The [borderSide] defines the line's color and weight.
  /// The [innerBorderSide] defines the inner line's color and weight.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final Paint paint = borderSide.toPaint();
    final RRect outer = borderRadius.toRRect(rect);
    final RRect center = outer.deflate(borderSide.width / 2.0);
    canvas.drawRRect(center, paint);

    final innerPaint = innerBorderSide.toPaint();
    canvas.drawRRect(center.deflate(borderSide.width / 2.0), innerPaint);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is OutlinedInputBorder &&
        other.borderSide == borderSide &&
        other.innerBorderSide == innerBorderSide &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(borderSide, innerBorderSide, borderRadius);
}

abstract class MaterialStateOutlinedInputBorder extends OutlinedInputBorder
    implements MaterialStateProperty<InputBorder> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const MaterialStateOutlinedInputBorder();

  /// Creates a [MaterialStateOutlinedInputBorder] from a [MaterialPropertyResolver<InputBorder>]
  /// callback function.
  ///
  /// If used as a regular input border, the border resolved in the default state (the
  /// empty set of states) will be used.
  ///
  /// The given callback parameter must return a non-null text style in the default
  /// state.
  static MaterialStateOutlinedInputBorder resolveWith(
          MaterialPropertyResolver<InputBorder> callback) =>
      _MaterialStateOutlinedInputBorder(callback);

  /// Returns a [InputBorder] that's to be used when a Material component is in the
  /// specified state.
  @override
  InputBorder resolve(Set<MaterialState> states);
}

/// A [MaterialStateOutlinedInputBorder] created from a [MaterialPropertyResolver<OutlinedInputBorder>]
/// callback alone.
///
/// If used as a regular input border, the border resolved in the default state will
/// be used.
///
/// Used by [MaterialStateTextStyle.resolveWith].
class _MaterialStateOutlinedInputBorder
    extends MaterialStateOutlinedInputBorder {
  const _MaterialStateOutlinedInputBorder(this._resolve);

  final MaterialPropertyResolver<InputBorder> _resolve;

  @override
  InputBorder resolve(Set<MaterialState> states) => _resolve(states);
}
