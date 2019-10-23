import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/blocs/splash_bloc.dart';
import 'package:expense_claims_app/pages/home_page.dart';
import 'package:expense_claims_app/pages/login_page.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final splashBloc = Provider.of<SplashBloc>(context);

    return Scaffold(
        body: StreamBuilder<bool>(
            stream: splashBloc.isLoggedIn,
            builder: (context, snapshot) {
              if (snapshot != null && snapshot.hasData) {
                if (snapshot.data) {
                  utils.pushReplacement(
                      context,
                      BlocProvider<HomeBloc>(
                        initBloc: (_, bloc) => bloc ?? HomeBloc(),
                        onDispose: (_, bloc) => bloc.dispose(),
                        child: HomePage(),
                      ),
                      delay: 3);
                } else if (!snapshot.data) {
                  utils.pushReplacement(
                      context,
                      BlocProvider<LoginBloc>(
                        initBloc: (_, bloc) => bloc ?? LoginBloc(),
                        onDispose: (_, bloc) => bloc.dispose(),
                        child: LoginPage(),
                      ),
                      delay: 3);
                }
              }
              return Center(
                child: Container(
                    height: 56.0,
                    child: Center(
                        // TODO: CHANGE LOGO PICTURE
                        child: SvgPicture.asset('assets/icons/logo.svg'))),
              );
            }));
  }
}
