import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';
import 'package:clicktorun_flutter/data/repositories/auth_repository.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/screens/main/home.dart';
import 'package:clicktorun_flutter/ui/utils/colors.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:clicktorun_flutter/ui/widgets/textformfield.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({Key? key}) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _username = "";
  double _heightInCentimetres = 0;
  double _weightInKilograms = 0;
  bool isLoading = false;

  void saveForm(BuildContext context) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      Future<bool> insertResults = UserRepository().insertUser(
        UserModel(
          username: _username,
          email: AuthRepository().currentUser!.email!,
          heightInCentimetres: _heightInCentimetres,
          weightInKilograms: _weightInKilograms,
        ),
      );
      insertResults.then((value) {
        setState(() {
          isLoading = false;
        });
        if (!value) {
          SnackbarUtils(context: context).createSnackbar(
            'Unkown Error has Occurred',
          );
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
        appBar: ClickToRunAppbar("Setting up your profile").getAppBar(),
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
                        padding: const EdgeInsets.all(50),
                        child: Image.asset('images/ic_details_page.png'),
                      ),
                      CustomTextFormField(
                        text: 'Username',
                        prefixIcon: const Icon(Icons.person),
                        onSaved: (String? value) {
                          _username = value!;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        text: 'Weight in kg',
                        prefixIcon: const Icon(Icons.monitor_weight),
                        doubleCheck: true,
                        onSaved: (String? value) {
                          _weightInKilograms = double.parse(value!);
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        text: 'Height in cm',
                        prefixIcon: const Icon(Icons.height),
                        doubleCheck: true,
                        onSaved: (String? value) {
                          _heightInCentimetres = double.parse(value!);
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      GradientButton(
                        text: 'Submit',
                        onPressed: () => saveForm(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                width: double.infinity,
                height: double.infinity,
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
