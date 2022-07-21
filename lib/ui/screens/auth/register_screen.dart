import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:clicktorun_flutter/ui/widgets/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  bool isLoading = false;

  void saveForm(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState!.save();
      try {
        await AuthRepository.instance().register(
          _email,
          _password,
        );
        setState(() {
          isLoading = false;
        });
        AuthRepository.instance().logout();
        SnackbarUtils(context: context).createSnackbar(
          'Account created successfully!',
        );
        _formKey.currentState!.reset();
        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        SnackbarUtils(context: context).createSnackbar(
          (e as FirebaseException).message.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppbar(title: "Register to ClickToRun"),
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 250,
                          child:
                              Image.asset('assets/images/ic_sign_up_page.png'),
                          padding: const EdgeInsets.all(50),
                        ),
                        CustomTextFormField(
                          text: "Email",
                          prefixIcon: const Icon(Icons.email),
                          onSaved: (String? value) {
                            _email = value!;
                          },
                          emailCheck: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFormField(
                          text: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          obscureText: true,
                          eye: true,
                          passwordLengthCheck: true,
                          onChanged: (String? value) {
                            _password = value!;
                          },
                          customValidators: (String? value) {
                            if (value != _confirmPassword) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFormField(
                          text: "Confirm Password",
                          prefixIcon: const Icon(Icons.check),
                          obscureText: true,
                          eye: true,
                          onChanged: (String? value) {
                            _confirmPassword = value!;
                          },
                          customValidators: (String? value) {
                            if (value != _password) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        GradientButton(
                          text: "Register",
                          onPressed: () => saveForm(context),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading) const LoadingContainer()
            ],
          ),
        ),
      ),
    );
  }
}
