import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/pages/home_page.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _recoverPasswordEmailController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginBloc _loginBloc;

  @override
  void didChangeDependencies() {
    _loginBloc = Provider.of<LoginBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _buildSignInForm(),
        ),
      );

  Widget _buildSignInForm() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (!value.contains("@") ||
                      !value.contains(".") && !value.contains(" ")) {
                    return 'Please enter a valid email';
                  } else if (value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocusNode),
              ),
              Container(
                height: 16.0,
              ),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _signIn(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  icon: Icon(Icons.more_horiz),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password should have at least 6 characters';
                  }
                  return null;
                },
                obscureText: true,
              ),
              _buildButtons(),
            ],
          ),
        ),
      );

  Widget _buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FlatButton(
            child: Text(
              'Forgot password?',
              style: TextStyle(color: Colors.black38, fontSize: 10.0),
            ),
            onPressed: () => _showForgotPasswordDialog(),
          ),
          StreamBuilder<Object>(
              stream: _loginBloc.authState,
              initialData: AuthState.IDLE,
              builder: (context, snapshot) {
                return snapshot.data == AuthState.LOADING
                    ? CircularProgressIndicator()
                    : FlatButton(
                        onPressed: () => _signIn(),
                        child: Text('Log in'),
                      );
              }),
        ],
      );

  Future _signIn() async {
    if (_formKey.currentState.validate()) {
      String result = await _loginBloc.signIn(
          email: _emailController.text, password: _passwordController.text);

      switch (result) {
        case AuthState.SUCCESS:
          utils.pushReplacement(
            context,
            BlocProvider<HomeBloc>(
              child: HomePage(),
              initBloc: (_, bloc) => bloc ?? HomeBloc(),
              onDispose: (_, bloc) => bloc?.dispose(),
            ),
          );
          break;
        case AuthState.ERROR:
          utils.showSnackbar(
            scaffoldKey: _scaffoldKey,
            color: errorColor,
            message: "Incorrect email or password. Try again.",
            duration: 2,
          );
          break;
      }
    }
  }

  void _showForgotPasswordDialog() {
    _recoverPasswordEmailController.text = _emailController?.text ?? "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Recover password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Enter the email that you want to recover the password for."),
            TextFormField(
              controller: _recoverPasswordEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Enter email',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          FlatButton(
            onPressed: () => _recoverPassword(),
            child: Text('Recover'),
          ),
        ],
      ),
    );
  }

  Future _recoverPassword() async {
    await repository.recoverPassword(
        email: _recoverPasswordEmailController.text);
    utils.showSnackbar(
      scaffoldKey: _scaffoldKey,
      message: "Recovery email was sent if the email is registered.",
    );
  }
}
