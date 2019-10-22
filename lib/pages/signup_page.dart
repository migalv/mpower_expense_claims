import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();

  // Focus nodes
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _repeatPasswordFocusNode = FocusNode();

  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Scaffold(
    key: _scaffoldKey,
    body: _buildSignUpForm(),
    appBar: AppBar(
      title: Text("Sign up"),
    ),
  );
  
  Widget _buildSignUpForm() => Padding(
    padding: EdgeInsets.all(16.0),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 16.0),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              icon: Icon(Icons.alternate_email), // TODO: NAME ICON
              border: OutlineInputBorder(),
            ),
            validator: (value) {}, // TODO: NAME VALIDATOR
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_emailFocusNode),
          ),
          Container(height: 16.0),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
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
          Container(height: 16.0),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.next,
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
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_repeatPasswordFocusNode),
          ),
          Container(height: 16.0),
          TextFormField(
            controller: _repeatPasswordController,
            focusNode: _repeatPasswordFocusNode,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Repeat password',
              icon: Icon(Icons.more_horiz), // TODO: REPEAT PASSWORD ICON
              border: const OutlineInputBorder(),
            ),
            validator: (value) { // TODO: CHECK IF PASSWORD IS THE SAME
              if (value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password should have at least 6 characters';
              }
              return null;
            },
            obscureText: true,
            onFieldSubmitted: (_) {} // TODO: SIGNUP
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FlatButton(
              onPressed: () {}, // TODO: SIGN IN BUTTON
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    ),
  );
}
