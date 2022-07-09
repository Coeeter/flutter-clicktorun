import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/auth/user_details_screen.dart';
import 'package:clicktorun_flutter/ui/screens/auth/forget_password_screen.dart';
import 'package:clicktorun_flutter/ui/screens/auth/register_screen.dart';
import 'package:clicktorun_flutter/ui/screens/main/home.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/model/clicktorun_user.dart';
import '../../widgets/appbar.dart';
import '../../widgets/gradient_button.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _email = "";
  String _password = "";
  bool isLoading = false;

  void saveForm(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() == true) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState?.save();
      Future<UserCredential> login = AuthRepository().login(
        _email,
        _password,
      );
      login.then((value) async {
        _formKey.currentState?.reset();
        UserModel? user = await UserRepository().getUser();
        setState(() {
          isLoading = false;
        });
        if (user == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const UserDetailsScreen(),
            ),
          );
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        SnackbarUtils(context: context).createSnackbar(
          e.message.toString(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: ClickToRunAppbar("Login to ClickToRun").getAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                width: double.infinity,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250,
                        child: Image.asset('images/ic_login_page.png'),
                        padding: const EdgeInsets.all(50),
                      ),
                      CustomTextFormField(
                        text: "Email",
                        prefixIcon: const Icon(Icons.email),
                        emailCheck: true,
                        onSaved: (String? value) {
                          _email = value!;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        text: "Password",
                        eye: true,
                        prefixIcon: const Icon(Icons.lock),
                        obscureText: true,
                        onSaved: (String? value) {
                          _password = value!;
                        },
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ForgetPasswordForm(),
                            ),
                          ),
                          child: Text(
                            'Forget Password?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            alignment: Alignment.topCenter,
                            splashFactory: NoSplash.splashFactory,
                          ),
                        ),
                      ),
                      GradientButton(
                        text: "Login",
                        onPressed: () => saveForm(context),
                      ),
                      TextButton(
                        child: Text(
                          "Don't have an account? Create one here!",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => RegisterForm(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).focusColor,
                ),
                child: const CircularProgressIndicator(
                  color: ClickToRunColors.secondary,
                ),
              )
          ],
        ),
      ),
    );
  }
}
