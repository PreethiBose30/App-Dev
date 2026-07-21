import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../dashboard/home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {


  late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();


    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );


    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );


    _controller.forward();


    Timer(
      const Duration(seconds: 3),
          (){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      },
    );
  }


  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context){

    return Scaffold(

      backgroundColor: AppColors.background,


      body: Center(

        child: FadeTransition(

          opacity: _animation,


          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,


            children: [


              Container(

                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(

                  color: AppColors.primary.withOpacity(0.15),

                  shape: BoxShape.circle,

                ),


                child: const Icon(

                  Icons.inventory_2_outlined,

                  size: 70,

                  color: AppColors.primary,

                ),

              ),


              const SizedBox(height: 25),


              const Text(

                "Digital Inventory",

                style: TextStyle(

                  color: AppColors.textPrimary,

                  fontSize: 28,

                  fontWeight: FontWeight.bold,

                ),

              ),


              const SizedBox(height: 10),


              const Text(

                "Organize. Track. Access.",

                style: TextStyle(

                  color: AppColors.textSecondary,

                  fontSize: 14,

                ),

              )

            ],

          ),

        ),

      ),

    );

  }

}