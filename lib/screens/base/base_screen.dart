import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lojaronilson/common/custom_drawer.dart';
import 'package:lojaronilson/screens/admin_orders/admin_orders_screen.dart';
import 'package:lojaronilson/screens/admin_users/admin_users_screen.dart';
import 'package:lojaronilson/screens/home/home_screen.dart';
import 'package:lojaronilson/screens/orders/orders_screen.dart';
import 'package:lojaronilson/screens/privacidade/privat.dart';
import 'package:lojaronilson/screens/products/products_screen.dart';
import 'package:lojaronilson/screens/stores/stores_screen.dart';
import 'package:provider/provider.dart';
import 'package:lojaronilson/models/page_manager.dart';
import 'package:lojaronilson/models/user_manager.dart';

class BaseScreen extends StatefulWidget {

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {

  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => PageManager(pageController),
      child: Consumer<UserManager>(
        builder: (_, userManager, __){
          return PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              HomeScreen(),
              ProductsScreen(),
              OrdersScreen(),
              StoresScreen(),
Privat(),
              //privaciade
              if(userManager.adminEnabled)
                ...[
                  AdminUsersScreen(),
                  AdminOrdersScreen(),
                ]

            ],
          );
        },
      ),
    );
  }
}