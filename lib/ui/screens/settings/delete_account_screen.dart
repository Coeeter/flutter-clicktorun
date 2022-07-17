import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/auth/login_screen.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:clicktorun_flutter/ui/widgets/textformfield.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatefulWidget {
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClickToRunAppbar('Delete Account?').getAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          height: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Are you sure you want to delete your account?',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'You will lose all your data related to this account!',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 50),
                        CustomTextFormField(
                          text: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          onSaved: (value) => _password = value!,
                          obscureText: true,
                          eye: true,
                        ),
                        const SizedBox(height: 30),
                        GradientButton(
                          text: 'Delete Account',
                          onPressed: () => deleteAccount(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading) LoadingContainer(),
            ],
          ),
        ),
      ),
    );
  }

  deleteAccount(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        await AuthRepository.instance().login(
          AuthRepository.instance().currentUser!.email!,
          _password,
        );
        bool deleteImageResults =
            await UserRepository.instance().deleteUserImage();
        bool deleteUserResults = await UserRepository.instance().deleteUser();
        setState(() {
          _isLoading = false;
        });
        if (!deleteUserResults || !deleteImageResults) {
          return SnackbarUtils(context: context).createSnackbar(
            'Unknown error has occurred',
          );
        }
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginForm(),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        SnackbarUtils(context: context).createSnackbar(
          'Wrong password has been given. Unable to delete account',
        );
      }
    }
  }
}
