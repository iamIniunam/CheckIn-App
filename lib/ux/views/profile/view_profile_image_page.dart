import 'package:attendance_app/ux/shared/components/app_material.dart';
import 'package:attendance_app/ux/shared/resources/app_colors.dart';
import 'package:attendance_app/ux/shared/resources/app_images.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ux/shared/components/app_page.dart';
import 'package:attendance_app/ux/shared/resources/app_strings.dart';

class ViewProfileImagePage extends StatefulWidget {
  const ViewProfileImagePage({super.key});

  @override
  ViewProfileImagePageState createState() => ViewProfileImagePageState();
}

class ViewProfileImagePageState extends State<ViewProfileImagePage> {
  @override
  void initState() {
    super.initState();
  }

  // Future selectNewProfilePhoto() async {
  //   ImageSource? imageSource = await showAppBottomSheet(
  //     context: context,
  //     title: AppStrings.changePicture,
  //     child: const ChoosePhotoBottomSheet(),
  //   );
  //   if (imageSource != null) {
  //     File? newProfileImage =
  //         await ImageUtils.selectAndCropImageFromSource(source: imageSource);
  //     //Complete the image changing logic
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      useSafeArea: false,
      title: AppStrings.profilePicture,
      titleTextColor: AppColors.white,
      leadingIconColor: AppColors.white,
      appBarColor: AppColors.defaultColor,
      body: ColoredBox(
        color: AppColors.defaultColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Image(image: AppImages.defaultProfileImageTeal),
                    // child: Visibility(
                    //   visible: false,
                    //   replacement: AppImageWidget.local(
                    //     image: AppImages.defaultProfileImageTeal,
                    //     height: double.infinity,
                    //     width: double.infinity,
                    //     showPlaceHolder: false,
                    //   ),
                    //   child: AppImageWidget(
                    //     showPlaceHolder: false,
                    //     imageUrl: 'imageUrl',
                    //     height: double.infinity,
                    //     width: double.infinity,
                    //     boxFit: BoxFit.cover,
                    //     borderRadius: 0,
                    //     placeHolder: null,
                    //   ),
                    // ),
                  ),
                ),
                const SizedBox(height: 32),
                AppMaterial(
                  inkwellBorderRadius: BorderRadius.circular(10),
                  onTap: () {
                    // selectNewProfilePhoto();
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.white),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: AppColors.white, size: 20),
                        SizedBox(width: 5),
                        Text(
                          AppStrings.changePicture,
                          style: TextStyle(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
