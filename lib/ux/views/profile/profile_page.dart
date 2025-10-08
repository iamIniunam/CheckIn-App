import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';
import 'package:attendance_app/ux/shared/view_models/course_view_model.dart';
import 'package:attendance_app/ux/shared/view_models/user_view_model.dart';
import 'package:attendance_app/ux/views/profile/components/profile_detail_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? newPhoneNumber;

  late UserViewModel userViewModel;
  late CourseViewModel courseViewModel;

  @override
  void initState() {
    super.initState();
    userViewModel = context.read<UserViewModel>();
    courseViewModel = context.read<CourseViewModel>();
  }

  String getUserStream() {
    String savedStream = userViewModel.savedPrimaryStream;
    if (savedStream.isNotEmpty) {
      return savedStream;
    }

    String calculatedStream =
        userViewModel.getUserPrimaryStream(courseViewModel.chosenStreams);
    return calculatedStream;
  }

  @override
  Widget build(BuildContext context) {
    final semester = userViewModel.semester;

    String semesterText;
    if (semester == '1') {
      semesterText = '1st';
    } else if (semester == '2') {
      semesterText = '2nd';
    } else {
      semesterText = 'Unknown';
    }

    return AppPageScaffold(
      title: AppStrings.studentProfile,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppMaterial(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        // Navigation.navigateToScreen(
                        //     context: context,
                        //     screen: const ViewProfileImagePage());
                      },
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: AppColors.defaultColor,
                        foregroundColor: AppColors.transparent,
                        backgroundImage: AppImages.defaultProfileImageTeal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.sampleFullName,
                      style: TextStyle(
                          color: AppColors.defaultColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userViewModel.program,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 36, top: 24, right: 36, bottom: 36),
                      decoration: BoxDecoration(
                          color: AppColors.transparent,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.defaultColor)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ProfileDetailItem(
                          //     title: AppStrings.studentIdNumber,
                          //     value: userViewModel.idNumber),
                          // ProfileDetailItem(
                          //     title: AppStrings.studentLevel,
                          //     value: 'Level ${userViewModel.level}'),
                          ProfileDetailItem(
                              title: AppStrings.currentSemester,
                              value: '$semesterText Semester'),
                          ProfileDetailItem(
                              title: AppStrings.stream, value: getUserStream()),
                          const ProfileDetailItem(
                              title: AppStrings.schoolEmail,
                              value: AppStrings.sampleSchoolEmail),
                          const ProfileDetailItem(
                              title: AppStrings.nationality,
                              value: AppStrings.sampleNationality),
                          ProfileDetailItem(
                            title: AppStrings.studentPhoneNumber,
                            value:
                                newPhoneNumber ?? AppStrings.samplePhoneNumber,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
