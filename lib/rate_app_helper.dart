
void openAppRating() async {
  const url = 'https://play.google.com/store/apps/details?id=com.example.church_app'; // Replace with actual
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  }
}

launchUrl(Uri parse) {
}

canLaunchUrl(Uri parse) {
}
