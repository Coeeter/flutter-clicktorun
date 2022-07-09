import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:clicktorun_flutter/ui/widgets/textformfield.dart';
import 'package:flutter/material.dart';

class ForgetPasswordForm extends StatefulWidget {
  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _email = "";
  bool isLoading = false;

  void sendResetLink(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState!.save();
      Future<void> sendLink = AuthRepository().sendResetLink(_email);
      sendLink.then((value) {
        setState(() {
          isLoading = false;
        });
        SnackbarUtils(context: context).createSnackbar(
          'Sent password reset link to email. Go check your email for further instructions',
        );
        Navigator.pop(context);
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
        appBar: ClickToRunAppbar("Forgot password?").getAppBar(),
        body: Stack(
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
                            Image.asset('images/ic_forget_password_page.png'),
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
                        height: 30,
                      ),
                      GradientButton(
                        text: "Submit",
                        onPressed: () => sendResetLink(context),
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
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
