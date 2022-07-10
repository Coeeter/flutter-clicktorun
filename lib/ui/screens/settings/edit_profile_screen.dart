import 'package:clicktorun_flutter/data/model/clicktorun_user.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:clicktorun_flutter/ui/widgets/profile_image.dart';
import 'package:clicktorun_flutter/ui/widgets/textformfield.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class EditUserDetailsScreen extends StatefulWidget {
  @override
  State<EditUserDetailsScreen> createState() => _EditUserDetailsScreenState();
}

class _EditUserDetailsScreenState extends State<EditUserDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  UserModel? _userModel;
  String? _username = "";
  double? _heightInCentimetres = 0.0;
  double? _weightInKilograms = 0.0;
  bool _isLoading = false;

  void saveForm(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final Map<String, dynamic> map = {};
      if (_username != _userModel!.username) {
        map["username"] = _username;
      }
      if (_weightInKilograms != _userModel!.weightInKilograms) {
        map["weightInKilograms"] = _weightInKilograms;
      }
      if (_heightInCentimetres != _userModel!.heightInCentimetres) {
        map["heightInCentimetres"] = _heightInCentimetres;
      }
      if (map.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return SnackbarUtils(context: context)
            .createSnackbar('No data has been changed!');
      }
      try {
        bool updateResults = await UserRepository().updateUser(map);
        setState(() {
          _isLoading = false;
        });
        SnackbarUtils(context: context).createSnackbar(
          updateResults
              ? 'Account updated successfully!'
              : 'Unknown error has occurred',
        );
        if (!updateResults) return;
        _formKey.currentState!.reset();
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        SnackbarUtils(context: context).createSnackbar(
          (e as FirebaseException).message.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.6;
    ColorScheme colorScheme = Theme.of(context).colorScheme.copyWith(
          surface: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF303030)
              : Colors.white,
        );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: ClickToRunAppbar("Edit account").getAppBar(),
        body: StreamBuilder<UserModel?>(
            stream: UserRepository().getUserStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LoadingContainer();
              if (snapshot.hasData) {
                _userModel = snapshot.data;
                _username = _userModel?.username;
                _weightInKilograms = _userModel?.weightInKilograms;
                _heightInCentimetres = _userModel?.heightInCentimetres;
              }
              return Container(
                height: double.infinity,
                decoration:
                    BoxDecoration(color: Theme.of(context).colorScheme.surface),
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
                              ProfileImage(
                                width: width,
                                colorScheme: colorScheme,
                                snapshot: snapshot,
                              ),
                              const SizedBox(height: 30),
                              CustomTextFormField(
                                text: 'Username',
                                prefixIcon: const Icon(Icons.person),
                                initialValue: _userModel?.username,
                                onSaved: (String? value) {
                                  _username = value!;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              CustomTextFormField(
                                text: 'Weight in kg',
                                doubleCheck: true,
                                initialValue: _userModel?.weightInKilograms
                                    .toStringAsFixed(1),
                                prefixIcon: const Icon(Icons.monitor_weight),
                                onSaved: (String? value) {
                                  _weightInKilograms = double.parse(value!);
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              CustomTextFormField(
                                text: 'Height in cm',
                                doubleCheck: true,
                                initialValue: _userModel?.heightInCentimetres
                                    .toStringAsFixed(1),
                                prefixIcon: const Icon(Icons.height),
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
                    if (_isLoading) LoadingContainer(),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
