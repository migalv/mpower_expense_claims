import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/login_bloc.dart';
import 'package:expense_claims_app/blocs/signup_bloc.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  // Focus nodes
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _repeatPasswordFocusNode = FocusNode();

  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SignUpBloc _signUpBloc;

  @override
  void didChangeDependencies() {
    _signUpBloc = Provider.of<SignUpBloc>(context);
    _signUpBloc.setShowDialogFunc(_showSignUpDoneDialog);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _signUpBloc.dispose();
    super.dispose();
  }

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
          child: ListView(
            children: <Widget>[
              Container(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  icon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: _signUpBloc.nameValidator,
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
                validator: _signUpBloc.emailValidator,
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
                  icon: Icon(Icons.lock_open),
                  border: const OutlineInputBorder(),
                ),
                validator: _signUpBloc.passwordValidator,
                obscureText: true,
                onFieldSubmitted: (_) => FocusScope.of(context)
                    .requestFocus(_repeatPasswordFocusNode),
              ),
              Container(height: 16.0),
              TextFormField(
                controller: _repeatPasswordController,
                focusNode: _repeatPasswordFocusNode,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Repeat password',
                  icon: Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_passwordController.text != null) {
                    if (_passwordController.text != value)
                      return "Password must be identical";
                  }
                  return _signUpBloc.passwordValidator(value);
                },
                obscureText: true,
                onFieldSubmitted: (_) => _signUp(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () => _signUp(),
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      );

  void _signUp() {
    if (_formKey.currentState.validate()) {
      _signUpBloc.signUp(
          email: _emailController.text, password: _passwordController.text);
    }
  }

  void _showSignUpDoneDialog() => showDialog(
        context: context,
        builder: (_) => StreamBuilder<String>(
            stream: _signUpBloc.authState,
            initialData: AuthState.LOADING,
            builder: (context, snapshot) {
              String title;
              Widget content;
              switch (snapshot.data) {
                case AuthState.LOADING:
                  title = "Registering user";
                  content = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Please wait . . .",
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      SizedBox(height: 16.0),
                      Center(
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  );
                  break;
                case AuthState.SUCCESS:
                  title = "User registered";
                  content = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "User registered successfully",
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      SizedBox(height: 16.0),
                      Center(
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 48.0,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  );
                  break;
                default:
                  title = "Unexpected error";
                  content = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "An unexpected error occurred, please try again later.",
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      SizedBox(height: 16.0),
                      Center(
                        child: Icon(
                          MdiIcons.alertCircleOutline,
                          size: 48.0,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  );
                  break;
              }
              return AlertDialog(
                title: Text(title),
                content: content,
                actions: <Widget>[
                  snapshot.data != AuthState.LOADING
                      ? FlatButton(
                          child: Text("DISMISS"),
                          onPressed: () {
                            if (snapshot.data == AuthState.SUCCESS) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } else
                              Navigator.pop(context);
                          },
                        )
                      : Container(),
                ],
              );
            }),
      );
}
