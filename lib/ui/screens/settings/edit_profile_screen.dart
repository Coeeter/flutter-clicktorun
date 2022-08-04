import 'dart:io';

import 'package:clicktorun_flutter/data/model/user_model.dart';
import 'package:clicktorun_flutter/data/repositories/user_repository.dart';
import 'package:clicktorun_flutter/ui/utils/Screen.dart';
import 'package:clicktorun_flutter/ui/utils/snackbar.dart';
import 'package:clicktorun_flutter/ui/widgets/appbar.dart';
import 'package:clicktorun_flutter/ui/widgets/gradient_button.dart';
import 'package:clicktorun_flutter/ui/widgets/loading_container.dart';
import 'package:clicktorun_flutter/ui/widgets/profile_image.dart';
import 'package:clicktorun_flutter/ui/widgets/textformfield.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditUserDetailsScreen extends StatefulWidget {
  const EditUserDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EditUserDetailsScreen> createState() => _EditUserDetailsScreenState();
}

class _EditUserDetailsScreenState extends State<EditUserDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  UserModel? _userModel;
  String? _username = "";
  double? _heightInCentimetres = 0.0;
  double? _weightInKilograms = 0.0;
  bool _isLoading = false;
  bool _isUploading = false;

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
        bool updateResults = await UserRepository.instance().updateUser(
          map: map,
        );
        setState(() {
          _isLoading = false;
        });
        SnackbarUtils(context: context).createSnackbar(
          updateResults
              ? 'Account updated successfully!'
              : 'Unknown error has occurred',
        );
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
    double width = MediaQuery.of(context).size.width / 2;
    ColorScheme colorScheme = Theme.of(context).colorScheme.copyWith(
          surface: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF303030)
              : Colors.white,
        );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppbar(title: "Edit account"),
        body: StreamBuilder<UserModel?>(
            stream: UserRepository.instance().getUserStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || _isUploading) {
                return Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: const LoadingContainer(
                    overlayVisibility: false,
                  ),
                );
              }
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
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: _modalBottomSheedBuilder,
                                  );
                                },
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
                    if (_isLoading) const LoadingContainer(),
                  ],
                ),
              );
            }),
      ),
    );
  }

  void _deletePhotoImage() async {
    setState(() {
      _isLoading = true;
      _isUploading = true;
    });
    bool result = await UserRepository.instance().deleteUserImage();
    setState(() {
      _isLoading = false;
      _isUploading = false;
    });
    SnackbarUtils(context: context).createSnackbar(
      result
          ? 'Profile picture has been deleted successfully!'
          : 'Unkown error has occurred',
    );
  }

  void _pickImage(GlobalKey globalKey, ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage == null) return;
    setState(() {
      _isLoading = true;
      _isUploading = true;
    });
    bool results = await UserRepository.instance().updateUser(
      map: {},
      profileImage: File(pickedImage.path),
    );
    setState(() {
      _isLoading = false;
      _isUploading = false;
    });
    SnackbarUtils(context: globalKey.currentContext!).createSnackbar(
      results
          ? "Updated profile picture successfully"
          : "Unknown error has occurred",
    );
  }

  Widget _modalBottomSheedBuilder(BuildContext context) {
    double height = Screen.height * 0.3 + 10;
    double btnHeight = (height - 30) / 4;
    double radius = 15;
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(radius),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: btnHeight,
                  child: _modalItem(
                    text: "Choose from library",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(_scaffoldKey, ImageSource.gallery);
                    },
                  ),
                ),
                SizedBox(
                  height: btnHeight,
                  child: _modalItem(
                    text: "Take Photo",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(_scaffoldKey, ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(
                  height: btnHeight,
                  child: _modalItem(
                    text: "Remove Current Photo",
                    onTap: () {
                      Navigator.pop(context);
                      _deletePhotoImage();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: btnHeight,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(radius),
              ),
            ),
            child: _modalItem(
              text: "Cancel",
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modalItem({
    required String text,
    required void Function() onTap,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Ink(
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
