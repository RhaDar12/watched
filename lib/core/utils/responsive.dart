import 'package:flutter/material.dart';
import '../../app/theme/app_dimensions.dart';

class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppDimensions.screenMd;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppDimensions.screenMd &&
      MediaQuery.of(context).size.width < AppDimensions.screenLg;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppDimensions.screenLg;

  static double width(BuildContext context, {double fraction = 1}) =>
      MediaQuery.of(context).size.width * fraction;

  static double height(BuildContext context, {double fraction = 1}) =>
      MediaQuery.of(context).size.height * fraction;

  static EdgeInsets padding(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// Returns horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AppDimensions.screenLg) return 64;
    if (width >= AppDimensions.screenMd) return 32;
    return AppDimensions.paddingMd;
  }
}
