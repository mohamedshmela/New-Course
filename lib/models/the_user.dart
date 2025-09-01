/*
TheUser class defines which properties each user should have:
- user name
- email
- photo url: we take this url from the user's google account. It could be null if he dosen't have an image in his google account
- isAdmin & isSuperAdmin: boolean properties to determine his role and what can he does when using the app
  if both are false, so he is a normal user. He can show courses.
  if isAdmin is true, so he is an admin and he can add and delete courses as well.
  if isSuperAdmin is true, so he is super admin and he can add and delete courses and changes users' roles as well.
  isAdmin & isSuperAdmin can't be true for the same user.
*/

class TheUser {
  const TheUser({
    required this.userName,
    required this.userEmail,
    required this.userPhotoUrl,
    required this.isAdmin,
    required this.isSuperAdmin,
  });

  final String userName;
  final String userEmail;
  final String? userPhotoUrl;
  final bool isAdmin;
  final bool isSuperAdmin;
}
