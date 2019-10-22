import 'package:expense_claims_app/pages/home_page.dart';
import 'package:expense_claims_app/pages/signup_page.dart';
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
  final FocusNode _passwordFocusNode = FocusNode();

  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                onFieldSubmitted: (_) {}, // TODO: SIGN IN FIELD
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
            onPressed: () {}, // TODO: FORGOT PASSWORD
          ),
          FlatButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute( // TODO: REGISTER BUTTON
                builder: (_) => SignUpPage(),
              ),
            ),
            child: Text('Register'),
          ),
          FlatButton(
            onPressed: () => utils.pushReplacement(context, HomePage()), // TODO: SIGN IN BUTTON
            child: Text('Submit'),
          ),
        ],
      );
}
