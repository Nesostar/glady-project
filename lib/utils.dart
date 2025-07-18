import 'package:url_launcher/url_launcher.dart';

void openAppRating() async {
  const url =
      'https://play.google.com/store/apps/details?id=com.example.church_app'; // Replace with your real app ID

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
