import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/*
This widget describes how the user tile should look like and deals with the case when the user doesn't have an image
*/

class MyUserTile extends StatelessWidget {
  const MyUserTile({
    super.key,
    required this.imageUrl,
    required this.onPressed,
    required this.userEmail,
    required this.userName,
    required this.isAdmin,
    required this.isSuperAdmin,
    this.topMargin = 8,
    this.bottomMargin = 8,
    this.rightMargin = 6,
    this.leftMargin = 6,
  });
  final String? imageUrl;
  final String userName;
  final String userEmail;
  final void Function() onPressed;
  final double topMargin;
  final double bottomMargin;
  final double rightMargin;
  final double leftMargin;
  final bool isAdmin;
  final bool isSuperAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: topMargin,
        bottom: bottomMargin,
        right: rightMargin,
        left: leftMargin,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onPressed,
          isThreeLine: false,
          leading: imageUrl == null
              ? const CircleAvatar(radius: 25, child: Icon(Icons.person))
              : CircleAvatar(
                  radius: 25,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorWidget: (context, url, error) {
                        return const Icon(Icons.person);
                      },
                      placeholder: (context, url) {
                        return const Icon(Icons.person);
                      },
                    ),
                  ),
                ),
          title: Row(
            children: [
              Text(
                '$userName : ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  isAdmin
                      ? 'admin'
                      : isSuperAdmin
                      ? 'super admin'
                      : 'user',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Text(
            userEmail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
