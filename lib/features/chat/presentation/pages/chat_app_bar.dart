import 'package:flutter/material.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/auth/domain/entities/user_data.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_profile_group.dart';

class ChatAppBar<T extends UserData> extends StatelessWidget
    implements PreferredSizeWidget {
  const ChatAppBar({super.key, required this.user});
  final T user;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: switch (user) {
        RiderData() => RiderProfileGroup(user: user as RiderData),
        _ => const SizedBox(),
      },
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
