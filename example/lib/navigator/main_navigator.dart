import 'package:flutter/material.dart';
import 'package:model_generator_example/screen/home_screen.dart';

class MainNavigatorWidget extends StatefulWidget {
  const MainNavigatorWidget({Key? key}) : super(key: key);

  @override
  MainNavigatorWidgetState createState() => MainNavigatorWidgetState();

  static MainNavigatorWidget of(context,
      {rootNavigator = false, nullOk = false}) {
    final MainNavigatorWidget? navigator = rootNavigator
        ? context.findRootAncestorStateOfType<MainNavigatorWidget>()
        : context.findAncestorStateOfType<MainNavigatorWidget>();
    assert(() {
      if (navigator == null && !nullOk) {
        throw FlutterError(
            'MainNavigatorWidget operation requested with a context that does not include a MainNavigatorWidget.\n'
            'The context used to push or pop routes from the MainNavigatorWidget must be that of a '
            'widget that is a descendant of a MainNavigatorWidget widget.');
      }
      return true;
    }());
    return navigator!;
  }
}

class MainNavigatorWidgetState extends State<MainNavigatorWidget> {
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigationKey,
      initialRoute: HomeScreen.routeName,
      onGenerateRoute: onGenerateRoute,
    );
  }

  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return MaterialPageRoute(
            builder: (context) => HomeScreen(), settings: settings);
      default:
        return null;
    }
  }

  void closeDialog() => Navigator.of(context, rootNavigator: true).pop();

  void goBack<T>({result}) => navigationKey.currentState?.pop(result);
}
