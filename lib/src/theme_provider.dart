/* nullable */
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';
export 'theme.dart';

/// An enum that indicates to the NeumorphicTheme which theme to use
/// LIGHT : the light theme (default theme)
/// DARK : the dark theme
/// SYSTEM : will depend on the user's system theme
///
/// @see Brightness
/// @see window.platformBrightness
///
enum CurrentTheme { LIGHT, DARK, SYSTEM }

/// A immutable contained by the NeumorhicTheme
/// That will save the current definition of the theme
/// It will be accessible to the childs widgets by an InheritedWidget
class ThemeHost {

  final NeumorphicThemeData theme;
  final NeumorphicThemeData darkTheme;
  final CurrentTheme currentTheme;

  const ThemeHost({
    @required this.theme,
    this.darkTheme,
    this.currentTheme = CurrentTheme.SYSTEM,
  });

  bool get useDark =>
      darkTheme != null &&
      (
          //forced to use DARK by user
          currentTheme == CurrentTheme.DARK ||
              //The setting indicating the current brightness mode of the host platform. If the platform has no preference, platformBrightness defaults to Brightness.light.
              window.platformBrightness == Brightness.dark);

  NeumorphicThemeData getCurrentTheme() {
    if (useDark) {
      return darkTheme;
    } else {
      return theme;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeHost &&
          runtimeType == other.runtimeType &&
          theme == other.theme &&
          darkTheme == other.darkTheme &&
          currentTheme == other.currentTheme;

  @override
  int get hashCode =>
      theme.hashCode ^ darkTheme.hashCode ^ currentTheme.hashCode;

  ThemeHost copyWith({
    NeumorphicThemeData theme,
    NeumorphicThemeData darkTheme,
    CurrentTheme currentTheme,
  }) {
    return new ThemeHost(
      theme: theme ?? this.theme,
      darkTheme: darkTheme ?? this.darkTheme,
      currentTheme: currentTheme ?? this.currentTheme,
    );
  }
}

/// The NeumorphicTheme (provider)
/// 1. Defines the used neumorphic theme used in child widgets
///
///   @see NeumorphicThemeData
///
///   NeumorphicTheme(
///     theme: NeumorphicThemeData(...),
///     darkTheme: NeumorphicThemeData(...),
///     currentTheme: CurrentTheme.LIGHT,
///     child: ...
///
/// 2. Provide by static methods the current theme
///
///   NeumorphicThemeData theme = NeumorphicTheme.getCurrentTheme(context);
///
/// 3. Provide by static methods the current theme's colors
///
///   Color baseColor = NeumorphicTheme.baseColor(context);
///   Color accent = NeumorphicTheme.accentColor(context);
///   Color variant = NeumorphicTheme.variantColor(context);
///
/// 4. Tells if the current theme is dark
///
///   bool dark = NeumorphicTheme.isUsingDark(context);
///
/// 5. Provides a way to update the current theme
///
///   NeumorphicTheme.of(context).updateCurrentTheme(
///     NeumorphicThemeData(
///       /* new values */
///     )
///   )
///
class NeumorphicTheme extends StatefulWidget {
  final NeumorphicThemeData theme;
  final NeumorphicThemeData darkTheme;
  final Widget child;
  final CurrentTheme currentTheme;

  NeumorphicTheme({
    Key key,
    @required this.child,
    this.theme = neumorphicDefaultTheme,
    this.darkTheme = neumorphicDefaultDarkTheme,
    this.currentTheme,
  });

  @override
  _NeumorphicThemeState createState() => _NeumorphicThemeState();

  static NeumorphicThemeInherited of(BuildContext context) {
    try {
      return context
          .dependOnInheritedWidgetOfExactType<NeumorphicThemeInherited>();
    } catch (t) {
      return null;
    }
  }

  static bool isUsingDark(BuildContext context) {
    return of(context).isUsingDark;
  }

  static Color accentColor(BuildContext context) {
    return getCurrentTheme(context).accentColor;
  }

  static Color baseColor(BuildContext context) {
    return getCurrentTheme(context).baseColor;
  }

  static Color variantColor(BuildContext context) {
    return getCurrentTheme(context).variantColor;
  }

  static NeumorphicThemeData getCurrentTheme(BuildContext context) {
    try {
      final provider = NeumorphicTheme.of(context);
      return provider.current;
    } catch (t) {
      return null;
    }
  }
}

class _NeumorphicThemeState extends State<NeumorphicTheme> {
  ThemeHost _themeHost;

  @override
  void initState() {
    super.initState();
    _themeHost = ThemeHost(
      theme: widget.theme,
      currentTheme: widget.currentTheme,
      darkTheme: widget.darkTheme,
    );
  }

  @override
  void didUpdateWidget(NeumorphicTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _themeHost = ThemeHost(
        theme: widget.theme,
        currentTheme: widget.currentTheme,
        darkTheme: widget.darkTheme,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicThemeInherited(
      value: _themeHost,
      onChanged: (value) {
        setState(() {
          _themeHost = value;
        });
      },
      child: widget.child,
    );
  }
}

class NeumorphicThemeInherited extends InheritedWidget {
  final Widget child;
  final ThemeHost value;
  final ValueChanged<ThemeHost> onChanged;

  NeumorphicThemeInherited(
      {Key key,
      @required this.child,
      @required this.value,
      @required this.onChanged});

  @override
  bool updateShouldNotify(NeumorphicThemeInherited old) => value != old.value;

  NeumorphicThemeData get current {
    return this.value.getCurrentTheme();
  }

  bool get isUsingDark {
    return value.useDark;
  }

  CurrentTheme get currentTheme => value.currentTheme;

  set currentTheme(CurrentTheme currentTheme) {
    this.onChanged(value.copyWith(currentTheme: currentTheme));
  }

  void updateCurrentTheme(NeumorphicThemeData update) {
    if (value.useDark) {
      final newValue = value.copyWith(darkTheme: update);
      //this.value = newValue;
      this.onChanged(newValue);
    } else {
      final newValue = value.copyWith(theme: update);
      //this.value = newValue;
      this.onChanged(newValue);
    }
  }
}
