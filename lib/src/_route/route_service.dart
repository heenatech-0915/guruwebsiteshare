import 'package:cpcdiagnostics_ecommerce/src/screen/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class RouterService{


    Route<dynamic> onGenerateRoute(RouteSettings routeSettings){

      print('route details-->$routeSettings');
     return MaterialPageRoute(builder: (_){
       return  const SplashScreen();
     });
   }
}